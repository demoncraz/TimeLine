//
//  CCNewCardTagContainerView.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/24.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCRemarkItem.h"

@interface CCNewCardTagContainerView : UIView

//储存有所添加了的备注
@property (nonatomic, strong) NSMutableArray<CCRemarkItem *> *remarkItems;

@end
