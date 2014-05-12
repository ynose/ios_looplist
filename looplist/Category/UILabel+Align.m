//
//  UILabel+Align.m
//  TapMailer
//
//  Created by Yoshio Nose on 12/03/26.
//  Copyright (c) 2012 ynose Apps. All rights reserved.
//

#import "UILabel+Align.h"

@implementation UILabel (Align)

-(void)verticalAlignTop
{
    // 文字列の表示領域のサイズを求める(文字列が空でも高さがゼロにならないように末尾にスペースを付ける)
    DEBUGLOG(@"%@", self.text);
    CGSize size = [[NSString stringWithFormat:@"%@ ", self.text] sizeWithAttributes:@{NSFontAttributeName:self.font}];

    self.numberOfLines = (size.width / self.frame.size.width) + (((size.width / self.frame.size.width) / 1 > 0) ? 1 : 0);
    size.height = size.height * self.numberOfLines;

    // ラベルのサイズを文字列の表示領域ぴったりのサイズに変更して文字を上寄せの状態にする
    CGRect labelFrame = self.frame;
    if (self.hidden == NO) {
        labelFrame.size.height = size.height;
    } else {
        labelFrame.size.height = 0;
    }
    self.frame = labelFrame;
}


@end
