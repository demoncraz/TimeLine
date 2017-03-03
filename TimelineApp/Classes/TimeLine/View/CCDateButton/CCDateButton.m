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
    //获取当前日期
    
    [self updateDate];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    [self setImage:[UIImage imageNamed:@"tintArrow"] forState:UIControlStateNormal];
    [self.titleLabel sizeToFit];
    
}

- (void)updateDate {
    
    NSString *dateString = getCurrentDate(@"YYYY年MM月dd日");
    
    [self setTitle:dateString forState:UIControlStateNormal];
//    [self setTitle:dateString forState:UIControlStateSelected];
    NSLog(@"update!");
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.CC_height = 60;//扩大按钮点击范围
    self.titleLabel.CC_x = 0;
    self.titleLabel.CC_y = 0;
    self.imageView.CC_x =  CGRectGetMaxX(self.titleLabel.frame) + 5;
    self.imageView.CC_y = (self.titleLabel.CC_height - self.imageView.CC_height) * 0.5
    ;
}


- (void)startTimer {
    
    //每小时更新日期数据
    
    [NSTimer scheduledTimerWithTimeInterval:3600 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updateDate];
    }];
}

- (void)setHighlighted:(BOOL)highlighted {
    
}

- (void)setSelected:(BOOL)selected {
    
}
@end
