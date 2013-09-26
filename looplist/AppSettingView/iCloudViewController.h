//
//  iCloudViewController.h
//  TapMailer
//
//  Created by Yoshio Nose on 2012/10/04.
//
//

#import <UIKit/UIKit.h>

@protocol iCloudViewControllerDelegate <NSObject>
-(void)iCloudViewRestoreDone:(id)sender;
@end

@interface iCloudViewController : UITableViewController

@property (weak, nonatomic) id <iCloudViewControllerDelegate>delegate;

@end
