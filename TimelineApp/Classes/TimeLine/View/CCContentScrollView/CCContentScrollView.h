//
//  CCContentScrollView.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTaskCard.h"
@class CCContentScrollView;


@protocol ContentScrollViewDelegate <NSObject>

//确定卡片个数
- (NSInteger)numberOfRowsInContentScrollView:(CCContentScrollView *)contentScrollView;

//设置卡片
- (CCTaskCard *)contentScrollView:(CCContentScrollView *)contentScrollView cardForRow:(NSInteger)row;




@end

@interface CCContentScrollView : UIScrollView

//额外代理，不与scrollView的代理冲突
@property (nonatomic, weak) id<ContentScrollViewDelegate> exDelegate;


/**
 刷新子控件数据
 */
- (void)reloadDate;

@end
