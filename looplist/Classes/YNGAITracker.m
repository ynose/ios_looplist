//
//  YNGAITracker.m
//  looplist
//
//  Created by Yoshio Nose on 2013/10/10.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#import "YNGAITracker.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@implementation YNGAITracker

+(void)setupGoogleAnalytics
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;

    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;

    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];

#ifndef DEBUG
    [[GAI sharedInstance] setDryRun:NO];    // 本番稼働（トラッキングあり）
#else
    [[GAI sharedInstance] setDryRun:YES];   // デバッグ（トラッキングなし）
#endif

    // Initialize tracker.
    //    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-27011566-2"];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-27011566-2"];
}

#pragma mark 画面名のトラック
+(void)trackScreenName:(NSString *)screenName
{
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:screenName];

    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark アクションのトラック
+(void)trackActionButton:(NSString *)buttonName label:(NSString *)label value:(NSNumber *)value
{
    [[GAI sharedInstance].defaultTracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"tap"
                                                                                       action:@"button"
                                                                                        label:label
                                                                                        value:value]
                                                set:buttonName forKey:kGAIScreenName] build]];
}

@end
