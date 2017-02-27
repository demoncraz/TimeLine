//
//  CCCardContentView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCardContentView.h"
#import "CCDatePicker.h"
#import "Masonry.h"
#import "GetCurrentTime.h"


@interface CCCardContentView ()<CCDatePickerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) UIImageView *bgImageView;

@property (nonatomic, weak) UIView *leftView;

@property (nonatomic, weak) UIView *rightView;

@property (nonatomic, strong) CCDatePicker *datePicker;

@property (nonatomic, weak) UIImageView *avatarImageView;

@property (nonatomic, weak) UIView *alertIcon;

@property (nonatomic, weak) UITextField *titleTF;

@property (nonatomic, weak) UITextField *timeTF;

@property (nonatomic, weak) UITextField *dateTF;

@end


@implementation CCCardContentView

#pragma mark - lazy loading

- (CCTaskCardItem *)item {
    if (_item == nil) {
        _item = [CCTaskCardItem taskCardItemWithTitle:@"" date:[NSDate date] alertType:0 isDone:NO remarkItems:[NSArray array]];
    }
    return _item;
}


- (CCDatePicker *)datePicker {
    if (_datePicker == nil) {
        _datePicker = [[CCDatePicker alloc] init];
        
        self.datePicker.delegate = self;
        _datePicker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 260, [UIScreen mainScreen].bounds.size.width, 260);
        
    }
    return _datePicker;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTaskCard];
        [self setDataWithTaskCardItem:self.item];
    }
    return self;
}

- (void)setDataWithTaskCardItem:(CCTaskCardItem *)item {
    //背景
    UIImage *bgImage = [[UIImage alloc] init];
    if (!item.isDone) {
        bgImage = [UIImage imageNamed:@"bg_line"];
    } else {
        bgImage = [UIImage imageNamed:@"bg_done"];
    }
    
    self.bgImageView.image = [bgImage stretchableImageWithLeftCapWidth:200 topCapHeight:10];
    
    //设置头像
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"avatarImage"];
    if (imageData) {
        UIImage *avatarImage = [UIImage imageWithData:imageData];
        self.avatarImageView.image = avatarImage;
    }
    
    //设置时间tf
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeString = [formatter stringFromDate:item.cardDate];
    self.timeTF.text = timeString;
    
    //设置日期tf
    [formatter setDateFormat:@"M月d日"];
    NSString *dateString = [formatter stringFromDate:item.cardDate];
    self.dateTF.text = dateString;
    //设置标题
    self.titleTF.text = item.cardTitle;
    
    //设置提醒样式
    if (self.item.taskCardAlertType == TaskCardAlertTypeNotification) {
        self.alertIcon.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"icon_notice"].CGImage);
    } else {
    }
    
    //这是备注列表
    self.containerView.remarkItems = item.remarkItems;
    
    //设置完成卡片样式
    for (UIView *subView in self.subviews) {
        if (item.isDone && ![subView isKindOfClass:[UIImageView class]]) {
            subView.alpha = 0.3;
        } else {
            subView.alpha = 1;
        }
    }

}



- (void)setupTaskCard {
    
    //1.设置背景图片
    UIImageView *bgImageView = [[UIImageView alloc] init];
    
    [self addSubview:bgImageView];
    _bgImageView = bgImageView;
    
    //2.设置左半部分view
    [self setupLeftView];
    
    //3.设置有半部分view
    [self setupRightView];
    
    
    [self setupConstraints];
    
}


- (void)setupLeftView {
    //设置左半部触控区域
    
    UIView *leftView = [[UIView alloc] init];
    //leftView.backgroundColor = [UIColor greenColor];
    [self addSubview:leftView];
    _leftView = leftView;
    //设置时间
    UITextField *timeTF = [[UITextField alloc] init];
    timeTF.textColor = ColorWithRGB(138, 138, 155, 1);
    timeTF.font = [UIFont systemFontOfSize:12];
    timeTF.textAlignment = NSTextAlignmentCenter;
    timeTF.tintColor= [UIColor clearColor];
    timeTF.inputView = self.datePicker;
    timeTF.enabled = NO;
    timeTF.delegate = self;
    [leftView addSubview:timeTF];
    _timeTF = timeTF;
    
    //设置日期
    UITextField *dateTF = [[UITextField alloc] init];
    dateTF.textColor = ColorWithRGB(138, 138, 155, 1);
    dateTF.font = [UIFont systemFontOfSize:12];
    dateTF.tintColor= [UIColor clearColor];
    dateTF.textAlignment = NSTextAlignmentCenter;
    dateTF.inputView = self.datePicker;
    dateTF.enabled = NO;
    dateTF.hidden = YES;
    dateTF.delegate = self;
    [leftView addSubview:dateTF];
    _dateTF = dateTF;
    
    
    
    //设置头像
    UIImageView *avatarImageView = [[UIImageView alloc] init];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    avatarImageView.layer.borderWidth = 2;
    
    [leftView addSubview:avatarImageView];
    _avatarImageView = avatarImageView;
    avatarImageView.layer.cornerRadius = 0.5 * avatarImageView.bounds.size.width;
    
    
}

