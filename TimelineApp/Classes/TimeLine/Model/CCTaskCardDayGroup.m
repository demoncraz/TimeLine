//
//  CCTaskCardDayGroup.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCTaskCardDayGroup.h"

@interface CCTaskCardDayGroup ()


@end

@implementation CCTaskCardDayGroup

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"items" : [CCTaskCardItem class]
             };
}

+ (instancetype)dayGroupWithDate:(NSDate *)date {
    CCTaskCardDayGroup *dayGroup = [[CCTaskCardDayGroup alloc] init];
    dayGroup.date = [CCDateTool getDateWithoutDailyTimeFromDate:date];
    dayGroup.items = [NSMutableArray array];
    return dayGroup;
}

@end
