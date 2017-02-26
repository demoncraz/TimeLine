//
//  CCCoverView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCoverView.h"
#import "CCTaskCardTabldViewCell.h"
#import "Masonry.h"
#import "UIView+FindViewThatIsFirstResponder.h"
#import "GetCurrentTime.h"
#import "GetCurrentTime.h"
#import "CCTaskCardItem.h"
#import "CCNewCardTagContainerView.h"

#define ContentViewTopMargin 145
#define ContentViewLeftMargin 10
#define ContentViewRightMargin 10
#define ContentViewMinHeight 65


@interface CCCoverView ()<UITextViewDelegate, CCDatePickerDelegate>

@property (nonatomic, strong) UIView *cellContentView;

@property (nonatomic, strong) CCTaskCardTabldViewCell *cell;

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) CCTaskCardItem *newCardItem;

@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, weak) CCNewCardTagContainerView *tagView;

@end

@implementation CCCoverView

#pragma mark - lazy loading

- (NSDate *)selectedDate {
    if (_selectedDate == nil) {
        _selectedDate = [NSDate date];
    }
    return _selectedDate;
}

- (CCTaskCardItem *)newCardItem {
    if (_newCardItem == nil) {
        _newCardItem = [[CCTaskCardItem alloc] init];
    }
    return _newCardItem;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];

        self.alpha = 0;
        [self showNewCard];
        [self showTagView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

}

- (void)showTagView {
    CCNewCardTagContainerView *tagView = [[CCNewCardTagContainerView alloc] init];
    tagView.frame = CGRectMake(ContentViewLeftMargin, 250, ScreenW - 2 * ContentViewLeftMargin, 70);
    _tagView = tagView;
    [self addSubview:tagView];
    
}


/**
 显示新建卡片
 */
- (void)showNewCard {
    CCTaskCardTabldViewCell *newCell = [CCTaskCardTabldViewCell taskCardCellWithDefaultData];
    
    _cell = newCell;
    
    [newCell setInnerDatePickerDelegateOf:self];
    [newCell.titleTF addTarget:self action:@selector(titleTextChange:) forControlEvents:UIControlEventEditingChanged];
    [newCell setEditable:YES];
    UIView *contentView = newCell.contentView;
    
    //为该模式下的cell添加一个完成按钮
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImage:[UIImage imageNamed:@"done_enabled"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"done_disabled"] forState:UIControlStateDisabled];
    [doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    doneButton.enabled = NO;
    [contentView addSubview:doneButton];
    _doneButton = doneButton;
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.cell.contentView.mas_centerY);
        make.right.equalTo(contentView.mas_right).offset(-10);
        make.width.height.equalTo(@20);
    }];
     //开场动画效果
    [self addSubview:contentView];
    _cellContentView = contentView;
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(ContentViewTopMargin);
        make.left.equalTo(self).offset(ContentViewLeftMargin);
        make.right.equalTo(self).offset(-ContentViewRightMargin);
        make.height.greaterThanOrEqualTo(@ContentViewMinHeight);
    }];
    
    contentView.transform = CGAffineTransformMakeTranslation(0, -60);
    //动画完成后设置时间选择器为第一相应者
    [self.cell setFirstResponder:CCTaskCardTabldViewCellResponderTypeDatePicker];
    [UIView animateWithDuration:0.3 animations:^{
        contentView.transform = CGAffineTransformIdentity;
    }];

}



#pragma mark - UITextViewDelegate


