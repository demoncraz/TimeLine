//
//  CCNotesTableViewCell.m
//  TimelineApp
//
//  Created by demoncraz on 2017/3/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNotesTableViewCell.h"
#import "CCNotesCellScrollView.h"
#import "Masonry.h"

@interface CCNotesTableViewCell () <UIScrollViewDelegate>

@property (nonatomic, weak) CCNotesCellScrollView *contentScrollView;

@end

@implementation CCNotesTableViewCell

- (void)setNotesItem:(CCNotesItem *)notesItem {
    _notesItem = notesItem;
    self.contentScrollView.textLabel.text = notesItem.text;
}


- (void)setEditingMode:(BOOL)editingMode animated:(BOOL)animated{
    _editingMode = editingMode;
    CGPoint contentOffset = CGPointZero;
    if (editingMode) {
        contentOffset = CGPointMake(self.contentScrollView.CC_width, 0);
    } else {
        contentOffset = CGPointMake(0, 0);
    }
    [self.contentScrollView setContentOffset:contentOffset animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    //scrollView
    CCNotesCellScrollView *contentScrollView = [[CCNotesCellScrollView alloc] init];
    _contentScrollView = contentScrollView;
    [self.contentView addSubview:contentScrollView];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentScrollView.frame = self.contentView.frame;
}





@end
