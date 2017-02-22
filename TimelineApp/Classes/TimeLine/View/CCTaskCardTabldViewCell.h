//
//  CCTaskCardTabldViewCell.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/6.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDatePicker.h"
#import "CCTaskCardItem.h"

typedef enum {
    CCTaskCardTabldViewCellResponderTypeTitle,
    CCTaskCardTabldViewCellResponderTypeContent,
    CCTaskCardTabldViewCellResponderTypeDatePicker
} CCTaskCardTabldViewCellResponderType;

@interface CCTaskCardTabldViewCell : UITableViewCell


@property (nonatomic, weak) UIImageView *bgImageView;

@property (nonatomic, weak) UIView *bgView;

@property (nonatomic, weak) UIView *separatorLine;

@property (nonatomic, weak) UIView *leftView;

@property (nonatomic, weak) UITextField *timeTF;

@property (nonatomic, weak) UITextField *dateTF;

@property (nonatomic, weak) UIImageView *avatarImageView;

@property (nonatomic, weak) UIView *rightView;

@property (nonatomic, strong) UITextField *titleTF;

@property (nonatomic, strong) UITextView *contentTF;

@property (nonatomic, weak) UIView *alertIcon;

@property (nonatomic, strong) CCDatePicker *datePicker;

@property (nonatomic, strong) NSString *identifier;


@property (nonatomic, strong) UIButton *deleteButton;


//数据模型
@property (nonatomic, strong) CCTaskCardItem *taskCardItem;

+ (instancetype)taskCardCellWithItem:(CCTaskCardItem *)item;

+ (instancetype)taskCardCellWithDefaultData;


/**
 设置设否可以编辑文本框
 */
- (void)setEditable:(BOOL)editable;

/**
 为内部的内容TF设置代理

 @param delegate 代理者
 */
- (void)setInnerTextViewDelegateOf:(id)delegate;
/**
 为内部的datePicker设置代理
 
 @param delegate 代理者
 */
- (void)setInnerDatePickerDelegateOf:(id)delegate;


/**
 设置谁为响应者
 */
- (void)setFirstResponder:(CCTaskCardTabldViewCellResponderType)responderType;

@end
