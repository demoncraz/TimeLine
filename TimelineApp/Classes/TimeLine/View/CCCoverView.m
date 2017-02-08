//
//  CCCoverView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCoverView.h"
#import "CCTaskCardEditingMode.h"
#import "Masonry.h"
#import "UIView+FindViewThatIsFirstResponder.h"

@interface CCCoverView ()



@end

@implementation CCCoverView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        //添加子控件
//
        
        CCTaskCardEditingMode *taskCard = [[CCTaskCardEditingMode alloc] init];
        
        [self addSubview:taskCard];
        _taskCard = taskCard;
        [taskCard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(154);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
        }];
        
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.taskCard.timeTF.isFirstResponder) {
        
        [self.taskCard.timeTF becomeFirstResponder];
    }
    
}





@end
