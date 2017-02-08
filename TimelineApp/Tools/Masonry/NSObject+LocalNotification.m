
//
//  NSObject+LocalNotification.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/8.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "NSObject+LocalNotification.h"

@implementation NSObject (LocalNotification)


/**
 注册添加本地通知
 
 @param date 通知的时间
 @param content 通知的内容
 @param key 通知的标示
 
 */
+ (void)registerLocalNotificationWithDate:(NSDate *)date content:(NSString *)content key:(NSString *)key {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    //配置通知属性
    notification.alertBody = content;
    notification.fireDate = date;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.repeatInterval = 0;
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = @"alert_sound.m4a";
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:content forKey:key];
    notification.userInfo = userInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}


/**
 取消对应的本地通知
 
 @param key 通知的key
 */
+ (void)cancelLocalNotificationWithKey:(NSString *)key {
    
    NSArray *notificationArr = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in notificationArr) {
        if (notification ){
            NSDictionary *userInfoDict = notification.userInfo;
            NSString *notificationKey = [[userInfoDict allKeys] lastObject];
            if ([notificationKey isEqualToString:key]) {//找到了对应的通知
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }
        }
    }
    
}

@end
