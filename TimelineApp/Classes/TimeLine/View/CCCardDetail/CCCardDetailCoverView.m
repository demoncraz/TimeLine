//
//  CCCardDetailCoverView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/22.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCardDetailCoverView.h"
#import "CCCardDetailView.h"

@interface CCCardDetailCoverView ()


@property (nonatomic, weak) CCCardDetailView *cardDetailView;

@end

@implementation CCCardDetailCoverView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CCCardDetailView *cardDetailView = [CCCardDetailView cardDetailView];
//        cardDetailView.backgroundColor = [UIColor whiteColor];
//        [cardDetailView sizeToFit];
        cardDetailView.CC_centerX = [UIApplication sharedApplication].keyWindow.CC_centerX;
        cardDetailView.CC_centerY = [UIApplication sharedApplication].keyWindow.CC_centerY - 49;
        cardDetailView.CC_width = ScreenW * 0.8;
        _cardDetailView = cardDetailView;
        [self addSubview:cardDetailView];
        [self setupActions];
    }
    return self;
}

- (void)setupActions {
    [self.cardDetailView.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.cardDetailView.remarkButton addTarget:self action:@selector(remarkButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.cardDetailView.doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.cardDetailView.confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 关闭按钮点击
- (void)closeButtonClick {//模拟点击遮罩
    [self dismissView];
}

#pragma mark - 备注按钮点击
- (void)remarkButtonClick {
    
}

#pragma mark - 完成按钮点击
- (void)doneButtonClick {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:CCConfirmNotShowUDKey]){//没有确认不再提醒, 提醒用户
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            self.cardDetailView.bottomView.CC_x -= self.cardDetailView.CC_width;
        } completion:^(BOOL finished) {
        }];
    } else {
        [self confirmCompletion];
    }
    
}


/**
 确认按钮点击
 */
- (void)confirmButtonClick {
    [self confirmCompletion];
}


/**
 确认完成
 */
- (void)confirmCompletion {
    CCTaskCardItem *item = self.cardDetailView.item;
    item.done = YES;
    [self.delegate CCCardDetailCoverView:self didCompleteTaskItem:item];
    [self dismissView];
}

- (void)showWithItem:(CCTaskCardItem *)item {
    self.cardDetailView.item = item;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismissView {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
