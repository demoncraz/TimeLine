//
//  CCDotItem.h
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/14.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CCDotStyleNone,         //没有标记
    CCDotStyleImportant,   //重要，标记为红点
    CCDotStyleNormal      //普通，标记为蓝点
} CCDotStyle;


@interface CCDotItem : NSObject

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, assign) CCDotStyle dotStyle;

+ (instancetype)itemWithDate:(NSDate *)date dotStyle:(CCDotStyle)dotStyle;

@end
