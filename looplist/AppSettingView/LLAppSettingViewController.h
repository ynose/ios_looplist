//
//  LLAppSettingViewController.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/25.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>

// プロトコル
@protocol AppSettingViewControllerDelegate <NSObject>
@required
- (void)appSettingViewControllerRefreshCheckList:(id)sender;
//- (void)appSettingViewControllerDidAddCheckList:(id)sender;
- (void)appSettingViewControllerDidRestoreCheckList:(id)sender;
@end

@class LLTabBarController;

@interface LLAppSettingViewController : UITableViewController

@property (nonatomic, assign) id <AppSettingViewControllerDelegate> delegate;
@property (weak, nonatomic) LLTabBarController *tabBarController;

@end
