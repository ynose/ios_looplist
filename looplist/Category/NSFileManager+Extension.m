//
//  NSFileManager+Extension.m
//  TapMailer
//
//  Created by Yoshio Nose on 2012/10/05.
//
//

#import "NSFileManager+Extension.h"

@implementation NSFileManager (Extension)

#pragma mark - Sandbox
+(NSURL *)sandboxURL
{
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    if ([paths count] < 1) {
        return nil;
    }
    return [paths objectAtIndex:0];
}

+(NSArray *)contentsOfDirectoryAtURL:(NSURL *)url
{
    NSError *error = nil;
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                   includingPropertiesForKeys:[NSArray arrayWithObject:NSURLParentDirectoryURLKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&error];
    return array;
}

#pragma mark - iCloud
+(BOOL)iCloudSupport
{
    // iOS (5.0 and later)
    if ([[NSFileManager defaultManager] respondsToSelector:@selector(URLForUbiquityContainerIdentifier:)]) {
        DEBUGLOG(@"!!! iCloud is support !!!\n");
        return YES;
    } else {
        DEBUGLOG(@"xxx iCloud is not support xxx\n");
        return NO;
    }
}

+(NSURL *)iCloudDocumentsURL
{
    NSURL *url = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    return [url URLByAppendingPathComponent:@"Documents" isDirectory:YES];
}

+(BOOL)iCloudAvailable:(void (^)(void))block
{
    if ([NSFileManager iCloudSupport]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] != nil) {
                DEBUGLOG(@"!!! iCloud is available !!!\n");
                if (block) {
                    block();
                }
            } else {
                DEBUGLOG(@"xxx iCloud is not available xxx\n");
            }
        });
        
        return YES;
    } else {
        return NO;
    }
}

@end
