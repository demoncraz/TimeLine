//
//  CCContentTableView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/6.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCContentTableView.h"
#import "CCTaskCardTabldViewCell.h"

@implementation CCContentTableView


- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    //在开始动画前先将deleteButton隐藏
    
    self.editing = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super deleteSections:sections withRowAnimation:animation];
    });
    
    
}


@end
