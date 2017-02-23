//
//  CCRemarkItem.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/23.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCRemarkItem.h"

@implementation CCRemarkItem

+ (instancetype)itemWithText:(NSString *)text imageName:(NSString *)imageName {
    CCRemarkItem *item = [[CCRemarkItem alloc] init];
    item.text = text;
    item.imageName = imageName;
    return item;
}

@end
