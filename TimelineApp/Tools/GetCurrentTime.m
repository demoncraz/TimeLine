//
//  GetCurrentTime.m
//  TimelineApp
//
//  Created by demoncraz on 2017/1/28.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "GetCurrentTime.h"

/**
 得到当前的时间

 @return NSString
 */

NSString* getCurrentDate(NSString* formatterString) {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:formatterString];
    
    return [dateFormatter stringFromDate:[NSDate date]];
    
}
