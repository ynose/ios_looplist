//
//  LLRootViewController.m
//  looplist
//
//  Created by Yoshio Nose on 2013/09/24.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLRootViewController.h"

#import "LLCheckListManager.h"
#import "LLCheckListSection.h"
#import "LLCheckList.h"

#import "LLCheckItemCell.h"
#import "LLTabBarController.h"
#import "YNActionSheet.h"
#import "UIView+KeyboardNotification.h"

#import "ProductManager.h"

#import "NADInterstitial.h"
#import "SVProgressHUD.h"


@interface LLRootViewController ()

@property (nonatomic, assign) NSInteger currentFilterIndex;

@property (strong, nonatomic) UIBarButtonItem *appSettingButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UISegmentedControl *filterSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@end

@implementation LLRootViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.currentFilterIndex = FILTER_ALL;
        self.singleViewMode = NO;
        self.tabBarItem.image = [UIImage imageNamed:@"tabbar-icon"];

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
    // 編集ボタンの作成
#ifndef LAUNCH_SCREENSHOT    // 起動画像スクリーンショット撮影の場合は表示しない
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
#endif

    // 設定ボタンの作成
#ifndef LAUNCH_SCREENSHOT    // 起動画像スクリーンショット撮影の場合は表示しない
    self.appSettingButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"settings-button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain
                                                            target:self.tabBarController
                                                      action:@selector(settingAppAction)];

    if (self.singleViewMode) {
        self.navigationItem.leftBarButtonItem = self.navigationController.navigationItem.backBarButtonItem;
    } else {
        self.navigationItem.leftBarButtonItem = self.appSettingButton;
    }
#endif

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
#ifdef LAUNCH_SCREENSHOT    // 起動画像スクリーンショット撮影
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
#endif

    // ヘッダーの設定
#ifndef LAUNCH_SCREENSHOT    // 起動画像スクリーンショット撮影の場合は表示しない
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    self.filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[LSTR(@"AllList"), LSTR(@"UncheckedList")]];
    CGRect frame = self.filterSegmentedControl.frame;
    frame.size.width = 280;
    self.filterSegmentedControl.frame = frame;
    self.filterSegmentedControl.center = headerView.center;
    self.filterSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.filterSegmentedControl setSelectedSegmentIndex:self.checkList.filterIndex];
    [self.filterSegmentedControl addTarget:self
                                    action:@selector(filterAction:)
                          forControlEvents:UIControlEventValueChanged];

    [headerView addSubview:self.filterSegmentedControl];
    self.tableView.tableHeaderView = headerView;
//    // 初期はヘッダーが隠れるようにする
//    self.tableView.contentOffset = CGPointMake(0, self.tableView.tableHeaderView.frame.size.height);
#endif


    // フッターの設定
#ifndef LAUNCH_SCREENSHOT    // 起動画像スクリーンショット撮影の場合は表示しない
    self.tableView.tableFooterView = self.footerView;
    self.completeButton.layer.cornerRadius = 4.0;
    self.completeButton.layer.backgroundColor = [UIColorMain CGColor];
#endif

    // 通常時と編集時のジェスチャー入れ替え
    [self exchangeGestureRecognizer:self.editing];

    // 編集中アイテムの初期値を最終行にする
    self.editIndexPath = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Pro版のみタブバーを表示する
//    LLTabBarController *tabBarController = (LLTabBarController *)self.tabBarController;
//    tabBarController.tabBar.hidden = ([ProductManager isAppPro]) ? NO : YES;
//    tabBarController.nadView.hidden = ([ProductManager isAppPro]) ? YES : NO;
//    tabBarController.tabBar.hidden = NO;
//    tabBarController.nadView.hidden = NO;


    // タブバッチの更新(moreViewControllerでの編集に反映させるためviewWillAppearで行う)
    [self refreshTabBarItem];

    // キーボード表示の通知設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasUnshown:)
                                                 name:UIKeyboardDidHideNotification object:nil];

    // アプリアクティブ時の通知設定
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil queue:nil usingBlock:^(NSNotification *note) {
                                                          // チェック日時や文字サイズを更新する
                                                          [self.tableView reloadVisibleRowsAfterDelay:0 withRowAnimation:UITableViewRowAnimationNone];
                                                      }];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

//    // Pro版のみタブバーを表示する
//    LLTabBarController *tabBarController = (LLTabBarController *)self.tabBarController;
//    tabBarController.nadView.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 選択されたチェックリスト（タブ）を保存
    [[NSUserDefaults standardUserDefaults] setInteger:self.checkListIndex forKey:SETTING_ACTIVETAB];

