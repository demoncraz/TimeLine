//
//  CCDatePicker.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCDatePicker.h"
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

@interface CCDatePicker ()

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIButton *cancelButton;



@end

@implementation CCDatePicker


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
//        datePicker.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [datePicker setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
        datePicker.minimumDate = [NSDate date];
        [self addSubview:datePicker];
        _datePicker = datePicker;
        
        //确定按钮
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmButton];
        _confirmButton = confirmButton;
        
        //取消按钮
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        _cancelButton = cancelButton;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.datePicker.frame = CGRectMake(0, 44, self.frame.size.width, 216);
    
    self.cancelButton.frame = CGRectMake(0, 0, self.frame.size.width * 0.5, 44);
    
    self.confirmButton.frame = CGRectMake(self.frame.size.width * 0.5, 0, self.frame.size.width * 0.5, 44);
}

#pragma mark - 按钮点击

- (void)confirmBtnClick {
    
    [self.delegate datePicker:self didConfirmDate:self.datePicker.date];
    
}

- (void)cancelBtnClick {
    [self dismiss];
    
}

#pragma mark - dismiss datePicker

- (void)dismiss {
    
    [self.delegate didDismissDatePicker:self];
    
}

#pragma mark - 监听datepicker滚动
- (void)dateChange:(UIDatePicker *)datePicker{
    self.selectedDate = datePicker.date;
    [self.delegate datePicker:self didChangeDate:datePicker.date];
}

@end
