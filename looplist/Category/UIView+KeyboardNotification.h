//
//  UIView+KeyboardNotification.h
//  looplist
//
//  Created by Yoshio Nose on 2013/10/03.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KeyboardNotification)

-(void)keyboardNotification:(NSNotification *)notification getKeyboardRect:(CGRect *)rect getAnimationDuration:(NSTimeInterval *)duration;

@end
