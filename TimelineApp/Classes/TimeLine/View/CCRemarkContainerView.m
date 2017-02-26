//
//  CCRemarkContainerView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/24.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCRemarkContainerView.h"
#import "Masonry.h"

#define RemarkItemHeight 10

@implementation CCRemarkContainerView



- (void)setRemarkItems:(NSArray *)remarkItems {
    
    _remarkItems = remarkItems;
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    for (NSInteger i = 0; i < remarkItems.count; i++) {
        CCRemarkItem *item = remarkItems[i];
        CGFloat y = (RemarkItemHeight + 5) * i;
        
        UIView *remarkView = [[UIView alloc] init];
        remarkView.frame = CGRectMake(0, y, 200, RemarkItemHeight);
        //tagImage
        UIImageView *tagImageView = [[UIImageView alloc] init];
        tagImageView.image = [UIImage imageNamed:item.imageName];
        [remarkView addSubview:tagImageView];
        
        [tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(remarkView.mas_left);
            make.centerY.equalTo(@5);
            make.width.height.equalTo(@10);
        }];
        
        //label
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = item.text;
        textLabel.font = [UIFont systemFontOfSize:12];
        textLabel.textColor = CCDefaultGreyClor;
        [remarkView addSubview:textLabel];
        
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(tagImageView.mas_centerY);
            make.left.equalTo(tagImageView.mas_right).offset(5);
            make.right.equalTo(remarkView.mas_right);
        }];
        [self addSubview:remarkView];
    }
    
}




@end
