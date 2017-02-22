//
//  CCNotesTitleView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/18.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNotesTitleView.h"
#import "Masonry.h"


#define CCNotesTitleColor ColorWithRGB(255, 255, 255, 1)

@interface CCNotesTitleView ()

@property (nonatomic, weak) UILabel *titleLabel;



@end

@implementation CCNotesTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupStyle];
        //标题
        [self setupTitle];
        //左按钮
        [self setupAddButton];
        //右按钮
        [self setupFullScreenButton];
    }
    return self;
}

- (void)setupStyle {
    self.backgroundColor = CCDefaultBlueColor;
    
}

- (void)setupTitle {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"备忘录";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = CCNotesTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@100);
    }];
    
    _titleLabel = titleLabel;
}

- (void)setupAddButton {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.backgroundColor = [UIColor blueColor];
    [addButton setImage:[UIImage imageNamed:@"notes_add"] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"notes_add"] forState:UIControlStateSelected];
    [self addSubview:addButton];
    _addButton = addButton;
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(5);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.equalTo(@40);
    }];
}

- (void)setupFullScreenButton {
    CCNotesFullScreenButton *fullScreenButton = [CCNotesFullScreenButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:fullScreenButton];
    _fullScreenButton = fullScreenButton;
    [fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-5);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.equalTo(@40);
    }];
}

@end
