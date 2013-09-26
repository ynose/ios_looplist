//
//  ELTouchTextView.m
//  EverList
//
//  Created by Yoshio Nose on 2013/07/26.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLTouchTextView.h"

@implementation LLTouchTextView

// UIScrollViewのタッチイベントから呼ばれる
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    [[self nextResponder] touchesBegan:touches withEvent:event];
}

@end
