//
//  NSDate+Extension.m
//  TapMailer
//
//  Created by Yoshio Nose on 12/04/16.
//  Copyright (c) 2012 ynose Apps. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

// 時刻を省いた日付のみを返す
+(NSDate *)_justDate:(NSDate *)aDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                                   fromDate:aDate];
    
    return [calendar dateFromComponents:dateComponents];    
}

// 日付と時刻を結合した日付を返す
+(NSDate *)date:(NSDate *)aDate andTime:(NSDate *)aTime
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                                   fromDate:aDate];
    NSDateComponents *timeComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                   fromDate:aTime];
    
    NSDateComponents *catComponents = [[NSDateComponents alloc] init];
    [catComponents setYear:[dateComponents year]];
    [catComponents setMonth:[dateComponents month]];
    [catComponents setDay:[dateComponents day]];
    [catComponents setHour:[timeComponents hour]];
    [catComponents setMinute:[timeComponents minute]];
    [catComponents setSecond:[timeComponents second]];
    
    return [calendar dateFromComponents:catComponents];
}

// 指定日付の年月の指定日の日付を返す
+(NSDate *)thisMonth:(NSDate *)aDate byDay:(NSInteger)aDay
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                                   fromDate:aDate];
    
    NSDateComponents *catComponents = [[NSDateComponents alloc] init];
    [catComponents setYear:[dateComponents year]];
    [catComponents setMonth:[dateComponents month]];
    [catComponents setDay:aDay];
    [catComponents setHour:0];
    [catComponents setMinute:0];
    [catComponents setSecond:0];
    
    return [calendar dateFromComponents:catComponents];
}

// 年月日時分秒を指定して日付を返す
+(NSDate *)dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *catComponents = [[NSDateComponents alloc] init];
    [catComponents setYear:year];
    [catComponents setMonth:month];
    [catComponents setDay:day];
    [catComponents setHour:hour];
    [catComponents setMinute:minute];
    [catComponents setSecond:second];
    
    return [calendar dateFromComponents:catComponents];
}

// 年月と時刻を省いた日のみを返す
-(NSDateComponents *)_datetimeComponents
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *datetimeComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | 
                                                                NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                   fromDate:self];

    return datetimeComponents;
}

-(NSInteger)year
{
    return [[self _datetimeComponents] year];
}

-(NSInteger)month
{
    return [[self _datetimeComponents] month];
}

-(NSInteger)day
{
    return [[self _datetimeComponents] day];
}

-(NSInteger)hour
{
    return [[self _datetimeComponents] hour];
}

-(NSInteger)minute
{
    return [[self _datetimeComponents] minute];
}

-(NSInteger)second
{
    return [[self _datetimeComponents] second];
}

// 日付を省いた時刻のみを返す
-(NSDate *)timeZeroSecond:(BOOL)zeroSecond
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *dateComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                   fromDate:self];

    [dateComponents setHour:[dateComponents hour]];
    [dateComponents setMinute:[dateComponents minute]];
    [dateComponents setSecond:(!zeroSecond) ? [dateComponents second] : 0];
    
    return [calendar dateFromComponents:dateComponents];
}

// 秒を省いた日付+時刻を返す
-(NSDate *)dateZeroSecond:(BOOL)zeroSecond
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                                   fromDate:self];

    NSDateComponents *timeComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                   fromDate:self];
    
    NSDateComponents *catComponents = [[NSDateComponents alloc] init];
    [catComponents setYear:[dateComponents year]];
    [catComponents setMonth:[dateComponents month]];
    [catComponents setDay:[dateComponents day]];
    [catComponents setHour:[timeComponents hour]];
    [catComponents setMinute:[timeComponents minute]];
    [catComponents setSecond:(!zeroSecond) ? [timeComponents second] : 0];
    
    return [calendar dateFromComponents:catComponents];
}

// 曜日番号を返す
-(NSInteger)weekday
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | 
                                                            NSWeekdayCalendarUnit
                                                   fromDate:self];

    return [dateComponents weekday];
}

