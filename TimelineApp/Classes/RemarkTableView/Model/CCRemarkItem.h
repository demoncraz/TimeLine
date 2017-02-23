//
//  CCRemarkItem.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/23.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCRemarkItem : NSObject

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSString *imageName;

+ (instancetype)itemWithText:(NSString *)text imageName:(NSString *)imageName;

@end
