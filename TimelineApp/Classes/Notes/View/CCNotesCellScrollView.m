//
//  CCNotesCellScrollView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/3/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNotesCellScrollView.h"
#import "CCNotesCellMenuView.h"
#import "Masonry.h"

#define CellLabelHeight 25

@interface CCNotesCellScrollView ()

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) CCNotesCellMenuView *menuView;

@end

@implementation CCNotesCellScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
    }
    return self;
}

- (void)setup {
    //配置
    self.pagingEnabled = YES;
    self.scrollEnabled = NO;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    //内容视图
    UIView *contentView = [[UIView alloc] init];
    UILabel *textLabel = [[UILabel alloc] init];
    _textLabel = textLabel;
    [contentView addSubview:textLabel];

//    self.textLabel.frame = CGRectMake(5, 10, 200, 20);
    //菜单视图
    CCNotesCellMenuView *menuView = [[CCNotesCellMenuView alloc] init];
    _contentView = contentView;
    [self addSubview:contentView];
    _menuView = menuView;
    [self addSubview:menuView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentSize = CGSizeMake(2 * self.CC_width, self.CC_height);
    self.textLabel.frame = CGRectMake(10, (self.CC_height - CellLabelHeight) * 0.5, self.CC_width - 20, CellLabelHeight);
    self.contentView.frame = self.frame;
    
    self.menuView.frame = self.frame;
    self.menuView.CC_x = self.CC_width;
    
}



@end
