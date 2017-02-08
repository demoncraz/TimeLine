//
//  CCTaskCard.m
//  TimeLine
//
//  Created by demoncraz on 2017/1/28.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCTaskCard.h"
#import "Masonry.h"
#import "GetCurrentTime.h"

#define ColorWithRGB(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define AvatarW 40
#define AvatarH 32
#define AvatarBorderW 1

@interface CCTaskCard ()


@end

@implementation CCTaskCard


#pragma mark - 利用模型快速创建taskCard对象
+ (instancetype)taskCardWithItem:(CCTaskCardItem *)item {
    CCTaskCard *taskCard = [[CCTaskCard alloc] init];
    taskCard.taskCardItem = item;
    return taskCard;
}

#pragma mark - lazy loading
- (CCDatePicker *)datePicker {
    if (_datePicker == nil) {
        _datePicker = [[CCDatePicker alloc] init];
        
        self.datePicker.delegate = self;
        _datePicker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 260, [UIScreen mainScreen].bounds.size.width, 260);
        
    }
    return _datePicker;
}


- (void)setTaskCardItem:(CCTaskCardItem *)taskCardItem {
    _taskCardItem = taskCardItem;
    
    //为子控件设置数据
    
    //设置头像
    self.avatarImageView.image = [UIImage imageNamed:@"avatar_1"];
    //设置时间tf

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeString = [formatter stringFromDate:taskCardItem.cardDate];
    self.timeTF.text = timeString;
    
    //设置日期tf
    [formatter setDateFormat:@"M月d日"];
    NSString *dateString = [formatter stringFromDate:taskCardItem.cardDate];
    self.dateTF.text = dateString;
    //设置标题
    self.titleLabel.text = taskCardItem.cardTitle;
    //设置内容
    self.contentLabel.text = taskCardItem.cardContent;
    //设置提醒样式
    self.alertIcon.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"icon_notice"].CGImage);
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTaskCard];
    }
    return self;
}


- (void)setupTaskCard {
    
    self.backgroundColor = [UIColor clearColor];
    
    //1.设置背景图片
    UIImageView *bgImageView = [[UIImageView alloc] init];
    UIImage *bgImage = [UIImage imageNamed:@"taskCardBg"];
//    bgImageView.image = bgImage;
    bgImageView.image = [bgImage stretchableImageWithLeftCapWidth:10 topCapHeight:15];
    
    [self addSubview:bgImageView];
    _bgImageView = bgImageView;

    //2.设置左半部分view
    [self setupLeftView];
  
    //3.设置有半部分view
    [self setupRightView];
    
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

    timeTF.tintColor= [UIColor clearColor];
    timeTF.inputView = self.datePicker;
    timeTF.delegate = self;
    [leftView addSubview:timeTF];
    _timeTF = timeTF;
    
    //设置日期
    UITextField *dateTF = [[UITextField alloc] init];
    dateTF.textColor = ColorWithRGB(138, 138, 155, 1);
    dateTF.font = [UIFont systemFontOfSize:12];
    dateTF.tintColor= [UIColor clearColor];
    dateTF.inputView = self.datePicker;
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
    

    // 设置分界线
    UIView *separatorLine = [[UIView alloc] init];
    separatorLine.backgroundColor = [UIColor whiteColor];
    separatorLine.layer.shadowColor = ColorWithRGB(0, 0, 0, 0.04).CGColor;
    separatorLine.layer.shadowOffset = CGSizeMake(0, -1);
    separatorLine.layer.shadowOpacity = 1;
    separatorLine.layer.shadowRadius = 0;
    [leftView addSubview:separatorLine];
    _separatorLine = separatorLine;
    
}

- (void)setupRightView {
    
    //右边视图
    UIView *rightView = [[UIView alloc] init];
    [self addSubview:rightView];
    _rightView = rightView;
    
    //标题文字
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [rightView addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    //内容文字
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = ColorWithRGB(135, 135, 147, 1);
    [rightView addSubview:contentLabel];
    _contentLabel = contentLabel;
    
    //提醒icon
    UIView *alertIcon = [[UIView alloc] init];
    //alertIcon.backgroundColor = [UIColor greenColor];
    //alertIcon.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.rightView addSubview:alertIcon];
    _alertIcon = alertIcon;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.backgroundImageView.frame = self.bounds;
    
    //1.1约束
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(9);
        make.left.right.bottom.equalTo(self);
    }];
    
    //左部份view
    /***********************左边部分的子控件******************************/
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(9);
        make.left.bottom.equalTo(self);
        make.width.equalTo(@120);
    }];
    
    //头像约束
//    self.avatarImageView.frame = CGRectMake(0, 0, 40, 40);
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(-5);
        make.centerX.equalTo(self.leftView.mas_centerX);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    self.avatarImageView.layer.cornerRadius = 20;
    
    //separator约束
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(-6);
        make.centerX.equalTo(self.leftView.mas_centerX);
        make.width.equalTo(@65);
        make.height.equalTo(@8);
    }];
    
    //时间按钮约束
    [self.timeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.leftView.mas_centerX);
        make.top.equalTo(self.separatorLine).offset(8);
    }];
    
    //设置日期
    [self.dateTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.leftView.mas_centerX);
        make.top.equalTo(self.timeTF.mas_bottom).offset(2);
    }];
    
    
    /***********************右边部分的子控件******************************/
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(9);
        make.right.bottom.equalTo(self);
        make.left.equalTo(self.leftView.mas_right);
    }];
    
    //标题约束
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rightView.mas_top).offset(10);
        make.left.equalTo(self.rightView.mas_left).offset(10);
        make.right.equalTo(self.alertIcon.mas_left).offset(-10);
    }];
    //内容约束
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.titleLabel.mas_left);
        make.right.equalTo(self.rightView).offset(-10);
    }];
    //提醒icon约束
    [self.alertIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rightView.mas_top).offset(10);
        make.right.equalTo(self.rightView).offset(-10);
        make.width.equalTo(@12);
        make.height.equalTo(@14);
    }];
    
    //自己的底部适应内容
    
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        make.height.mas_greaterThanOrEqualTo(@70);
        make.bottom.equalTo(self.contentLabel.mas_bottom).offset(10);
    }];
    
}




#pragma mark - CCDatePickerDelegate
- (void)didDismissDatePicker:(CCDatePicker *)datePicker {
    [self.timeTF endEditing:YES];
    [self.dateTF endEditing:YES];
    self.taskCardItem = self.taskCardItem;//重置时间
    
}

- (void)datePicker:(CCDatePicker *)datePicker didChangeDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeString = [formatter stringFromDate:date];
    [formatter setDateFormat:@"M月d日"];
    NSString *dateString = [formatter stringFromDate:date];
    
    self.timeTF.text = timeString;
    self.dateTF.text = dateString;
}

- (void)datePicker:(CCDatePicker *)datePicker didConfirmDate:(NSDate *)date {
    [self.timeTF endEditing:YES];
    [self.dateTF endEditing:YES];
    self.taskCardItem.cardDate = date; //更改模型数据
}

@end
