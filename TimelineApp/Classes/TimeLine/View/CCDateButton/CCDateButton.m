//
//  CCDateButton.m
//  TimeLine
//
//  Created by demoncraz on 2017/1/26.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCDateButton.h"
#import "GetCurrentTime.h"

@interface CCDateButton ()

@property (nonatomic, strong) NSTimer *dateUpdateTimer;

@end

@implementation CCDateButton

- (void)dealloc {
    NSLog(@"按钮被销毁");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupButton];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupButton];
    [self startTimer];
}

- (void)setupButton {
    [self addTarget:self action:@selector(dateButtonClick) forControlEvents:UIControlEventTouchUpInside];
    //获取当前日期
    
    [self updateDate];
    
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.titleLabel sizeToFit];
    
}

- (void)updateDate {
    
    NSString *dateString = getCurrentDate(@"YYYY年MM月dd日");
    
    [self setTitle:dateString forState:UIControlStateNormal];
    [self setTitle:dateString forState:UIControlStateSelected];
    NSLog(@"update!");
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageEdgeInsets = UIEdgeInsetsMake(0, self.titleLabel.bounds.size.width + 5, 0, -self.titleLabel.bounds.size.width - 5);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -self.imageView.bounds.size.width, 0, self.imageView.bounds.size.width);
}


- (void)dateButtonClick {
    self.selected = !self.selected;
}

- (void)startTimer {
    
    //每小时更新日期数据
    
    [NSTimer scheduledTimerWithTimeInterval:3600 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updateDate];
    }];
}

@end
