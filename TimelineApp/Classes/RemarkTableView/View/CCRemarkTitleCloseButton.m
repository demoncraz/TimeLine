//
//  CCRemarkTitleCloseButton.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/24.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCRemarkTitleCloseButton.h"

@implementation CCRemarkTitleCloseButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //文字
        [self setTitle:@"备注" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        
        //图片
        [self setImage:[UIImage imageNamed:@"remark_close"] forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.CC_x = 0;
    self.imageView.CC_x = CGRectGetMaxX(self.titleLabel.frame) + 5;
}


@end
