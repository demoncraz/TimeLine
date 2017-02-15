//
//  CCDateTool.h
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/13.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCDateTool : NSObject



/**
  根据日期计算农历年、月、日

 @param date 日期
 @"month" : month,
 @"day" : day
 */
+ (NSDictionary *)getChineseDateComponentsFromDate:(NSDate *)date;


/**
 根据日期计算年、月、日
 @param date 日期
 @return 字符串字典
 @"year" : year,
 @"month" : month,
 @"day" : day
 */
+ (NSDictionary *)getDateComponentsFromDate:(NSDate *)date;

/**
 计算给定日期是星期几
 
 @param date 日期
 @return 星期几 0为星期天 6为星期六
 */
+ (NSInteger)getWeedDayFromDate:(NSDate *)date;

/**
 根据给定年份、月份、日返回一个NSDate对象
 
 @param year 年份
 @param month 月份
 @param day 天
 @return NSDate对象
 */
+ (NSDate *)getDateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

/**
 计算某个月有几天
 
 @param month 月份
 @param year 年份
 @return 本月天数
 */
+ (NSInteger)getTotalDaysOfMonth:(NSInteger)month year:(NSInteger)year;


/**
 判断某天是不是今天

 @param date 日期
 */
+ (BOOL)isToday:(NSDate *)date;


/**
 判断两个时间是不是同一天

 @param aDay 第一个时间
 @param anotherDay 第二个时间
 @return YES为同一天，NO相反
 */
+ (BOOL)isSameDay:(NSDate *)aDay anotherDay:(NSDate *)anotherDay;

@end
