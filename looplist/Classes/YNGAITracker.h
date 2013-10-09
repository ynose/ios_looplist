//
//  YNGAITracker.h
//  looplist
//
//  Created by Yoshio Nose on 2013/10/10.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YNGAITracker : NSObject

+(void)setupGoogleAnalytics;
+(void)trackScreenName:(NSString *)screenName;
+(void)trackActionButton:(NSString *)buttonName label:(NSString *)label value:(NSNumber *)value;

@end
