//
//  NSFileCoordinator+Extension.m
//  TapMailer
//
//  Created by Yoshio Nose on 2012/10/06.
//
//

#import "NSFileCoordinator+Extension.h"

@implementation NSFileCoordinator (Extension)

-(BOOL)removeFile:(NSURL *)URL
{
    __block BOOL success;
    [self coordinateWritingItemAtURL:URL
                             options:NSFileCoordinatorWritingForDeleting
                               error:nil
                          byAccessor:^(NSURL* writingURL) {
                              NSError *error = nil;
                              if ([[NSFileManager defaultManager] removeItemAtURL:writingURL error:&error]) {
                                  success = YES;
                              } else {
                                  DEBUGLOG(@"Couldn't remove URL:%@ %@", URL, error.description);
                                  success = NO;
                              };
                          }];

    return success;
}

@end
