//
//  ProductManager.m
//  TapMailer
//
//  Created by Yoshio Nose on 2013/06/24.
//
//

#import "ProductManager.h"

@implementation ProductManager

static ProductManager *_sharedInstance = nil;

#define PRODUCT_ID @"jp.yoshionose.looplist.pro"
#define SETTING_APP_PRO @"AppPro"


#pragma mark - シングルトン定義
+(ProductManager*)sharedManager
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [self new];
        }
    }
    return _sharedInstance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    return nil;
}

-(id)copyWithZone:(NSZone*)zone
{
	return self;        // シングルトン状態を保持するため何もせず self を返す
}

#pragma mark - 製品情報
+(BOOL)isAppPro
{
    // Pro版の有無を返す
    return [[NSUserDefaults standardUserDefaults] boolForKey:SETTING_APP_PRO];
}

+(void)setAppPro:(BOOL)bought
{
    // TProの機能の有無を保存する
    @synchronized(self) {
        [[NSUserDefaults standardUserDefaults] setBool:bought forKey:SETTING_APP_PRO];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(NSString *)settingKeyAppPro
{
    return SETTING_APP_PRO;
}

+(NSSet *)productIds
{
    return [NSSet setWithObject:PRODUCT_ID];
}

-(void)bought:(NSString *)productIds
{
    if ([productIds isEqualToString:PRODUCT_ID]) {
        [ProductManager setAppPro:YES];
    }
}

@end
