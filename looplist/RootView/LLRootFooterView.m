//
//  LLRootFooterView.m
//  EverList
//
//  Created by Yoshio Nose on 2013/07/19.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLRootFooterView.h"
#import "Define.h"
//#import "UIGlossyButton.h"
//#import "DCRoundSwitch.h"


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

-(void)setEditing:(BOOL)editing
{
    _editing = editing;

    // 完了スイッチとリスト詳細ボタンの表示を切り替える
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.checklistDetailButton setAlpha:(editing) ? 1.0 : 0.0];
        [self.completeSwitch setAlpha:(!editing) ? 1.0 : 0.0];
    } completion:^(BOOL finished) {
        self.checklistDetailButton.enabled = editing;
        self.completeSwitch.enabled = !editing;
    }];
}

//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//
//    // チェック完了スイッチ
//    self.completeSwitch.on = NO;
//    self.completeSwitch.offText = nil;
//    self.completeSwitch.onText = LSTR(@"CheckCompleteSwitchCaption");
//    self.completeSwitch.onTintColor = UIColorMain;
//
//    // チェック完了スイッチのTapジェスチャーを無効にする
//    if (_tapRecognizer == nil) {
//        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                 action:@selector(completeSwitchTapAction:)];
//    }
//    [self.completeSwitch removeGestureRecognizer:_tapRecognizer];
//    [self.completeSwitch addGestureRecognizer:_tapRecognizer];


//    // リスト編集ボタン
//    [self.checklistDetailButton setTitle:LSTR(@"CheckListDetailButtonCaption") forState:UIControlStateNormal];
//	UIGlossyButton *b = (UIGlossyButton *)self.checklistDetailButton;
//	[b useWhiteLabel: YES];
//    b.buttonCornerRadius = 2.0; b.buttonBorderWidth = 1.0f;
//	[b setStrokeType: kUIGlossyButtonStrokeTypeGradientFrame];
//    b.tintColor = b.borderColor = [UIColor brownColor];
//}
//
//// チェック完了スイッチのTapジェスチャーを無効にする
//-(void)completeSwitchTapAction:(UITapGestureRecognizer *)gestureRecognizer
//{
//}

#pragma mark - ボタン
#pragma mark チェックリスト設定ボタン
- (IBAction)checklistDetailButtonTouchUp:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(checklistDetailButtonTouchUp:)]) {
        [self.delegate checklistDetailButtonTouchUp:sender];
    }
}

#pragma mark チェック完了スイッチ
//- (IBAction)completeSwitchValueChanged:(id)sender
//{
//    if (((UISwitch *)sender).on == YES) {
//        if ([self.delegate respondsToSelector:@selector(completeCheckList:)]) {
//            [self.delegate completeCheckList:sender];
//        }
//    }
//}
- (IBAction)completeTouchUp:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(completeCheckList:)]) {
        [self.delegate completeCheckList:sender];
    }
}


@end
