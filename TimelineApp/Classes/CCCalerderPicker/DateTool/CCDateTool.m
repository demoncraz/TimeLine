//
//  CCDateTool.m
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/13.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCDateTool.h"

@implementation CCDateTool


/**
 根据日期计算农历年、月、日
 
 @param date 日期
 @"month" : month,
 @"day" : day
 */


+ (NSDictionary *)getChineseDateComponentsFromDate:(NSDate *)date {
    NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    NSInteger day = [cal component:NSCalendarUnitDay fromDate:date];
    NSInteger month = [cal component:NSCalendarUnitMonth fromDate:date];
    NSDictionary *dateDict = @{
                               @"month" : [NSString stringWithFormat:@"%ld",month],
                               @"day" : [NSString stringWithFormat:@"%ld",day]
                               };
    return dateDict;
}

+ (NSDictionary *)getDateComponentsFromDate:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:date];
    NSString *year = [dateString substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [dateString substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [dateString substringWithRange:NSMakeRange(8, 2)];
    NSDictionary *dateDict = @{
                               @"year" : year,
                               @"month" : month,
                               @"day" : day
                               };
    return dateDict;
}

/**
 计算给定日期是星期几
 
 @param date 日期
 @return 星期几 0为星期天 6为星期六
 */
+ (NSInteger)getWeedDayFromDate:(NSDate *)date {
    NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSInteger weekDay = [cal component:NSCalendarUnitWeekday fromDate:date];
    return weekDay - 1;
}

/**
 根据给定年份、月份、日返回一个NSDate对象

 @param year 年份
 @param month 月份
 @param day 天
 @return NSDate对象
 */
+ (NSDate *)getDateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld", year, month, day]];
}


/**
 计算某个月有几天

 @param month 月份
 @param year 年份
 @return 本月天数
 */
+ (NSInteger)getTotalDaysOfMonth:(NSInteger)month year:(NSInteger)year {
    switch (month) {
        case 1:
            return 31;
        case 2:
            return ((year%4==0)&&(year%100!=0))||(year%400==0) ? 29 : 28;
        case 3:
            return 31;
        case 4:
            return 30;
        case 5:
            return 31;
        case 6:
            return 30;
        case 7:
            return 31;
        case 8:
            return 31;
        case 9:
            return 30;
        case 10:
            return 31;
        case 11:
            return 30;
        case 12:
            return 31;
        default:
            return 0;
    }
}


+ (BOOL)isToday:(NSDate *)date {
    NSDate *currentDate = [NSDate date];
    NSDictionary *currentDateDict = [self getDateComponentsFromDate:currentDate];
    NSDictionary *dateDict = [self getDateComponentsFromDate:date];
    __block NSInteger i = 0;
    [dateDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSString * obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:currentDateDict[key]]) i++;
    }];
    return i == 3;
}


/**
 判断两个时间是不是同一天
 
 @param aDay 第一个时间
 @param anotherDay 第二个时间
 @return YES为同一天，NO相反
 */
+ (BOOL)isSameDay:(NSDate *)aDay anotherDay:(NSDate *)anotherDay {
    NSDictionary *dateDict1 = [self getDateComponentsFromDate:aDay];
    NSDictionary *dateDict2 = [self getDateComponentsFromDate:anotherDay];
    __block NSInteger i = 0;
    [dateDict1 enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSString * obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:dateDict2[key]]) i++;
    }];
    return i == 3;
}

@end
