//
//  CCNotesItem.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/20.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNotesItem.h"

@implementation CCNotesItem

+ (instancetype)itemWithText:(NSString *)text date:(NSDate *)date{
    CCNotesItem *item = [[CCNotesItem alloc] init];
    item.text = text;
    item.date = date;
    return item;
}

@end
