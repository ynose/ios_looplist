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
    // チェックリスト数分のタブを作成する
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSInteger index = 0; index < [[LLCheckListManager sharedManager].arrayCheckLists count]; index++) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        
        UINavigationController *navigationController = [storyBoard instantiateViewControllerWithIdentifier:@"RootNavigationController"];
        navigationController.tabBarItem.image = [UIImage imageNamed:@"tabbar-icon"];
        navigationController.tabBarItem.tag = index;

        LLRootViewController *rootViewController = (LLRootViewController *)navigationController.topViewController;
        rootViewController.checkListIndex = index;
        rootViewController.checkList = (LLCheckList *)[LLCheckListManager sharedManager].arrayCheckLists[index];
        [rootViewController refreshTabBarItem];

        [viewControllers addObject:navigationController];
    }
    self.viewControllers = nil;     // 一旦すべて削除しないとMoreに削除したビューが残ってしまう
    [self setViewControllers:viewControllers];
}


#pragma mark - タブ選択
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    DEBUGLOG(@"%@", [viewController class]);

    // MoreViewControllerの場合は無視させる
    if ([viewController class] != [UINavigationController class]) {
        return YES;
    }


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

#pragma mark タブの編集画面終了
-(void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    // カスタマイズしたタブの順序を保存する
    NSMutableArray *arrayBeforeCheckLists = [[LLCheckListManager sharedManager].arrayCheckLists copy];

    NSInteger index = 0;
    for (UINavigationController *navController in viewControllers) {
        DEBUGLOG(@"Tag = %d", navController.tabBarItem.tag);
        LLCheckList *checkList = arrayBeforeCheckLists[navController.tabBarItem.tag];
        [[LLCheckListManager sharedManager] replaceCheckList:index++ withObject:checkList];
    }

    [[LLCheckListManager sharedManager] saveCheckLists];
    [[LLCheckListManager sharedManager] saveCheckItems];
    [[LLCheckListManager sharedManager] loadCheckItems];

    [self refreshViewControllers];
    [self setSelectedIndex:0];
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
// チェックリスト追加ボタン
-(void)appSettingViewControllerDidAddCheckList:(id)sender
{
    // チェックリストを新規追加
    NSInteger insertIndex = [[LLCheckListManager sharedManager] addObject:[[LLCheckList alloc] initWithCheckItemsFileName]];
    [[LLCheckListManager sharedManager] saveCheckLists];
    [[LLCheckListManager sharedManager] saveCheckItems];

    // タブバーに反映する
    [self refreshViewControllers];
    [self setSelectedIndex:insertIndex];

    // 追加したら編集モードにする
    UINavigationController *navController = (UINavigationController *)self.selectedViewController;
    LLRootViewController *rootViewController = (LLRootViewController *)navController.topViewController;
    [rootViewController setEditing:YES];
}

-(void)appSettingViewControllerDidRestoreCheckList:(id)sender
{
    // タブバーに反映する
    [self refreshViewControllers];
}

#pragma mark チェックリスト削除ボタン
-(void)deleteCheckListAtIndex:(NSInteger)checkListIndex
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[LLCheckListManager sharedManager] removeCheckList:checkListIndex];
        [[LLCheckListManager sharedManager] saveCheckLists];
        [[LLCheckListManager sharedManager] saveCheckItems];

        [self refreshViewControllers];
        [self setSelectedIndex:0];
    }];
}


@end
