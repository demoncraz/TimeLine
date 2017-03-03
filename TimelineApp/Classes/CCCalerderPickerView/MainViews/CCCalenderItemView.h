//
//  CCCalenderItemView.h
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/13.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDotItem.h"

@interface CCCalenderItemView : UICollectionViewCell

@property (nonatomic, assign) BOOL shouldShowDot;

@property (nonatomic, strong) NSDate *itemDate;


/**
 根据模型显示dot

 @param item 模型
 */
- (void)showDotWithDotItem:(CCDotItem *)item;

@end
