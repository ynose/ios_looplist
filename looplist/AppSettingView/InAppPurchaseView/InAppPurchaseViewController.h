//
//  InAppPurchaseViewController.h
//  TapMailer
//
//  Created by Yoshio Nose on 12/03/16.
//  Copyright (c) 2012 ynose Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol inAppPurchaseViewControllerDelegate <NSObject>
-(void)inAppPurchaseDone:(id)sender;
@end

@interface InAppPurchaseViewController : UITableViewController

@property (weak, nonatomic) id <inAppPurchaseViewControllerDelegate>delegate;

@end
