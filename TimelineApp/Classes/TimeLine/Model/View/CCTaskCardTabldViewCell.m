//
//  CCTaskCardTabldViewCell.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/6.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCTaskCardTabldViewCell.h"
#import "Masonry.h"
#import "GetCurrentTime.h"


@interface CCTaskCardTabldViewCell ()<CCDatePickerDelegate,UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, assign, getter=isDeleteMode) BOOL deleteMode;



@end

@implementation CCTaskCardTabldViewCell


- (void)setEditable:(BOOL)editable {
    self.titleTF.enabled = editable;
    self.contentTF.userInteractionEnabled = editable;
}

/**
 为内部的contentTextView添加代理的方法

 @param delegate 代理者
 */
- (void)setInnerTextViewDelegateOf:(id)delegate {
    self.contentTF.delegate = delegate;
}
/**
 为内部的datePicker添加代理的方法
 
 @param delegate 代理者
 */
- (void)setInnerDatePickerDelegateOf:(id)delegate {
    self.datePicker.delegate = delegate;
}

/**
 设置谁为响应者
 */
- (void)setFirstResponder:(CCTaskCardTabldViewCellResponderType)responderType {
    switch (responderType) {
        case CCTaskCardTabldViewCellResponderTypeTitle:
            [self.titleTF becomeFirstResponder];
            break;
        case CCTaskCardTabldViewCellResponderTypeContent:
            [self.contentTF becomeFirstResponder];
            break;
        case CCTaskCardTabldViewCellResponderTypeDatePicker:
            [self.dateTF becomeFirstResponder];
            break;
    }
}

#pragma mark - 利用模型快速创建taskCard对象
+ (instancetype)taskCardCellWithItem:(CCTaskCardItem *)item {
    CCTaskCardTabldViewCell *taskCardCell = [[CCTaskCardTabldViewCell alloc] init];
    taskCardCell.taskCardItem = item;
    return taskCardCell;
    
}

+ (instancetype)taskCardCellWithDefaultData {
    CCTaskCardItem *blankItem = [CCTaskCardItem taskCardItemWithTitle:@"" content:@"" date:[NSDate date] alertType:TaskCardAlertTypeNone];
    CCTaskCardTabldViewCell *taskCardCell = [CCTaskCardTabldViewCell taskCardCellWithItem:blankItem];
    return taskCardCell;
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
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"avatarImage"];
    if (imageData) {
        UIImage *avatarImage = [UIImage imageWithData:imageData];
        self.avatarImageView.image = avatarImage;
    }
    
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
    self.titleTF.text = taskCardItem.cardTitle;
    //设置内容
    self.contentTF.text = taskCardItem.cardContent;
    //设置提醒样式
    if (taskCardItem.taskCardAlertType == TaskCardAlertTypeNotification) {
        self.alertIcon.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"icon_notice"].CGImage);
    } else {
        
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
        }];
        
        [self setupTaskCard];
    }
    return self;
}


#pragma mark - 自定义删除按钮




- (void)setupTaskCard {
    
    self.backgroundColor = [UIColor clearColor];

    
    
    
    //1.设置背景图片
    UIImageView *bgImageView = [[UIImageView alloc] init];
    UIImage *bgImage = [UIImage imageNamed:@"bg_line"];
    //    bgImageView.image = bgImage;
    bgImageView.image = [bgImage stretchableImageWithLeftCapWidth:200 topCapHeight:10];
    
    [self.contentView addSubview:bgImageView];
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
    [self.contentView addSubview:leftView];
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
    [self.contentView addSubview:rightView];
    _rightView = rightView;
    
    //标题
    UITextField *titleTF = [[UITextField alloc] init];
    titleTF.placeholder = @"标题...";
    titleTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    titleTF.enabled = NO;
//    titleTF.backgroundColor = [UIColor blueColor];
    [rightView addSubview:titleTF];
    _titleTF = titleTF;
    
    //内容
    UITextView *contentTF = [[UITextView alloc] init];
//    contentTF.placeholder = @"内容...";
    contentTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    contentTF.textColor = ColorWithRGB(135, 135, 147, 1);
    contentTF.backgroundColor = [UIColor clearColor];
    contentTF.userInteractionEnabled = NO;
    contentTF.delegate = self;
    contentTF.textContainerInset = UIEdgeInsetsMake(4, -5, 4, 0);
    [rightView addSubview:contentTF];
    _contentTF = contentTF;
    
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

}

- (void)setupConstraints {
    
    
    //    约束
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(9);
        make.left.right.bottom.equalTo(self.contentView);
    }];
    
    //左部份view
    /***********************左边部分的子控件******************************/
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(9);
        make.left.bottom.equalTo(self.contentView);
        make.width.equalTo(@((ScreenW - 20) * (100.0 / 355)));
    }];
    
    //头像约束
    //    self.avatarImageView.frame = CGRectMake(0, 0, 40, 40);
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(0);
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
        make.bottom.lessThanOrEqualTo(self.leftView.mas_bottom).offset(-5);
    }];
    
    
    /***********************右边部分的子控件******************************/
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(9);
        make.right.bottom.equalTo(self.contentView);
        make.left.equalTo(self.leftView.mas_right);
    }];
    
    //标题约束
    [self.titleTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rightView.mas_top).offset(10);
        make.left.equalTo(self.rightView.mas_left).offset(10);
        make.right.equalTo(self.alertIcon.mas_right).offset(-10);
        make.height.equalTo(@20);
    }];
    //内容约束
    [self.contentTF mas_makeConstraints:^(MASConstraintMaker *make) {
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







#pragma mark - 加载自定义delete按钮

/**state
 UITableViewCellStateDefaultMask                     = 0,
 UITableViewCellStateShowingEditControlMask          = 1 << 0,
 UITableViewCellStateShowingDeleteConfirmationMask   = 1 << 1
 *
 */
- (void)willTransitionToState:(UITableViewCellStateMask)state {
    //将要进入编辑模式时候call 懒加载的view自定义
    
    if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //        NSLog(@"%@", self.subviews);
            
            for (UIView *view in self.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
                    
                    view.clipsToBounds = NO;
                
                    UIButton *buttonView = (UIButton *)[view.subviews firstObject];
                    [buttonView setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    buttonView.clipsToBounds = NO;
                    //给默认的deleteButton添加背景图片
                    UIImageView *buttonImageView = [[UIImageView alloc] init];
                    buttonImageView.backgroundColor = ColorWithRGB(68, 141, 231, 1);
                    
//                    buttonImageView.userInteractionEnabled = YES;

                    buttonImageView.layer.cornerRadius = 3;
                    buttonImageView.image = [UIImage imageNamed:@"delete_button_white"];
                    buttonImageView.contentMode = UIViewContentModeCenter;
                    buttonImageView.frame = CGRectMake(-10, 12, buttonView.frame.size.width - 3, buttonView.frame.size.height - 15);
                    [buttonView addSubview:buttonImageView];
                    
                    buttonView.backgroundColor = [UIColor clearColor];
                    buttonView.superview.backgroundColor = [UIColor clearColor];
   
                    
                }
            }
            
        });

    }
    
    

}






@end


