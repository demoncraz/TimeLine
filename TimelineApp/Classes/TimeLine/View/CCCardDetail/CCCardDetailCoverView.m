//
//  CCCardDetailCoverView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/22.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCardDetailCoverView.h"
#import "CCCardDetailView.h"
#import "CCRemarkNavigationController.h"
#import "CCRemarkViewController.h"
#import "CCRemarkItem.h"

#define CCStatusBarH 20
#define CCCardDetailTransitAnimationDuration 0.3
#define CCCardDetailViewDefaultCenterX [UIApplication sharedApplication].keyWindow.CC_centerX
#define CCCardDetailViewDefaultCenterY [UIApplication sharedApplication].keyWindow.CC_centerY - 49

@interface CCCardDetailCoverView ()


@property (nonatomic, weak) CCCardDetailView *cardDetailView;

@property (nonatomic, strong) CCRemarkNavigationController *navVc;

@end

@implementation CCCardDetailCoverView

#pragma mark - lazy loading

- (CCRemarkNavigationController *)navVc {
    if (_navVc == nil) {
        _navVc = [[CCRemarkNavigationController alloc] init];
        _navVc.view.CC_height = ScreenH - CCStatusBarH - self.cardDetailView.CC_height;
    }
    return _navVc;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CCCardDetailView *cardDetailView = [CCCardDetailView cardDetailView];

        cardDetailView.CC_width = ScreenW * 0.8;
        cardDetailView.CC_centerX = CCCardDetailViewDefaultCenterX;
        cardDetailView.CC_centerY = CCCardDetailViewDefaultCenterY;
        _cardDetailView = cardDetailView;
        [self addSubview:cardDetailView];
        
        //监听备注列表的通知
        [CCNotificationCenter addObserver:self selector:@selector(remarkVcWillDismiss) name:CCRemarkViewControllerWillDismissNotification object:nil];
        
        [self setupActions];
    }
    return self;
}

- (void)dealloc {
    [CCNotificationCenter removeObserver:self];
}

- (void)setupActions {
    [self.cardDetailView.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.cardDetailView.remarkButton addTarget:self action:@selector(remarkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cardDetailView.doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.cardDetailView.confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 关闭按钮点击
- (void)closeButtonClick {//模拟点击遮罩
    [self dismissView];
}

#pragma mark - 备注按钮点击
- (void)remarkButtonClick:(UIButton *)button {
    button.enabled = NO;
    //上移详情窗口
    [UIView animateWithDuration:CCCardDetailTransitAnimationDuration animations:^{
        self.cardDetailView.CC_y = CCStatusBarH;
    }];
    //弹出remarkVc
    
    [self addSubview:self.navVc.view];
    self.navVc.item = self.cardDetailView.item;
    [UIView animateWithDuration:CCCardDetailTransitAnimationDuration animations:^{
        self.navVc.view.CC_y = CCStatusBarH + self.cardDetailView.CC_height;
    }];
    
    
}

#pragma mark - 完成按钮点击
- (void)doneButtonClick {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:CCConfirmNotShowUDKey]){//没有确认不再提醒, 提醒用户
        [UIView animateWithDuration:CCCardDetailTransitAnimationDuration delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
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
    self.item = item;
    self.cardDetailView.item = item;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:CCCardDetailTransitAnimationDuration animations:^{
        self.alpha = 1;
    }];
}

- (void)dismissView {
    [UIView animateWithDuration:CCCardDetailTransitAnimationDuration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 监听到备注列表关闭的通知
- (void)remarkVcWillDismiss {
    [UIView animateWithDuration:CCCardDetailTransitAnimationDuration animations:^{
        self.cardDetailView.CC_centerY = CCCardDetailViewDefaultCenterY;
    } completion:^(BOOL finished) {
        self.cardDetailView.remarkButton.enabled = YES;
    }];
}

@end
