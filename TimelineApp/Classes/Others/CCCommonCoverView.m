//
//  CCCommonCoverView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/20.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCommonCoverView.h"

@implementation CCCommonCoverView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = ColorWithRGB(0, 0, 0, 0.7);
        self.alpha = 0;
        [self addTarget:self action:@selector(commonCoverViewClick:) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}

- (void)commonCoverViewClick:(CCCommonCoverView*)coverView {
    //发送通知
    if (coverView) {
        [CCNotificationCenter postNotificationName:CCCommonCoverViewWillDismissNotification object:coverView.identifier];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        coverView.alpha = 0;
    } completion:^(BOOL finished) {
        [coverView removeFromSuperview];
    }];
}

+ (instancetype)showWithIdentifier:(NSString *)identifier {
    CCCommonCoverView *coverView = [[CCCommonCoverView alloc] init];
    coverView.identifier = identifier;
    [[UIApplication sharedApplication].keyWindow addSubview:coverView];
    [UIView animateWithDuration:0.3 animations:^{
        coverView.alpha = 1;
    }];
    return coverView;
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
