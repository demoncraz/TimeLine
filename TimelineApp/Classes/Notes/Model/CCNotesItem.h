//
//  CCNotesItem.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/20.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCNotesItem : NSObject

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSDate *date;

+ (instancetype)itemWithText:(NSString *)text date:(NSDate *)date;

@end
