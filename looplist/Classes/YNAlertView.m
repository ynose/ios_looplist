//
//  YNAlertView.m
//  TapMailer
//
//  Created by Yoshio Nose on 2012/10/25.
//
//

#import "YNAlertView.h"

@implementation YNAlertView

-(id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        _blocks = [NSMutableArray array];
    }

    return self;
}

//-(id)initWithAlertViewStyle:(UIAlertViewStyle)UIAlertViewStyle
//{
//    self = [super init];
//    if (self) {
//        self.delegate = self;
//        self.alertViewStyle = UIAlertViewStyle;
//        _blocks = [NSMutableArray array];
//    }
//    
//    return self;
//}

// addButtonWithTitle:のオーバライド
-(NSInteger)addButtonWithTitle:(NSString *)title
{
    [_blocks addObject:^(UIAlertView *alertView){}];
    
    return [super addButtonWithTitle:title];
}

-(NSInteger)addButtonWithTitle:(NSString *)title withBlock:(void (^)(UIAlertView *alertView))block
{
    if (block) {
        [_blocks addObject:block];
    } else {
        [_blocks addObject:^(UIAlertView *alertView){}];
    }

    return [super addButtonWithTitle:title];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void (^block)(UIAlertView *) = [_blocks objectAtIndex:buttonIndex];
    if (block) {
        block(self);
    }
}

@end
