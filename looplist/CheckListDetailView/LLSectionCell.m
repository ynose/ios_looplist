//
//  LLSectionCell.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/08/28.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLSectionCell.h"

@interface LLSectionCell ()  <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation LLSectionCell

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.textField.delegate = self;
    self.textField.text = self.checkListSection.caption;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.checkListSection.caption = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.checkListSection.caption = nil;
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(sectionCellDidBeginEditing:)]) {
        [self.delegate sectionCellDidBeginEditing:textField];
    }
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(sectionCellShouldEndEditing:)]) {
        [self.delegate sectionCellShouldEndEditing:textField];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - パプリックメソッド
-(BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

@end
