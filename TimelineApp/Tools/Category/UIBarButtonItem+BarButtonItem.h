//
//  UIBarButtonItem+BarButtonItem.h
//  BuDeJie
//
//  Created by demoncraz on 2017/2/9.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (BarButtonItem)

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image selImage:(UIImage *)highImage target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)backButtonItemWithImage:(UIImage *)image selImage:(UIImage *)highImage target:(id)target action:(SEL)action;
@end
