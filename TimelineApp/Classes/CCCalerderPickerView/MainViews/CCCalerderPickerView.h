//
//  CCCalerderPickerView.h
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/13.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDotItem.h"


@interface CCCalerderPickerView : UIView


/**
 创建单例对象

 @return 单例对象
 */
+ (instancetype)calenderPickerView;



/**
  为某天设置标记点

 */
- (void)setDotForDates:(NSArray<CCDotItem *> *)dotItems;


/**
 召唤控件出来
 */
- (void)show;

/**
 隐藏并移除控件
 */
- (void)dismiss;



@end