//    // 広告の再開
//    LLTabBarController *tabBarController = (LLTabBarController *)self.tabBarController;
//    tabBarController.nadView.hidden = NO;
//    [tabBarController.nadView resume];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // キーボード表示の通知解除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    // アプリアクティブ時の通知解除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
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
        // データ保存
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
    if (self.singleViewMode) {
        [self.navigationItem setLeftBarButtonItem:(editing) ? self.addButton : self.navigationController.navigationItem.backBarButtonItem
                                         animated:animated];
    } else {
        [self.navigationItem setLeftBarButtonItem:(editing) ? self.addButton : self.appSettingButton
                                         animated:animated];
    }

    // 通常モードに戻るときはキーボードをしまう
    if (!editing) {
        [self.view endEditing:YES];
    }

    // フッタービューの編集モード
    // 完了スイッチの有効無効を切り替える
    self.completeButton.enabled = !editing;
    self.completeButton.layer.backgroundColor = (self.editing) ? [UIColorMainDisable CGColor] : [UIColorMain CGColor];

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

// 次の行のIndexPath
-(NSIndexPath *)indexPathOfNextRow:(NSIndexPath *)indexPath
{
    NSIndexPath *nextIndexPath = nil;

    if (indexPath.row < [[self.checkList sectionAtIndex:indexPath.section].checkItems count] - 1) {
        // 同じSectionに次のRowがある場合は
        nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1      // 次のRowを返す
                                           inSection:indexPath.section];    // 同じSection
        DEBUGLOG_IndexPath(nextIndexPath);
    } else {
        // 同じSectionに次のRowがない場合は
        // 次以降のSectionのうち、Rowを持っているのSectionを探す（SectionにRowがまったく無い場合もある）
        for (NSInteger i = indexPath.section + 1; i <= [self.checkList.arraySections count] - 1; i++) {
            if (0 < [[self.checkList sectionAtIndex:i].checkItems count]) {
                nextIndexPath = [NSIndexPath indexPathForRow:0      // 先頭のRowを返す
                                                   inSection:i];    // 見つかったSection
                DEBUGLOG_IndexPath(nextIndexPath);
                break;
            }
        }
    }

    return nextIndexPath;
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

        LLCheckItemCell *cell = (LLCheckItemCell *)[tableView cellForRowAtIndexPath:gestureIndexPath];
        cell.checkedDate = checkItem.checkedDate;

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


    // 追加行にスクロールしてカーソルをセット
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    [self.tableView reloadVisibleRowsAfterDelay:0.5 withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - ELRootFooterViewDelegate
#pragma mark チェック完了
- (IBAction)completeTouchUp:(id)sender
{
    // アクションシートでチェック完了を確認
    YNActionSheet *actionSheet = [YNActionSheet new];

    // 完了ボタン
    [actionSheet addButtonWithTitle:LSTR(@"actionCheckComplete") withBlock:^(NSInteger buttonIndex) {
        // 全行削除
        [self performSelector:@selector(completeAllChecks:) withObject:sender afterDelay:0.1];  // 遅延実行
    }];

    // キャンセルボタン
    // iPadではキャンセルボタンは表示されないがイベントは発生する
    [actionSheet addButtonWithTitle:LSTR(@"actionCancel") withBlock:nil];
    actionSheet.cancelButtonIndex =  [actionSheet numberOfButtons] - 1;


    // TabBarが表示されているとCancelボタンがTabBarにかぶって押せなくなるためTabBarから表示が必要
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

// チェック完了時の全行削除とデータ保存
-(void)completeAllChecks:(id)sender
{
    // 全行削除アニメーションの準備
    self.finishAction = YES;
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

    // 全行削除とチェック完了処理
    [self.tableView deleteRowsAtIndexPaths:indexPaths duration:0.4 withRowAnimation:UITableViewRowAnimationFade
                                completion:^(BOOL finished) {
                                    // チェック完了処理
                                    [[LLCheckListManager sharedManager] completeCheckList:self.checkListIndex];
                                    [[LLCheckListManager sharedManager] saveCheckLists];
                                    [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];

                                    // 次回のチェックリストを表示する
                                    [self performSelector:@selector(setupNewCheckList:) withObject:sender afterDelay:delay];  // 遅延実行 0.3がベスト
                                }];

    [SVProgressHUD showSuccessWithStatus:nil];

    /* GoogleAnalytics API */
    [YNGAITracker trackActionButton:@"Complete" label:@"CheckItems" value:@(self.checkList.numberOfAllCheckItems)];
}

// チェック完了時の全行再作成
-(void)setupNewCheckList:(id)sender
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
        for (NSInteger row = 0; row < [[self.checkList sectionAtIndex:section].checkItems count]; row++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }

    // 全行挿入
    self.finishAction = NO;
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];


    // バッジ更新
    [self refreshTabBarItem];

    // インタースティシャル広告表jい
    [self interstitialAdShow];
}

