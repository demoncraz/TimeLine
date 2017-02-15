//
//  CCImageView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/15.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCImageView.h"

@implementation CCImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    self.layer.cornerRadius = self.frame.size.width * 0.5;
    self.layer.masksToBounds = YES;
}

@end
