//
//  LLCheckItemCell.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/11.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLCheckItemCell.h"

#import "NSDate+Extension.h"

#import "LLColorLabelButton.h"


@interface LLCheckItemCell ()
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet LLColorLabelButton *colorLabelButton;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;
@end


@implementation LLCheckItemCell

#pragma mark - 連番
-(void)setSequenceNumber:(NSUInteger)sequenceNumber
{
    _sequenceNumber = sequenceNumber;

    self.numberLabel.text = [@(sequenceNumber) stringValue];
    [self.colorLabelButton setTitle:[@(sequenceNumber) stringValue] forState:UIControlStateNormal];
    [self.colorLabelButton setNeedsLayout]; // ラベルボタンのTitle反映に必要
}

-(void)prepareForReuse
{
    [super prepareForReuse];

    // チェックON/OFFリセット
    [self changeCheckState:NO];
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.colorLabelButton.colorLabelIndex = self.checkItem.colorLabelIndex;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing == NO) {
        // 通常モード
        self.colorLabelButton.hidden = (self.checkItem.colorLabelIndex == 0) ? YES : NO;
        [self changeCheckState:(self.checkedDate) ? YES : NO];
    } else {
        // 編集モード
        self.captionTextField.delegate = self;
        self.colorLabelButton.hidden = NO;
        [self changeCheckState:NO];
    }


    self.colorLabelButton.enabled = editing;
    self.captionTextField.enabled = editing;
}

// チェック状態に応じた画面オブジェクトの表示切り替え
-(void)changeCheckState:(BOOL)checked
{
    if (checked) {
        self.backgroundColor = UIColorCellChecked;
        self.captionTextField.textColor = UIColorTextChecked;
        self.checkmarkImageView.hidden = NO;
    } else {
        self.backgroundColor = UIColorCellUncheck;
        self.captionTextField.textColor = UIColorTextUncheck;
        self.checkmarkImageView.hidden = YES;
    }
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
            checkDateString = [checkedDate stringWithFormat:@"EdMMM"];
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

    // チェックON/OFF切り替え
    [self changeCheckState:(self.checkedDate) ? YES : NO];

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
