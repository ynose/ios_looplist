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
@property (weak, nonatomic) IBOutlet UIButton *checklistDetailButton;
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

    UIImage *backgroundImage = [UIImage imageNamed:@"roundButtonBackground"];
    [self.completeSwitch setBackgroundImage:[backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [self.checklistDetailButton setBackgroundImage:[backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
}

-(void)setEditing:(BOOL)editing
{
    _editing = editing;

//    // 完了スイッチとリスト詳細ボタンの表示を切り替える
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
//        [self.checklistDetailButton setAlpha:(editing) ? 1.0 : 0.0];
//        [self.completeSwitch setAlpha:(!editing) ? 1.0 : 0.0];
//    } completion:^(BOOL finished) {
//        self.checklistDetailButton.enabled = editing;
//        self.completeSwitch.enabled = !editing;
//    }];

    self.checklistDetailButton.hidden = !editing;
    self.completeSwitch.hidden = editing;
}


#pragma mark - ボタン
#pragma mark チェックリスト設定ボタン
- (IBAction)checklistDetailButtonTouchUp:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(checklistDetailButtonTouchUp:)]) {
        [self.delegate checklistDetailButtonTouchUp:sender];
    }
}

#pragma mark チェック完了スイッチ
- (IBAction)completeTouchUp:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(completeCheckList:)]) {
        [self.delegate completeCheckList:sender];
    }
}


@end
