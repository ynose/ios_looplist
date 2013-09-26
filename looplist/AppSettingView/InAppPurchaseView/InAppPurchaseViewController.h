//
//  InAppPurchaseViewController.h
//  TapMailer
//
//  Created by Yoshio Nose on 12/03/16.
//  Copyright (c) 2012 ynose Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PaymentManager.h"

@protocol inAppPurchaseViewControllerDelegate <NSObject>
-(void)inAppPurchaseDone:(id)sender;
@end

@interface InAppPurchaseViewController : UITableViewController <PaymentManagerDelegete>

@property (weak, nonatomic) id <inAppPurchaseViewControllerDelegate>delegate;

@end
