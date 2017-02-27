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

@interface CCTaskCardDayGroup : NSObject

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, assign) NSInteger count;

+ (instancetype)dayGroupWithDate:(NSDate *)date;

- (void)addItem:(CCTaskCardItem *)item;

- (void)removeItem:(CCTaskCardItem *)item;

- (CCTaskCardItem *)itemAtIndex:(NSInteger)index;

- (BOOL)hasItem:(CCTaskCardItem *)item;

- (NSInteger)rowIndexForItem:(CCTaskCardItem *)item;

@end
