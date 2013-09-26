//
//  YNAlertView.h
//  TapMailer
//
//  Created by Yoshio Nose on 2012/10/25.
//
//

#import <UIKit/UIKit.h>

@interface YNAlertView : UIAlertView <UIAlertViewDelegate>
{
    __strong NSMutableArray *_blocks;
}

//-(id)initWithAlertViewStyle:(UIAlertViewStyle)UIAlertViewStyle;
-(NSInteger)addButtonWithTitle:(NSString *)title withBlock:(void (^)(UIAlertView *))block;

@end
