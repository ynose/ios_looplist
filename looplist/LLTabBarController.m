//
//  LLTabBarController.m
//  looplist
//
//  Created by Yoshio Nose on 2013/09/24.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLTabBarController.h"

#import "LLAppSettingViewController.h"
#import "LLRootViewController.h"

#import "ProductManager.h"
#import "LLCheckListManager.h"


@interface LLTabBarController ()  <UITabBarControllerDelegate, AppSettingViewControllerDelegate, NADViewDelegate>
@property (nonatomic, assign) BOOL loadedAd;
@end

@implementation LLTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.delegate = self;   // UITabBarControllerDelegateを自分にする必要あり

    // タブを選択する
    [self refreshViewControllers];
    [self setSelectedIndex:[[NSUserDefaults standardUserDefaults] integerForKey:SETTING_ACTIVETAB]];

    // 無料版のみ広告表示
#ifdef APPSTORE_SCREENSHOT
    // AppStore用スクリーンショット
    // ダミーの広告枠を表示する
    [self dummyAd];
#else
    if (![ProductManager isAppPro]) {
        [self setupAd];
    }
#endif

//    [self dummyAd];
//    [self nadViewDidFinishLoad:nil];
//    [self nadViewDidReceiveAd:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // 広告の再開
    [self.nadView resume];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // 広告の一時停止
    [self.nadView pause];
}

-(void)setupAd
{
    // (2) NADView の作成
//    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.tabBar.frame.size.height - 50, 320, 50)];
    self.nadView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    // (3) ログ出力の指定
    [self.nadView setIsOutputLog:NO];
    // (4) set apiKey, spotId.
#ifndef DEBUG
    [self.nadView setNendID:@"1584498c8e4444d600ecb3725c630b1791b22aa0" spotID:@"96305"];   // 本番用
#else
    // テスト用でもネットワークにつながっていないと表示されない
    [self.nadView setNendID:@"a6eca9dd074372c898dd1df549301f277c53f2b9" spotID:@"3172"];    // 表示テスト用
#endif
    [self.nadView setDelegate:self]; //(5)
    [self.nadView load]; //(6)
    [self.view addSubview:self.nadView]; // 最初から表示する場合
}

#ifdef APPSTORE_SCREENSHOT
// AppStoreスクリーンショット用ダミー広告枠
-(void)dummyAd
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.tabBar.frame.size.height - 50, 320, 50)];
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderColor = [[UIColor grayColor] CGColor];
    view.layer.borderWidth = 1;

    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.text = @"Ad";
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];

    [self.view addSubview:view]; // 最初から表示する場合
}
#endif

-(void)nadViewDidFinishLoad:(NADView *)adView
{
    DEBUGLOG(@"delegate nadViewDidFinishLoad:");

    self.loadedAd = YES;
    for (UINavigationController *navController in self.viewControllers) {
        LLRootViewController *rootViewController = (LLRootViewController *)navController.topViewController;

        UIEdgeInsets inset = rootViewController.tableView.contentInset;
        inset.bottom += 50;
        rootViewController.tableView.contentInset = inset;
        rootViewController.tableView.scrollIndicatorInsets = inset;
    }
}

-(void)dealloc
{
    [self.nadView setDelegate:nil]; // delegate に nil をセット
    self.nadView = nil; // プロパティ経由で release、nil をセット
}

#pragma mark 全タブ内のビューコントローラを再構築
-(void)refreshViewControllers
{
    // チェックリスト数分のタブを作成する
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSInteger index = 0; index < MIN([[LLCheckListManager sharedManager].arrayCheckLists count], SHOWLIST_COUNT); index++) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        
        UINavigationController *navigationController = [storyBoard instantiateViewControllerWithIdentifier:@"RootNavigationController"];

        LLCheckList *checkList = (LLCheckList *)[LLCheckListManager sharedManager].arrayCheckLists[index];
        LLRootViewController *rootViewController = (LLRootViewController *)navigationController.topViewController;
        rootViewController.checkListIndex = index;
        rootViewController.checkList = checkList;
        [rootViewController refreshTabBarItem];

        [viewControllers addObject:navigationController];
    }
    [self setViewControllers:viewControllers];

//    // Pro版のみタブバーを表示する
//    self.tabBar.hidden = ([ProductManager isAppPro]) ? NO : YES;
//    self.tabBar.hidden = NO;

}


#pragma mark - タブ選択
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    LLRootViewController *rootViewController = (LLRootViewController *)((UINavigationController *)viewController).visibleViewController;

    // 同じタブをタップした場合は未チェック項目にスクロール
    if (tabBarController.selectedViewController == viewController) {

        // 一番上の未チェックアイテムを探す
        NSMutableArray *arraySections = [rootViewController checkListSections];
        NSIndexPath *uncheckedIndexPath = nil;
        for (NSInteger section = 0; section < [arraySections count] && uncheckedIndexPath == nil; section++) {
            for (NSInteger row = 0; row < [((LLCheckListSection *)arraySections[section]).checkItems count] &&
                 uncheckedIndexPath == nil; row++) {
                if (!((LLCheckItem *)((LLCheckListSection *)arraySections[section]).checkItems[row]).checkedDate) {
                    uncheckedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                }
            }
        }

        // 一番上の未チェックアイテムにスクロールする
        UITableView *tableView = rootViewController.tableView;
        if (uncheckedIndexPath) {
            [tableView scrollToRowAtIndexPath:uncheckedIndexPath
                             atScrollPosition:UITableViewScrollPositionNone animated:YES];
        } else {
            // 未チェックアイテムが無い場合はフッターにスクロールする
            [tableView scrollToRowAtIndexPath:[rootViewController indexPathOfEndRow]
                             atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        return NO;
    } else {
        // チェック日時を更新するためにリロードする
        [rootViewController.tableView reloadVisibleRowsAfterDelay:0 withRowAnimation:UITableViewRowAnimationNone];

        return YES;
    }
}


#pragma mark メニューボタン
-(void)menuAction:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *navigationController = [storyBoard instantiateViewControllerWithIdentifier:@"AppSettingViewController"];
    LLAppSettingViewController *viewController = (LLAppSettingViewController *)navigationController.topViewController;
    viewController.delegate = self;
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - AppSettingViewControllerDelegate
-(void)appSettingViewControllerRefreshCheckList:(id)sender
{
    // タブバーに反映する
    [self refreshViewControllers];

//    // 無料版のみ広告表示
//    if ([ProductManager isAppPro]) {
//        [self.nadView setDelegate:nil]; // delegate に nil をセット
//        self.nadView = nil; // プロパティ経由で release、nil をセット
//    }
}

@end
