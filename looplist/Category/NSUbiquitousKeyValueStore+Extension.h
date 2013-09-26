//
//  NSUbiquitousKeyValueStore+Extension.h
//  TapMailer
//
//  Created by Yoshio Nose on 2012/11/05.
//
//

#import <Foundation/Foundation.h>

@interface NSUbiquitousKeyValueStore (Extension)

-(void)setUserDefaultInteger:(NSUserDefaults *)userDefaults forKey:(NSString *)key;
-(void)setUserDefaultBool:(NSUserDefaults *)userDefaults forKey:(NSString *)key;

@end
