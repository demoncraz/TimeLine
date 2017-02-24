//
//  CCRemarkNavigationController.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/23.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNavigationController.h"
#import "CCRemarkItem.h"

@interface CCRemarkNavigationController : CCNavigationController

@property (nonatomic, strong) NSMutableArray *remarkItems;

@end
