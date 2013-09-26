//
//  LLRootViewController.m
//  looplist
//
//  Created by Yoshio Nose on 2013/09/24.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLRootViewController.h"
#import "Define.h"

#import "LLCheckListManager.h"
#import "LLCheckListSection.h"
#import "LLCheckList.h"

#import "LLCheckItemCell.h"
#import "LLRootFooterView.h"
#import "LLTabBarController.h"
#import "YNActionSheet.h"

#import "MSCellAccessory.h"
#import "SVProgressHUD.h"


static NSString *kCellIdentifier = @"Cell";

@interface LLRootViewController ()

@property (nonatomic, assign) NSInteger currentFilterIndex;
@property (nonatomic, assign) BOOL finishAction;

@property (strong, nonatomic) UIBarButtonItem *menuButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UISegmentedControl *filterSegmentedControl;
@property (strong, nonatomic) NSIndexPath *indexPathOfSelected;
@property (strong, nonatomic) NSIndexPath *editIndexPath;

@end

@implementation LLRootViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.currentFilterIndex = FILTER_ALL;

        // 長押しジェスチャーの作成
        if (_longPressRecognizer == nil) {
            _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(longPressCellAction:)];
            _longPressRecognizer.allowableMovement = 15;
            _longPressRecognizer.minimumPressDuration = LONGPRESS_DURATION;
        }

        if (_longPressEditRecognizer == nil) {
            _longPressEditRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(longPressCellEditAction:)];
            _longPressEditRecognizer.allowableMovement = 15;
            _longPressEditRecognizer.minimumPressDuration = LONGPRESS_DURATION;
        }
}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    // ナビゲーションバーの設定
    self.title = self.checkList.caption;
    self.navigationItem.rightBarButtonItem = [self editButtonItem];

    self.menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain
                                                      target:self.tabBarController
                                                      action:@selector(menuAction:)];
    self.navigationItem.leftBarButtonItem = self.menuButton;


    // 追加[+]ボタンの作成
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(addAction:)];


    // Tableiewの設定
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.rowHeight = 92;

    // 再利用セルのクラスを登録(dequeueReusableCellWithIdentifierで使う)
    [self.tableView registerNib:[UINib nibWithNibName:@"LLCheckItemCell" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kCellIdentifier];

    // ヘッダーの設定
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    self.filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[LSTR(@"AllList"), LSTR(@"UncheckedList")]];
    CGRect frame = self.filterSegmentedControl.frame;
    frame.size.width = headerView.frame.size.width - 44;
    self.filterSegmentedControl.frame = frame;
    self.filterSegmentedControl.center = headerView.center;
    self.filterSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.filterSegmentedControl setSelectedSegmentIndex:self.checkList.filterIndex];
    [self.filterSegmentedControl addTarget:self
                                    action:@selector(filterAction:)
                          forControlEvents:UIControlEventValueChanged];

    [headerView addSubview:self.filterSegmentedControl];
    self.tableView.tableHeaderView = headerView;
    // 初期はヘッダーが隠れるようにする
    self.tableView.contentOffset = CGPointMake(0, self.tableView.tableHeaderView.frame.size.height);


    // フッターの設定
    LLRootFooterView *footerView = [LLRootFooterView view];
    footerView.delegate = self;
    self.tableView.tableFooterView = footerView;

    // 通常時と編集時のジェスチャー入れ替え
    [self exchangeGestureRecognizer:self.editing];

    // 編集中アイテムの初期値を最終行にする
    self.editIndexPath = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 編集ボタン
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing == YES) {
        // 編集モード
        // 編集中アイテムの初期値を最終行にする
        self.editIndexPath = nil;
    } else {
        // 通常モード
        [[LLCheckListManager sharedManager] saveCheckLists];
        [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];
    }

    // フィルタの設定(編集モード時は並べ替えを考慮して「すべて」フィルタにして使用不可にする)
    if (editing == YES) {
        // 編集モード(「すべて」フィルタ)
        _currentFilterIndex = self.filterSegmentedControl.selectedSegmentIndex;
        if (_currentFilterIndex != FILTER_ALL) {
            [self.filterSegmentedControl setSelectedSegmentIndex:FILTER_ALL];
        }
        self.filterSegmentedControl.enabled = NO;
    } else {
        // 通常モード(元のフィルタに戻す)
        if (_currentFilterIndex != self.filterSegmentedControl.selectedSegmentIndex) {
            [self.filterSegmentedControl setSelectedSegmentIndex:_currentFilterIndex];
        }
        self.filterSegmentedControl.enabled = YES;
    }
    [self filterAction:self.filterSegmentedControl];


    // 編集モードの場合に新規追加ボタンを表示(アニメーション)
    [self.navigationItem setLeftBarButtonItem:(editing == YES) ? self.addButton : self.menuButton animated:animated];

    // フッタービューの編集モード
    [(LLRootFooterView *)self.tableView.tableFooterView setEditing:editing];

    // 通常時と編集時のジェスチャー入れ替え
    [self exchangeGestureRecognizer:editing];

}

