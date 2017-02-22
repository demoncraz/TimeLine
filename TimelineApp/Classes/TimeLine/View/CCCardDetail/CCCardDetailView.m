//
//  CCCardDetailView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/22.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCardDetailView.h"
#import "NSDate+Date.h"
#import "CCDateTool.h"

@interface CCCardDetailView ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkboxButton;


@end

@implementation CCCardDetailView

- (void)setItem:(CCTaskCardItem *)item {
    _item = item;
    self.titleLabel.text = item.cardTitle;
    self.contentLabel.text = item.cardContent;
    
    if ([CCDateTool isSameDay:item.cardDate anotherDay:[NSDate date]]) {//是今天
        self.timeLabel.text = [NSString stringWithFormat:@"今天 %ld:%ld", item.cardDate.hour, item.cardDate.minute];
    } else {
        self.timeLabel.text = [NSString stringWithFormat:@"%ld月%ld日 %ld:%ld", item.cardDate.month, item.cardDate.day, item.cardDate.hour, item.cardDate.minute];
    }
    
    //设置完成按钮状态
    self.doneButton.enabled = !item.isDone;
    
}

+ (instancetype)cardDetailView {
    return [[[NSBundle mainBundle] loadNibNamed:@"CCCardDetailView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.CC_width * 0.5;
    self.avatarImageView.layer.masksToBounds = YES;
    //设置头像
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"avatarImage"];
    if (imageData) {
        UIImage *avatarImage = [UIImage imageWithData:imageData];
        self.avatarImageView.image = avatarImage;
    }
    
    //设置昵称
    NSString *nameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    self.nameLabel.text = nameString ? nameString : @"未设置";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.CC_height = CGRectGetMaxY(self.bottomView.frame) + 30;
}

- (IBAction)checkboxButtonClick:(UIButton *)button {
    self.checkboxButton.selected = !self.checkboxButton.selected;
}


- (IBAction)confirmButtonClick:(id)sender {
    if (self.checkboxButton.selected) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CCConfirmNotShowUDKey];
    }
}


@end
