//
//  CCCoverView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCoverView.h"
#import "Masonry.h"
#import "UIView+FindViewThatIsFirstResponder.h"
#import "GetCurrentTime.h"
#import "GetCurrentTime.h"
#import "CCTaskCardItem.h"
#import "CCNewCardTagContainerView.h"
#import "CCCardContentView.h"
#import "CCDateTool.h"

#define ContentViewTopMargin 145
#define ContentViewLeftMargin 10
#define ContentViewRightMargin 10
#define ContentViewMinHeight 90


@interface CCCoverView ()<CCNewCardTagContainerViewDelegate, CCCardContentViewDelegate> {
    CCTaskCardItem *_newCardItem;
}

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) CCTaskCardItem *newCardItem;

@property (nonatomic, weak) CCNewCardTagContainerView *tagView;

@property (nonatomic, assign) CGRect tagViewOriFrame;

@property (nonatomic, weak) CCCardContentView *cardView;


@end

@implementation CCCoverView

#pragma mark - lazy loading


- (CCTaskCardItem *)newCardItem {
    if (_newCardItem == nil) {
        _newCardItem = [[CCTaskCardItem alloc] init];
        _newCardItem.cardDate = [NSDate date];//默认为当前时间
    }
    return _newCardItem;
}

- (void)setNewCardItem:(CCTaskCardItem *)newCardItem {
    _newCardItem = newCardItem;
    [self.cardView setDataWithTaskCardItem:newCardItem];//自动更新
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];

        self.alpha = 0;
        [self showNewCard];
        [self showTagView];
        
    }
    return self;
}


- (void)showTagView {
    CCNewCardTagContainerView *tagView = [[CCNewCardTagContainerView alloc] init];
    tagView.CCDelegate = self;
    tagView.frame = CGRectMake(ContentViewLeftMargin, ContentViewTopMargin + self.cardView.CC_height + 20, ScreenW - 2 * ContentViewLeftMargin, 160);
    _tagViewOriFrame = tagView.frame;
    _tagView = tagView;
    [self addSubview:tagView];

}


/**
 显示新建卡片
 */
- (void)showNewCard {

    
    CCCardContentView *cardView = [[CCCardContentView alloc] init];
    _cardView = cardView;
    cardView.delegate = self;
    cardView.allowEditing = YES;
    cardView.frame = CGRectMake(ContentViewLeftMargin, ContentViewTopMargin, ScreenW - 2 * ContentViewLeftMargin, ContentViewMinHeight);
    [self addSubview:cardView];
    //为该模式下的cell添加一个完成按钮
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImage:[UIImage imageNamed:@"done_enabled"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"done_disabled"] forState:UIControlStateDisabled];
    [doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    doneButton.enabled = NO;
    [cardView addSubview:doneButton];
    _doneButton = doneButton;
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cardView.mas_centerY);
        make.right.equalTo(cardView.mas_right).offset(-10);
        make.width.height.equalTo(@20);
    }];
//     //开场动画效果

//    contentView.transform = CGAffineTransformMakeTranslation(0, -60);


}


#pragma mark - 完成按钮点击调用
- (void)doneButtonClick {
    
    //设置备注项
    self.newCardItem.remarkItems = self.tagView.remarkItems;
    
    //将选择的日期精确到分钟
    NSDate *date = self.newCardItem.cardDate;
    NSTimeInterval timeSince = [date timeIntervalSince1970];
    NSInteger minutes = timeSince / 60;
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:minutes * 60];
    self.newCardItem.cardDate = newDate;
    
    //通知外界
    [CCNotificationCenter postNotificationName:CCNewCardCompleteNotification object:self.newCardItem];
}


/**
 隐藏CoverView

 @param option 隐藏选项
 CCCoverViewDismissOptionCancel 取消
 CCCoverViewDismissOptionAddNew 新增完毕
 
 */
- (void)dismissCoverViewWithOptions:(CCCoverViewDismissOption)option {
    DefineWeakSelf;
    if (option == CCCoverViewDismissOptionCancel) {//如果是删除模式，就将卡片上移消失
        [UIView animateWithDuration:0.3 animations:^{
            self.cardView.transform = CGAffineTransformMakeTranslation(0, -60);
        }];

    } else if (option == CCCoverViewDismissOptionAddNew) {//如果是添加完成，就讲卡片从右方滑出
        [UIView animateWithDuration:0.3 animations:^{
            self.cardView.transform = CGAffineTransformMakeTranslation(ScreenW - 40, 0);
        }];
    }
    
    //退出编辑模式
    [weakSelf endEditing:YES];
    //隐藏遮罩
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
    
}

#pragma mark - CCNewCardTagContainerViewDelegate
- (void)CCNewCardTagContainerView:(CCNewCardTagContainerView *)newCardTagContainerView didChangeRemarkItems:(NSMutableArray *)remarkItems {
    self.cardView.containerView.remarkItems = remarkItems;
    self.newCardItem.remarkItems = remarkItems;
    CGFloat newHeight = (remarkItems.count * 15 + 50) > ContentViewMinHeight ? (remarkItems.count * 15 + 50) : ContentViewMinHeight;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        //tagView相应下移
        CGFloat difference = newHeight - ContentViewMinHeight;
        self.cardView.CC_height = ContentViewMinHeight + difference;
        self.tagView.CC_y = self.tagViewOriFrame.origin.y + difference;
    }];

}

#pragma mark - CCCardContentViewDelegate
- (void)CCCardContentView:(CCCardContentView *)cardContentView didChangeTitle:(NSString *)title {
    self.newCardItem.cardTitle = title;
    self.doneButton.enabled = title.length > 0;
}

- (void)CCCardContentView:(CCCardContentView *)cardContentView didChangeDate:(NSDate *)date {
    self.newCardItem.cardDate = date;
}

@end
