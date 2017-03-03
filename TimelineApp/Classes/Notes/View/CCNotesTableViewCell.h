//
//  CCNotesTableViewCell.h
//  TimelineApp
//
//  Created by demoncraz on 2017/3/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNotesItem.h"

@interface CCNotesTableViewCell : UITableViewCell

@property (nonatomic, strong) CCNotesItem *notesItem;

@property (nonatomic, assign, readonly, getter=isEditingMode) BOOL editingMode;

- (void)setEditingMode:(BOOL)editingMode animated:(BOOL)animated;

@end
