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

- (void)setSelected:(BOOL)selected {
    self.backgroundColor = selected ? CCDefaultBlueColor : [UIColor whiteColor];
    [super setSelected:selected];
}




@end
