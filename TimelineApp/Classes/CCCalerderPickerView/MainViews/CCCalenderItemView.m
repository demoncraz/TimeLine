//
//  CCCalenderItemView.m
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/13.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCalenderItemView.h"
#import "CCDateTool.h"
#import "CCCalenderItemButton.h"

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



@property (nonatomic, weak) CCCalenderItemButton *itemButton;

@end

@implementation CCCalenderItemView

//+ (instancetype)calenderItemView {
////    return [[[NSBundle mainBundle] loadNibNamed:@"CCCalenderItemView" owner:nil options:nil] firstObject];
//    CCCalenderItemView *itemView = [[CCCalenderItemView alloc] init];
//    
//    UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    itemButton.backgroundColor = [UIColor redColor];
//    itemButton.frame = CGRectMake(0, 0, 50, 60);
//    [itemView.contentView addSubview:itemButton];
//    
//    return itemView;
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CCCalenderItemButton *itemButton = [CCCalenderItemButton calendarItemButton];
        [itemButton addTarget:self action:@selector(itemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        itemButton.itemDate = [NSDate date];
        _itemButton = itemButton;
        [self.contentView addSubview:itemButton];
    }
    return self;
}

- (void)itemButtonClick:(CCCalenderItemButton *)button {
    [CCNotificationCenter postNotificationName:CCCalendarItemDidSelectNotification object:button];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.itemButton.frame = self.contentView.bounds;
}

- (void)setItemDate:(NSDate *)itemDate {
    _itemDate = itemDate;
    [self.itemButton setItemDate:itemDate];
    
}


- (void)setShouldShowDot:(BOOL)shouldShowDot {
    _shouldShowDot = shouldShowDot;
    if (shouldShowDot) {
        self.itemButton.dotView.hidden = NO;
    } else {
        self.itemButton.dotView.hidden = YES;
    }
}

/**
 根据模型显示dot
 
 @param item 模型
 */
- (void)showDotWithDotItem:(CCDotItem *)item {
    self.itemButton.dotView.hidden = NO;
    switch (item.dotStyle) {
        case CCDotStyleImportant:
            self.itemButton.dotView.backgroundColor = CCDotColorImportant;
            break;
        case CCDotStyleNormal:
            self.itemButton.dotView.backgroundColor = CCDotColorNormal;
            break;
        default:
            self.itemButton.dotView.backgroundColor = [UIColor clearColor];
            break;
    }
}


@end
