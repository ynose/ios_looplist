//
//  LLCheckListManageViewController.m
//  looplist
//
//  Created by Yoshio Nose on 2013/10/04.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLCheckListManageViewController.h"

#import "Define.h"

#import "LLTabBarController.h"
#import "LLRootViewController.h"
#import "LLCheckListDetailViewController.h"

#import "LLCheckListManager.h"
#import "LLCheckList.h"

@interface LLCheckListManageViewController () <LLCheckListDetailViewDelegate>
@property (nonatomic, assign) BOOL changeCheckList;
@property (nonatomic, assign) NSInteger checkListIndex;
@end

static NSString *kListCellIdentifier = @"Cell";

@implementation LLCheckListManageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [self editButtonItem];

    self.changeCheckList = NO;


    // 再利用セルのクラスを登録(dequeueReusableCellWithIdentifierで使う)
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kListCellIdentifier];
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//
//    self.navigationItem.rightBarButtonItem.target = self;;
//}

-(void)viewDidDisappear:(BOOL)animated
{
    // チェックリストの編集あり
    if (self.changeCheckList) {
        if ([self.delegate respondsToSelector:@selector(checkListManageViewControllerChangeCheckList:)]) {
            [self.delegate checkListManageViewControllerChangeCheckList:self];
        }
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing) {
        // 追加[+]ボタンの作成
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                                target:self
                                                                                                action:@selector(addAction:)]
                                         animated:animated];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil animated:animated];
    }

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return LSTR(@"Setting-CheckListManage-ShownList");
    } else {
        return LSTR(@"Setting-CheckListManage-UnshowList");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger showListCount = SHOWLIST_COUNT;
    if (section == 0) {
        return showListCount;
    } else {
        NSInteger checkListCount = [[LLCheckListManager sharedManager].arrayCheckLists count];
        return checkListCount - showListCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kListCellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.showsReorderControl = YES;

    NSInteger row = ((indexPath.section == 0) ? 0 : [tableView numberOfRowsInSection:0]) + indexPath.row;
    LLCheckList *checkList = [LLCheckListManager sharedManager].arrayCheckLists[row];
    cell.textLabel.text = checkList.caption;

    return cell;
}

#pragma mark セル選択
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.checkListIndex = ((indexPath.section == 0) ? 0 : [tableView numberOfRowsInSection:0]) + indexPath.row;
    LLCheckList *checkList = [LLCheckListManager sharedManager].arrayCheckLists[self.checkListIndex];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];

    if (tableView.editing) {
        // 編集モードはリストの設定画面を表示
        LLCheckListDetailViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"CheckListSettingViewController"];
        viewController.delegate = self;
        viewController.checkListIndex = self.checkListIndex;
        viewController.checkList = checkList;

        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        // 通常モードはRootViewを表示
        LLRootViewController *viewController = [storyBoard  instantiateViewControllerWithIdentifier:@"RootViewController"];
        viewController.checkListIndex = self.checkListIndex;
        viewController.checkList = checkList;
        viewController.singleViewMode = YES;

        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LSTR(@"BackButtonCaption")
                                                                                          style:UIBarButtonItemStylePlain
                                                                                         target:self action:@selector(backAction:)];

        LLTabBarController *tabBarController = [LLTabBarController new];
        tabBarController.title = checkList.caption;
        tabBarController.viewControllers = @[navController];

        // RootViewを表示
        [self.navigationController pushViewController:tabBarController animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];

        // 遷移先での変更有無に関わらず変更ありとしてチェックリストをリセットさせる
        self.changeCheckList = YES;
    }
}

// 通常モードはRootView用のBackBarButtonアクション
-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


