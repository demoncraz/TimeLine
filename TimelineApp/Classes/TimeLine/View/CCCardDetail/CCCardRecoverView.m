
//
//  CCCardRecoverView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCardRecoverView.h"

@implementation CCCardRecoverView

+ (instancetype)cardRecoverView {
    return [[[NSBundle mainBundle] loadNibNamed:@"CCCardRecoverView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
}


@end
