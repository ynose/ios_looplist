//
//  LLDetailViewController.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/22.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "LLCheckItemDetailViewController.h"

#import "LLColorLabelButton.h"
#import "LLTouchScrollView.h"
#import "LLTouchTextView.h"

#import "UIView+KeyboardNotification.h"
#import "NSDate+Extension.h"
#import "LLCheckListManager.h"
#import "LLCheckItem.h"


@interface LLCheckItemDetailViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet LLTouchScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *baseviewInScrollView;
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
    self.scrollView.alwaysBounceVertical = YES;

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

    // 画像
    self.attachImageView.image = self.attachImage;

    // ドロップシャドウ
    if (self.attachImage) {
        self.scrollView.layer.masksToBounds = NO;
        self.scrollView.layer.shadowOpacity = 0.7f;
        self.scrollView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.scrollView.layer.shadowRadius = 4.0f;
        self.scrollView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 5, self.view.frame.size.width, 20)].CGPath;
    }

    self.scrollView.delegate = self;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resizeView:self.view.frame.size];
    [self resetScrollViewContentInset:self.view.frame.size];

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

// ImagePicker表示時にも呼ばれてしまう
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // 詳細情報を保存してRootViewに戻る
    self.checkItem.caption = self.captionTextField.text;
    self.checkItem.memo = self.memoTextView.text;

    // デリゲートに通知
    if ([self.delegate respondsToSelector:@selector(saveDetail:attachImage:)]) {
        [self.delegate saveDetail:self.checkItem attachImage:self.attachImage];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // キーボード表示の通知を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self resizeView:size];

    [self resetScrollViewContentInset:size];

    // ドロップシャドウのサイズ
    self.scrollView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 5, size.width, 20)].CGPath;
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
        UIScrollView *scrollView = self.scrollView;
        UIEdgeInsets insets = scrollView.contentInset;
        insets.bottom = keyboardRect.size.height;
        scrollView.contentInset = insets;
        scrollView.scrollIndicatorInsets = insets;

        // 本文のカーソル位置にスクロールさせる
        if (_activeTextView == self.memoTextView) {
            [self scrollView:self.scrollView scrollToCursor:self.memoTextView animated:YES];

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
        UIScrollView *scrollView = self.scrollView;
        UIEdgeInsets insets = scrollView.contentInset;
        insets.bottom = 0;
        scrollView.contentInset = insets;
        scrollView.scrollIndicatorInsets = insets;

        [self resetScrollViewContentInset:self.view.frame.size];
    }];
}


#pragma mark - UITextFieldDelegate
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


#pragma mark UITextViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _activeTextView = textView;
}

-(void)textViewDidChange:(UITextView *)textView
{
    // ビューのサイズを調整する
    [self resizeView:self.view.frame.size];

    // 本文のカーソル位置にスクロールさせる
    [self scrollView:self.scrollView scrollToCursor:self.memoTextView animated:NO];
}


#pragma mark -
// UIScrollView+Extension.hのタッチイベントから呼ばれる
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    // メモ(もしくはメモよりも下の領域)がタップされたら、メモを編集モードに設定する
    UITouch *touch = [touches anyObject];
    if ([event touchesForView:self.memoTextView] != NULL ||
        CGRectGetMaxY(self.memoTextView.frame) < [touch locationInView:self.baseviewInScrollView].y) {
        [self.memoTextView setEditable:YES];
        [self.memoTextView becomeFirstResponder];
        return;
    }


    // ビューがタップされたらメモを表示モードに設定する（URLをタップ可能に設定する）
    [self.memoTextView setEditable:NO];

    // キーボードをしまう
    [self.view endEditing:YES];
}

-(void)resizeView:(CGSize)viewSize
{
    // メモ(位置＋サイズ)
    CGRect memoFrame = self.memoTextView.frame;
    memoFrame.size.height = self.memoTextView.contentSize.height;

    CGRect textViewFrame = [self rectWithText:self.memoTextView.text forTextView:self.memoTextView margin:1];
    self.memoTextView.frame = textViewFrame;


    // スクロールビューのコンテントサイズをメモのサイズに合わせる
    CGSize contentSize = viewSize;
    contentSize.height = CGRectGetMaxY(textViewFrame);
    self.scrollView.contentSize = contentSize;

    CGRect baseViewFrame = self.baseviewInScrollView.frame;
    baseViewFrame.size.height = CGRectGetMaxY(textViewFrame) * 2;
    self.baseviewInScrollView.frame = baseViewFrame;
}

