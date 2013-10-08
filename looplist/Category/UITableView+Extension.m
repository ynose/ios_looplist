//
//  UITableView+Extension.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/23.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "UITableView+Extension.h"

@implementation UITableView (Extension)


// 削除予定
// 行挿入とスクロール
//-(void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
//{
//    [UIView animateWithDuration:1 animations:^{
//        [self insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
//    } completion:^(BOOL finished) {
//        // 追加行にスクロール
//        [UIView animateWithDuration:0 animations:^{
//            [self scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:scrollPosition animated:animated];
//        } completion:completion];
//    }];
//}

-(void)deleteRowsAtIndexPaths:(NSArray *)indexPaths duration:(NSTimeInterval)duration withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration animations:^{
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } completion:completion];
}

// 選択行の選択解除
-(void)deselectSelectedRow:(BOOL)animated
{
    [self deselectRowAtIndexPath:[self indexPathForSelectedRow] animated:animated];
}
// 選択セルの選択解除
-(void)deselectCell:(UITableViewCell *)cell animated:(BOOL)animated
{
    [self deselectRowAtIndexPath:[self indexPathForCell:cell] animated:animated];
}

// 最終セクションの最終行にスクロール
-(void)scrollToEndRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    if ([self numberOfRowsInSection:0] > 0) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self numberOfRowsInSection:0] - 1 inSection:[self numberOfSections] - 1]
                    atScrollPosition:scrollPosition animated:animated];
    }
}


#pragma mark - 遅延実行
-(void)reloadDataAfterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:delay];
}

-(void)reloadVisibleRowsAfterDelay:(NSTimeInterval)delay withRowAnimation:(UITableViewRowAnimation)animation
{
    [self performSelector:@selector(_reloadVisibleRowsWithRowAnimation:) withObject:@(animation) afterDelay:delay];
}
-(void)_reloadVisibleRowsWithRowAnimation:(id)animation
{
    [self reloadRowsAtIndexPaths:[self indexPathsForVisibleRows] withRowAnimation:(UITableViewRowAnimation)animation];
}

@end
