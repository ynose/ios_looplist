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

#import "Define.h"

#import "ProductManager.h"
#import "LLCheckListManager.h"


@interface LLTabBarController ()  <UITabBarControllerDelegate, AppSettingViewControllerDelegate>

@end

@implementation LLTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.delegate = self;   // UITabBarControllerDelegateを自分にする必要あり

    // タブを選択する
    [self refreshViewControllers];
    [self setSelectedIndex:[[NSUserDefaults standardUserDefaults] integerForKey:SETTING_ACTIVETAB]];

    [self.moreNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarMetrics:UIBarMetricsDefault];
    [self.moreNavigationController.navigationBar setTintColor:UIColorButtonText];
    [self.moreNavigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorButtonText}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 全タブ内のビューコントローラを再構築
-(void)refreshViewControllers
{
//    self.viewControllers = nil;     // 一旦すべて削除しないとMoreに削除したビューが残ってしまう

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

    // Pro版のみタブバーを表示する
    self.tabBar.hidden = ([ProductManager isAppPro]) ? NO : YES;
}


#pragma mark - タブ選択
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    LLRootViewController *rootViewController = (LLRootViewController *)((UINavigationController *)viewController).visibleViewController;

    return [self tabBarController:tabBarController shouldSelectRootViewController:rootViewController];
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectRootViewController:(LLRootViewController *)rootViewController
{
    // 同じタブをタップした場合は未チェック項目にスクロール
    if (tabBarController.selectedViewController == rootViewController) {

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
}

@end
