//
//  iCloudViewController.m
//  Looplist
//
//  Created by Yoshio Nose on 2012/10/04.
//
//

#import "iCloudViewController.h"

#import "SVProgressHUD.h"

#import "NSFileManager+Extension.h"
#import "NSDate+Extension.h"
#import "NSUbiquitousKeyValueStore+Extension.h"
#import "NSFileCoordinator+Extension.h"

#import "LLCheckListManager.h"
#import "LLCheckList.h"

#import "YNAlertView.h"


@interface iCloudViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *backupButtonCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *restoreButtonCell;
@end

@implementation iCloudViewController

const int kMaxObservation = 10;             // アップロード、ダウンロードの最大監視回数
const float kObservationInterval = 3.0f;    // アップロード、ダウンロードの監視間隔(秒)
__strong static NSString *kBackupKey = @"Backup";
__strong static NSString *kLastBackupKey = @"LastBackup";
__strong static NSString *kDevideNameKey = @"DeviceName";

static NSMutableArray *_oldTemplateURLs;
__strong static NSMetadataQuery *_query;
__strong static NSDate *_lastBackup;
__strong static NSString *_deviceName;
static bool _isUploadedCheckList;
static bool _isUploadedCheckItem;
static bool _isDownloadedCheckList;
static bool _isDownloadedCheckItem;
__strong static NSTimer *_timer;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    _lastBackup = nil;

    [NSFileManager iCloudAvailable:^{
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SETTING_ICLOUD_AVAILABLE];
            
            // KeyValueStoreの同期を監視
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyValueStoreDidChangeExternally:)
                                                         name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                       object:[NSUbiquitousKeyValueStore defaultStore]];
            
            [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        });
        
    }];
    
    
    // 検索範囲を設定
    _query = nil;
    _query = [[NSMetadataQuery alloc] init];
    NSArray *scopes = [NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope];
    [_query setSearchScopes:scopes];
    
    // 検索条件を設定
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like '*.dat'", NSMetadataItemFSNameKey];
    [_query setPredicate:predicate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGatheringForManagedDocument:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:_query];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidUpdateForManagedDocument:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:_query];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (MACRO_ICLOUD_AVAILABLE == YES) {
        [self lastBackup];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:_query];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:_query];

    [_query stopQuery];
    [_query disableUpdates];
}

#pragma mark - Table view data source
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            // 前回のバックアップ情報
            // バックアップ日時
            NSMutableString *backupInfo = [NSMutableString stringWithString:(_lastBackup)? [_lastBackup stringFullDateTimeBy24Time:YES] : LSTR(@"None")];
            // デバイス名
            [backupInfo appendString:(_deviceName)? [NSString stringWithFormat:@"\n%@", _deviceName] : @""];
            
            return [NSString stringWithFormat:LSTR(@"iCloud-Backup-Footer"), backupInfo];
            break;
        }
        default:
            // 説明文
            return LSTR(@"iCloud-Restore-Footer");
            break;
    }
}

