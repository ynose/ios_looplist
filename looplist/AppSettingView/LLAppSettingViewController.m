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

#import "LLCheckListManager.h"
#import "ProductManager.h"

#import "LLEvernoteAccountViewController.h"
#import "iCloudViewController.h"
#import "InAppPurchaseViewController.h"


// Segue名の定義
static NSString *kAddListSegue = @"AddListSegue";
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


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // リストの上限数を表示
    NSInteger checkListCount = [[LLCheckListManager sharedManager].arrayCheckLists count];
    self.addListButtonCell.detailTextLabel.text = [NSString stringWithFormat:@"%d / %d", checkListCount, MAX_CHECKLIST];

    // Evernoteサインイン状態を表示
    EvernoteSession *session = [EvernoteSession sharedSession];
    if (session.isAuthenticated) {
        // 認証済み
        self.evernoteButtonCell.detailTextLabel.text = LSTR(@"Setting-EvernoteAccount-Signed");
    } else {
        self.evernoteButtonCell.detailTextLabel.text = @"";
    }

    // 購入済み状態を表示する
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
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    // リスト追加
                    // リスト数の上限を超えていなければ追加可能
                    NSInteger checkListCount = [[LLCheckListManager sharedManager].arrayCheckLists count];
                    if (checkListCount < MAX_CHECKLIST) {
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

#pragma mark - InAppPurchaseViewControllerDelegate
-(void)inAppPurchaseDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - iCloudViewControllerDelegate
-(void)iCloudViewRestoreDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
