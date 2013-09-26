//
//  ELCheckListDetailViewController+SectionTableView.m
//  EverList
//
//  Created by Yoshio Nose on 2013/08/28.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLCheckListDetailViewController.h"

#import "UITableView+Extension.h"

#import "LLCheckListManager.h"
#import "LLCheckList.h"
#import "LLCheckListSection.h"
#import "LLSectionCell.h"

static NSString *kCellIdentifier = @"Cell";

@implementation LLCheckListDetailViewController (SectionTableView)

-(void)setupSectionTableView
{
    self.sectionTableView.delegate = self;
    self.sectionTableView.dataSource = self;
    self.sectionTableView.editing = YES;

    // 再利用セルのクラスを登録(dequeueReusableCellWithIdentifierで使う)
    [self.sectionTableView registerNib:[UINib nibWithNibName:@"LLSectionCell" bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:kCellIdentifier];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.checkList.arraySections count] + 1;    // セクション数 + 追加ボタン
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:0];
    if (indexPath.row < rows - 1 && 1 < rows ) {
        // セルの作成（再利用）
        LLSectionCell *sectionCell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        sectionCell.delegate = self;
        sectionCell.checkListSection = (LLCheckListSection *)self.checkList.arraySections[indexPath.row];
        sectionCell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = sectionCell;
    } else {
        //追加ボタン
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = LSTR(@"AddSection");
    }
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self rowOfAddButtonCell]) {
        return UITableViewCellEditingStyleInsert;
    } else if (indexPath.row > 0) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 追加ボタン
    if (indexPath.row == [self rowOfAddButtonCell]) {
        [self.sectionTableView deselectSelectedRow:YES];
        [self addSection];
        [self performSelector:@selector(resizeTableView) withObject:nil afterDelay:0.4];  // 遅延実行
    }
}

// セクションを追加
-(void)addSection
{
    [self.checkList addSection];

    // 追加ボタンの上に新しいセクションを追加する
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self rowOfAddButtonCell] - 1 inSection:0];   DEBUGLOG_IndexPath(indexPath);

//    [self.sectionTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft
//                                 atScrollPosition:UITableViewScrollPositionNone animated:YES completion:^(BOOL finished) {
//                                     [self.sectionTableView scrollToRowAtIndexPath:indexPath
//                                                                  atScrollPosition:UITableViewScrollPositionNone animated:YES];
//
//                                     LLSectionCell *cell = (LLSectionCell *)[self.sectionTableView cellForRowAtIndexPath:indexPath];
//                                     [cell becomeFirstResponder];
//
//                                 }];
    // 追加行にスクロールしてカーソルをセット
    [self.sectionTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.sectionTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    LLSectionCell *cell = (LLSectionCell *)[self.sectionTableView cellForRowAtIndexPath:indexPath];
    [cell becomeFirstResponder];

}

// tableView:moveRowAtIndexPath:toIndexPath:を定義していないと呼ばれない
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 追加ボタンは移動不可
    if (indexPath.row < [self rowOfAddButtonCell]) {
        return YES;
    } else {
        return NO;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // セクションの移動
    [self.checkList moveSection:sourceIndexPath.row toSection:destinationIndexPath.row];

    [self.sectionTableView reloadVisibleRowsAfterDelay:0.5 withRowAnimation:UITableViewRowAnimationNone];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
        {
            LLCheckListSection *checkListSection = (LLCheckListSection *)self.checkList.arraySections[indexPath.row];

            // セクションのタイトルをクリア
            checkListSection.caption = nil;

            // ２番目以降のセクションの場合は１つ前のセクションにチェックアイテムを移動する
            if (indexPath.row > 0) {
                NSInteger fromSection = indexPath.row;
                NSInteger toSection = indexPath.row - 1;
                while (0 < [checkListSection.checkItems count]) {
                    NSInteger numberOfCheckItems = [((LLCheckListSection *)self.checkList.arraySections[toSection]).checkItems count];
                    [[LLCheckListManager sharedManager] moveCheckItem:[NSIndexPath indexPathForRow:0 inSection:fromSection]
                                                          toIndexPath:[NSIndexPath indexPathForRow:numberOfCheckItems inSection:toSection]
                                                          inCheckList:self.checkListIndex];
                }
                [self.checkList.arraySections removeObjectAtIndex:fromSection];
            }

            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
        }
        case UITableViewCellEditingStyleInsert:
            [self addSection];
        default:
            break;
    }

    [self performSelector:@selector(resizeTableView) withObject:nil afterDelay:0.4];  // 遅延実行
}

-(void)resizeTableView
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self resizeView];  // 遅延実行
                     }
                     completion:nil
     ];
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // セル移動先の許可
    // ただし追加ボタンの下には移動させない
    if (proposedDestinationIndexPath.row < [self rowOfAddButtonCell]) {
        return proposedDestinationIndexPath;
    } else {
        return [NSIndexPath indexPathForRow:[self tableView:tableView numberOfRowsInSection:0] - 2 inSection:0];
    }
}

// 追加ボタンセルの位置を返す
-(NSInteger)rowOfAddButtonCell
{
//    return [self.checkList.arraySections count];
    return [self tableView:self.sectionTableView numberOfRowsInSection:0] - 1;
}

-(void)sectionCellDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
}

//-(void)sectionCellShouldEndEditing:(UITextField *)textField
//{
//    NSInteger row = [self.checkList.arraySections indexOfObject:checkListSection];
//
//    [self.sectionTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
//                                 withRowAnimation:UITableViewRowAnimationNone];
//}

@end