// 月曜日始まりの曜日番号を返す(0=月..5=土,6=日)
-(NSInteger)mondayZeroWeeday
{
    NSInteger weekday = [self weekday];
    if (weekday == 1) {         // 1=日曜日
        return 6;
    } else {                    // 2=月曜日 〜 7=土曜日
        return weekday - 2;
    }
}

// 今日との差分日数を返す
-(NSInteger)todayDiffDays
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDate *today = [NSDate _justDate:[NSDate date]];
    NSDate *compDate = [NSDate _justDate:self];
    NSInteger days = [[calendar components:NSDayCalendarUnit fromDate:today toDate:compDate options:0] day];
    
    return days;
}

// 指定日付に指定日数をプラスした日付を返す(時刻はゼロ)
+(NSDate *)justDate:(NSDate *)aDate byAddingDayInterval:(NSInteger)days
{
    NSDate *date = [self _justDate:aDate];
    
    return [date dateByAddingTimeInterval:days * 24 * 60 * 60];
}

// 指定日付の週の指定曜日の日付を返す
-(NSDate *)thisWeekDateAtWeekday:(NSInteger)aWeekday
{
    NSInteger weekday = [self weekday];
    NSDate *monday;
    if (weekday == 1) {
        // 月曜日=2と指定日の曜日=weekdayの差から月曜日の日付を求める
        monday = [NSDate justDate:self byAddingDayInterval:-6];                            
    } else {
        // 月曜日=2と指定日の曜日=weekdayの差から月曜日の日付を求めるを返す
        monday = [NSDate justDate:self byAddingDayInterval:2 - weekday];                   
    }
    
    // 月曜日の日付を基準として指定曜日=aWeekdayに当たる日付        
    return [NSDate justDate:monday byAddingDayInterval:(aWeekday == 1) ? 6: aWeekday - 2];   
}

