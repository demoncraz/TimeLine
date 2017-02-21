//
//  UIView+Frame.m
//  BuDeJie
//
//  Created by demoncraz on 2017/2/12.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)


- (CGFloat)CC_x {
    return self.frame.origin.x;
}

- (void)setCC_x:(CGFloat)CC_x {
    CGRect frame = self.frame;
    frame.origin.x = CC_x;
    self.frame = frame;
}

- (CGFloat)CC_y {
    return self.frame.origin.y;
}

- (void)setCC_y:(CGFloat)CC_y {
    CGRect frame = self.frame;
    frame.origin.y = CC_y;
    self.frame = frame;
}

- (CGFloat)CC_width {
    return self.frame.size.width;
}

-(void)setCC_width:(CGFloat)CC_width {
    CGRect frame = self.frame;
    frame.size.width = CC_width;
    self.frame = frame;
}

- (CGFloat)CC_height {
    return self.frame.size.height;
}

-(void)setCC_height:(CGFloat)CC_height {
    CGRect frame = self.frame;
    frame.size.height = CC_height;
    self.frame = frame;
}

- (CGFloat)CC_centerX {
    return self.center.x;
}

- (void)setCC_centerX:(CGFloat)CC_centerX {
    CGPoint center = self.center;
    center.x = CC_centerX;
    self.center = center;
}


- (CGFloat)CC_centerY {
    return self.center.y;
}

- (void)setCC_centerY:(CGFloat)CC_centerY {
    CGPoint center = self.center;
    center.y = CC_centerY;
    self.center = center;
}

@end
