//
//  NSObject+LocalNotification.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/8.
//  Copyright © 2017年 demoncraz. All rights reserved.
//


/**********添加本地通知********/



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (LocalNotification)


/**
 注册添加本地通知

 @param date 通知的时间
 @param content 通知的内容
 @param key 通知的key
 */
+ (void)registerLocalNotificationWithDate:(NSDate *)date content:(NSString *)content key:(NSString *)key;


/**
 取消对应的本地通知

 @param key 通知的key
 */
+ (void)cancelLocalNotificationWithKey:(NSString *)key;



@end