#pragma mark - Table view delegate
#pragma mark セル選択
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // バックアップ＆復元の確認アラートを表示
    YNAlertView *alert = [YNAlertView new];

    // キャンセルボタン
    [alert addButtonWithTitle:LSTR(@"actionCancel")];
    alert.cancelButtonIndex = 0;

    switch (indexPath.section) {
        case 0:
        {
            // バックアップボタン
            alert.title = LSTR(@"alertBackup");
            alert.message = LSTR(@"msgBackup");
            [alert addButtonWithTitle:LSTR(@"captionBackup") withBlock:^(UIAlertView *alertView) {
                if (MACRO_ICLOUD_AVAILABLE == YES) {
                    // プログレス表示
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                
                    // 設定のバックアップ
                    [iCloudViewController backupAppSettings];

                    _isUploadedCheckList = NO;
                    _isUploadedCheckItem = NO;

                    [iCloudViewController backupCheckListFile];
                    [iCloudViewController backupCheckItemFile];

                    // アップロード完了を監視する
                    _timer = [NSTimer scheduledTimerWithTimeInterval:kObservationInterval
                                                              target:self
                                                            selector:@selector(uploadObserver)
                                                            userInfo:nil
                                                             repeats:YES];
                
                }
            }];
            
            break;
        }
        default:
        {
            // バックアップ情報が取得できない場合は復元不可
            if (_lastBackup == nil) {
                return;
            }

            // 復元ボタン
            alert.title = LSTR(@"alertRestore");
            alert.message = LSTR(@"msgRestore");
            [alert addButtonWithTitle:LSTR(@"captionRestore") withBlock:^(UIAlertView *alertView) {
                if (MACRO_ICLOUD_AVAILABLE == YES) {
                    // プログレス表示
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

                    // 設定の復元
                    [iCloudViewController restoreAppSettings];

                    _isDownloadedCheckList = NO;
                    _isDownloadedCheckItem = NO;

                    // 現在デバイス内に存在しているテンプレートファイル名を取得しておく（復元後に不要になったファイルを削除するため）
                    _oldTemplateURLs = [NSMutableArray array];
                    NSArray *array = [NSFileManager contentsOfDirectoryAtURL:[[LLCheckListManager sharedManager] URLForCheckListDirectory]];
                    for (NSURL *url in array) {
                        NSString *fileName = [url lastPathComponent];
                        DEBUGLOG(@"Old Files:%@", fileName);
                        if ([fileName hasPrefix:@"checkitems_"] && [fileName hasSuffix:@".dat"]) { // checklist_*.datのみ抽出する
                            [_oldTemplateURLs addObject:url];
                        }
                    }
                    DEBUGLOG(@"Old CheckLists Count:%lu", (unsigned long)[_oldTemplateURLs count]);
                    
                    [iCloudViewController moveFromiCloud];
                    
                    // ダウンロード完了を監視する
                    _timer = [NSTimer scheduledTimerWithTimeInterval:kObservationInterval
                                                              target:self
                                                            selector:@selector(downloadObserver)
                                                            userInfo:nil
                                                             repeats:YES];
                    
                    
                }
            }];

            break;
        }
    }

    [alert show];
}


