//
//  CCTaskCardItemGroups.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCTaskCardItemGroups.h"
#import "CCTaskCardDayGroup.h"

@interface CCTaskCardItemGroups ()

@property (nonatomic, strong) NSMutableArray<CCTaskCardDayGroup *> *dayGroups;

@end

@implementation CCTaskCardItemGroups

+ (instancetype)itemGroups {
    CCTaskCardItemGroups *itemGroups = [[CCTaskCardItemGroups alloc] init];
    itemGroups.dayGroups = [NSMutableArray array];
    return itemGroups;
}

- (NSInteger)addItem:(CCTaskCardItem *)item {
    
    for (CCTaskCardDayGroup *dayGroup in self.dayGroups) {
        //如果日期存在，加入
        if ([CCDateTool isSameDay:dayGroup.date anotherDay:item.cardDate]) {
            [dayGroup addItem:item];
            return -1;
        }
    }
    //如果日期不存在，创建新的
    NSInteger index = 0;
    
    for (CCTaskCardDayGroup *dayGroup in self.dayGroups) {
        if ([dayGroup.date timeIntervalSince1970] < [item.cardDate timeIntervalSince1970]) {
            index ++;
        }
    }
    
    CCTaskCardDayGroup *newDayGroup = [CCTaskCardDayGroup dayGroupWithDate:item.cardDate];
    [newDayGroup addItem:item];
    [self.dayGroups insertObject:newDayGroup atIndex:index];
    
//    [self sortByDate];
    
    return index;
}

- (void)removeItem:(CCTaskCardItem *)item {
    for (CCTaskCardDayGroup *dayGroup in self.dayGroups) {
        if ([dayGroup hasItem:item]) {
            [dayGroup removeItem:item];
            if (dayGroup.count == 0) {//当天没有item了，删除这个组
                [self.dayGroups removeObject:dayGroup];
            }
            return;
        }
    }
}

- (void)removeItem:(CCTaskCardItem *)item withIndexPath:(NSIndexPath *)indexPath {
    CCTaskCardDayGroup *dayGroup = [self dayGroupAtIndex:indexPath.section];
    [dayGroup removeItem:item];
    if (dayGroup.count == 0) {
        [self.dayGroups removeObject:dayGroup];
    }
}

- (void)sortByDate {
    if (self.dayGroups.count > 0) {
        [self.dayGroups sortUsingComparator:^NSComparisonResult(CCTaskCardDayGroup *dayGroup1, CCTaskCardDayGroup *dayGroup2) {
            if ([dayGroup1.date timeIntervalSince1970] > [dayGroup2.date timeIntervalSince1970]) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }];
    }
}

- (NSInteger)count {
    return self.dayGroups.count;
}

- (CCTaskCardDayGroup *)dayGroupAtIndex:(NSInteger)index {
    return self.dayGroups[index];
}

- (NSIndexPath *)indexPathForItem:(CCTaskCardItem *)item {
    for (NSInteger i = 0; i < self.dayGroups.count; i ++) {
        CCTaskCardDayGroup *group = self.dayGroups[i];
        if ([group hasItem:item]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[group rowIndexForItem:item] inSection:i];
            return indexPath;
        }
    }
    return nil;
}

/**
 删除所有记录
 */
- (void)removeAllGroups {
    [self.dayGroups removeAllObjects];
}

@end
