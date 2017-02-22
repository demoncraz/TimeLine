//
//  CCTaskCardItem.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/2.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    TaskCardAlertTypeNone,
    TaskCardAlertTypeNotification,
    TaskCardAlertTypeOther
} TaskCardAlertType;

/***模型数据**/
@interface CCTaskCardItem : NSObject

@property (nonatomic, strong) NSDate *cardDate;

@property (nonatomic, strong) NSString *cardTitle;

@property (nonatomic, strong) NSString *cardContent;

@property (nonatomic, assign) TaskCardAlertType taskCardAlertType;

@property (nonatomic, strong) NSString *cardAvatarImage;

@property (nonatomic, assign, getter=isDone) BOOL done;


/***其他数据**/
@property (nonatomic, assign) CGFloat height;


//使用字典快速创建模型对象
+ (instancetype)taskCardItemWithTitle:(NSString *)title content:(NSString *)content date:(NSDate *)date alertType:(TaskCardAlertType)alertType;

+ (instancetype)taskCardItemWithDict:(NSDictionary *)dict;



/**
 根据item的date，用timeSince1970获得对应通知的key

 @return key
 */
- (NSString *)getKeyFromItem;

@end
