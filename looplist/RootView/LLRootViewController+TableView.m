//
//  LLRootViewController+TableView.m
//  looplist
//
//  Created by Yoshio Nose on 2013/10/03.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLRootViewController.h"

#import "LLCheckListManager.h"

#import "MSCellAccessory.h"

static CGFloat kSectionHeight = 24;

@implementation LLRootViewController (TableView)


#pragma mark セクション作成
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#ifndef LAUNCH_SCREENSHOT    // 起動画像スクリーンショット撮影
    DEBUGLOG(@"%d", [self.checkList.arraySections count]);
    return [self.checkList.arraySections count];
#else
    return 0;
#endif
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kSectionHeight)];
    [view setBackgroundColor:UIColorSectionBackground];

    UILabel *label = [UILabel new];
    label.textColor = UIColorSectionText;
    label.text = [self.checkList sectionAtIndex:section].caption;
    label.font = [UIFont systemFontOfSize:14];
    [label sizeToFit];
    label.center = view.center;
    CGRect frame = label.frame;
    frame.origin.x = 4;
    label.frame = frame;

    [view addSubview:label];

    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.checkList.arraySections count] >= 2) {
        // 複数グループある場合はグループ名が未入力でもすべて表示する
        return kSectionHeight;
    } else {
        // グループが１つの場合はグループ名が未入力なら表示しない
        if ([[self.checkList sectionAtIndex:section].caption length] == 0) {
            return 0;
        } else {
            return kSectionHeight;
        }
    }
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

    // 予約されたセルにカーソルをセットする
    if ([indexPath compare:self.indexPathOfNeedFirstResponder] == NSOrderedSame) {
        [cell becomeFirstResponder];
    }

    return cell;
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

    // セル削除
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // KVOを削除する
        // オブジェクトが削除されればKVOも消える？いらないかも？
        LLCheckItem *checkItem = [self checkItemAtIndexPath:indexPath];
        if (checkItem.keyValueObserver) {
            [checkItem removeObserver:checkItem.keyValueObserver forKeyPath:KVOCheckedDate];
        }
        checkItem.keyValueObserver = nil;

        // キーボードをしまう
        [self.view endEditing:YES];

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

#pragma mark セル選択 チェックON
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
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

// Enterキーで次のセルに移動する場合も反応してしまうため一旦保留
//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (self.editing) {
//        _scrollBeginingPoint = [scrollView contentOffset];
//    }
//}
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (self.editing) {
//        CGPoint currentPoint = [scrollView contentOffset];
//        if (abs(currentPoint.y - _scrollBeginingPoint.y) > 90) {
//            [self.view endEditing:YES];
//        }
//    }
//}

@end
