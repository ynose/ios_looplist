//
//  YNActionSheet.h
//  TapMailer
//
//  Created by Yoshio Nose on 2012/11/12.
//
//

#import <UIKit/UIKit.h>

@interface YNActionSheet : UIActionSheet <UIActionSheetDelegate>
{
    __strong NSMutableArray *_blocks;
}

@property (copy, nonatomic) void (^didDismissBlock)(UIActionSheet *, NSInteger);
//@property (copy, nonatomic) void (^didDismissBlock)(UIActionSheet *actionSheet, NSInteger index);


-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)firstOtherTitle,...;

-(NSInteger)addButtonWithTitle:(NSString *)title withBlock:(void (^)(NSInteger buttonIndex))block;
-(void)showFromTableViewSelectedRow:(UITableView *)tableView animated:(BOOL)animated NS_AVAILABLE_IOS(3_2);

@end
