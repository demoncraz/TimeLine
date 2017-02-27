//
//  CCCalenderItemButton.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCalenderItemButton : UIButton

@property (nonatomic, strong) NSDate *itemDate;

+ (instancetype)calendarItemButton;

@end