- (void)setupRightView {
    
    //右边视图
    UIView *rightView = [[UIView alloc] init];
    [self addSubview:rightView];
    _rightView = rightView;
    
    //标题
    UITextField *titleTF = [[UITextField alloc] init];
    titleTF.placeholder = @"标题...";
    titleTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [titleTF addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    titleTF.enabled = NO;
    //    titleTF.backgroundColor = [UIColor blueColor];
    [rightView addSubview:titleTF];
    _titleTF = titleTF;
    
    //备注标签
    CCRemarkContainerView *containerView = [[CCRemarkContainerView alloc] init];
    _containerView = containerView;
    containerView.frame = CGRectMake(0, 0, 200, 50);
    [rightView addSubview:containerView];
    
    
    //提醒icon
    UIView *alertIcon = [[UIView alloc] init];
    //alertIcon.backgroundColor = [UIColor greenColor];
    //alertIcon.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.rightView addSubview:alertIcon];
    _alertIcon = alertIcon;
    
}

- (void)setupConstraints {
    
    
    //    约束
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(9);
        make.left.right.bottom.equalTo(self);
    }];
    
    //左部份view
    /***********************左边部分的子控件******************************/
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(9);
        make.left.bottom.equalTo(self);
        make.width.equalTo(@((ScreenW - 20) * (100.0 / 355)));
    }];
    
    //头像约束
    //    self.avatarImageView.frame = CGRectMake(0, 0, 40, 40);
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftView).offset(-9);
        make.centerX.equalTo(self.leftView.mas_centerX);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    self.avatarImageView.layer.cornerRadius = 20;
    
    
    //时间按钮约束
    [self.timeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.leftView.mas_centerX);
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(5);
        make.height.equalTo(@15);
    }];
    
    //设置日期
    [self.dateTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.leftView.mas_centerX);
        make.top.equalTo(self.timeTF.mas_bottom).offset(2);
        make.height.equalTo(@15);
        //        make.bottom.lessThanOrEqualTo(self.leftView.mas_bottom).offset(-5);
    }];
    
    
    /***********************右边部分的子控件******************************/
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(9);
        make.right.bottom.equalTo(self);
        make.left.equalTo(self.leftView.mas_right).offset(5);
    }];
    
    //标题约束
    [self.titleTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rightView.mas_top).offset(10);
        make.left.equalTo(self.rightView.mas_left).offset(10);
        make.right.equalTo(self.alertIcon.mas_right).offset(-10);
        make.height.equalTo(@20);
    }];
    //备注约束
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleTF.mas_bottom).offset(0);
        make.left.equalTo(self.titleTF.mas_left);
        //        make.right.equalTo(self.rightView).offset(-10);
        make.width.equalTo(@(CCTaskCardContentW));
        make.height.mas_greaterThanOrEqualTo(@25);
        make.bottom.equalTo(self.rightView.mas_bottom).offset(-10);
    }];
    //提醒icon约束
    [self.alertIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rightView.mas_top).offset(10);
        make.right.equalTo(self.rightView).offset(-10);
        make.width.equalTo(@12);
        make.height.equalTo(@14);
    }];
    
}


#pragma mark - 设置是否可以编辑
- (void)setAllowEditing:(BOOL)allowEditing {
    self.timeTF.enabled = allowEditing;
    self.dateTF.enabled = allowEditing;
    self.titleTF.enabled = allowEditing;
    self.dateTF.hidden = !allowEditing;
}

#pragma mark - CCDatePickerDelegate
- (void)didDismissDatePicker:(CCDatePicker *)datePicker {
    [self.timeTF endEditing:YES];
    [self.dateTF endEditing:YES];
    self.dateTF.text = getCurrentDate(@"M月d日");//重置时间
    self.timeTF.text = getCurrentDate(@"HH:mm");
    [self.delegate CCCardContentView:self didChangeDate:[NSDate date]];
}

- (void)datePicker:(CCDatePicker *)datePicker didChangeDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeString = [formatter stringFromDate:date];
    [formatter setDateFormat:@"M月d日"];
    NSString *dateString = [formatter stringFromDate:date];
    
    
    
//    self.selectedDate = date;
    
    self.timeTF.text = timeString;
    self.dateTF.text = dateString;
    
    [self.delegate CCCardContentView:self didChangeDate:date];
}

- (void)datePicker:(CCDatePicker *)datePicker didConfirmDate:(NSDate *)date {
    [self.timeTF endEditing:YES];
    [self.dateTF endEditing:YES];
    
}

#pragma mark - TextField
- (void)textChange:(UITextField *)textField {
    [self.delegate CCCardContentView:self didChangeTitle:textField.text];
}


@end
