//
//  LLRootViewController+TableView.m
//  looplist
//
//  Created by Yoshio Nose on 2013/10/03.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLRootViewController.h"

#import "LLTabBarController.h"
#import "LLCheckListManager.h"

static CGFloat kSectionHeight = 24;

@implementation LLRootViewController (TableView)


#pragma mark セクション作成
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#ifndef LAUNCH_SCREENSHOT    // 起動画像スクリーンショット撮影
    DEBUGLOG(@"%ld", [self.checkList.arraySections count]);
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
        return [[self checkListSection:section].checkItems count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *kKVOCheckedDate = KVO_CHECKEDDATE;

    LLCheckItem *checkItem = [self checkItemAtIndexPath:indexPath];

    // セルの作成
    LLCheckItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.sequenceNumber = [self.checkList sequenceOfCheckItem:checkItem];
    cell.checkItem = checkItem;
    cell.captionTextField.text = checkItem.caption;
    cell.checkedDate = checkItem.checkedDate;
    cell.attachImageView.image = [[LLCheckListManager sharedManager] loadAttachImage:checkItem.identifier];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.tintColor = (checkItem.hasDetail || [[LLCheckListManager sharedManager] existsAttachImageFile:checkItem.identifier] != nil) ? UIColorMain : UIColoeHasDetail;

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
    // セル削除
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // キーボードをしまう
        [self.view endEditing:YES];

        // チェック項目の削除
        LLCheckItem *checkItem = [self checkItemAtIndexPath:indexPath];
        [[LLCheckListManager sharedManager] removeAttachImageFile:checkItem.identifier];
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
            checkItem.checkedDate = [NSDate date];
            [[LLCheckListManager sharedManager] saveCheckItemsInCheckList:self.checkListIndex];

            LLCheckItemCell *cell = (LLCheckItemCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.checkedDate = checkItem.checkedDate;
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

    // 画像の読み込み
    UIImage *image = [[LLCheckListManager sharedManager] loadAttachImage:checkItem.identifier];
    detailViewController.attachImage = image;


//#ifdef APPSTORE_SCREENSHOT
//    LLTabBarController *tabBarController = (LLTabBarController *)self.tabBarController;
//    tabBarController.dummyAdView.hidden = YES;
//#else
//    //    tabBarController.nadView.hidden = YES;
//#endif
    [self.navigationController pushViewController:detailViewController animated:YES];

//    // 広告の一時停止
//    LLTabBarController *tabBarController = (LLTabBarController *)self.tabBarController;
//    tabBarController.nadView.hidden = YES;
//    [tabBarController.nadView pause];
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
