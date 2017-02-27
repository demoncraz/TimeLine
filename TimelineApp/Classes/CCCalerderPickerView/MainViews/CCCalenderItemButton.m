//
//  CCCalenderItemButton.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCalenderItemButton.h"
#import "CCDateTool.h"

#define CCDefaultDateTextColor ColorWithRGB(16, 16, 42, 1)
#define CCHighlightDateTextColor [UIColor whiteColor]
#define CCWeekendTextColor ColorWithRGB(121, 121, 136, 1)
#define CCDefaultHighlightBgColor ColorWithRGB(68, 141, 231, 1)
#define CCDotColorImportant ColorWithRGB(234, 71, 71, 1)
#define CCDotColorNormal ColorWithRGB(68, 141, 231, 1)

#define ChineseDays @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"]

@interface CCCalenderItemButton ()

@property (weak, nonatomic) IBOutlet UIView *dotView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *normalDay;
@property (weak, nonatomic) IBOutlet UILabel *chineseDay;


@end

@implementation CCCalenderItemButton

+ (instancetype)calendarItemButton {
    return [[[NSBundle mainBundle] loadNibNamed:@"CCCalenderItemButton" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = self.bgView.CC_width * 0.5;
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
    self.normalDay.text = dayString;
    //判断星期几
    NSInteger weekDay = [CCDateTool getWeedDayFromDate:itemDate];
    
    if ([CCDateTool isToday:itemDate]) {
        self.chineseDay.text = @"今天";
        self.bgView.backgroundColor = CCDefaultHighlightBgColor;
        self.normalDay.textColor = CCHighlightDateTextColor;
        self.chineseDay.textColor = CCHighlightDateTextColor;
    } else {
        //计算农历日并显示
        NSDictionary *chineseDateDict = [CCDateTool getChineseDateComponentsFromDate:itemDate];
        NSInteger chineseDay = [chineseDateDict[@"day"] integerValue];
        self.chineseDay.text = ChineseDays[chineseDay - 1];
        
        self.bgView.backgroundColor = [UIColor clearColor];
        
        if (weekDay == 0 || weekDay == 6) {//如果是周末
            self.normalDay.textColor = CCWeekendTextColor;
            self.chineseDay.textColor = CCWeekendTextColor;
        } else {
            self.normalDay.textColor = CCDefaultDateTextColor;
            self.chineseDay.textColor = CCDefaultDateTextColor;
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.bgView.layer.borderColor = CCDefaultBlueColor.CGColor;
        self.bgView.layer.borderWidth = 1;
    } else {
        self.bgView.layer.borderWidth = 0;
    }
}

@end
