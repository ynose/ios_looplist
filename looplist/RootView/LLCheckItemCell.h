//
//  LLCheckItemCell.h
//  EverList
//
//  Created by Yoshio Nose on 2013/07/11.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLCheckItem.h"

@protocol LLCheckItemCellDelegate <NSObject>
@required
-(void)checkItemCellShouldBeginEditing:(LLCheckItem *)checkItem;
-(void)checkItemCellShouldReturn:(LLCheckItem *)checkItem;
@end

@interface LLCheckItemCell : UITableViewCell <UITextFieldDelegate>

@property(assign, nonatomic) id<LLCheckItemCellDelegate> delegate;
@property(strong, nonatomic) LLCheckItem *checkItem;
@property (assign, nonatomic) NSUInteger sequenceNumber;
@property(nonatomic) NSDate *checkedDate;

@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UILabel *checkedDateLabel;

@end
