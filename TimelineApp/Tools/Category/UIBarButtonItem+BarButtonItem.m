//
//  UIBarButtonItem+BarButtonItem.m
//  BuDeJie
//
//  Created by demoncraz on 2017/2/9.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "UIBarButtonItem+BarButtonItem.h"

@implementation UIBarButtonItem (BarButtonItem)

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action {
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barButton setImage:image forState:UIControlStateNormal];
    [barButton setImage:highImage forState:UIControlStateHighlighted];
    [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [barButton sizeToFit];
    UIView *containerView = [[UIView alloc] initWithFrame:barButton.bounds];
    [containerView addSubview:barButton];
    
    return [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    
}

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image selImage:(UIImage *)highImage target:(id)target action:(SEL)action {
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barButton setImage:image forState:UIControlStateNormal];
    [barButton setImage:highImage forState:UIControlStateSelected];
    [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [barButton sizeToFit];
    UIView *containerView = [[UIView alloc] initWithFrame:barButton.bounds];
    [containerView addSubview:barButton];
    
    return [[UIBarButtonItem alloc] initWithCustomView:containerView];
}

+ (UIBarButtonItem *)backButtonItemWithImage:(UIImage *)image selImage:(UIImage *)highImage target:(id)target action:(SEL)action {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton setImage:highImage forState:UIControlStateHighlighted];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}


@end
