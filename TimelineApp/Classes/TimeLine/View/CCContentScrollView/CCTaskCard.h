//
//  CCTaskCard.h
//  TimeLine
//
//  Created by demoncraz on 2017/1/28.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTaskCardItem.h"
#import "CCDatePicker.h"

@interface CCTaskCard : UIView<UITextFieldDelegate, CCDatePickerDelegate>

@property (nonatomic, weak) UIImageView *bgImageView;

@property (nonatomic, weak) UIView *bgView;

@property (nonatomic, weak) UIView *separatorLine;

@property (nonatomic, weak) UIView *leftView;

@property (nonatomic, weak) UITextField *timeTF;

@property (nonatomic, weak) UITextField *dateTF;

@property (nonatomic, weak) UIImageView *avatarImageView;

@property (nonatomic, weak) UIView *rightView;

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UILabel *contentLabel;

@property (nonatomic, weak) UIView *alertIcon;

@property (nonatomic, strong) CCDatePicker *datePicker;


//数据模型
@property (nonatomic, strong) CCTaskCardItem *taskCardItem;

+ (instancetype)taskCardWithItem:(CCTaskCardItem *)item;



@end
