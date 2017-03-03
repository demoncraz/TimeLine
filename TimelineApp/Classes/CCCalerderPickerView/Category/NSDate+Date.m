//
//  NSDate+Date.m
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/13.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "NSDate+Date.h"
#import <objc/message.h>

@interface NSDate ()

@end

@implementation NSDate (Date)



- (void)setYear:(NSInteger)year {
    
}
- (NSInteger)year {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    return [[formatter stringFromDate:self] integerValue];
}


- (void)setMonth:(NSInteger)month {
    
}
- (NSInteger)month {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM"];
    return [[formatter stringFromDate:self] integerValue];
}


- (void)setDay:(NSInteger)day {
    
}
- (NSInteger)day {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    return [[formatter stringFromDate:self] integerValue];
}


- (void)setHour:(NSInteger)hour {
    
}
- (NSInteger)hour {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH"];
    return [[formatter stringFromDate:self] integerValue];
}


- (void)setMinute:(NSInteger)minute {
    
}
- (NSInteger)minute {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm"];
    return [[formatter stringFromDate:self] integerValue];
}

- (void)setSecond:(NSInteger)second {
    
}
- (NSInteger)second {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ss"];
    return [[formatter stringFromDate:self] integerValue];
}

- (NSDate *)c_date {
    
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate:self];
    
    return [self dateByAddingTimeInterval:interval];

}


@end