// 通常時と編集時のジェスチャー入れ替え
-(void)exchangeGestureRecognizer:(BOOL)editing
{
    if (editing == YES) {
        [self.tableView removeGestureRecognizer:_longPressRecognizer];
        [self.tableView addGestureRecognizer:_longPressEditRecognizer];
        // ジェスチャーを登録すると編集時セル移動させたい時にもジェスチャーが起動するとタップ＆ホールドが解除されてしまい移動しづらい（今後の課題）
    } else {
        [self.tableView removeGestureRecognizer:_longPressEditRecognizer];
        [self.tableView addGestureRecognizer:_longPressRecognizer];
    }
}

#pragma mark セクション作成
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DEBUGLOG(@"%d", [self.checkList.arraySections count]);
    return [self.checkList.arraySections count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.checkList sectionAtIndex:section].caption;
}

#pragma mark セル作成
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.finishAction == YES) {
        return 0;
    } else {
        DEBUGLOG(@"numberOfRowsInSection(%d) = %d", section, [[self checkListSection:section].checkItems count]);
        return [[self checkListSection:section].checkItems count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kKVOCheckedDate = KVO_CHECKEDDATE;

    LLCheckItem *checkItem = [self checkItemAtIndexPath:indexPath];

    // セルの作成（再利用）
    LLCheckItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.sequenceNumber = [self.checkList sequenceOfCheckItem:checkItem];
    cell.checkItem = checkItem;
    cell.captionTextField.text = checkItem.caption;
    cell.checkedDate = nil;
    if (checkItem.hasDetail) {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DETAIL_BUTTON
                                                          color:UIColorMain];
    } else {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DETAIL_BUTTON
                                                          color:[UIColor colorWithRed:0.808 green:0.808 blue:0.808 alpha:1.000]];
    }


    // チェック項目にKVOの登録
    if (checkItem.keyValueObserver) {
        [checkItem removeObserver:checkItem.keyValueObserver forKeyPath:kKVOCheckedDate];
    }
    [checkItem addObserver:cell forKeyPath:kKVOCheckedDate options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                   context:nil];
    checkItem.keyValueObserver = cell;

    // KVOでチェック日時をセルに表示させる
    if (checkItem.checkedDate) {
        checkItem.checkedDate = checkItem.checkedDate;
    }
    return cell;
}

// 次の行のIndexPath
-(NSIndexPath *)indexPathOfNextRow:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (row < [[self.checkList sectionAtIndex:indexPath.section].checkItems count] - 1) {
        row++;  // 同じSectionの次のRow
    } else {
        if (section < [self.checkList.arraySections count] - 1) {
            section++;  // 次のSectionの先頭Row
            row = 0;
        }
    }

    return [NSIndexPath indexPathForRow:row inSection:section];
}

// 最終行のIndexPath
-(NSIndexPath *)indexPathOfEndRow
{
    for (NSInteger sectionIndex = [self.checkList.arraySections count] - 1; 0 <= sectionIndex; sectionIndex--) {
        LLCheckListSection *checkListSection = [self checkListSection:sectionIndex];
        NSInteger numberOfRows = [checkListSection.checkItems count];
        if (numberOfRows > 0) {
            return [NSIndexPath indexPathForRow:numberOfRows -1 inSection:sectionIndex];
        }
    }

    return nil;
}

