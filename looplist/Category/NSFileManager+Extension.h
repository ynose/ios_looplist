//
//  NSFileManager+Extension.h
//  TapMailer
//
//  Created by Yoshio Nose on 2012/10/05.
//
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Extension)

+(NSURL *)sandboxURL;
+(NSArray *)contentsOfDirectoryAtURL:(NSURL *)url;

+(BOOL)iCloudSupport;
+(NSURL *)iCloudDocumentsURL;
+(BOOL)iCloudAvailable:(void (^)(void))block;

@end
