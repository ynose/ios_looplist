//
//  LLDetailViewController.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/22.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LLCheckItemDetailViewController.h"

#import "LLColorLabelButton.h"
#import "LLTouchScrollView.h"
#import "LLTouchTextView.h"

#import "UIView+KeyboardNotification.h"
#import "NSDate+Extension.h"
#import "LLCheckListManager.h"
#import "LLCheckItem.h"


@interface LLCheckItemDetailViewController ()
@property (weak, nonatomic) IBOutlet LLColorLabelButton *colorLabelButton;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UILabel *checkedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet LLTouchTextView *memoTextView;
@end

@implementation LLCheckItemDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.checkItem.caption;
    ((UIScrollView *)self.view).alwaysBounceVertical = YES;

    // ラベル
    [self.colorLabelButton setTitle:[@(self.sequenceNumber) stringValue] forState:UIControlStateNormal];
    self.colorLabelButton.colorLabelIndex = self.checkItem.colorLabelIndex;


    // リストタイトル
    self.captionTextField.text = self.checkItem.caption;


    // チェック日時
    if (self.checkItem.checkedDate) {
        // 月/日(曜日)+時刻 フル表示
        self.checkedDateLabel.text = [self.checkItem.checkedDate stringFullDateTimeBy24Time:YES];
    } else {
        self.checkedDateLabel.text = @"";
    }


    // メモ
    self.memoTextView.text = self.checkItem.memo;
    [self.memoTextView setEditable:NO];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resizeView];

    // キーボード表示の通知を設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasUnshown:)
                                                 name:UIKeyboardDidHideNotification object:nil];

    /* GoogleAnalytics API */
    [YNGAITracker trackScreenName:@"CheckItem DetailView"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // 詳細情報を保存してRootViewに戻る
    self.checkItem.caption = self.captionTextField.text;
    self.checkItem.memo = self.memoTextView.text;

    // デリゲートに通知
    if ([self.delegate respondsToSelector:@selector(saveDetail:)]) {
        [self.delegate saveDetail:self.checkItem];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // キーボード表示の通知を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


#pragma mark - Keyboard Notification
// キーボードが表示された時
-(void)keyboardWasShown:(NSNotification *)notification
{
    CGRect keyboardRect;
    NSTimeInterval animationDuration;

    // ビューのサイズ調整
    [self.view keyboardNotification:notification getKeyboardRect:&keyboardRect getAnimationDuration:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        // ビューのサイズをキーボードの高さを引いた高さに変更する
        UIScrollView *scrollView = (UIScrollView *)self.view;
        UIEdgeInsets insets = scrollView.contentInset;
        insets.bottom = keyboardRect.size.height;
        scrollView.contentInset = insets;
        scrollView.scrollIndicatorInsets = insets;

        // フォーカスの当たった入力項目がキーボードに隠れないようにスクロールさせる
        CGRect viewFrame = self.view.frame;
        viewFrame.size.height -= keyboardRect.size.height;
        if (_activeTextView == self.memoTextView) {
            // 本文のカーソル位置にスクロールさせる
            CGPoint origin = _activeTextView.frame.origin;
            NSString *head = [_activeTextView.text substringToIndex:_activeTextView.selectedRange.location];
    //        CGSize initialSize = [head sizeWithFont:_activeTextView.font constrainedToSize:_activeTextView.contentSize];
            CGSize initialSize = [head sizeWithAttributes:@{NSFontAttributeName: _activeTextView.font}];

            NSUInteger startOfLine = [head length];
            //        while (startOfLine > 0) {
            //            /*
            //             * 1. Adjust startOfLine to the beginning of the first word before startOfLine
            //             * 2. Check if drawing the substring of head up to startOfLine causes a reduction in height compared to initialSize.
            //             * 3. If so, then you've identified the start of the line containing the cursor, otherwise keep going. */
            //        }

            NSString* tail = [head substringFromIndex:startOfLine];
    //        CGSize lineSize = [tail sizeWithFont:_activeTextView.font
    //                                    forWidth:_activeTextView.contentSize.width
    //                               lineBreakMode:NSLineBreakByWordWrapping];
            CGSize lineSize = [tail sizeWithAttributes:@{NSFontAttributeName: _activeTextView.font}];

            CGPoint cursor = origin;
            cursor.x += lineSize.width;
            cursor.y += initialSize.height - lineSize.height;

            [scrollView scrollRectToVisible:CGRectMake(0, cursor.y + 20, 10, 10) animated:YES];
        }
    }];
    
}

// キーボードが消された時
-(void)keyboardWasUnshown:(NSNotification *)notification
{
    CGRect keyboardRect;
    NSTimeInterval animationDuration;

    // ビューのサイズ調整
    [self.view keyboardNotification:notification getKeyboardRect:&keyboardRect getAnimationDuration:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        // ビューのサイズを元のサイズに戻す
        UIScrollView *scrollView = (UIScrollView *)self.view;
        UIEdgeInsets insets = scrollView.contentInset;
        insets.bottom = 0;
        scrollView.contentInset = insets;
        scrollView.scrollIndicatorInsets = insets;
    }];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.memoTextView.layer.borderWidth = 1;
    self.memoTextView.layer.borderColor = [[UIColor colorWithRed:0.875 green:0.875 blue:0.875 alpha:1.000] CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.memoTextView setEditable:NO];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // メモにカーソルをセット
    [self.memoTextView setEditable:YES];
    [self.memoTextView becomeFirstResponder];

    return NO;
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _activeTextView = textView;
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self resizeView];
}


-(void)resizeView
{
    // メモTextView(位置＋サイズ)
    CGRect frame = self.memoTextView.frame;
    frame.size.height = self.memoTextView.contentSize.height;
    self.memoTextView.frame = frame;

    if (CGRectGetMaxY(self.memoTextView.frame) < CGRectGetMaxY(self.view.frame)) {
        frame.size.height = self.view.frame.size.height - self.memoTextView.frame.origin.y;
        self.memoTextView.frame = frame;
    }

    
    // ビューContentSize(サイズ)
    CGSize contentSize = self.view.frame.size;
    contentSize.height = CGRectGetMaxY(self.memoTextView.frame);
    ((UIScrollView *)self.view).contentSize = contentSize;
}

// UIScrollView+Extension.hのタッチイベントから呼ばれる
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    // メモがタップされたら編集モードに設定する
    if ([event touchesForView:self.memoTextView] != NULL) {
        [self.memoTextView setEditable:YES];
        [self.memoTextView becomeFirstResponder];
        return;
    }

    // ビューがタップされたらメモを表示モードに設定する（URLをタップ可能に設定する）
    [self.memoTextView setEditable:NO];

    // キーボードをしまう
    [self.view endEditing:YES];
}


#pragma mark ラベルボタン
- (IBAction)colorLabelTouchUp:(id)sender {
    self.checkItem.colorLabelIndex = (self.checkItem.colorLabelIndex < 5) ? self.checkItem.colorLabelIndex + 1: 0;
    self.colorLabelButton.colorLabelIndex = self.checkItem.colorLabelIndex;
}


@end
