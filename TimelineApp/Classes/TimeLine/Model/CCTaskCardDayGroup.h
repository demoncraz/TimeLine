//
//  CCTaskCardDayGroup.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCTaskCardItem.h"
#import "CCDateTool.h"

#import "MJExtension.h"

@interface CCTaskCardDayGroup : NSObject

@property (nonatomic, strong) NSMutableArray<CCTaskCardItem *> *items;

@property (nonatomic, strong) NSDate *date;

+ (instancetype)dayGroupWithDate:(NSDate *)date;





@end
