//
//  CCCalerderPickerView.m
//  CCCalenderPicker
//
//  Created by demoncraz on 2017/2/13.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCCalerderPickerView.h"
#import "CCCalenderItemView.h"
#import "CCDateTool.h"
#import "NSDate+Date.h"
#import "CCCalenderDateView.h"


#define CCSecondsOfDay (24 * 60 * 60)
#define CCCalenderItemHeight 55
#define ColorWithRGB(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
#define CCDefaultSeparatorLineMargin 10
#define CCDefaultSeparatorLineColor ColorWithRGB(220,220,227,1)

#define CCDefaultShowAnomationDuration 0.3

static NSString * const cellId = @"cell";

static CCCalerderPickerView *sharedCalenderPickView;

@interface CCCalerderPickerView ()

@property (weak, nonatomic) IBOutlet UIButton *monthButton;


@property (nonatomic, strong) CCCalenderDateView *dateView;

@property (nonatomic, strong) NSMutableArray *dateArr;

@property (nonatomic) CCYearMonth currentYearMonth;

@property (nonatomic, assign) NSInteger rows;

@property (nonatomic, strong) NSMutableArray *separatorLines;

@property (nonatomic, strong) NSMutableArray *reusableDateViews;

@property (nonatomic, strong) NSArray *dotArr;

@end

@implementation CCCalerderPickerView



#pragma mark - lazy loading

- (NSArray *)dotArr {
    if (_dotArr == nil) {
        _dotArr = [NSArray array];
    }
    return _dotArr;
}

- (NSMutableArray *)reusableDateViews {
    if (_reusableDateViews == nil) {
        _reusableDateViews = [NSMutableArray array];
    }
    return _reusableDateViews;
}


- (NSMutableArray *)dateArr {
    if (_dateArr == nil) {
        _dateArr = [NSMutableArray array];
    }
    return _dateArr;
    
}

//创建单例对象
+ (instancetype)calenderPickerView {
    return [[[NSBundle mainBundle] loadNibNamed:@"CCCalerderPickerView" owner:nil options:nil] firstObject];
}




- (void)awakeFromNib {
    
    [super awakeFromNib];
    CGRect frame = self.frame;
    frame.size.width = ScreenW;
    self.frame = frame;
    //设置label为当前年月
    CCYearMonth currentYearMonth = {[NSDate date].year, [NSDate date].month};
    self.currentYearMonth = currentYearMonth;
    [self setupUI];
//    [self reloadDateWithYearMonth:self.currentYearMonth];
    
}


/**
 设置头部月份标题文字
 @param yearMonth 年月
 */
- (void)setMonthLabelTextWithYearMonth:(CCYearMonth)yearMonth {
//    self.monthLabel.text = [NSString stringWithFormat:@"%ld年%ld月", yearMonth.year, yearMonth.month];
    [self.monthButton setTitle:[NSString stringWithFormat:@"%ld年%ld月", yearMonth.year, yearMonth.month] forState:UIControlStateNormal];
}


- (void)setupUI {
//    //设置描边
//    self.layer.borderWidth = 0.5;
//    self.layer.borderColor = ColorWithRGB(220, 220, 227, 1).CGColor;
    
    
    /*创建colloctionView*/
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 7.0, CCCalenderItemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _dateView = [[CCCalenderDateView alloc] initWithFrame:CGRectMake(0, 89, [UIScreen mainScreen].bounds.size.width, 275) collectionViewLayout:layout];
    _dateView.yearMonth = self.currentYearMonth;
    [self addSubview:_dateView];
    
    
}

- (CCCalenderDateView *)getDateView {
    
    //先从缓存池中取
    CCCalenderDateView *dateView = [self.reusableDateViews lastObject];
    if (dateView == nil) {//如果没取到，就创建
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 7.0, CCCalenderItemHeight);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        dateView = [[CCCalenderDateView alloc] initWithFrame:CGRectMake(0, 89, [UIScreen mainScreen].bounds.size.width, 275) collectionViewLayout:layout];
    }
    
    return dateView;
    
}





#pragma mark - 上一个月按钮点击

- (IBAction)lastMonthClick:(id)sender {
    if (self.dateView.frame.origin.x != 0) {//如果还在切换中，不响应点击
        return;
    }
    
    CCYearMonth yearmonth = self.currentYearMonth;
    yearmonth.month --;
    
    if (yearmonth.month == 0) {
        yearmonth.month = 12;
        yearmonth.year -= 1;
    }
    self.currentYearMonth = yearmonth;
    [self setMonthLabelTextWithYearMonth:self.currentYearMonth];
    [self switchMonth:NO];

}

- (IBAction)nextMonthClick:(id)sender {
    if (self.dateView.frame.origin.x != 0) {//如果还在切换中，不响应点击
        return;
    }
    CCYearMonth yearmonth = self.currentYearMonth;
    yearmonth.month ++;
    if (yearmonth.month == 13) {
        yearmonth.month = 1;
        yearmonth.year += 1;
    }
    self.currentYearMonth = yearmonth;
    [self setMonthLabelTextWithYearMonth:self.currentYearMonth];
    [self switchMonth:YES];
    
}

#pragma mark - 切换月份逻辑
- (void)switchMonth:(BOOL)isNextMonth {

    
    CCCalenderDateView *newDateView = [self getDateView];
    newDateView.dotArr = self.dotArr;
    newDateView.yearMonth = self.currentYearMonth;
    [self addSubview:newDateView];
    
    NSInteger flag = isNextMonth ? 1 : -1;
    
    //重新设置位置
    CGRect newFrame = newDateView.frame;
    newFrame.origin.x = flag * newFrame.size.width;
    newDateView.frame = newFrame;
    //切换月份动画
    [UIView animateWithDuration:0.3 animations:^{
        //新卡片移入
        CGPoint center = newDateView.center;
        center.x = self.dateView.center.x;
        newDateView.center = center;
        //就卡片移出
        CGRect frame = self.dateView.frame;
        frame.origin.x = - flag * frame.size.width;
        self.dateView.frame = frame;
        
    } completion:^(BOOL finished) {
        [self.dateView removeFromSuperview];
        [self.reusableDateViews removeLastObject];
        [self.reusableDateViews addObject:self.dateView];
        self.dateView = newDateView;
    }];
    
}

- (void)setDotForDates:(NSArray<CCDotItem *> *)dotItems {
    _dotArr = dotItems;
    self.dateView.dotArr = dotItems;
}

#pragma mark - 监听顶部年月标题的点击
- (IBAction)monthButtonClick:(id)sender {
    [self dismiss];
}

#pragma mark - show
- (void)show {
    
    CGRect frame = self.frame;
    frame.origin.y = -frame.size.height;
    self.frame = frame;
    
    [UIView animateWithDuration:CCDefaultShowAnomationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = self.frame;
        newFrame.origin.y = 0;
        self.frame = newFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - dismiss
- (void)dismiss {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CCCalendarDismissNotification" object:nil];
    
    [UIView animateWithDuration:CCDefaultShowAnomationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.frame;
        frame.origin.y = - frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

-(void)dealloc {
    NSLog(@"%s", __func__);
}


@end