// tableView:moveRowAtIndexPath:toIndexPath:を定義していないと呼ばれない
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // チェックリストの移動
    DEBUGLOG_IndexPath(sourceIndexPath);
    DEBUGLOG_IndexPath(destinationIndexPath);

    // セクションまたぎを考慮
    NSInteger showListCount = [self tableView:tableView numberOfRowsInSection:0];

    NSInteger sourceRow = 0;
    NSInteger destinationRow = 0;

    if (sourceIndexPath.section == destinationIndexPath.section) {
        // セクション移動なし
        sourceRow = ((sourceIndexPath.section == 0) ? 0 : showListCount) + sourceIndexPath.row;
        destinationRow = ((destinationIndexPath.section == 0) ? 0 : showListCount) + destinationIndexPath.row;
    } else if (sourceIndexPath.section == 1) {
        // 表示セクションに移動 ↑
        destinationRow = destinationIndexPath.row;
        sourceRow = showListCount + sourceIndexPath.row;
        showListCount++;
    } else {
        // 非表示セクションに移動 ↓
        showListCount--;
        sourceRow = sourceIndexPath.row;
        destinationRow = showListCount + destinationIndexPath.row;
    }


    if (sourceRow != destinationRow) {
        __strong LLCheckList *checkList = [LLCheckListManager sharedManager].arrayCheckLists[sourceRow];

        [[LLCheckListManager sharedManager].arrayCheckLists removeObjectAtIndex:sourceRow];
        [[LLCheckListManager sharedManager].arrayCheckLists insertObject:checkList atIndex:destinationRow];
        [[LLCheckListManager sharedManager] saveCheckLists];
    }
    [[NSUserDefaults standardUserDefaults] setInteger:MIN(MAX(showListCount, 1), SHOWLIST_MAX) forKey:SETTING_SHOWTABS];

    self.changeCheckList = YES;
}

#pragma mark - リストの追加
-(void)addAction:(id)sender
{
    // リストの追加 ***Pro版限定***
    // リスト数の上限を超えていなければ追加可能
    NSInteger checkListCount = [[LLCheckListManager sharedManager].arrayCheckLists count];
    if (checkListCount < MAX_CHECKLIST) {
        // チェックリストを新規追加
        NSIndexPath *indexPath;
        NSInteger showListCount = [self.tableView numberOfRowsInSection:0];
        if (showListCount < SHOWLIST_MAX) {
            // 表示リストの上限以内なら表示リストに追加する
            [[LLCheckListManager sharedManager].arrayCheckLists insertObject:[[LLCheckList alloc] initWithCheckItemsFileName]
                                                                     atIndex:showListCount];
            indexPath = [NSIndexPath indexPathForRow:showListCount inSection:0];
            [[NSUserDefaults standardUserDefaults] setInteger:MIN(MAX(++showListCount, 1), SHOWLIST_MAX) forKey:SETTING_SHOWTABS];
            self.changeCheckList = YES;
        } else {
            // その他に追加する
            [[LLCheckListManager sharedManager] addObject:[[LLCheckList alloc] initWithCheckItemsFileName]];
            indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:1] inSection:1];
        }
        [[LLCheckListManager sharedManager] saveCheckLists];

        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

        self.changeCheckList = YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // チェックリストを削除
        NSInteger showListCount = [self.tableView numberOfRowsInSection:0];
        NSInteger checkListIndex = ((indexPath.section == 0) ? 0 : showListCount) + indexPath.row;
        [[LLCheckListManager sharedManager] removeCheckList:checkListIndex];
        [[LLCheckListManager sharedManager] saveCheckLists];

        // 表示リストから削除した場合は表示リスト数を減算する
        if (indexPath.section == 0) {
            [[NSUserDefaults standardUserDefaults] setInteger:MIN(MAX(--showListCount, 1), SHOWLIST_MAX) forKey:SETTING_SHOWTABS];
            self.changeCheckList = YES;
        }

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}


-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // セル移動先の許可
    NSInteger showListCount = [self.tableView numberOfRowsInSection:0];
    if (sourceIndexPath.section == 1 && proposedDestinationIndexPath.section == 0) {
        // その他から表示リストに移動する場合は、表示リストの上限以下なら移動可能
        return (showListCount < SHOWLIST_MAX) ? proposedDestinationIndexPath : sourceIndexPath;
    } else if (sourceIndexPath.section == 0 && proposedDestinationIndexPath.section == 1) {
        // 表示リストからその他に移動する場合は、表示リストが０にならなければ移動可能（最後の１つだった場合は移動不可）
        return (showListCount > 1) ? proposedDestinationIndexPath : sourceIndexPath;
    } else {
        // 移動可
        return proposedDestinationIndexPath;
    }
}

#pragma mark - ELCheckListDetailViewDelegate
-(void)saveCheckListDetail:(LLCheckList *)checkList
{
    // 変更内容を保存
    [[LLCheckListManager sharedManager] replaceCheckList:self.checkListIndex withObject:checkList];
    [[LLCheckListManager sharedManager] saveCheckLists];

    // 変更内容を画面に反映
    [self.tableView reloadData];

    self.changeCheckList = YES;
}

@end
