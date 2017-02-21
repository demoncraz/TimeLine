//
//  CCCommonCoverView.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/20.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCommonCoverView : UIButton

@property (nonatomic, strong) NSString *identifier;

/**
 显示遮罩层
 */
+ (instancetype)showWithIdentifier:(NSString *)identifier;


- (void)dismiss;

@end
