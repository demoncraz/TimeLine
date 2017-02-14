//
//  CCCalenderItemView.m
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/13.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCalenderItemView.h"
#import "CCDateTool.h"

#define ColorWithRGB(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define CCDefaultDateTextColor ColorWithRGB(16, 16, 42, 1)
#define CCHighlightDateTextColor [UIColor whiteColor]
#define CCWeekendTextColor ColorWithRGB(121, 121, 136, 1)
#define CCDefaultHighlightBgColor ColorWithRGB(68, 141, 231, 1)
#define CCDotColorImportant ColorWithRGB(234, 71, 71, 1)
#define CCDotColorNormal ColorWithRGB(68, 141, 231, 1)


#define ChineseDays @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"]

@interface CCCalenderItemView ()

@property (weak, nonatomic) IBOutlet UILabel *normalDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *chineseDateLabel;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIView *dotView;



@end

@implementation CCCalenderItemView

+ (instancetype)calenderItemView {
    return [[[NSBundle mainBundle] loadNibNamed:@"CCCalenderItemView" owner:nil options:nil] firstObject];
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    //设置底部圆点为⭕️形
    self.dotView.layer.cornerRadius = self.dotView.bounds.size.width * 0.5;
    //设置背景色图为原型
    self.bgView.layer.cornerRadius = self.bgView.bounds.size.width * 0.5;
    self.bgView.layer.masksToBounds = YES;
    
}

- (void)setItemDate:(NSDate *)itemDate {
    _itemDate = itemDate;
    NSDictionary *dateDict = [CCDateTool getDateComponentsFromDate:itemDate];
    NSString *dayString = dateDict[@"day"];
    //设置日期（天）
    //去掉前面的0
    if ([dayString hasPrefix:@"0"]) {
        dayString = [dayString substringFromIndex:1];
    }
    self.normalDateLabel.text = dayString;
    
    if ([CCDateTool isToday:itemDate]) {
        self.chineseDateLabel.text = @"今天";
        self.bgView.backgroundColor = CCDefaultHighlightBgColor;
        self.normalDateLabel.textColor = CCHighlightDateTextColor;
        self.chineseDateLabel.textColor = CCHighlightDateTextColor;
    } else {
        //计算农历日并显示
        NSDictionary *chineseDateDict = [CCDateTool getChineseDateComponentsFromDate:itemDate];
        NSInteger chineseDay = [chineseDateDict[@"day"] integerValue];
        self.chineseDateLabel.text = ChineseDays[chineseDay - 1];
        
        self.bgView.backgroundColor = [UIColor clearColor];
        self.normalDateLabel.textColor = CCDefaultDateTextColor;
        self.chineseDateLabel.textColor = CCDefaultDateTextColor;
    }
    //判断星期几
    NSInteger weekDay = [CCDateTool getWeedDayFromDate:itemDate];
    if (weekDay == 0 || weekDay == 6) {//如果是周末
        self.normalDateLabel.textColor = CCWeekendTextColor;
        self.chineseDateLabel.textColor = CCWeekendTextColor;
    } else {
        self.normalDateLabel.textColor = CCDefaultDateTextColor;
        self.chineseDateLabel.textColor = CCDefaultDateTextColor;
    }
    
}


- (void)setShouldShowDot:(BOOL)shouldShowDot {
    _shouldShowDot = shouldShowDot;
    if (shouldShowDot) {
        self.dotView.hidden = NO;
    } else {
        self.dotView.hidden = YES;
    }
}

/**
 根据模型显示dot
 
 @param item 模型
 */
- (void)showDotWithDotItem:(CCDotItem *)item {
    self.dotView.hidden = NO;
    switch (item.dotStyle) {
        case CCDotStyleImportant:
            self.dotView.backgroundColor = CCDotColorImportant;
            break;
        case CCDotStyleNormal:
            self.dotView.backgroundColor = CCDotColorNormal;
            break;
        default:
            self.dotView.backgroundColor = [UIColor clearColor];
            break;
    }
}


@end
