//
//  CCTagButton.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/23.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCTagButton.h"

@implementation CCTagButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 0.5;
        
        [self addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.CC_x = CGRectGetMaxX(self.imageView.frame) + 10;
    
}

- (void)buttonClick:(UIButton *)button {
    button.selected = !button.selected;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateSelected];
    [self setTitleColor:CCDefaultGreyClor forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (void)setSelected:(BOOL)selected {
    self.backgroundColor = selected ? CCDefaultBlueColor : [UIColor whiteColor];
    [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
    //取消高亮
}

@end
