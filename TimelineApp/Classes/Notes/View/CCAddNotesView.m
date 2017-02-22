//
//  CCAddNotesView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/20.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCAddNotesView.h"

@interface CCAddNotesView ()

@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

@end

@implementation CCAddNotesView


+ (instancetype)addNotesView {
    CCAddNotesView *addNotesView = [[[NSBundle mainBundle] loadNibNamed:@"CCAddNotesView" owner:nil options:nil] lastObject];
    addNotesView.CC_width = ScreenW * 0.8;
    addNotesView.CC_centerX = [UIApplication sharedApplication].keyWindow.CC_centerX;
    addNotesView.CC_centerY = [UIApplication sharedApplication].keyWindow.CC_centerY - 100;
    addNotesView.alpha = 0;
//    [addNotesView becomeFirstResponder];
    return addNotesView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
}

- (void)startEdting {
    [self.notesTextView becomeFirstResponder];
}


- (IBAction)cancelButtonClick:(id)sender {
    [self.delegate addNotesViewWillDismiss:self];
}

- (IBAction)doneButtonClick:(id)sender {
    [self.delegate addNotesView:self didConfirmWithContent:self.notesTextView.text createDate:[NSDate date]];
}


@end
