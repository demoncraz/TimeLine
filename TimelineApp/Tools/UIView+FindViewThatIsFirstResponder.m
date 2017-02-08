//
//  UIView+FindViewThatIsFirstResponder.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/4.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "UIView+FindViewThatIsFirstResponder.h"

@implementation UIView (FindViewThatIsFirstResponder)

- (UIView *)findViewThatIsFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findViewThatIsFirstResponder];
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}

@end
