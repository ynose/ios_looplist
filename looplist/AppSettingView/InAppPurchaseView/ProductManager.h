//
//  ProductManager.h
//  TapMailer
//
//  Created by Yoshio Nose on 2013/06/24.
//
//

#import <Foundation/Foundation.h>

@interface ProductManager : NSObject

+(ProductManager*)sharedManager;
+(BOOL)isAppPro;
+(void)setAppPro:(BOOL)bought;
+(NSString *)settingKeyAppPro;
+(NSSet *)productIds;

-(void)bought:(NSString *)productIds;

@end
