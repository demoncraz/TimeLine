//
//  CCCardContentView.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTaskCardItem.h"
#import "CCRemarkContainerView.h"
@class CCCardContentView;

typedef NS_ENUM(NSInteger, CCCardFirstResponder) {
    CCCardFirstResponderTitle,
    CCCardFirstResponderDatePicker
};

@protocol CCCardContentViewDelegate <NSObject>

- (void)CCCardContentView:(CCCardContentView *)cardContentView didChangeTitle:(NSString *)title;
- (void)CCCardContentView:(CCCardContentView *)cardContentView didChangeDate:(NSDate *)date;

@end


@interface CCCardContentView : UIView

@property (nonatomic, weak) id<CCCardContentViewDelegate> delegate;

//控制是否允许编辑
@property (nonatomic, assign, getter=isAllowEditing) BOOL allowEditing;

@property (nonatomic, strong) CCTaskCardItem *item;

@property (nonatomic, weak) CCRemarkContainerView *containerView;


- (void)setDataWithTaskCardItem:(CCTaskCardItem *)item;

- (void)setFirstResponder:(CCCardFirstResponder)firstResponder;


@end
