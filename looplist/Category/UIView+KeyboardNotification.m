//
//  UIView+KeyboardNotification.m
//  looplist
//
//  Created by Yoshio Nose on 2013/10/03.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "UIView+KeyboardNotification.h"

@implementation UIView (KeyboardNotification)


-(void)keyboardNotification:(NSNotification *)notification getKeyboardRect:(CGRect *)rect getAnimationDuration:(NSTimeInterval *)duration
{
    NSDictionary *userInfo = [notification userInfo];

    // キーボードのサイズを取得
    CGRect keybordRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keybordRect = [self convertRect:keybordRect fromView:nil];
    *rect = keybordRect;

    // ビューのサイズ調整をキーボード表示のアニメーションにシンクロさせる
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    *duration = animationDuration;

}

@end
