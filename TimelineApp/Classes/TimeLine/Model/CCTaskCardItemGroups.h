//
//  CCTaskCardItemGroups.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCTaskCardDayGroup.h"

@interface CCTaskCardItemGroups : NSObject


@property (nonatomic, assign, readonly) NSInteger count;

+ (instancetype)itemGroups;


/**
 添加item

 @param item item
 @return 新的组序列，如果未添加新组，返回-1
 */
- (NSInteger)addItem:(CCTaskCardItem *)item;

- (void)removeItem:(CCTaskCardItem *)item;

- (void)removeItem:(CCTaskCardItem *)item withIndexPath:(NSIndexPath *)indexPath;

- (CCTaskCardDayGroup *)dayGroupAtIndex:(NSInteger)index;

- (NSIndexPath *)indexPathForItem:(CCTaskCardItem *)item;

/**
 删除所有记录
 */
- (void)removeAllGroups;

@end
