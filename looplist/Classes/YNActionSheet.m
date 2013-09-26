//
//  YNActionSheet.m
//  TapMailer
//
//  Created by Yoshio Nose on 2012/11/12.
//
//

#import "YNActionSheet.h"

@implementation YNActionSheet

-(id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        _blocks = [NSMutableArray array];
    }

    return self;
}

-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)firstOtherTitle,...
{
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        self.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        int index = 0;
        
        if (destructiveButtonTitle) {
            [self addButtonWithTitle:destructiveButtonTitle];
            self.destructiveButtonIndex = index;
            index++;
        }
        
        if (firstOtherTitle) {
            [self addButtonWithTitle:firstOtherTitle];
            index++;
            
            va_list args;
            va_start(args, firstOtherTitle);
            NSString* title;
            while ((title = va_arg(args, NSString*))) {
                [self addButtonWithTitle:title];
                index++;
            }
            va_end(args);
        }
        
        [self addButtonWithTitle:cancelButtonTitle];
        self.cancelButtonIndex = index;
    }
    return self;
}

#pragma mark - block付きボタン作成
-(NSInteger)addButtonWithTitle:(NSString *)title withBlock:(void (^)(NSInteger buttonIndex))block
{
    if (block) {
        [_blocks addObject:block];
    } else {
        [_blocks addObject:^(NSInteger buttonIndex){}];
    }

    return [super addButtonWithTitle:title];
}

// iPad向けTableViewの選択行にPopover表示
-(void)showFromTableViewSelectedRow:(UITableView *)tableView animated:(BOOL)animated
{
    if ([tableView indexPathForSelectedRow]) {
        CGRect popoverRect = [tableView rectForRowAtIndexPath:[tableView indexPathForSelectedRow]];
        [self showFromRect:popoverRect inView:tableView animated:animated];
    }
}


#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (_didDismissBlock) {
        _didDismissBlock(actionSheet, buttonIndex);
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // ボタンタップでblockを実行
    void (^block)(NSInteger buttonIndex) = [_blocks objectAtIndex:buttonIndex];
    if (block) {
        block(buttonIndex);
    }
}

@end
