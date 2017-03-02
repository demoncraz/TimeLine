//
//  CCBackTodayButton.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/28.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCBackTodayButton.h"

#define ButtonScreenRightMargin 10
#define BackButtonDefaultW 70
#define BackButtonDefaultH 30

@interface CCBackTodayButton ()

@property (nonatomic, weak) UIImageView *mainImageView;

@property (nonatomic, weak) UIImageView *circle1;

@property (nonatomic, weak) UIImageView *circle2;

@end

@implementation CCBackTodayButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.CC_width = BackButtonDefaultW;
        self.CC_height = BackButtonDefaultH;
        self.alpha = 0.7;
        
//        [self addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        //主要图片
        UIImageView *mainImageView = [[UIImageView alloc] init];
        mainImageView.image = [UIImage imageNamed:@"today_button"];
        _mainImageView = mainImageView;
        [self addSubview:mainImageView];

        //circle1
        UIImageView *circle1 = [[UIImageView alloc] init];
        circle1.image = [UIImage imageNamed:@"today_circle1"];
        _circle1 = circle1;
        [self insertSubview:circle1 belowSubview:self.mainImageView];
        
        //circle2
        UIImageView *circle2 = [[UIImageView alloc] init];
        circle2.image = [UIImage imageNamed:@"today_circle1"];
        _circle2 = circle2;
        [self insertSubview:circle2 belowSubview:self.circle1];
        
        //设置frame
        CGFloat mainImageWH = BackButtonDefaultH;
        self.mainImageView.frame = CGRectMake(BackButtonDefaultW - mainImageWH - ButtonScreenRightMargin, 0, mainImageWH, mainImageWH);
        CGFloat circle1WH = BackButtonDefaultH * 0.4;
        CGFloat circle2WH = BackButtonDefaultH * 0.2;
        
        self.circle1.frame = CGRectMake(BackButtonDefaultW - circle1WH - ButtonScreenRightMargin, (self.CC_height - circle1WH) * 0.5, circle1WH, circle1WH);
        self.circle2.frame = CGRectMake(BackButtonDefaultW - circle2WH - ButtonScreenRightMargin, (self.CC_height - circle2WH) * 0.5, circle2WH, circle2WH);
        
    }
    return self;
}


- (void)hideButtonWithCompletion:(void(^)())completion {
    [UIView animateWithDuration:0.3 animations:^{
        self.mainImageView.transform = CGAffineTransformIdentity;
        self.circle1.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
}

- (void)showButton {
    [UIView animateWithDuration:0.3 animations:^{
        self.mainImageView.transform = CGAffineTransformMakeTranslation(-25, 0);
        self.circle1.transform = CGAffineTransformMakeTranslation(-10, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
//            self.CC_x -= 40;
        } completion:^(BOOL finished) {
        }];
    }];
}

@end
