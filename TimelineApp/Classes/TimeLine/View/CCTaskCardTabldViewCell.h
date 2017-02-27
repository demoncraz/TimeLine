//
//  CCTaskCardTabldViewCell.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/6.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDatePicker.h"
#import "CCTaskCardItem.h"
#import "CCRemarkContainerView.h"

typedef enum {
    CCTaskCardTabldViewCellResponderTypeTitle,
    CCTaskCardTabldViewCellResponderTypeContent,
    CCTaskCardTabldViewCellResponderTypeDatePicker
} CCTaskCardTabldViewCellResponderType;

@interface CCTaskCardTabldViewCell : UITableViewCell

//数据模型
@property (nonatomic, strong) CCTaskCardItem *taskCardItem;

+ (instancetype)taskCardCellWithItem:(CCTaskCardItem *)item;

@end
