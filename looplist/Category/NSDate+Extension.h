//
//  NSDate+Extension.h
//  TapMailer
//
//  Created by Yoshio Nose on 12/04/16.
//  Copyright (c) 2012 ynose Apps. All rights reserved.
//

// TODO:TapMailerとほぼ同じなので共通化したい

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

+(NSDate *)date:(NSDate *)aDate andTime:(NSDate *)aTime;
+(NSDate *)thisMonth:(NSDate *)aDate byDay:(NSInteger)aDay;
+(NSDate *)dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

-(NSInteger)year;
-(NSInteger)month;
-(NSInteger)day;
-(NSInteger)hour;
-(NSInteger)minute;
-(NSInteger)second;

-(NSDate *)timeZeroSecond:(BOOL)zeroSecond;
-(NSDate *)dateZeroSecond:(BOOL)zeroSecond;
-(NSInteger)weekday;
-(NSInteger)mondayZeroWeeday;
-(NSInteger)todayDiffDays;
-(NSDate *)thisWeekDateAtWeekday:(NSInteger)aWeekday;
-(NSDate *)dateAfterTodayAtInterval:(NSCalendarUnit)repeatInterval;

-(NSString *)stringTimeBy24Time:(BOOL)by24Time;
-(NSString *)stringFullDateTimeBy24Time:(BOOL)by24Time;
-(NSString *)stringWithFormat:(NSString *)format;
-(NSString *)stringWithDateFormat:(NSString *)format;
-(NSString *)weekdayTimeBy24Time:(BOOL)by24Time;
+(NSString *)stringWeekdayWithDays:(NSArray *)days by24Time:(BOOL)by24Time;
-(NSString *)monthTimeBy24Time:(BOOL)by24Time;

// TapMailerから移植したけどLooplistでは使わない
//+(NSString *)sendDateLocalizedFormatToday:(NSDate *)date;
//+(NSString *)sendDateLocalizedFormatYesterday:(NSDate *)date;
//+(NSString *)sendDateLocalizedFormat2DaysLater:(NSDate *)date;
//+(NSString *)sendDateLocalizedFormatPaste:(NSDate *)date;

@end