-(void)uploadObserver
{
    static int count = 0;
    count++;
    DEBUGLOG(@"ObservationCount:%d", count);

    if (_isUploadedCheckList == YES && _isUploadedCheckItem == YES) {
        // 正常終了
        
        // バックアップ情報を(前回のバックアップとして表示するため)iCloudに記録する
        NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
        NSArray *objectArray = [NSArray arrayWithObjects:[NSDate date], [[UIDevice currentDevice] name], nil];
        NSArray *keyArray = [NSArray arrayWithObjects:kLastBackupKey, kDevideNameKey, nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objectArray
                                                               forKeys:keyArray];
        [keyValueStore setDictionary:dictionary forKey:kBackupKey];
        [keyValueStore synchronize];
        
        [self lastBackup];
        
        [SVProgressHUD showSuccessWithStatus:nil];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [_timer invalidate];
        count = 0;
    } else if (count >= kMaxObservation) { // 終了しない場合はエラー扱いにする
        // エラー
        [SVProgressHUD showErrorWithStatus:@"Error"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [_timer invalidate];
        count = 0;
    }
}

-(void)downloadObserver
{
    static int count = 0;
    count++;
    DEBUGLOG(@"ObservationCount:%d", count);
    
    if (_isDownloadedCheckList == YES && _isDownloadedCheckItem == YES) {
        // 正常終了
        
        // 1.ヘッダーの再読み込み
        [[LLCheckListManager sharedManager] loadCheckLists];
        
        // 2.チェックリストの再読み込み
        [[LLCheckListManager sharedManager] loadCheckItems];

        // 3.復元した結果、使用されなくなるチェックリストファイルを削除
        [[LLCheckListManager sharedManager] disposeGarbageFilesAtURL:_oldTemplateURLs];


        [SVProgressHUD showSuccessWithStatus:nil];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [_timer invalidate];
        count = 0;

        // デリゲートに通知
        if ([self.delegate respondsToSelector:@selector(iCloudViewRestoreDone:)]) {
            [self.delegate iCloudViewRestoreDone:self];
        }

    } else if (count >= kMaxObservation) { // 終了しない場合はエラー扱いにする) {
        // エラー
        [SVProgressHUD showErrorWithStatus:@"Error"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [_timer invalidate];
        count = 0;
    } else {
        // ダウンロード再試行
        DEBUGLOG(@"Download Observation again ->>>>>>>");
    }
}

#pragma mark - Backup
+(void)backupAppSettings
{
    NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    // 選択タブ
    [keyValueStore setObject:@([userDefaults integerForKey:SETTING_ACTIVETAB]) forKey:SETTING_ACTIVETAB];


    [keyValueStore synchronize];
}

+(void)restoreAppSettings
{
    NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    [keyValueStore synchronize];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // 選択タブ
    [keyValueStore setUserDefaultInteger:userDefaults forKey:SETTING_ACTIVETAB];


    [userDefaults synchronize];
}

+(void)backupCheckListFile
{
    // Sandbox URL
    NSURL *sandboxURL = [[LLCheckListManager sharedManager] URLForCheckListFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[sandboxURL path]] == NO) {
        // コピー元が存在しない場合はファイルを作成する
        [[LLCheckListManager sharedManager] saveCheckLists];
    }

    [iCloudViewController backupFile:sandboxURL withBlock:^{
        _isUploadedCheckList = YES;
    }];
}

+(void)backupCheckItemFile
{
    // すべてのチェックリストを保存する
    [[LLCheckListManager sharedManager] saveCheckLists];
    
    for (LLCheckList *checkList in [LLCheckListManager sharedManager].arrayCheckLists) {
        NSURL *sandboxURL = [[LLCheckListManager sharedManager] URLForCheckListFileAtFileName:checkList.checkItemsFileName];
        [iCloudViewController backupFile:sandboxURL withBlock:^{
            _isUploadedCheckItem = YES;
        }];
    };
}

+(NSURL *)backupURL
{
    // backupディレクトリが無い場合は作成する
    // iCloudにアップロードするファイルをbackupディレクトリにコピーして、それをiCLoudに移動する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1) {
        return nil;
    }
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"backup"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSError *error;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    // backupURLを返す
    paths = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    if ([paths count] < 1) {
        return nil;
    }
    NSURL *url = [paths objectAtIndex:0];
    return [url URLByAppendingPathComponent:@"backup" isDirectory:YES];
}

+(void)backupFile:(NSURL *)sandboxURL withBlock:(void (^)(void))block
{
    NSString *fileName = [sandboxURL lastPathComponent];

    // Backupディレクトリの既存ファイルを削除する必要がある
    NSURL *backupURL = [[iCloudViewController backupURL] URLByAppendingPathComponent:fileName];
    NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    [fileCoordinator removeFile:backupURL];
    fileCoordinator = nil;
    
    // Backupディレクトリにコピーする
    NSError *error = nil;
    if ([[NSFileManager defaultManager] copyItemAtURL:sandboxURL toURL:backupURL error:&error]) {
        
        // iCloud URL
        NSURL *iCloudURL = [[NSFileManager iCloudDocumentsURL] URLByAppendingPathComponent:fileName];
        
        // BackupからiCloudに移動
        [iCloudViewController moveToiCloud:backupURL destination:iCloudURL withBlock:block];
    };
    
}

#pragma mark - iCloudアクセス
// 前回バックアップ情報を取得
-(void)lastBackup
{
    // バックアップ情報を取得する
    NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    [keyValueStore synchronize];
    NSDictionary *dictionary = [keyValueStore dictionaryForKey:kBackupKey];
    
    _lastBackup = nil;
    _lastBackup = (NSDate *)[dictionary objectForKey:kLastBackupKey];
    _deviceName = nil;
    _deviceName = (NSString *)[dictionary objectForKey:kDevideNameKey];
    
    DEBUGLOG(@"LastBackup:%@ DeciveName:%@", _lastBackup, _deviceName);

    [self.tableView reloadData];
}

-(void)keyValueStoreDidChangeExternally:(NSNotification *)notification
{
    DEBUGLOG(@"!!! iCloud KeyValueStore synchronized !!!");
    [self lastBackup];
}

