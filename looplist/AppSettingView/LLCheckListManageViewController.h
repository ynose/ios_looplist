//
//  LLCheckListManageViewController.h
//  looplist
//
//  Created by Yoshio Nose on 2013/10/04.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckListManageViewControllerDelegate <NSObject>
@required
- (void)checkListManageViewControllerChangeCheckList:(id)sender;
@end

@interface LLCheckListManageViewController : UITableViewController

@property (nonatomic, assign) id <CheckListManageViewControllerDelegate> delegate;

@end
