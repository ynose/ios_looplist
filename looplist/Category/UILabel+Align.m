//
//  UILabel+Align.m
//  TapMailer
//
//  Created by Yoshio Nose on 12/03/26.
//  Copyright (c) 2012 ynose Apps. All rights reserved.
//

#import "UILabel+Align.h"

@implementation UILabel (Align)

#define LABEL_MARGINRIGHT 24
#define LABEL_MARGINLEFT 24
#define LABEL_MARGINTOP 5
#define LABEL_MARGINBOTTOM 5

-(void)verticalAlignTop
{
    // 文字列の表示領域のサイズを求める(文字列が空でも高さがゼロにならないように末尾にスペースを付ける)
//    CGSize size = [[NSString stringWithFormat:@"%@ ", self.text] sizeWithFont:self.font
//                                                            constrainedToSize:CGSizeMake(self.bounds.size.width, 2000)
//                                                                lineBreakMode:NSLineBreakByWordWrapping];
    CGSize size = [[NSString stringWithFormat:@"%@ ", self.text] sizeWithAttributes:@{NSFontAttributeName: self.font}];

    // 1行分の高さを求めて、必要な行数を計算する
//    CGSize size1 = [@"X" sizeWithFont:self.font
//                    constrainedToSize:CGSizeMake(self.bounds.size.width, 2000)
//                        lineBreakMode:NSLineBreakByWordWrapping];
    CGSize size1 = [@"X" sizeWithAttributes:@{NSFontAttributeName: self.font}];

    self.numberOfLines = size.height / size1.height;
    
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
