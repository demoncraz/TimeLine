//
//  CCNewCardTagButton.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/24.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNewCardTagButton.h"

@implementation CCNewCardTagButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = CCDefaultGreyClor.CGColor;
        self.layer.borderWidth = 0.5;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.imageView.CC_height = 15;
//    self.imageView.CC_width = 15;
//    self.imageView.CC_centerY = self.titleLabel.CC_centerY;
    self.titleLabel.CC_x = CGRectGetMaxX(self.imageView.frame) + 2;

}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateSelected];
    [self setTitleColor:CCDefaultGreyClor forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    NSString *imageName = [self getImageNameWithTitle:title];
    NSString *selectedImageName = [self getSelectedImageNameWithTitle:title];
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
}


- (void)setHighlighted:(BOOL)highlighted {
    //取消高亮
}

/**
 根据title返回tag图片名
 
 @param title tag标题
 @return 图片名
 */
- (NSString *)getImageNameWithTitle:(NSString *)title {
    return [NSString stringWithFormat:@"remark_%@", title];
}

- (NSString *)getSelectedImageNameWithTitle:(NSString *)title {
    return [NSString stringWithFormat:@"remark_%@_white", title];
}

@end