// iCloudへバックアップ
+(void)moveToiCloud:(NSURL *)sourceURL destination:(NSURL *)destinationURL withBlock:(void (^)(void))block
{
    DEBUGLOG(@"sourceURL:%@, destinationURL%@", sourceURL, destinationURL);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {

        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // iCloud上にファイルが存在する場合は削除する(削除しておかないと移動ができない)
        if ([fileManager fileExistsAtPath:[destinationURL path]]) {
            DEBUGLOG(@"Exist iCloudURL:%@", destinationURL);
            
            NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [fileCoordinator removeFile:destinationURL];
            fileCoordinator = nil;
        }

        // iCloudにファイルを移動
        NSError *error = nil;
        BOOL success = [fileManager setUbiquitous:YES itemAtURL:sourceURL destinationURL:destinationURL error:&error];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (success) {
                DEBUGLOG(@"Success move iCloudURL:%@", destinationURL);
                if (block) {
                    block();
                }
            } else {
                DEBUGLOG(@"Couldn't move iCloudURL%@ %@", error.debugDescription, error.description);
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });

    });
}

// iCloudから復元
+(void)moveFromiCloud
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [_query startQuery];
}

-(void)queryDidUpdateForManagedDocument:(NSNotification *)notification
{
    [self queryDidFinishGatheringForManagedDocument:notification];
}

-(void)queryDidFinishGatheringForManagedDocument:(NSNotification *)notification
{
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];     // 再検索できなくなるのでstopQueryしてはいけない

    NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];

    for (NSMetadataItem *item in query.results) {
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        NSString *fileName = [url lastPathComponent];
        DEBUGLOG(@"FileName:%@", fileName);
        
        id out = nil;
        NSError *error = nil;
//        [url getResourceValue:&out forKey:NSURLUbiquitousItemIsDownloadedKey error:&error];
//        if ([out boolValue]) {

        if ([url getResourceValue:&out forKey:NSURLUbiquitousItemDownloadingStatusDownloaded error:&error]) {
            DEBUGLOG(@"NSURLUbiquitousItemIsDownloadedKey:%@", ([out boolValue])? @"True": @"Fales");
            
            // チェックリスト
            if ([fileName isEqualToString:[[[LLCheckListManager sharedManager] URLForCheckListFile] lastPathComponent]]) {
                NSURL *fileURL = [[LLCheckListManager sharedManager] URLForCheckListFile];
                [fileCoordinator removeFile:fileURL];
                
                if ([[NSFileManager defaultManager] copyItemAtURL:url toURL:fileURL error:&error]) {
                    _isDownloadedCheckList = YES;
                    DEBUGLOG(@"Success Restore CheckList");
                } else {
                    _isDownloadedCheckList = NO;
                    DEBUGLOG(@"Can't Restore CheckList:%@", error.localizedDescription);
                }

            // チェックアイテム
            } else if ([fileName hasPrefix:@"checkitems_"] && [fileName hasSuffix:@".dat"]) {
                
                NSURL *fileURL = [[[LLCheckListManager sharedManager] URLForCheckListDirectory] URLByAppendingPathComponent:fileName];
                [fileCoordinator removeFile:fileURL];
                
                if ([[NSFileManager defaultManager] copyItemAtURL:url toURL:fileURL error:&error]) {
                    _isDownloadedCheckItem = YES;
                    DEBUGLOG(@"Success Restore CheckItems");
                } else {
                    _isDownloadedCheckItem = NO;
                    DEBUGLOG(@"Can't Restore CheckItems:%@", error.localizedDescription);
                }

            }

        } else {
            [url getResourceValue:&out forKey:NSURLUbiquitousItemIsDownloadingKey error:&error];
            if ([out boolValue]) {
                DEBUGLOG(@"NSURLUbiquitousItemIsDownloadingKey:%@", ([out boolValue])? @"True": @"Fales");
            } else {
                [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:url error:&error];
                if (error) {
                    DEBUGLOG(@"Can't start Downloading:%@", error.localizedDescription);
                } else {
                    DEBUGLOG(@"Start Downloading");
                }
            }
        }
    }

    fileCoordinator = nil;

    // ダウンロード指示後は再検索する必要がある
    [query enableUpdates];
}

@end