// 次回の通知日時を返す(LoadlNotificationでの次回通知と同じ日時を計算して表示する)
-(NSDate *)dateAfterTodayAtInterval:(NSCalendarUnit)repeatInterval
{
    NSInteger weekday;
    NSDate *nextDate = [self copy];
    NSDate *aTime = [self timeZeroSecond:YES]; // 時刻は常に同じ時刻
    NSComparisonResult compResult;
    
    switch (repeatInterval) {
        case NSDayCalendarUnit:
            // 現在日時以降の同時刻を返す
            compResult = [[nextDate timeZeroSecond:YES] compare:[[NSDate date] timeZeroSecond:YES]];
            if (compResult == NSOrderedAscending || compResult == NSOrderedSame) {          // 指定時刻<現在時刻なら
                                                                                            // 明日の指定時刻にする
                nextDate = [NSDate date:[[NSDate date] dateByAddingTimeInterval:1 * 24 * 60 * 60] andTime:aTime];                
            } else {
                nextDate = [NSDate date:[NSDate date] andTime:aTime];                       // 今日の指定時刻にする
            }

            return nextDate;
            break;
            
        case NSWeekCalendarUnit:
            // 現在日時以降の直近の同じ曜日の日時を返す
            weekday = [self weekday];
            compResult = [[nextDate timeZeroSecond:YES] compare:[[NSDate date] timeZeroSecond:YES]];
            if (weekday == [[NSDate date] weekday] && (compResult == NSOrderedAscending || compResult == NSOrderedSame)) {   
                                                                                            // 今日と同じ指定曜日かつ指定時刻<現在時刻
                                                                                            // 明日の指定時刻にする
                nextDate = [NSDate date:[[NSDate date] dateByAddingTimeInterval:1 * 24 * 60 * 60] andTime:aTime];                
            } else {                
                nextDate = [NSDate date:[NSDate date] andTime:aTime];                       // 今日の指定時刻にする
            }                                                                           
            
            while ([nextDate weekday] != weekday) {                                         // 指定曜日と同じ曜日になるまで
                nextDate = [nextDate dateByAddingTimeInterval:1 * 24 * 60 * 60];            // +1日していく
            }
            return nextDate;
            break;
            
        case NSMonthCalendarUnit:
        {
            /*
             月末に設定した場合の次回通知日の計算結果(+1ヶ月)が以下のようになってしまう
             翌月にその日が無いと翌々月の日にちになってしまう
             2012/1/29 -> 2/29
             2012/1/30 -> 3/1   * 2/29になってほしい。要補正か？Local Notificationの通知はいつになるのか？
             2012/1/31 -> 3/2   * 2/29になってほしい。
             2012/2/1  -> 3/1
             */
            /*
             2012/8/31 -> 9/30 通知あり
             2012/8/31 -> 10/1 通知なし
             2012/8/31 -> 10/31 通知あり
             2012/8/30 -> 9/30 通知あり
             2012/8/30 -> 10/31 通知なし
             2013/1/30 -> 2/28 通知なし？なぜ？
             */
            
            
            // 月次の場合は更新してしまうと日にちが変わってしまう場合があるので 8/31 -> 9/31(9/31は無いので10/1になる)
            // 正しい月末日に修正する 8/31 -> 9/30
            NSDate *thisMonthDate = [NSDate dateFromYear:[[NSDate date] year]
                                                   month:[[NSDate date] month]
                                                     day:[nextDate day] 
                                                    hour:[aTime hour] 
                                                  minute:[aTime minute]
                                                  second:[aTime second]];
            if ([thisMonthDate month] != [[NSDate date] month]) {
                thisMonthDate = [NSDate dateFromYear:[[NSDate date] year]
                                               month:[[NSDate date] month]
                                                 day:1 - 1
                                                hour:[aTime hour]
                                              minute:[aTime minute]
                                              second:[aTime second]];
            }

            // 今月の通知日を過ぎているか判定する
            NSComparisonResult compResult = [[thisMonthDate dateZeroSecond:YES] compare:[NSDate date]];
            BOOL past = (compResult == NSOrderedAscending || compResult == NSOrderedSame) ? YES : NO;
            // 現在日時以降の直近の同じ日時分秒に更新する
            NSDate *nextMonthDate = [NSDate dateFromYear:[[NSDate date] year]
                                                   month:[[NSDate date] month] + ((past)? 1 : 0)    // すでに過去になっていたら翌月にする
                                                     day:[nextDate day] 
                                                    hour:[aTime hour] 
                                                  minute:[aTime minute] 
                                                  second:[aTime second]];

            // 同じ月末日が無い月で翌々月になってしまった場合は月末日を算出しなおす
            if ([nextMonthDate month] != [[NSDate date] month] + ((past)? 1 : 0)) {
                return [NSDate dateFromYear:[[NSDate date] year] 
                                      month:[[NSDate date] month] + ((past)? 1 : 0) + 1
                                        day:1 - 1 
                                       hour:[aTime hour] 
                                     minute:[aTime minute] 
                                     second:[aTime second]];
            } else {
                return nextMonthDate;
            }
            
            break;
        }   
        default:
            // 指定日を返す
            return [NSDate date:nextDate andTime:aTime];
            break;
    }
}


-(NSString *)stringTimeBy24Time:(BOOL)by24Time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@", [NSDate TM_timeTemplateBy24Time:by24Time]]];
    
    NSString *dateString = [dateFormatter stringFromDate:self];

    return dateString;
}

-(NSString *)TM_dateTemplate:(NSString *)dateTemplate timeTemplate:(NSString *)timeTemplate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ %@", dateTemplate, timeTemplate]];

    NSString *dateString = [dateFormatter stringFromDate:self];

    return dateString;
}

-(NSString *)TM_dateTemplate:(NSString *)dateTemplate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateTemplate];

    NSString *dateString = [dateFormatter stringFromDate:self];

    return dateString;
}