-(void)interstitialAdShow
{
    NADInterstitialShowResult result = [[NADInterstitial sharedInstance] showAd];
    switch ( result ){
    case AD_SHOW_SUCCESS:
        DEBUGLOG(@"広告の表示に成功しました。");
        break;
    case AD_SHOW_ALREADY:
        DEBUGLOG(@"既に広告が表示されています。");
        break;
    case AD_FREQUENCY_NOT_REACHABLE:
        DEBUGLOG(@"広告のフリークエンシーカウントに達していません。");
        break;
    case AD_LOAD_INCOMPLETE:
        DEBUGLOG(@"抽選リクエストが実行されていない、もしくは実行中です。");
        break;
    case AD_REQUEST_INCOMPLETE:
        DEBUGLOG(@"抽選リクエストに失敗しています。");
        break;
    case AD_DOWNLOAD_INCOMPLETE:
        DEBUGLOG(@"広告のダウンロードが完了していません。");
        break;
    }
}

#pragma mark - LLDetailViewDelegate
-(void)saveDetail:(LLCheckItem *)checkItem attachImage:(UIImage *)image
{
    // 選択していたIndexPathから置換元のチェックアイテムを取得
    LLCheckItem *beforeCheckItem = [self checkItemAtIndexPath:self.indexPathOfSelected];
    // 未フィルタ配列から置換元アイテムの位置を取得
    NSInteger row = [[self.checkList sectionAtIndex:self.indexPathOfSelected.section].checkItems indexOfObject:beforeCheckItem];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:self.indexPathOfSelected.section];

    [[LLCheckListManager sharedManager] replaceCheckItem:checkItem atIndexPath:indexPath inCheckList:self.checkListIndex];
    [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];

    // 画像の保存
    if (image) {
        [[LLCheckListManager sharedManager] saveAttachImage:image fileName:checkItem.identifier];
    } else {
        [[LLCheckListManager sharedManager] removeAttachImageFile:checkItem.identifier];
    }

    // 変更内容をリストに反映する
    [self.tableView reloadRowsAtIndexPaths:@[self.indexPathOfSelected] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - チェック項目の追加
-(void)addAction:(id)sender
{
    // 新規チェック項目を追加
    LLCheckItem *checkItem = [LLCheckItem new];

    // セルにカーソルがある場合はそのセルと同じセクションに追加する
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
    // 追加行にスクロールしてカーソルをセット
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
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
    if (cell) {
        [cell becomeFirstResponder];
    } else {
        // 画面の外にあるとnilになってしまい、カーソルがセットされないので
        // セル生成時のカーソルをセットするように予約する
        self.indexPathOfNeedFirstResponder = indexPath;
    }
}


#pragma mark - ELCheckItemCellDelegate
-(void)checkItemCellShouldBeginEditing:(LLCheckItem *)checkItem
{
    // アクティブ行を保持
    self.editIndexPath = [self indexPathOfCheckItem:checkItem];   DEBUGLOG_IndexPath(self.editIndexPath);

    self.indexPathOfNeedFirstResponder = nil;
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
    self.title = self.checkList.caption;
//    self.title = ([ProductManager isAppPro]) ? self.checkList.caption : @"Looplist";

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
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.checkList.filterIndex = kFilterAll;
    } else {
        self.checkList.filterIndex = kFilterUnchecked;
    }

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
        [self.tableView insertRowsAtIndexPaths:rowsArray withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView deleteRowsAtIndexPaths:rowsArray withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Keyboard Notification
// キーボードが表示された時
-(void)keyboardWasShown:(NSNotification *)notification
{
    CGRect keyboardRect;
    NSTimeInterval animationDuration;

    // スクロールインジケーターの調整
    [self.view keyboardNotification:notification getKeyboardRect:&keyboardRect getAnimationDuration:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        UIScrollView *scrollView = (UIScrollView *)self.view;
        UIEdgeInsets insets = scrollView.contentInset;
        insets.bottom = keyboardRect.size.height;
        scrollView.scrollIndicatorInsets = insets;
    }];
}

// キーボードが消された時
-(void)keyboardWasUnshown:(NSNotification *)notification
{
    CGRect keyboardRect;
    NSTimeInterval animationDuration;

    // スクロールインジケーターの調整
    [self.view keyboardNotification:notification getKeyboardRect:&keyboardRect getAnimationDuration:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        UIScrollView *scrollView = (UIScrollView *)self.view;
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
    }];
}

@end
