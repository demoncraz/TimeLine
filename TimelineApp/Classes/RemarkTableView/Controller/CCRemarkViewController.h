//
//  CCRemarkViewController.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/22.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CCTaskCardItem.h"

@interface CCRemarkViewController : UITableViewController

//备注列表
@property (nonatomic, strong) CCTaskCardItem *item;

@end
