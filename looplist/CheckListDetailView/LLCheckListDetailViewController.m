//
//  LLCheckListSettingViewController.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/08/12.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLCheckListDetailViewController.h"

#import "Define.h"

#import "LLTouchScrollView.h"
#import "YNActionSheet.h"

#import "NSDate+Extension.h"
#import "ProductManager.h"
#import "LLCheckList.h"


@interface LLCheckListDetailViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet LLTouchScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UILabel *sectionCaptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *saveToEvernoteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *saveToEvernoteSwitch;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@end

@implementation LLCheckListDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // キャプション編集テキストフィールド
    self.captionTextField.delegate = self;
    self.captionTextField.placeholder = LSTR(@"ListTitlePlaceholder");
    self.captionTextField.text = self.checkList.caption;

    // セクション編集テーブル
    if ([ProductManager isAppPro]) {
        [self setupSectionTableView];
    } else {
        self.sectionCaptionLabel.hidden = YES;
        self.sectionTableView.hidden = YES;
    }

    // Save to Evernote ***Pro版限定***
    if (![ProductManager isAppPro]) {
//        self.saveToEvernoteLabel.text = LSTR(@"SaveToEvernoteCaption");
        self.saveToEvernoteSwitch.on = self.checkList.saveToEvernote;
        self.saveToEvernoteLabel.hidden = YES;
        self.saveToEvernoteSwitch.hidden = YES;
    }

    // チェックリスト情報
    if (self.checkList.finishDate) {
        self.createDateLabel.text = [NSString stringWithFormat:LSTR(@"FinishDate"), [self.checkList.finishDate stringFullDateTimeBy24Time:YES]];
    } else {
        self.createDateLabel.text = @"";
    }
    self.finishCountLabel.text = [NSString stringWithFormat:LSTR(@"FinishCount"), self.checkList.finishCount];

    // 削除ボタン
//    [self.deleteButton setTitle:LSTR(@"DeleteCheckListCaption") forState:UIControlStateNormal];

    // スクロールビューの調整
    self.scrollView.alwaysBounceVertical = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self resizeView];

    // キーボード表示の通知を設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyborodWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyborodWasUnshown:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // キーボード表示の通知を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self resizeView];
}


-(void)resizeView
{
    // セクションテーブルビュー
    CGRect rect = self.sectionTableView.frame;
    rect.size.height = [self.sectionTableView numberOfRowsInSection:0] * self.sectionTableView.rowHeight;
    self.sectionTableView.frame = rect;


    // 画面の下に配置させるために下のオブジェクトから順に位置決めする
    // 削除ボタン
    rect = self.deleteButton.frame;
    rect.origin.y = MAX(self.view.frame.size.height - rect.size.height - 20,
                        CGRectGetMaxY(self.sectionTableView.frame)
                            + self.finishCountLabel.frame.size.height + 44
                            + self.createDateLabel.frame.size.height + 7
                            + self.saveToEvernoteSwitch.frame.size.height + 44
                            + 44);
    self.deleteButton.frame = rect;

    // Finish Count
    rect = self.finishCountLabel.frame;
    rect.origin.y = self.deleteButton.frame.origin.y - rect.size.height - 44;
    self.finishCountLabel.frame = rect;

    // Create Date
    rect = self.createDateLabel.frame;
    rect.origin.y = self.finishCountLabel.frame.origin.y - rect.size.height - 7;
    self.createDateLabel.frame = rect;

    // Save to Evernote
    rect = self.saveToEvernoteSwitch.frame;
    rect.origin.y = self.createDateLabel.frame.origin.y - rect.size.height - 44;
    self.saveToEvernoteSwitch.frame = rect;

    CGPoint center = self.saveToEvernoteLabel.center;
    center.y = self.saveToEvernoteSwitch.center.y;
    self.saveToEvernoteLabel.center = center;



    // ビューContentSize(サイズ)
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.deleteButton.frame) + 20);
}


#pragma mark - Keyboard Notification
// キーボードが表示された時
-(void)keyborodWasShown:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];

    // キーボードのサイズを取得
    CGRect keybordRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keybordRect = [self.view convertRect:keybordRect fromView:nil];

    // ビューのサイズ調整をキーボード表示のアニメーションにシンクロさせる
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    [UIView animateWithDuration:animationDuration animations:^{
        // ビューのサイズをキーボードの高さを引いた高さに変更する
        UIScrollView *scrollView = (UIScrollView *)self.view;
        UIEdgeInsets insets = scrollView.contentInset;
        insets.bottom = keybordRect.size.height;
        scrollView.contentInset = insets;
        scrollView.scrollIndicatorInsets = insets;


        // フォーカスの当たった入力項目がキーボードに隠れないようにスクロールさせる
        CGRect viewFrame = self.view.frame;
        viewFrame.size.height -= keybordRect.size.height;

        // カーソルのセル位置にスクロールさせる
        CGRect cursorCellFrame = [self.view convertRect:_activeTextField.superview.superview.frame fromView:self.sectionTableView];
        [scrollView scrollRectToVisible:cursorCellFrame animated:YES];
    }];

}

// キーボードが消された時
-(void)keyborodWasUnshown:(NSNotification *)notification
{
    // ビューのサイズ調整をキーボード表示のアニメーションにシンクロさせる
    NSDictionary *userInfo = [notification userInfo];

    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    [UIView animateWithDuration:animationDuration animations:^{
        // ビューのサイズを元のサイズに戻す
        UIScrollView *scrollView = (UIScrollView *)self.view;
        UIEdgeInsets insets = scrollView.contentInset;
        insets.bottom = 0;
        scrollView.contentInset = insets;
        scrollView.scrollIndicatorInsets = insets;
    }];
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - 完了ボタン
- (IBAction)doneAction:(id)sender {
    // 詳細情報を反映してRootViewに戻る
    self.checkList.caption = self.captionTextField.text;
    self.checkList.saveToEvernote = self.saveToEvernoteSwitch.on;

    if ([self.delegate respondsToSelector:@selector(saveCheckListDetail:)]) {
        [self.delegate saveCheckListDetail:self.checkList];
    }
}


#pragma mark チェックリスト削除ボタン
- (IBAction)deleteTouchUp:(id)sender
{
    YNActionSheet *actionSheet = [[YNActionSheet alloc] init];

    // 削除ボタン
    [actionSheet addButtonWithTitle:LSTR(@"actionDelete") withBlock:^(NSInteger buttonIndex) {
        if ([self.checkListDetailDelegate respondsToSelector:@selector(deleteCheckListAtIndex:)]) {
            [self.checkListDetailDelegate deleteCheckListAtIndex:self.checkListIndex];
        }
    }];
    actionSheet.destructiveButtonIndex =  [actionSheet numberOfButtons] - 1;

    // キャンセルボタン
    // iPadではキャンセルボタンは表示されないがイベントは発生する
    [actionSheet addButtonWithTitle:LSTR(@"actionCancel") withBlock:nil];
    actionSheet.cancelButtonIndex =  [actionSheet numberOfButtons] - 1;

    [actionSheet showInView:self.view];
}


@end
