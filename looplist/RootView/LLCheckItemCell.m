//
//  LLCheckItemCell.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/11.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLCheckItemCell.h"

#import "Define.h"
#import "NSDate+Extension.h"

#import "LLColorLabelButton.h"


@interface LLCheckItemCell ()
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet LLColorLabelButton *colorLabelButton;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;
@end

@implementation LLCheckItemCell


#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    static NSString *KVOCheckedDate = KVO_CHECKEDDATE;

    if ([keyPath isEqualToString:KVOCheckedDate]) {
        // チェック日時を表示
        id newDate = [change objectForKey:NSKeyValueChangeNewKey];
        if (newDate != [NSNull null]) {
            self.checkedDate = (NSDate *)newDate;
        } else {
            self.checkedDate = nil;
        }

        // チェックON/OFFに応じて背景画像を切り替える
        self.checkmarkImageView.hidden = (self.checkedDate) ? NO : YES;
    }
}

//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
////        // セルの背景画像
////        [self setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBackground"]]];
////        [self setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBackground-selected"]]];
//        UIView *view = [UIView new];
//        [view setBackgroundColor:[UIColor whiteColor]];
//        [self setBackgroundView:view];
//    }
//    return self;
//}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
//    // セルの背景画像
//    [self setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBackground"]]];
//    UIView *view = [UIView new];
//    [view setBackgroundColor:[UIColor whiteColor]];
//    [self setBackgroundView:view];

                             
    // チェックマーク
    self.checkmarkImageView.hidden = YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.numberLabel.text = [@(self.sequenceNumber) stringValue];

    self.colorLabelButton.colorLabelIndex = self.checkItem.colorLabelIndex;
    [self.colorLabelButton setTitle:self.numberLabel.text forState:UIControlStateNormal];

    self.captionTextField.placeholder = LSTR(@"NewCheckCaption");
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing == NO) {
        // 通常モード
        [self.captionTextField resignFirstResponder];   // キーボードを非表示

        self.colorLabelButton.hidden = (self.checkItem.colorLabelIndex == 0) ? YES : NO;
    } else {
        // 編集モード
        self.captionTextField.delegate = self;
        self.colorLabelButton.hidden = NO;
    }

    self.colorLabelButton.enabled = editing;
    self.captionTextField.enabled = editing;
}



#pragma mark - プロパティ
-(void)setCheckedDate:(NSDate *)checkedDate
{
    _checkedDate = checkedDate;

    NSString *checkDateString = @"";
    if (checkedDate) {
        NSInteger secondSinceNow = [@(([checkedDate timeIntervalSinceReferenceDate] -
                                       [[NSDate date] timeIntervalSinceReferenceDate]) * -1) integerValue];

        // 簡易表示
        if (2592000 < secondSinceNow) {         // 30日以上
            checkDateString = [checkedDate stringDate];
        } else if (86400 < secondSinceNow) {    // 1日以上
            checkDateString = [NSString stringWithFormat:LSTR(@"BeforeDay"), secondSinceNow / 86400];
        } else if (3600 < secondSinceNow) {     // 1時間以上
            checkDateString = [NSString stringWithFormat:LSTR(@"BeforeHour"), secondSinceNow / 3600];
        } else if (60 < secondSinceNow) {       // 1分以上
            checkDateString = [NSString stringWithFormat:LSTR(@"BeforeMinute"), secondSinceNow / 60];
        } else if (30 < secondSinceNow) {       // 30秒以上
            checkDateString = LSTR(@"WithinMinute");
        } else {
            checkDateString = LSTR(@"JustNow");
        }
    }
    self.checkedDateLabel.text = checkDateString;

    [self setNeedsLayout];
}


#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.checkItem.caption = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.checkItem.caption = nil;
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(checkItemCellShouldBeginEditing:)]) {
        [self.delegate checkItemCellShouldBeginEditing:self.checkItem];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(checkItemCellShouldReturn:)]) {
        [self.delegate checkItemCellShouldReturn:self.checkItem];
    }
    return YES;
}

#pragma mark - カラーラベルタップ
- (IBAction)colorLabelTouchUp:(id)sender {
    self.checkItem.colorLabelIndex = (self.checkItem.colorLabelIndex < 5) ? self.checkItem.colorLabelIndex + 1: 0;
    self.colorLabelButton.colorLabelIndex = self.checkItem.colorLabelIndex;
}


#pragma mark - パプリックメソッド
-(BOOL)becomeFirstResponder
{
    return [self.captionTextField becomeFirstResponder];
}

@end
