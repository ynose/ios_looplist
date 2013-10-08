//
//  LLRootFooterView.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/19.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLRootFooterView.h"

#import "Define.h"

@interface LLRootFooterView ()
@property (weak, nonatomic) IBOutlet UIButton *completeSwitch;
@end

@implementation LLRootFooterView

+(LLRootFooterView *)view
{
    UINib *nib = [UINib nibWithNibName:@"LLRootFooterView" bundle:[NSBundle mainBundle]];
    return [nib instantiateWithOwner:self options:nil][0];
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.completeSwitch.layer.cornerRadius = 4.0;
    self.completeSwitch.layer.backgroundColor = (self.editing) ? [UIColorMainDisable CGColor] : [UIColorMain CGColor];
}

-(void)setEditing:(BOOL)editing
{
    _editing = editing;

    // 完了スイッチの有効無効を切り替える
    self.completeSwitch.enabled = !editing;
    self.completeSwitch.layer.backgroundColor = (self.editing) ? [UIColorMainDisable CGColor] : [UIColorMain CGColor];
}


#pragma mark チェック完了スイッチ
- (IBAction)completeTouchUp:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(completeCheckList:)]) {
        [self.delegate completeCheckList:sender];
    }
}


@end
