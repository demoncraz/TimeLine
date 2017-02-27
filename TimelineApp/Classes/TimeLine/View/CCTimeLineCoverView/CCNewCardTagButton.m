//
//  CCNewCardTagButton.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/24.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNewCardTagButton.h"
#import "Masonry.h"
#define CCTagButtonRightMargin 3

@implementation CCNewCardTagButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0.5;
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addTarget:self action:@selector(tagButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.CC_width = 14;
    self.imageView.CC_height = 15;
    self.imageView.CC_centerY = self.titleLabel.CC_centerY;
    
    self.titleLabel.CC_x  = CGRectGetMaxX(self.imageView.frame) + 3;

}

- (void)setTitle:(NSString *)title {
//    [super setTitle:title];
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    NSString *imageName = [NSString stringWithFormat:@"remark_%@_white", title];
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
}


- (void)setHighlighted:(BOOL)highlighted {
    //取消高亮
}


- (void)tagButtonClick:(UIButton *)button {
    button.selected = !button.selected;
}

@end