-(NSString *)stringDate
{
    // 日付のみ
    NSString *dateTemplate = [NSDateFormatter dateFormatFromTemplate:@"EdMMM" options:0 locale:[NSLocale currentLocale]];

    return [self TM_dateTemplate:dateTemplate];
}

-(NSString *)stringFullDateTimeBy24Time:(BOOL)by24Time
{
    // 日付
    NSString *dateTemplate = [NSDateFormatter dateFormatFromTemplate:@"EdMMM" options:0 locale:[NSLocale currentLocale]];
        
    return [self TM_dateTemplate:dateTemplate timeTemplate:[NSDate TM_timeTemplateBy24Time:by24Time]];
}

-(NSString *)stringWithFormat:(NSString *)format
{
    NSString *template = [NSDateFormatter dateFormatFromTemplate:format options:0 locale:[NSLocale currentLocale]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:template];
    
    NSString *dateString = [dateFormatter stringFromDate:self];

    return dateString;
}

#pragma mark 日付・時刻の文字列展開
-(NSString *)stringWithDateFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:format];

    NSString *dateString = [dateFormatter stringFromDate:self];

    DEBUGLOG(@"%@ => %@", format, dateString);

    return dateString;
}

-(NSString *)weekdayTimeBy24Time:(BOOL)by24Time
{
    // 曜日
    NSString *dateTemplate = [NSDateFormatter dateFormatFromTemplate:@"EEEE" options:0 locale:[NSLocale currentLocale]];
    
    return [self TM_dateTemplate:dateTemplate timeTemplate:[NSDate TM_timeTemplateBy24Time:by24Time]];
}

+(NSString *)stringWeekdayWithDays:(NSArray *)days by24Time:(BOOL)by24Time
{
    switch ([days count]) {
        case 0:
            return @"";
            break;

        case 1:
            // 単一選択 (月曜日 9:00)
            return [days[0] weekdayTimeBy24Time:by24Time];
            break;

        default:
        {
            // 複数選択 (月,火 9:00)
            NSString *dateTemplate = [NSDateFormatter dateFormatFromTemplate:@"E" options:0 locale:[NSLocale currentLocale]];
            NSMutableArray *array = [NSMutableArray array];
            for (NSDate *date in days) {
                [array addObject:[date TM_dateTemplate:dateTemplate]];
            }
            return [NSString stringWithFormat:@"%@ %@", [array componentsJoinedByString:@","],
                    [days[0] TM_dateTemplate:[NSDate TM_timeTemplateBy24Time:by24Time]]];
            break;
        }
    }
}

+(NSString *)TM_timeTemplateBy24Time:(BOOL)by24Time
{
    if (by24Time) {
        return LSTR(@"24TimeFullFormat");
    } else {
        return LSTR(@"12TimeFullFormat");
    }
}

-(NSString *)monthTimeBy24Time:(BOOL)by24Time
{
    // 月の日
    NSString *dateTemplate = [NSDateFormatter dateFormatFromTemplate:@"d" options:0 locale:[NSLocale currentLocale]];
    
    return [self TM_dateTemplate:dateTemplate timeTemplate:[NSDate TM_timeTemplateBy24Time:by24Time]];
}


// 月日ができるまで保留
//// 指定日付に月数をプラスした日付を返す(時刻はそのまま)
//+(NSDate *)date:(NSDate *)aDate byAddingMonthInterval:(NSInteger)months
//{
//    NSDateComponents *dateComponents = [[self sharedCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | 
//                                        NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit
//                                                                fromDate:aDate];
//    
//    NSDateComponents *catComponents = [[[NSDateComponents alloc] init] autorelease];
//    [catComponents setYear:[dateComponents year]];
//    [catComponents setMonth:[dateComponents month] + months];
//    [catComponents setDay:[dateComponents day]];
//    [catComponents setHour:[dateComponents hour]];
//    [catComponents setMinute:[dateComponents minute]];
//    [catComponents setSecond:0];
//    
//    return [[self sharedCalendar] dateFromComponents:catComponents];
//}
//

@end
