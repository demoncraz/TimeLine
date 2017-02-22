//
//  CCTaskCardItem.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/2.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCTaskCardItem.h"

@implementation CCTaskCardItem

//使用字典快速创建模型对象
+ (instancetype)taskCardItemWithDict:(NSDictionary *)dict {

    CCTaskCardItem *item = [[CCTaskCardItem alloc] init];
    
    [item setValuesForKeysWithDictionary:dict];
    
    return item;
}

+ (instancetype)taskCardItemWithTitle:(NSString *)title content:(NSString *)content date:(NSDate *)date alertType:(TaskCardAlertType)alertType {
    CCTaskCardItem *item = [[CCTaskCardItem alloc] init];
    item.cardTitle = title;
    item.cardContent = content;
    item.cardDate = date;
    item.taskCardAlertType = alertType;
    
    return item;
}


- (NSString *)getKeyFromItem {
    
    NSString *keyString = [NSString stringWithFormat:@"%f", [self.cardDate timeIntervalSince1970]];
    
    return keyString;
}

/**
 根据模型计算cell高度
 */
- (CGFloat)height {
    NSString *contentString = self.cardContent;
    CGSize textSize = [contentString boundingRectWithSize:CGSizeMake(CCTaskCardContentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size:12]} context:nil].size;
    
    return textSize.height + 60;
}


@end
