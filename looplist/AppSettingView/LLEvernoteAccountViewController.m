//
//  LLEvernoteAccountViewController.m
//  Looplist
//
//  Created by Yoshio Nose on 2013/09/13.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "LLEvernoteAccountViewController.h"

#import "SVProgressHUD.h"
//#import "EvernoteSDK.h"     // Evernote API

#import "UITableView+Extension.h"

@interface LLEvernoteAccountViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *signInCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *signOutCell;
@end

@implementation LLEvernoteAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.signInCell.textLabel.textColor = UIColorMain;
    self.signOutCell.textLabel.textColor = UIColorMain;

//    EvernoteSession *session = [EvernoteSession sharedSession];
//    if (session.isAuthenticated) {
//        // 認証済み
//        self.signInCell.detailTextLabel.text = LSTR(@"Setting-EvernoteAccount-Signed");
//    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectSelectedRow:YES];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
//                    [self evernoteSignIn];
                    break;
                    
                default:
                    break;
            }
            break;

        case 1:
            switch (indexPath.row) {
                case 0:
//                    [self evernoteSignOut];
                    break;

                default:
                    break;
            }
            break;

        default:
            break;
    }
}


#pragma mark - Evernote
//-(void)evernoteSignIn
//{
//    EvernoteSession *session = [EvernoteSession sharedSession];
//    NSLog(@"Session host: %@", [session host]);
//    NSLog(@"Session key: %@", [session consumerKey]);
//    NSLog(@"Session secret: %@", [session consumerSecret]);
//
//    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
//        if (error || !session.isAuthenticated){
//            if (error) {
//                NSLog(@"Error authenticating with Evernote Cloud API: %@", error);
//                if (error.code != EvernoteSDKErrorCode_USER_CANCELLED) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                    message:error.localizedDescription
//                                                                   delegate:nil
//                                                          cancelButtonTitle:LSTR(@"actionOK")
//                                                          otherButtonTitles:nil];
//                    [alert show];
//                }
//            }
//            if (!session.isAuthenticated) {
//                NSLog(@"Session not authenticated");
//            }
//        } else {
//            // We're authenticated!
//            EvernoteUserStore *userStore = [EvernoteUserStore userStore];
//            [userStore getUserWithSuccess:^(EDAMUser *user) {
//                // success
//                NSLog(@"Authenticated as %@", [user username]);
//
//                [SVProgressHUD showSuccessWithStatus:LSTR(@"Setting-EvernoteAccount-Signed")];
//
//                // デリゲートに通知
//                if ([self.delegate respondsToSelector:@selector(evernoteAccountViewDone:)]) {
//                    [self.delegate evernoteAccountViewDone:self];
//                }
//
//            } failure:^(NSError *error) {
//                // failure
//                NSLog(@"Error getting user: %@", error);
//            } ];
//        }
//    }];
//}
//
//-(void)evernoteSignOut
//{
//    EvernoteSession *session = [EvernoteSession sharedSession];
//    NSLog(@"Session host: %@", [session host]);
//    NSLog(@"Session key: %@", [session consumerKey]);
//    NSLog(@"Session secret: %@", [session consumerSecret]);
//
//    if (session.isAuthenticated) {
//        [session logout];
//        [SVProgressHUD showSuccessWithStatus:LSTR(@"Setting-EvernoteAccount-SignOut")];
//    }
//
//
//    // デリゲートに通知
//    if ([self.delegate respondsToSelector:@selector(evernoteAccountViewDone:)]) {
//        [self.delegate evernoteAccountViewDone:self];
//    }
//}

@end
