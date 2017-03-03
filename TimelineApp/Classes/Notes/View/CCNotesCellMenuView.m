//
//  CCNotesCellMenuView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/3/2.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNotesCellMenuView.h"

@interface CCNotesCellMenuView ()


@end

@implementation CCNotesCellMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ColorWithRGB(0, 0, 0, 0.7);
        [self setupButtons];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setupButtons {

    //删除按钮
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:[UIImage imageNamed:@"notes_delete"] forState:UIControlStateNormal];
    [deleteButton sizeToFit];
    [deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _deleteButton = deleteButton;
    [self addSubview:deleteButton];
    
    //编辑按钮
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setImage:[UIImage imageNamed:@"notes_edit"] forState:UIControlStateNormal];
    [editButton sizeToFit];
    [editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _editButton = editButton;
    [self addSubview:editButton];
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.editButton.CC_centerY = self.CC_height * 0.5;
    self.editButton.CC_centerX = self.CC_width / 3.0;
    
    self.deleteButton.CC_centerY = self.CC_height * 0.5;
    self.deleteButton.CC_centerX = self.CC_width / 3.0 * 2;
}

- (void)deleteButtonClick {
    NSLog(@"delete");
    [CCNotificationCenter postNotificationName:CCNotesCellMenuDeleteButtonClickNotification object:nil];
}

- (void)editButtonClick {
    [CCNotificationCenter postNotificationName:CCNotesCellMenuEditButtonClickNotification object:nil];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [CCNotificationCenter postNotificationName:CCNotesCellMenuTouchBeganNotification object:nil];
}

@end
