//
//  LLAppSettingViewController.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/25.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLAppSettingViewController.h"

// Evernote API
//#import "EvernoteSDK.h"

#import "YNAlertView.h"
#import "UITableView+Extension.h"

#import "LLCheckListManager.h"
#import "ProductManager.h"

#import "LLCheckListManageViewController.h"
#import "LLEvernoteAccountViewController.h"
#import "iCloudViewController.h"
#import "InAppPurchaseViewController.h"


// Segue名の定義
static NSString *kCheckListManageSegue = @"CheckListManageSegue";
static NSString *kEvernoteAccountSegue = @"EvernoteAccountSegue";
static NSString *kICloudSegueSegue = @"iCloudSegue";
static NSString *kInAppPurchaseSegue = @"InAppPurchaseSegue";


@interface LLAppSettingViewController () <CheckListManageViewControllerDelegate, EvernoteAccountViewControllerDelegate,
                                          iCloudViewControllerDelegate, inAppPurchaseViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *checkListManageButtonCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *evernoteButtonCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *iCloudButtonCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *inAppPurchaseButtonCell;

@property (nonatomic, assign) BOOL needRefreshCheckList;
@end

@implementation LLAppSettingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // リストの上限数を表示
    NSInteger checkListCount = [[LLCheckListManager sharedManager].arrayCheckLists count];
    NSInteger checkListMax = MAX_CHECKLIST;
//    NSInteger checkListMax = 1;
//    if ([ProductManager isAppPro]) {
//        checkListMax = MAX_CHECKLIST;
//    }
    self.checkListManageButtonCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)checkListCount, (long)checkListMax];

//    // Evernoteサインイン状態を表示
//    EvernoteSession *session = [EvernoteSession sharedSession];
//    if (session.isAuthenticated) {
//        // 認証済み
//        self.evernoteButtonCell.detailTextLabel.text = LSTR(@"Setting-EvernoteAccount-Signed");
//    } else {
//        self.evernoteButtonCell.detailTextLabel.text = @"";
//    }

//    // 購入状態を表示する
//    if ([ProductManager isAppPro]) {
//        // 購入済み
//        self.inAppPurchaseButtonCell.detailTextLabel.text = LSTR(@"Setting-InAppPurchase-Purchased");
//    } else {
//        self.inAppPurchaseButtonCell.detailTextLabel.text = LSTR(@"Setting-InAppPurchase-NotYet");
//    }
}


#pragma mark - セル選択
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    DEBUGLOG(@"shouldPerformSegueWithIdentifier:%@", identifier);

//    // リストの管理 ***Pro版限定***
//    if ([identifier isEqualToString:kCheckListManageSegue]) {
//        if (![self showAlertAppPro]) {
//            [self.tableView deselectCell:(UITableViewCell *)sender animated:YES];
//            return NO;
//        }
//    }

//    // Evernoteアカウント ***Pro版限定***
//    if ([identifier isEqualToString:kEvernoteAccountSegue]) {
//        if (![self showAlertAppPro]) {
//            [self.tableView deselectCell:(UITableViewCell *)sender animated:YES];
//            return NO;
//        }
//    }

    // その他は無条件にセル選択可能
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DEBUGLOG(@"prepareForSegue:%@", segue.identifier);

    if ([segue.identifier isEqualToString:kCheckListManageSegue]) {
        ((LLCheckListManageViewController *)segue.destinationViewController).delegate = self;
    }

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


#pragma mark - 完了ボタン
- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

    // チェックリストの編集あり
    if (self.needRefreshCheckList) {
        if ([self.delegate respondsToSelector:@selector(appSettingViewControllerRefreshCheckList:)]) {
            [self.delegate appSettingViewControllerRefreshCheckList:self];
        }
    }
}

#pragma mark - CheckListManageViewControllerDelegate
-(void)checkListManageViewControllerChangeCheckList:(id)sender
{
    self.needRefreshCheckList = YES;
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

    if ([self.delegate respondsToSelector:@selector(appSettingViewControllerRefreshCheckList:)]) {
        [self.delegate appSettingViewControllerRefreshCheckList:self];
    }
}

#pragma mark - InAppPurchaseViewControllerDelegate
-(void)inAppPurchaseDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

    self.needRefreshCheckList = YES;
}


//#pragma mark -
//// Pro版限定機能を使用可否判定とアラート表示
//-(BOOL)showAlertAppPro
//{
//    if (![ProductManager isAppPro]) {
//
//        YNAlertView *alert = [YNAlertView new];
//
//        alert.title = LSTR(@"Setting-AlertProVersionTitle");
//        alert.message = LSTR(@"Setting-AlertProVersionMessage");
//
//        // キャンセルボタン
//        [alert addButtonWithTitle:LSTR(@"actionCancel")];
//        alert.cancelButtonIndex = 0;
//
//        // 購入画面へボタン
//        [alert addButtonWithTitle:LSTR(@"Setting-AlertProVersionPurchase") withBlock:^(UIAlertView *alertView) {
//            [self performSegueWithIdentifier:kInAppPurchaseSegue sender:self];
//        }];
//
//        [alert show];
//        return NO;
//
//    } else {
//        return YES;
//    }
//}


@end
