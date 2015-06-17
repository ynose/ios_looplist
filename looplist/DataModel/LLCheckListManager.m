//
//  LLCheckListManager.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/09.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLCheckListManager.h"


@implementation LLCheckListManager 

static LLCheckListManager *_sharedInstance = nil;
static NSString *_checkListDir = @"checklist";
static NSString *_checkListFile = @"checklist.dat";

static NSString *_attachImageDir = @"attachImages";


-(id)init
{
    self = [super init];
    if (self) {
        // ファイルマネージャを取得する
        NSFileManager *fileManager = [NSFileManager defaultManager];

        // .checklistディレクトリを作成する
        NSString *dir = [self dir];
        if (![fileManager fileExistsAtPath:dir]) {
            NSError *error;
            [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        }
    }

    return self;
}

#pragma mark - シングルトン定義
+(LLCheckListManager*)sharedManager
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [self new];
        }
    }
    return _sharedInstance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    return nil;
}

-(id)copyWithZone:(NSZone*)zone {
	return self;        // シングルトン状態を保持するため何もせず self を返す
}


#pragma mark - ファイル操作
-(void)loadCheckLists
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[self dir] stringByAppendingPathComponent:_checkListFile];
    NSMutableArray *array;

    if (!path || ![fileManager fileExistsAtPath:path]) {
        array = [NSMutableArray arrayWithObject:[[LLCheckList alloc] initWithCheckItemsFileName]];
    } else {
        array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!array) {
            array = [NSMutableArray arrayWithObject:[[LLCheckList alloc] initWithCheckItemsFileName]];
        }
    }

    self.arrayCheckLists = array;
}

-(void)saveCheckLists
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = [self dir];

    // ディレクトリを作成
    if (![fileManager fileExistsAtPath:dir]) {
        NSError *error;
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
    }

    //ファイルを保存
    [NSKeyedArchiver archiveRootObject:self.arrayCheckLists toFile:[dir stringByAppendingPathComponent:_checkListFile]];
}

-(void)saveAttachImage:(UIImage *)image fileName:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = [self dir];
    dir = [dir stringByAppendingPathComponent:_attachImageDir];
    // ディレクトリを作成
    if (![fileManager fileExistsAtPath:dir]) {
        NSError *error;
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
    }


    NSString *path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", fileName]];


    // NSDataのwriteToFileメソッドを使ってファイルに書き込みます
    // atomically=YESの場合、同名のファイルがあったら、まずは別名で作成して、その後、ファイルの上書きを行います
    NSData *data = UIImageJPEGRepresentation(image, 0.8f);
    if ([data writeToFile:path atomically:NO]) {
        NSLog(@"save OK");
    } else {
        NSLog(@"save NG");
    }
}

-(void)removeAttachImageFile:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = [self dir];
    dir = [dir stringByAppendingPathComponent:_attachImageDir];

    NSString *path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", fileName]];


    if (path && [fileManager fileExistsAtPath:path]) {
        NSError *error;
        if ([fileManager removeItemAtPath:path error:&error] == NO) {
            DEBUGLOG(@"deleteAttachImageFile:Code=%d, Desc=%@", [error code], [error localizedDescription]);
        }
    }

}

-(UIImage *)loadAttachImage:(NSString *)fileName
{
    NSString *dir = [self dir];
    dir = [dir stringByAppendingPathComponent:_attachImageDir];
    NSString *path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", fileName]];


    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];

    UIImage *image = nil;
    if (!error) {
        image = [UIImage imageWithData:data];
    }

    return image;
}

#pragma mark - CheckListオブジェクト操作
-(void)insertObject:(LLCheckList *)checkList inCheckList:(NSUInteger)checkListIndex
{
    [self.arrayCheckLists insertObject:checkList atIndex:checkListIndex];
}

-(NSInteger)addObject:(LLCheckList *)checkList
{
    NSInteger insertIndex = [self.arrayCheckLists count];
    [self.arrayCheckLists insertObject:checkList atIndex:insertIndex];

    return insertIndex;
}

-(void)removeCheckList:(NSInteger)checkListIndex
{
    // 画像ファイルも同時に削除する
    LLCheckList *checkList = (LLCheckList *)self.arrayCheckLists[checkListIndex];
    for (LLCheckListSection *section in checkList.arraySections) {
        for (LLCheckItem *checkItem in section.checkItems) {
            [[LLCheckListManager sharedManager] removeAttachImageFile:checkItem.identifier];
        }
    }

    // ファイルも同時に削除する
    [self deleteFileAtIndex:checkListIndex];
    [self.arrayCheckLists removeObjectAtIndex:checkListIndex];

    // １つもなくなる場合は空データを作成する
    if ([self.arrayCheckLists count] == 0) {
        self.arrayCheckLists = [NSMutableArray arrayWithObject:[[LLCheckList alloc] initWithCheckItemsFileName]];
    }
}

-(void)replaceCheckList:(NSUInteger)checkListIndex withObject:(LLCheckList *)checkList
{
    [self.arrayCheckLists replaceObjectAtIndex:checkListIndex withObject:checkList];
}

-(void)deleteFileAtIndex:(NSInteger)index
{
    // ファイルマネージャを取得する
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = [self dir];

    LLCheckList *checkList = (LLCheckList *)self.arrayCheckLists[index];
    NSString *path = [dir stringByAppendingPathComponent:checkList.checkItemsFileName];
    DEBUGLOG(@"Delete Filer : %@", path);

    if (path && [fileManager fileExistsAtPath:path]) {
        NSError *error;
        if ([fileManager removeItemAtPath:path error:&error] == NO) {
            DEBUGLOG(@"deleteFileAtIndex:Code=%d, Desc=%@", [error code], [error localizedDescription]);
        }
    }
}


#pragma mark 全チェック項目チェック完了
-(void)completeCheckList:(NSUInteger)checkListIndex
{
    for (LLCheckListSection *checkListSection in ((LLCheckList *)self.arrayCheckLists[checkListIndex]).arraySections) {
        for (LLCheckItem *checkItem in checkListSection.checkItems) {
            // 次回に持ち越さない項目をリセット
            [checkItem complete];
        }
    }

    // チェック完了回数をインクリメント
    [self.arrayCheckLists[checkListIndex] incrementFinishCount];
}


#pragma mark - iCloudバックアップ用メソッド
-(NSURL *)URLForCheckListFile
{
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    if ([paths count] < 1) {
        return nil;
    }
    NSURL *url = [paths objectAtIndex:0];
    url = [url URLByAppendingPathComponent:_checkListDir isDirectory:YES];
    return [url URLByAppendingPathComponent:_checkListFile];
}

-(NSURL *)URLForCheckListDirectory
{
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    if ([paths count] < 1) {
        return nil;
    }
    NSURL *url = [paths objectAtIndex:0];
    return [url URLByAppendingPathComponent:_checkListDir isDirectory:YES];
}

-(NSURL *)URLForCheckListFileAtFileName:(NSString* )fileName
{
    NSURL *url = [self URLForCheckListDirectory];
    return [url URLByAppendingPathComponent:fileName];
}

#pragma mark ファイルパス
-(NSString *)dir
{
    // ドキュメントパスを取得する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1) {
        return nil;
    }

    // .checklistパスを生成する
    NSString *path = paths[0];
    return [path stringByAppendingPathComponent:_checkListDir];
}

@end