// フィルタ状態に応じたセクション配列を返す
-(NSMutableArray *)checkListSections
{
    if (self.filterSegmentedControl.selectedSegmentIndex == FILTER_ALL) {
        return self.checkList.arraySections;
    } else {
        return self.checkList.arrayUncheckedSections;
    }
}

// フィルタ状態に応じたセクション配列から指定セクションを返す
-(LLCheckListSection *)checkListSection:(NSInteger)section
{
    return (LLCheckListSection *)[self checkListSections][section];
}

-(LLCheckItem *)checkItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (LLCheckItem *)[self checkListSection:indexPath.section].checkItems[indexPath.row];
}

-(NSIndexPath *)indexPathOfCheckItem:(LLCheckItem *)checkItem
{
    NSInteger section = 0;
    NSInteger row = NSNotFound;
    while (section < [self.checkList.arraySections count] && row == NSNotFound) {
        row = [[self.checkList sectionAtIndex:section].checkItems indexOfObject:checkItem];
        if (row == NSNotFound) {
            section++;
        }
    }
    return [NSIndexPath indexPathForRow:row inSection:section];
}


// スワイプでsetEditing:animated:が呼び出されないようにオーバーライドしておく
-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark セルの編集
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *KVOCheckedDate = KVO_CHECKEDDATE;

    // 削除
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // KVOを削除する
        // オブジェクトが削除されればKVOも消える？いらないかも？
        LLCheckItem *checkItem = [self checkItemAtIndexPath:indexPath];
        if (checkItem.keyValueObserver) {
            [checkItem removeObserver:checkItem.keyValueObserver forKeyPath:KVOCheckedDate];
        }
        checkItem.keyValueObserver = nil;

        // チェック項目の削除
        [[LLCheckListManager sharedManager] removeCheckItem:checkItem inCheckList:self.checkListIndex];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];

        // 編集中アイテムの初期値を最終行にする
        self.editIndexPath = nil;

        [self refreshTabBarItem];
    }

    // セルをリロードして行番号を更新する
    [tableView reloadVisibleRowsAfterDelay:0.5 withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark セルの移動
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // 配列を移動
    [[LLCheckListManager sharedManager] moveCheckItem:sourceIndexPath toIndexPath:destinationIndexPath inCheckList:self.checkListIndex];

    // セルをリロードして行番号を更新する
    [tableView reloadVisibleRowsAfterDelay:0.5 withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - セル選択 チェックON
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        // 編集モード
        [tableView deselectSelectedRow:YES];
    } else {
        // 通常モード
        // チェックON
        LLCheckItem *checkItem = [self checkItemAtIndexPath:indexPath];

        if (!checkItem.checkedDate) {
            checkItem.checkedDate = [NSDate date]; // KVOでセルの日時が更新される
            [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];
        }

        // 選択解除
        [tableView deselectSelectedRow:YES];

        if (self.checkList.filterIndex == FILTER_ALL) {
            // 次のセルにスクロールする
            if (![indexPath isEqual:[self indexPathOfEndRow]]) {
                [tableView scrollToRowAtIndexPath:[self indexPathOfNextRow:indexPath]
                                 atScrollPosition:UITableViewScrollPositionNone animated:YES];
            } else {
                // 最終行の場合はフッターが見えるようにスクロールする
                [tableView scrollToRowAtIndexPath:[self indexPathOfEndRow]
                                 atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        } else {
            // 変更結果をフィルタ配列に反映して行を削除する
            [self performSelector:@selector(rowDeleteAction:) withObject:@[indexPath] afterDelay:0.2];  // 遅延実行
        }

        // タブバッチの更新
        [self refreshTabBarItem];
    }
}

// 未チェックフィルタ時のチェックON行削除
-(void)rowDeleteAction:(NSArray *)indexPaths
{
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}


#pragma mark セルの長押しジェスチャ(通常モード用) チェックOFF
-(void)longPressCellAction:(UILongPressGestureRecognizer *)gestureRecognizer
{
    // 長押しをしたセルを特定する
    CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    NSIndexPath *gestureIndexPath = [tableView indexPathForRowAtPoint:gesturePoint];

    if (gestureIndexPath && gestureRecognizer.state == UIGestureRecognizerStateBegan) {

        // ジェスチャー元の選択が解除されているので、もう一度選択状態にする
        // 長押し中は選択状態を維持するために必要
        [tableView selectRowAtIndexPath:gestureIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

        // チェックOFF
        LLCheckItem *checkItem = [self checkItemAtIndexPath:gestureIndexPath];

        checkItem.checkedDate = nil;    // KVOでセルの日時が更新される
        [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];

        // タブバッチの更新
        [self refreshTabBarItem];

    } else if (gestureIndexPath && (gestureRecognizer.state == UIGestureRecognizerStateChanged ||
                                    gestureRecognizer.state == UIGestureRecognizerStateEnded)) {
        // 長押しをやめたらジェスチャー元の選択をアニメーション解除する
        // 長押し中は選択状態を維持するために必要
        [tableView deselectRowAtIndexPath:gestureIndexPath animated:NO];
    }
}

#pragma mark セルの長押しジェスチャ(編集モード用)
-(void)longPressCellEditAction:(UILongPressGestureRecognizer *)gestureRecognizer
{
    // 長押しをしたセルを特定する
    CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    NSIndexPath *gestureIndexPath = [tableView indexPathForRowAtPoint:gesturePoint];

    if (gestureIndexPath && gestureRecognizer.state == UIGestureRecognizerStateBegan) {

        // ジェスチャー元の選択が解除されているので、もう一度選択状態にして強調する
        [tableView selectRowAtIndexPath:gestureIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

        // 編集モードのアクションシートを表示
        YNActionSheet *actionSheet = [YNActionSheet new];

        // コピーボタン
        [actionSheet addButtonWithTitle:LSTR(@"actionCopy") withBlock:^(NSInteger buttonIndex) {
            // コピーしたチェック項目を挿入
            [self copyCheckItem:gestureIndexPath];
            // バッジ更新
            [self refreshTabBarItem];
        }];


        // キャンセルボタン
        // iPadではキャンセルボタンは表示されないがイベントは発生する
        [actionSheet addButtonWithTitle:LSTR(@"actionCancel") withBlock:nil];
        actionSheet.cancelButtonIndex =  [actionSheet numberOfButtons] - 1;

        actionSheet.didDismissBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            [tableView deselectSelectedRow:YES];
        };


        if (DEVICE_IPAD) {
            // iPadは選択したテンプレートリストの位置に表示する
            [actionSheet showFromTableViewSelectedRow:tableView animated:YES];
        } else {
            // TabBarが表示されているとCancelボタンがTabBarにかぶって押せなくなるためTabBarから表示が必要
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        }
        
    }
}


#pragma mark チェック項目のコピー
-(void)copyCheckItem:(NSIndexPath *)sourceIndexPath
{
    // コピーしたチェック項目を挿入
    LLCheckItem *newCheckItem = [[self checkItemAtIndexPath:sourceIndexPath] copy];
    [newCheckItem complete];    // チェック項目をリセット
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sourceIndexPath.row + 1 inSection:sourceIndexPath.section];


    [[LLCheckListManager sharedManager] insertCheckItem:newCheckItem
                                            atIndexPath:indexPath
                                            inCheckList:self.checkListIndex];
    [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];


//    [self.tableView insertRowsAtIndexPaths:@[indexPath]
//                          withRowAnimation:UITableViewRowAnimationLeft atScrollPosition:UITableViewScrollPositionNone animated:YES
//                                completion:^(BOOL finished) {
//                                    // セルをリロードして行番号を更新する
//                                    [self.tableView reloadVisibleRowsAfterDelay:0.5 withRowAnimation:UITableViewRowAnimationNone];
//                                }];
    // 追加行にスクロールしてカーソルをセット
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    [self.tableView reloadVisibleRowsAfterDelay:0.5 withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - ELRootFooterViewDelegate
#pragma mark チェック完了
-(void)completeCheckList:(UIControl *)sender
{
    // 全行削除
    [self performSelector:@selector(deleteCheckListRows:) withObject:sender afterDelay:0.1];  // 遅延実行
}

-(void)deleteCheckListRows:(id)sender
{
    // 全行削除アニメーション
    _finishAction = YES;
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
        for (NSInteger row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    NSTimeInterval delay = 0.8;
    if ([indexPaths count] > 0) {   // 表示されている行が残っている場合は行削除の時間を考慮して少し長くする
        delay = 1.3;
    }

    [self.tableView deleteRowsAtIndexPaths:indexPaths duration:0.4 withRowAnimation:UITableViewRowAnimationTop
                                completion:^(BOOL finished) {
                                    // チェック完了処理
                                    [[LLCheckListManager sharedManager] completeCheckList:self.checkListIndex];
                                    [[LLCheckListManager sharedManager] saveCheckLists];
                                    [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];

                                    // 次回のチェックリストを表示する
                                    [self performSelector:@selector(setupNewCheckList:) withObject:sender afterDelay:delay];  // 遅延実行 0.3がベスト
                                }];

    //    [SVProgressHUD showSuccessWithStatus:LSTR(@"CheckComplete")];
    [SVProgressHUD showSuccessWithStatus:nil];
}

-(void)setupNewCheckList:(id)sender
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
        for (NSInteger row = 0; row < [[self.checkList sectionAtIndex:section].checkItems count]; row++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }

    // 全行挿入
    _finishAction = NO;
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];

    //    self.tableView.contentOffset = CGPointMake(0, self.tableView.tableHeaderView.frame.size.height);

//    // チェック完了スイッチをOffに戻す
//    [((UISwitch *)sender) setOn:NO animated:YES];

    // バッジ更新
    [self refreshTabBarItem];
}

#pragma mark チェックリスト詳細ボタン
-(void)checklistDetailButtonTouchUp:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *navigationController = [storyBoard instantiateViewControllerWithIdentifier:@"CheckListDetailViewController"];
    LLCheckListDetailViewController *viewController = (LLCheckListDetailViewController *)navigationController.topViewController;
    viewController.delegate = self;
    viewController.checkListDetailDelegate = (LLTabBarController *)self.tabBarController;
    viewController.checkListIndex = self.checkListIndex;
    viewController.checkList = self.checkList;
    viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - ELCheckListDetailViewDelegate
#pragma mark チェックリスト詳細完了ボタン
-(void)saveCheckListDetail:(LLCheckList *)checkList
{
    // 変更内容を保存
    self.checkList = checkList;
    [[LLCheckListManager sharedManager] replaceCheckList:self.checkListIndex withObject:checkList];
    [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];
    [[LLCheckListManager sharedManager] saveCheckLists];

    // 変更内容を画面に反映
    self.title = self.checkList.caption;
    [self.tableView reloadData];

    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - チェックアイテム詳細ビューを表示
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    LLCheckItemDetailViewController *detailViewController = [storyBoard instantiateViewControllerWithIdentifier:@"CheckItemDetailViewController"];

    // 選択したIndexPathを保持(saveDetail:で使用するため)
    self.indexPathOfSelected = indexPath;
    LLCheckItem *checkItem = [self checkItemAtIndexPath:indexPath];

    detailViewController.delegate = self;
    detailViewController.checkItem = checkItem;
    detailViewController.sequenceNumber = [self.checkList sequenceOfCheckItem:checkItem];

    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)saveDetail:(LLCheckItem *)checkItem
{
    // 選択していたIndexPathから置換元のチェックアイテムを取得
    LLCheckItem *beforeCheckItem = [self checkItemAtIndexPath:self.indexPathOfSelected];
    // 未フィルタ配列から置換元アイテムの位置を取得
    NSInteger row = [[self.checkList sectionAtIndex:self.indexPathOfSelected.section].checkItems indexOfObject:beforeCheckItem];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:self.indexPathOfSelected.section];

    [[LLCheckListManager sharedManager] replaceCheckItem:checkItem atIndexPath:indexPath inCheckList:self.checkListIndex];
    [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];

    // 変更内容をリストに反映する
    [self.tableView reloadRowsAtIndexPaths:@[self.indexPathOfSelected] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - チェック項目の追加
-(void)addAction:(id)sender
{
    // 新規チェック項目を追加
    LLCheckItem *checkItem = [LLCheckItem new];
    NSInteger section;
    if (self.editIndexPath) {
        section = self.editIndexPath.section;
    } else {
        section = [self indexPathOfEndRow].section;
    }

    NSIndexPath *indexPath = [[LLCheckListManager sharedManager] addCheckItem:checkItem section:section
                                                                  inCheckList:self.checkListIndex];
    DEBUGLOG_IndexPath(indexPath);

    // 次の行に挿入
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft
//                          atScrollPosition:UITableViewScrollPositionNone animated:YES completion:^(BOOL finished) {
//                              // カーソルをセット
//                              [self performSelector:@selector(setCheckItemCellBecomeFirstResponder:) withObject:indexPath afterDelay:0.3];  // 遅延実行 0.3がベスト
//                          }];
    // 追加行にスクロールしてカーソルをセット
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    [self setCheckItemCellBecomeFirstResponder:indexPath];


    // バッジ更新
    [self refreshTabBarItem];
}


// セルのTextFieldにカーソルをセット
-(void)setCheckItemCellBecomeFirstResponder:(id)sender
{
    NSIndexPath *indexPath;
    if ([sender isKindOfClass:[NSIndexPath class]]) {
        indexPath = (NSIndexPath *)sender;
    } else {
        indexPath = [self indexPathOfEndRow];
    }
    DEBUGLOG_IndexPath(indexPath);

    // スクロールしてカーソルをセット
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionNone animated:YES];

    LLCheckItemCell *cell = (LLCheckItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell becomeFirstResponder];
}


#pragma mark - ELCheckItemCellDelegate
-(void)checkItemCellShouldBeginEditing:(LLCheckItem *)checkItem
{
    // アクティブ行を保持
    self.editIndexPath = [self indexPathOfCheckItem:checkItem];   DEBUGLOG_IndexPath(self.editIndexPath);
}

-(void)checkItemCellShouldReturn:(LLCheckItem *)checkItem
{
    NSIndexPath *indexPath = [self indexPathOfCheckItem:checkItem]; DEBUGLOG_IndexPath(indexPath);
    if ([indexPath isEqual:[self indexPathOfEndRow]]) {
        // 最終行の場合はチェック項目を新規追加
        [self addAction:nil];
    } else {
        // 次の行へ移動
        [self setCheckItemCellBecomeFirstResponder:[self indexPathOfNextRow:indexPath]];
    }
}

#pragma mark - タブバッチの更新
-(void)refreshTabBarItem
{
    // タイトルを表示
    self.navigationController.tabBarItem.title = self.checkList.caption;
    self.title = self.checkList.caption;

    // 未チェック数をバッジに表示
    NSInteger unchecked = [self.checkList.arrayUncheckedItems count];
    self.navigationController.tabBarItem.badgeValue = (unchecked > 0) ? [@(unchecked) stringValue] : nil;
}


#pragma mark - フィルター
-(void)filterAction:(UISegmentedControl *)segmentedControl
{
    if (self.checkList.filterIndex == segmentedControl.selectedSegmentIndex) {
        return; // 同じ選択は無視する
    }
    self.checkList.filterIndex = segmentedControl.selectedSegmentIndex;

    // チェック済みアイテムを画面上から非表示(削除)/表示(追加)するためのインデックスの配列を作る
    NSMutableArray *rowsArray = [NSMutableArray array];
    for (LLCheckItem *checkItem in self.checkList.arrayCheckedItems) {
        for (NSInteger section = 0; section < [self.checkList.arraySections count]; section++) {
            NSInteger row = [[self.checkList sectionAtIndex:section].checkItems indexOfObject:checkItem];
            if (row != NSNotFound) {
                [rowsArray addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                DEBUGLOG_IndexPath(((NSIndexPath *)[rowsArray lastObject]));
                break;
            }
        }
    }

    // チェック済みアイテムの表示・非表示を切り替える
    if (segmentedControl.selectedSegmentIndex == FILTER_ALL) {
        [self.tableView insertRowsAtIndexPaths:rowsArray withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [self.tableView deleteRowsAtIndexPaths:rowsArray withRowAnimation:UITableViewRowAnimationTop];
    }
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