-(void)resetScrollViewContentInset:(CGSize)viewSize
{
    // 画像の位置
    if (self.attachImage) {
        // ImageはImageViewの中で中央に表示されているので、Imageが画面上部に表示されるようにImageViewの位置を調整する
        CGRect bounds = CGRectMake(0, 0, viewSize.width, self.attachImageView.bounds.size.height);
        CGRect imageFrame = AVMakeRectWithAspectRatioInsideRect(self.attachImage.size, bounds);
        CGRect imageViewFrame = self.attachImageView.frame;
        imageViewFrame.origin.y = -imageFrame.origin.y;
        self.attachImageView.frame = imageViewFrame;

        // Imageのサイズに応じてスクロールビューのcontentInsetを調整する
        self.scrollView.contentInset = UIEdgeInsetsMake(imageFrame.size.height, 0, 0, 0);
        CGFloat offsetHeight = 120 - [[UIApplication sharedApplication] statusBarFrame].size.height;    // メモ欄が１行表示されるくらいの高さ
        if (imageFrame.size.height < viewSize.height) {
            [self.scrollView setContentOffset:CGPointMake(0, -(imageFrame.size.height - ((imageFrame.size.height + offsetHeight < viewSize.height) ? 0 : offsetHeight))) animated:YES];
        } else {
            [self.scrollView setContentOffset:CGPointMake(0, -(viewSize.height - offsetHeight)) animated:YES];
        }
    } else {
        self.scrollView.contentInset = UIEdgeInsetsZero;
        self.scrollView.contentOffset = CGPointZero;
    }

}

// 本文のカーソル位置にスクロールさせる
-(void)scrollView:(UIScrollView *)scrollView scrollToCursor:(UITextView *)textView animated:(BOOL)animated
{
    // カーソルが表示される位置にスクロールする
    NSString *head = [textView.text substringToIndex:textView.selectedRange.location];
    CGRect textViewFrame = [self rectWithText:head forTextView:textView margin:1];

    NSDictionary *attributes = @{NSFontAttributeName:textView.font};
    CGFloat charHeight = [self heightForChar:attributes];
    textViewFrame.origin.y = CGRectGetMaxY(textViewFrame) - charHeight;
    textViewFrame.size.height = charHeight;

    CGRect visibleRect = scrollView.frame;
    UIEdgeInsets insets = scrollView.contentInset;
    visibleRect.size.height = insets.bottom;

    [scrollView scrollRectToVisible:textViewFrame animated:animated];
//    if (!CGRectIntersectsRect(visibleRect, textViewFrame)) {
//        [scrollView scrollRectToVisible:textViewFrame animated:animated];
//    }

}

// 文字列をTextViewに表示するために必要なサイズを計算する
-(CGRect)rectWithText:(NSString *)text forTextView:(UITextView *)textView margin:(float)margin
{
    NSDictionary *attributes = @{NSFontAttributeName:textView.font};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributes];

    // textViewの幅から左右の余白(textContainerInset)を引く
    // 高さは大きめに取っておく
    CGSize textViewMaxSize = CGSizeMake(textView.bounds.size.width -
                                        (textView.textContainerInset.left + textView.textContainerInset.right),
                                        99999999);
    // 本文をTextViewに表示した時のサイズを計算する
    CGRect textRect = [attributedString boundingRectWithSize:textViewMaxSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    // margin行分の余裕＋上下の余白(textContainerInset)を付けたサイズを返す
    CGFloat charHeight = [self heightForChar:attributes];
    charHeight *= (margin < 1) ? 1 : margin;
    CGRect textViewRect = textView.frame;
    textViewRect.size.height = MAX(textRect.size.height + charHeight +
                                   textView.textContainerInset.top + textView.textContainerInset.bottom, charHeight);

    return textViewRect;
}

-(CGFloat)heightForChar:(NSDictionary *)attributes
{
    NSAttributedString *charAttributedString = [[NSAttributedString alloc] initWithString:@"あ" attributes:attributes];
    CGRect charRect = [charAttributedString boundingRectWithSize:CGSizeMake(320, 320)
                                                         options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    return charRect.size.height;
}


#pragma mark - ラベルボタン
- (IBAction)colorLabelTouchUp:(id)sender {
    self.checkItem.colorLabelIndex = (self.checkItem.colorLabelIndex < 5) ? self.checkItem.colorLabelIndex + 1: 0;
    self.colorLabelButton.colorLabelIndex = self.checkItem.colorLabelIndex;
}


@end
