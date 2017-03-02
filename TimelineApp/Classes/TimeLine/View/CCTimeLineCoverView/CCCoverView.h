//
//  CCCoverView.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCCoverView;


/*定义CoverView隐藏的选项*/
typedef enum {
    CCCoverViewDismissOptionCancel,//取消
    CCCoverViewDismissOptionAddNew //新卡片添加完成
} CCCoverViewDismissOption;


@interface CCCoverView : UIView

/**
 显示新建卡片
 */
- (void)showNewCard;

/**
 隐藏CoverView
 

 set property coverView to be nil after the dismiss call if there is strong refence on it
 
 @param option 隐藏选项
 CCCoverViewDismissOptionCancel 取消
 CCCoverViewDismissOptionAddNew 新增完毕
 
 */
- (void)dismissCoverViewWithOptions:(CCCoverViewDismissOption)option;


@end
