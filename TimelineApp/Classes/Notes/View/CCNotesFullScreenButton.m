//
//  CCNotesFullScreenButton.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/19.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNotesFullScreenButton.h"

@implementation CCNotesFullScreenButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        {
//            self.backgroundColor = [UIColor blueColor];
            [self setImage:[UIImage imageNamed:@"notes_right"] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"notes_right"] forState:UIControlStateSelected];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [UIView animateWithDuration:0.15 animations:^{
        self.transform = (selected == YES) ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
    }];
    
}

@end
