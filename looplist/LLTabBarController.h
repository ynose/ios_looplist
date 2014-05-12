//
//  LLTabBarController.h
//  looplist
//
//  Created by Yoshio Nose on 2013/09/24.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "LLCheckListDetailViewController.h"

#import "NADView.h"


@class LLRootViewController;

@interface LLTabBarController : UITabBarController

@property (nonatomic, strong) NADView * nadView;

-(void)refreshViewControllers;
-(void)menuAction:(id)sender;

@end
