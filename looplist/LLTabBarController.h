//
//  LLTabBarController.h
//  looplist
//
//  Created by Yoshio Nose on 2013/09/24.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "LLCheckListDetailViewController.h"

@class LLRootViewController;

@interface LLTabBarController : UITabBarController //  <LLCheckListDetailDelegate>

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectRootViewController:(LLRootViewController *)rootViewController;

-(void)refreshViewControllers;
-(void)menuAction:(id)sender;

@end
