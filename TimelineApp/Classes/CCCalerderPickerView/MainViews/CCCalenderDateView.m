//
//  CCCalenderDateView.m
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/14.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCalenderDateView.h"
#import "CCCalenderItemView.h"
#import "CCDateTool.h"

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
#define CCCalenderItemHeight 55
#define CCSecondsOfDay (24 * 60 * 60)
#define ColorWithRGB(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define CCDefaultSeparatorLineMargin 10
#define CCDefaultSeparatorLineColor ColorWithRGB(220,220,227,1)


@interface CCCalenderDateView ()<UICollectionViewDataSource>



@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

//储存当月所有要展示的日期
@property (nonatomic, strong) NSMutableArray *dateArr;

@property (nonatomic, assign) NSInteger rows;

@property (nonatomic, strong) NSMutableArray *separatorLines;


@end

@implementation CCCalenderDateView

#pragma mark - lazy loading

- (NSArray *)dotArr {
    if (_dotArr == nil) {
        _dotArr = [NSArray array];
    }
    return _dotArr;
}

- (NSMutableArray *)separatorLines {
    if (_separatorLines == nil) {
        _separatorLines = [NSMutableArray array];
    }
    return _separatorLines;
}

- (NSMutableArray *)dateArr {
    if (_dateArr == nil) {
        _dateArr = [NSMutableArray array];
    }
    return _dateArr;
    
}

- (UICollectionViewFlowLayout *)layout {
    if (_layout == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 7.0, CCCalenderItemHeight);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _layout = layout;
    }
    return _layout;
}

- (void)setYearMonth:(CCYearMonth)yearMonth {
    CGRect selfFrame = self.frame;
    _yearMonth = yearMonth;
    [self setupDateWithMonth:yearMonth.month year:yearMonth.year];
    //根据要展示的天数重新设置frame
    CGFloat newHeight = CCCalenderItemHeight * self.rows;
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
    
    selfFrame = self.frame;
    
    [self reloadData];
    
    [self setupSeparatorLines];
    
}


#pragma mark - 创建并添加分割线

- (void)setupSeparatorLines {
    NSInteger count = self.rows - 1;
    //现将原来的分割线清除
    NSInteger countDifference = count - self.separatorLines.count;
    if (countDifference > 0) {//需要增加线条
        for (int i = 0; i < countDifference; i++) {
            UIView *separatorLineView = [[UIView alloc] init];
            separatorLineView.backgroundColor = CCDefaultSeparatorLineColor;
            [self addSubview:separatorLineView];
            [self.separatorLines addObject:separatorLineView];
        }
    } else if (countDifference < 0) {//需要去掉一些
        for (int i = 0; i < -countDifference; i++) {
            [self.separatorLines.lastObject removeFromSuperview];
            [self.separatorLines removeLastObject];
        }
        
    }
    
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat y = CCCalenderItemHeight;
    for (int i = 0; i < self.separatorLines.count; i++) {
        UIView *view = self.separatorLines[i];
        view.frame = CGRectMake(CCDefaultSeparatorLineMargin, y, ScreenW - 2 * CCDefaultSeparatorLineMargin, 0.5);
        y += CCCalenderItemHeight;
    }
}


- (void)setupDateWithMonth:(NSInteger)month year:(NSInteger)year {
    [self.dateArr removeAllObjects];
    //1.计算当前月1号是星期几
    NSDate *firstDay = [CCDateTool getDateFromYear:year month:month day:1];
    NSInteger firstWeekDay = [CCDateTool getWeedDayFromDate:firstDay];
    
    //计算当前月有几天
    NSInteger totalMonthDays = [CCDateTool getTotalDaysOfMonth:month year:year];
    
    //计算需要补几天
    NSInteger extra = 7 - (firstWeekDay + totalMonthDays) % 7;
    
    //计算总共需要展示的天数
    NSInteger totalItems = firstWeekDay + totalMonthDays + extra;
    
    //计算要展示的第一天的日期
    NSDate *firstDisplayingDate = [NSDate dateWithTimeInterval:-CCSecondsOfDay * firstWeekDay sinceDate:firstDay];
    
    //创建当前要展示的数据数组
    NSInteger dayInterval = 0;
    for (int i = 0; i < totalItems; i++) {
        NSDate *date = [NSDate dateWithTimeInterval:CCSecondsOfDay * dayInterval sinceDate:firstDisplayingDate];
        [self.dateArr addObject:date];
        dayInterval++;
    }
    self.rows = self.dateArr.count / 7 + (self.dateArr.count % 7 == 0 ? 0 : 1);
    
}



- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        //注册cell
        [self registerNib:[UINib nibWithNibName:@"CCCalenderItemView" bundle:nil] forCellWithReuseIdentifier:@"cell"];
        self.dataSource = self;
        //设置背景颜色
        self.backgroundColor = [UIColor whiteColor];
        //设置底部边框
        self.layer.shadowOffset = CGSizeMake(0, 0.5);
        self.layer.shadowColor = ColorWithRGB(220, 220, 227, 1).CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 0;
        self.layer.masksToBounds = NO;
        
    }
    return self;
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dateArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CCCalenderItemView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    //设置数据
    cell.itemDate = self.dateArr[indexPath.row];
    
    for (CCDotItem *item in self.dotArr) {
        if ([CCDateTool isSameDay:cell.itemDate anotherDay:item.date]) {
            cell.shouldShowDot = YES;
            [cell showDotWithDotItem:item];
            break;
        } else {
            cell.shouldShowDot = NO;
        }
    }
    
    return cell;
}




@end
