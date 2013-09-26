//
//  LLSectionCell.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/08/28.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLCheckListSection.h"

@protocol LLSectionCellDelegate <NSObject>
@optional
-(void)sectionCellDidBeginEditing:(UITextField *)textField;
-(void)sectionCellShouldEndEditing:(UITextField *)textField;
//-(void)checkItemCellShouldReturn:(ELCheckItem *)checkItem;
@end

@interface LLSectionCell : UITableViewCell

@property(assign, nonatomic) id<LLSectionCellDelegate> delegate;
@property(strong, nonatomic) LLCheckListSection *checkListSection;


-(BOOL)becomeFirstResponder;

@end
