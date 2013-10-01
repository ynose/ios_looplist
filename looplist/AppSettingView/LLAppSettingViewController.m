//
//  LLAppSettingViewController.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/25.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLAppSettingViewController.h"

// Evernote API
#import "EvernoteSDK.h"

#import "Define.h"

#import "YNAlertView.h"
#import "UITableView+Extension.h"

#import "LLCheckListManager.h"
#import "ProductManager.h"

#import "LLEvernoteAccountViewController.h"
#import "iCloudViewController.h"
#import "InAppPurchaseViewController.h"


// Segue名の定義
static NSString *kEvernoteAccountSegue = @"EvernoteAccountSegue";
static NSString *kICloudSegueSegue = @"iCloudSegue";
static NSString *kInAppPurchaseSegue = @"InAppPurchaseSegue";


@interface LLAppSettingViewController () <EvernoteAccountViewControllerDelegate, iCloudViewControllerDelegate,
                                          inAppPurchaseViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *addListButtonCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *evernoteButtonCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *iCloudButtonCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *inAppPurchaseButtonCell;
@end

@implementation LLAppSettingViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.addListButtonCell.textLabel.textColor = UIColorMain;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // リストの上限数を表示
    NSInteger checkListCount = [[LLCheckListManager sharedManager].arrayCheckLists count];
    NSInteger checkListMax = 1;
    if ([ProductManager isAppPro]) {
        checkListMax = MAX_CHECKLIST;
    }
    self.addListButtonCell.detailTextLabel.text = [NSString stringWithFormat:@"%d / %d", checkListCount, checkListMax];

    // Evernoteサインイン状態を表示
    EvernoteSession *session = [EvernoteSession sharedSession];
    if (session.isAuthenticated) {
        // 認証済み
        self.evernoteButtonCell.detailTextLabel.text = LSTR(@"Setting-EvernoteAccount-Signed");
    } else {
        self.evernoteButtonCell.detailTextLabel.text = @"";
    }

    // 購入状態を表示する
    if ([ProductManager isAppPro]) {
        // 購入済み
        self.inAppPurchaseButtonCell.detailTextLabel.text = LSTR(@"Setting-InAppPurchase-Purchased");
    } else {
        self.inAppPurchaseButtonCell.detailTextLabel.text = LSTR(@"Setting-InAppPurchase-NotYet");
    }
}


#pragma mark - セル選択
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    DEBUGLOG(@"shouldPerformSegueWithIdentifier:%@", identifier);

    // Evernoteアカウント ***Pro版限定***
    if ([identifier isEqualToString:kEvernoteAccountSegue]) {
        if (![self showAlertAppPro]) {
            return NO;
        }
    }


    // その他は無条件にセル選択可能
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DEBUGLOG(@"prepareForSegue:%@", segue.identifier);

    // Evernoteアカウント
    if ([segue.identifier isEqualToString:kEvernoteAccountSegue]) {
        ((LLEvernoteAccountViewController *)segue.destinationViewController).delegate = self;
    }

    // バックアップ＆復元
    if ([segue.identifier isEqualToString:kICloudSegueSegue]) {
        ((iCloudViewController *)segue.destinationViewController).delegate = self;
    }

    // 購入
    if ([segue.identifier isEqualToString:kInAppPurchaseSegue]) {
        ((InAppPurchaseViewController *)segue.destinationViewController).delegate = self;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectSelectedRow:YES];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    // リスト追加 ***Pro版限定***
                    // リスト数の上限を超えていなければ追加可能
                    NSInteger checkListCount = [[LLCheckListManager sharedManager].arrayCheckLists count];
                    if ([self showAlertAppPro] && checkListCount < MAX_CHECKLIST) {
                        [self dismissViewControllerAnimated:YES completion:^{
                            if ([self.delegate respondsToSelector:@selector(appSettingViewControllerDidAddCheckList:)]) {
                                [self.delegate appSettingViewControllerDidAddCheckList:self];
                            }
                        }];
                    }
                }
                break;
                    
                default:
                    break;
            }
            break;

        default:
            break;
    }
}

#pragma mark - 完了ボタン
- (IBAction)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - EvernoteAccountViewControllerDelegate
-(void)evernoteAccountViewDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - iCloudViewControllerDelegate
-(void)iCloudViewRestoreDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

    if ([self.delegate respondsToSelector:@selector(appSettingViewControllerDidRestoreCheckList:)]) {
        [self.delegate appSettingViewControllerDidRestoreCheckList:self];
    }
}

#pragma mark - InAppPurchaseViewControllerDelegate
-(void)inAppPurchaseDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
// Pro版限定機能を使用可比判定とアラート表示
-(BOOL)showAlertAppPro
{
    if (![ProductManager isAppPro]) {

        YNAlertView *alert = [YNAlertView new];

        alert.title = LSTR(@"Setting-AlertProVersionTitle");
        alert.message = LSTR(@"Setting-AlertProVersionMessage");

        // キャンセルボタン
        [alert addButtonWithTitle:LSTR(@"actionCancel")];
        alert.cancelButtonIndex = 0;

        // 購入画面へボタン
        [alert addButtonWithTitle:LSTR(@"Setting-AlertProVersionPurchase") withBlock:^(UIAlertView *alertView) {
            [self performSegueWithIdentifier:kInAppPurchaseSegue sender:self];
        }];

        [alert show];
        return NO;

    } else {
        return YES;
    }
}


@end