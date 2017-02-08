//
//  CCTaskCardEditingMode.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCTaskCardEditingMode.h"
#import "GetCurrentTime.h"
#import "Masonry.h"
#import "CCDatePicker.h"
#import "UIView+FindViewThatIsFirstResponder.h"


@interface CCTaskCardEditingMode ()

@property (nonatomic, weak) UITextField *titleTextField;

@property (nonatomic, weak) UITextField *contentTextField;

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) CCTaskCardItem *brandNewCardItem;

@end

@implementation CCTaskCardEditingMode



#pragma mark - lazy loading

- (NSDate *)selectedDate {
    if (_selectedDate == nil) {
        _selectedDate = [NSDate date];
    }
    return _selectedDate;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置头像
        self.avatarImageView.image = [UIImage imageNamed:@"avatar_1"];
        
        //设置时间
        
        self.timeTF.text = getCurrentDate(@"HH:mm");
        
        //设置日期
        self.dateTF.text = getCurrentDate(@"M月d日");
        
        //添加标题输入框
        UITextField *titleTextField = [[UITextField alloc] init];
        titleTextField.placeholder = @"标题...";
        
        titleTextField.font = [UIFont systemFontOfSize:16];
        [titleTextField addTarget:self action:@selector(titleTextFieldChange:) forControlEvents:UIControlEventEditingChanged];
        titleTextField.delegate = self;
        
        //移除原有的titleTextField
        self.titleLabel.hidden = YES;
        [self addSubview:titleTextField];
        _titleTextField = titleTextField;
        [titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(self.titleLabel);
            make.right.equalTo(self.mas_right).offset(-30);
        }];
        
        //添加内容输入框
        UITextField *contentTextField = [[UITextField alloc] init];
        contentTextField.font = [UIFont systemFontOfSize:12];
        contentTextField.textColor = [UIColor lightGrayColor];
        contentTextField.placeholder = @"内容...";
        //移除原有的contentTextField
        self.contentLabel.hidden = YES;
        contentTextField.delegate = self;
        [self addSubview:contentTextField];
        _contentTextField = contentTextField;
        [contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(self.contentLabel);
            make.right.equalTo(self.mas_right).offset(-30);
        }];
        
        //设置提醒样式选择器 ****
        self.alertIcon.hidden = YES;
        
        
        //添加完成按钮
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.enabled = NO;
        [doneButton setImage:[UIImage imageNamed:@"done_disabled"] forState:UIControlStateDisabled];
        [doneButton setImage:[UIImage imageNamed:@"done_enabled"] forState:UIControlStateNormal];
        [doneButton setImage:[UIImage imageNamed:@"done_enabled"] forState:UIControlStateHighlighted];
        
        [doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        self.doneButton = doneButton;
        [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.leftView.mas_centerY);
            make.right.equalTo(self).offset(-10);
            make.width.height.equalTo(@20);
        }];

    }
    return self;
}



#pragma mark - 监听输入

- (void)titleTextFieldChange:(UITextField *)textField {
//    NSLog(@"%@",textField.text);
    if (textField.text.length == 0) {
        self.doneButton.enabled = NO;
    } else {
        self.doneButton.enabled = YES;
    }
}


#pragma mark - 完成按钮点击
- (void)doneButtonClick {
    NSString *titleString = self.titleTextField.text;
    NSString *contentString = self.contentTextField.text;
    
    //创建一个模型对象
    CCTaskCardItem *newCardItem = [CCTaskCardItem taskCardItemWithTitle:titleString content:contentString date:self.selectedDate alertType:TaskCardAlertTypeNotification];
    self.brandNewCardItem = newCardItem;
    //将模型对象传给外界viewController
   
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNewCardCompleteNofitifation object:newCardItem];
    
    
    
}

#pragma mark - CCDatePickerDelegate


/**
 重写父类的代理方法
 */
- (void)didDismissDatePicker:(CCDatePicker *)datePicker {
    
    self.timeTF.text = getCurrentDate(@"HH:mm");
    self.dateTF.text = getCurrentDate(@"M月d日");
    [self.timeTF endEditing:YES];
    [self.dateTF endEditing:YES];
}

- (void)datePicker:(CCDatePicker *)datePicker didConfirmDate:(NSDate *)date {
    [super datePicker:datePicker didConfirmDate:date];
    self.selectedDate = date;
    //时间编辑完成后自动跳转到标题文本框 （如标题文本已有内容，不跳转）
    if (self.titleTextField.text.length == 0) {
        [self.titleTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
    }
}

#pragma mark - titleTextFieldDelegate代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField && self.contentTextField.text.length == 0) {//如果点击return的是titleTF,退出键盘并移动光标到内容输入框
        //判断内容框内是否有文字，如果有，则不跳转光标
        [self.contentTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.timeTF || textField == self.dateTF) {//如果是时间选择框，编辑结束时记录选择的时间
        self.selectedDate = self.datePicker.selectedDate;
    }
}

@end
