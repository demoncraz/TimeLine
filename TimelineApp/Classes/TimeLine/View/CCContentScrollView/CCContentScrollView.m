//
//  CCContentScrollView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCContentScrollView.h"
#import "CCTaskCardItem.h"
#import "Masonry.h"
#define ScreenW [UIScreen mainScreen].bounds.size.width

@interface CCContentScrollView ()

@property (nonatomic, strong) NSMutableArray *cards;

@property (nonatomic, strong) UIImageView *noInfoImageView;

@end

@implementation CCContentScrollView

#pragma mark - lazy loading
- (NSMutableArray *)cards {
    if (_cards == nil) {
        _cards = [NSMutableArray array];
    }
    return _cards;
}


- (UIImageView *)noInfoImageView {
    if (_noInfoImageView == nil) {
        _noInfoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_card"]];
    }
    return _noInfoImageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //注册监听newCard完成的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewCard:) name:CCNewCardCompleteNofitifation object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];

    if (self.cards.count == 0) {//只有当第一次加载的时候设置卡片
        [self setupTaskCards];
    }
    
    
}

#pragma mark - 展示卡片
- (void)setupTaskCards {
    
    
    NSInteger number = [self.exDelegate numberOfRowsInContentScrollView:self];
    
    if (number == 0) {//如果卡片个数为0，展示背景图
        
        [self addSubview:self.noInfoImageView];
        
        [self.noInfoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(120);
            make.centerX.equalTo(self.mas_centerX);
        }];
        
        return;
    }
    
    for (NSInteger i = 0; i < number; i++) {
        CCTaskCard *card = [self.exDelegate contentScrollView:self cardForRow:i];
        [self addSubview:card];
        [self.cards addObject:card];
    }
    
    
    [self arrangeTaskCards];
}

#pragma mark - 排列卡片的位置
- (void)arrangeTaskCards {
    //重新获取卡片个数
    NSInteger number = [self.exDelegate numberOfRowsInContentScrollView:self];
    
    for (NSInteger i = 0; i < number; i++) {
        CCTaskCard *card = self.cards[i];
        
        if (i == 0) {
            [card mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_top).offset(44);
                make.left.equalTo(self.mas_left).offset(20);
                make.right.equalTo(self.mas_right).offset(-20);
                NSInteger cardWidth = [UIScreen mainScreen].bounds.size.width - 40;
                make.width.mas_equalTo(@(cardWidth));
            }];
        } else {
            [card mas_remakeConstraints:^(MASConstraintMaker *make) {
                CCTaskCard *aboveCard = self.cards[i - 1];
                if (i == number - 1) {
                    make.bottom.equalTo(self.mas_bottom).offset(-20);
                }
                make.left.right.equalTo(aboveCard);
                make.top.equalTo(aboveCard.mas_bottom).offset(20);
            }];
        }

    }
    
    
}

#pragma mark - 刷新子控件数据
/**
 刷新子控件数据
 */
- (void)reloadDate {
    
    //重新判断卡片个数，如果大于0，去掉空白背景图片
    if (self.cards.count > 0) {
        [self.noInfoImageView removeFromSuperview];
    }
    //将cards数组按照日期排序
    
    [self.cards sortUsingComparator:^NSComparisonResult(CCTaskCard *card1, CCTaskCard *card2) {
        if ([card1.taskCardItem.cardDate timeIntervalSince1970] > [card2.taskCardItem.cardDate timeIntervalSince1970]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedAscending;
        }
    }];
    
    [self arrangeTaskCards];
}


- (void)addNewCard:(NSNotification *)notification {
    CCTaskCardItem *item = notification.object;
    CCTaskCard *taskCard = [CCTaskCard taskCardWithItem:item];
    [self.cards addObject:taskCard];
    [self addSubview:taskCard];
}


@end
