//
//  CCTaskCardDayGroup.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCTaskCardDayGroup.h"

@interface CCTaskCardDayGroup ()

@property (nonatomic, strong) NSMutableArray<CCTaskCardItem *> *items;

@end

@implementation CCTaskCardDayGroup

+ (instancetype)dayGroupWithDate:(NSDate *)date {
    CCTaskCardDayGroup *dayGroup = [[CCTaskCardDayGroup alloc] init];
    dayGroup.date = date;
    dayGroup.items = [NSMutableArray array];
    return dayGroup;
}

- (void)addItem:(CCTaskCardItem *)item {
    [self.items addObject:item];
    [self sortByDate];
}

- (void)removeItem:(CCTaskCardItem *)item {
    [self.items removeObject:item];
}

- (void)sortByDate {
    if (self.items.count > 0) {
        [self.items sortUsingComparator:^NSComparisonResult(CCTaskCardItem *item1, CCTaskCardItem *item2) {
            if ([item1.cardDate timeIntervalSince1970] > [item2.cardDate timeIntervalSince1970]) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }];
    }
}

- (NSInteger)count {
    return self.items.count;
}

- (CCTaskCardItem *)itemAtIndex:(NSInteger)index {
    return self.items[index];
}

- (BOOL)hasItem:(CCTaskCardItem *)item {
    return [self.items containsObject:item];
}

- (NSInteger)rowIndexForItem:(CCTaskCardItem *)item {
    return [self.items indexOfObject:item];
}

@end
