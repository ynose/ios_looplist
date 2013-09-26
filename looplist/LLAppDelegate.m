//
//  LLAppDelegate.m
//  looplist
//
//  Created by Yoshio Nose on 2013/09/24.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLAppDelegate.h"

#import "EvernoteSDK.h"

#import "Define.h"
#import "NSFileManager+Extension.h"

#import "LLCheckListManager.h"

//#import "LLTabBarController.h"
#import "ProductManager.h"



@implementation LLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // デフォルト設定値を作成
    [self makeUserDefaults];

    // デフォルト設定値を読み込む
    [self loadUserDefaults];

    [self setupAppearance];

    [[LLCheckListManager sharedManager] loadCheckLists];
    [[LLCheckListManager sharedManager] loadCheckItems];


    // iCLoudの使用可否
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SETTING_ICLOUD_AVAILABLE];
    [NSFileManager iCloudAvailable:^{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SETTING_ICLOUD_AVAILABLE];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }];


    /* Evernote API */
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;
    NSString *CONSUMER_KEY = @"ynose249-3034";
    NSString *CONSUMER_SECRET = @"00f9a5815f95b1b9";

    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
                              consumerKey:CONSUMER_KEY
                           consumerSecret:CONSUMER_SECRET];

    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL canHandle = NO;
    if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]] == YES) {
        canHandle = [[EvernoteSession sharedSession] canHandleOpenURL:url];
    }
    return canHandle;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 設定値を保存する
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // チェック日時を更新する
//    UINavigationController *navigationController = (UINavigationController *)[self appTabBarController].selectedViewController;
//    [((LLRootViewController *)navigationController.topViewController).tableView reloadVisibleRowsAfterDelay:0
//                                                                                           withRowAnimation:UITableViewRowAnimationNone];

    [[EvernoteSession sharedSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // 設定値を保存する
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self saveAllFiles];
}

#pragma mark - デフォルト設定を作成
-(void)makeUserDefaults
{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

    // タブNo
    [defaults setObject:@0 forKey:SETTING_ACTIVETAB];

    // Pro版購入フラグ
    [defaults setObject:@"NO" forKey:[ProductManager settingKeyAppPro]];

    //    // URL Schemeアラート表示フラグ
    //    [defaults setObject:@"NO" forKey:SETTING_URLSCHEMEALERT];
    //
    //    // 「TapMailerの説明書」を表示のアラートフラグ
    //    [defaults setObject:@"YES" forKey:SETTING_OPENDOCUMENTALERT];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:defaults];

    //#ifdef DEBUG
    //    // 「TapMailerの説明書」を表示のアラートフラグを戻す
    //    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SETTING_OPENDOCUMENTALERT];
    //#endif
    //#ifdef APPSTORE_SCREENSHOT
    //    // TapMailer Proの機能を有効にする
    //    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SETTING_TAPMAILER_PRO];
    //#endif
#ifdef RESET_INAPPPURCHASE
    [ProductManager setAppPro:NO];
#endif
    [ProductManager setAppPro:NO];

}

-(void)loadUserDefaults
{
    // 今は特になし
}

-(void)saveAllFiles
{
    DEBUGLOG();
    // 設定値を保存する
    [[NSUserDefaults standardUserDefaults] synchronize];

    // ヘッダー、チェックリストを保存
    [[LLCheckListManager sharedManager] saveCheckLists];
    [[LLCheckListManager sharedManager] saveCheckItems];
}

-(void)setupAppearance
{
    // ナビゲーションバー
    [[UINavigationBar appearance] setTintColor:UIColorMainTint];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorMain}];

    // タブバー
    [[UITabBar appearance] setTintColor:UIColorMainTint];

    // テーブルビュー
    [[UITableView appearance] setTintColor:UIColorMainTint];
}

@end