#define CCCoverViewDefaultTextHeight 25
#define CCTaskCardBottomMargin 10
- (void)textViewDidChange:(UITextView *)textView {
    
    

    static CGFloat maxHeight = 500;
    static CGSize sizeConstraints;
    sizeConstraints = CGSizeMake(textView.bounds.size.width, MAXFLOAT);
    CGSize textSize = [textView sizeThatFits:sizeConstraints];
    
   
    
    NSInteger lineNumber = (textSize.height - CCCoverViewDefaultTextHeight) * 1.0 / DefaultSingleLineHeight + 0.1;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(coverView:didChangeLineNumbers:)]) {
        [self.delegate coverView:self didChangeLineNumbers:lineNumber];
    }
    
    //    CGRect frame= textView.frame;
    if (textSize.height <= textView.bounds.size.height) {
        textSize.height = textView.bounds.size.height;
    } else {
        
        if (textSize.height >= maxHeight) {
            textView.scrollEnabled = YES;
            textSize.height = maxHeight;

        } else {
            textView.scrollEnabled = NO;
        }
    }

    textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textSize.height);

    CGFloat newFrameHeight = CGRectGetMaxY(textView.frame) + CCTaskCardBottomMargin;
  
    if (newFrameHeight >= (self.cellContentView.frame.size.height)) {
        
        CGRect frame = self.cellContentView.frame;
        
        frame.size.height = newFrameHeight;
        self.cellContentView.frame = frame;
        
    }
    
    
}

#pragma mark - titleText变化时调用的方法
- (void)titleTextChange:(UITextField *)textField {
    self.doneButton.enabled = textField.text.length > 0;
}

#pragma mark - 完成按钮点击调用
- (void)doneButtonClick {
    //设置标题
    self.newCardItem.cardTitle = self.cell.titleTF.text;
    
    //设置备注项
    self.newCardItem.remarkItems = self.tagView.remarkItems;
    
    //将选择的日期精确到分钟
    NSTimeInterval secondSince = [self.selectedDate timeIntervalSince1970];
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:(NSInteger)(secondSince / 60) * 60];
    self.newCardItem.cardDate = newDate;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNewCardCompleteNotification object:self.newCardItem];
    
}


#pragma mark - CCDatePickerDelegate
- (void)didDismissDatePicker:(CCDatePicker *)datePicker {
    [self.cell.timeTF endEditing:YES];
    [self.cell.dateTF endEditing:YES];
    self.cell.dateTF.text = getCurrentDate(@"M月d日");//重置时间
    self.cell.timeTF.text = getCurrentDate(@"HH:mm");
    
}

- (void)datePicker:(CCDatePicker *)datePicker didChangeDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeString = [formatter stringFromDate:date];
    [formatter setDateFormat:@"M月d日"];
    NSString *dateString = [formatter stringFromDate:date];
    
    
    
    self.selectedDate = date;
    
    self.cell.timeTF.text = timeString;
    self.cell.dateTF.text = dateString;
}

- (void)datePicker:(CCDatePicker *)datePicker didConfirmDate:(NSDate *)date {
    [self.cell.timeTF endEditing:YES];
    [self.cell.dateTF endEditing:YES];
    DefineWeakSelf;
    

    
    if (self.cell.titleTF.text.length == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.cell setFirstResponder:CCTaskCardTabldViewCellResponderTypeTitle];
        });
    }
    
}


/**
 隐藏CoverView

 @param option 隐藏选项
 CCCoverViewDismissOptionCancel 取消
 CCCoverViewDismissOptionAddNew 新增完毕
 
 */
- (void)dismissCoverViewWithOptions:(CCCoverViewDismissOption)option {
    DefineWeakSelf;
    if (option == CCCoverViewDismissOptionCancel) {//如果是删除模式，就将卡片上移消失
        [UIView animateWithDuration:0.3 animations:^{
            self.cellContentView.transform = CGAffineTransformMakeTranslation(0, -60);
        }];

    } else if (option == CCCoverViewDismissOptionAddNew) {//如果是添加完成，就讲卡片从右方滑出
        [UIView animateWithDuration:0.3 animations:^{
            self.cellContentView.transform = CGAffineTransformMakeTranslation(ScreenW - 40, 0);
        }];
    }
    
    //退出编辑模式
    [weakSelf endEditing:YES];
    //隐藏遮罩
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
    
}


@end
