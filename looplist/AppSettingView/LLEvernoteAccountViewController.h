//
//  LLEvernoteAccountViewController.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/09/13.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EvernoteAccountViewControllerDelegate <NSObject>
-(void)evernoteAccountViewDone:(id)sender;
@end

@interface LLEvernoteAccountViewController : UITableViewController

@property (weak, nonatomic) id <EvernoteAccountViewControllerDelegate>delegate;

@end
