//
//  CCDotItem.m
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/14.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCDotItem.h"

@implementation CCDotItem

+ (instancetype)itemWithDate:(NSDate *)date dotStyle:(CCDotStyle)dotStyle {
    CCDotItem *item = [[CCDotItem alloc] init];
    item.date = date;
    item.dotStyle = dotStyle;
    return item;
}

@end
