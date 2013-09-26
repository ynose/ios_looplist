//
//  NSUbiquitousKeyValueStore+Extension.m
//  TapMailer
//
//  Created by Yoshio Nose on 2012/11/05.
//
//

#import "NSUbiquitousKeyValueStore+Extension.h"

@implementation NSUbiquitousKeyValueStore (Extension)

-(void)setUserDefaultInteger:(NSUserDefaults *)userDefaults forKey:(NSString *)key
{
    DEBUGLOG(@"%@ = %@", key, ([self objectForKey:key] == nil)? @"not exitst" : [self objectForKey:key]);
    
    if ([self objectForKey:key] != nil) {
        [userDefaults setInteger:[[self objectForKey:key] integerValue] forKey:key];
    }
}

-(void)setUserDefaultBool:(NSUserDefaults *)userDefaults forKey:(NSString *)key
{
    DEBUGLOG(@"%@ = %@", key, ([self objectForKey:key] == nil)? @"not exitst" : [self objectForKey:key]);
    
    if ([self objectForKey:key] != nil) {
        [userDefaults setBool:[self boolForKey:key] forKey:key];
    }
}

@end
