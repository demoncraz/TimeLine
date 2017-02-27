//
//  TimeLineViewController.m
//  TimeLine
//
//  Created by demoncraz on 2017/1/26.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "TimeLineViewController.h"
#import "Masonry.h"
#import "CCContentTableView.h"
#import "CCTaskCardTabldViewCell.h"
#import "CCCoverView.h"
#import "MJExtension.h"
#import "NSObject+LocalNotification.h"
#import "CCCalerderPickerView.h"
#import "CCNotesViewController.h"
#import "UIView+Frame.h"
#import "CCCommonCoverView.h"
#import "NSDate+Date.h"
#import "CCDateTool.h"
#import "CCCardDetailCoverView.h"
#import "CCTaskCardItemGroups.h"
#import "CCDateButton.h"

#define DefaultGroupInset 50
#define DefaultBgLineColor ColorWithRGB(210, 210, 210, 1)
#define DefaultDateLabelFont [UIFont systemFontOfSize:12];
#define DefaultDateLabelColor ColorWithRGB(72, 72, 95, 1);
#define EstimatedCardHeight 110
#define CCTimelineCellMinHeight 75


@interface TimeLineViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, CCCoverViewDelegate, CCCardDetailCoverViewDelegate,CCCalerderPickerViewDelegate>

@property (weak, nonatomic) IBOutlet CCContentTableView *contentTableView;

@property (nonatomic, strong) UIButton *noInfoButton;

//当前日期显示的模型数组
@property (nonatomic, strong) CCTaskCardItemGroups *displayingItemGroups;

//保存所有任务卡对象
@property (nonatomic, strong) NSMutableArray *taskCards;

@property (weak, nonatomic) UIButton *addButton;

@property (nonatomic, assign, getter=isAddingNew) BOOL addingNew;

@property (nonatomic, strong) CCCoverView *coverView;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSString *previousText;

@property (nonatomic, weak) CCCalerderPickerView *pickerView;

@property (nonatomic, weak) UIButton *calendarCoverView;

@property (nonatomic, strong) NSMutableArray *notificationDates;

@property (nonatomic, strong) CCNotesViewController *notesVc;

@property (nonatomic, strong) UIButton *notesCoverView;

@property (weak, nonatomic) IBOutlet CCDateButton *titleMonthButton;

@property (strong, nonatomic) NSDate *selectedDate;

@end

@implementation TimeLineViewController


#pragma mark - lazy loading

- (NSDate *)selectedDate {
    if (_selectedDate ==nil) {
        _selectedDate = [NSDate date];
    }
    return _selectedDate;
}

- (CCNotesViewController *)notesVc {
    if (_notesVc == nil) {
        _notesVc = [[CCNotesViewController alloc] init];
    }
    return _notesVc;
}

- (NSMutableArray *)notificationDates {
    if (_notificationDates == nil) {
        _notificationDates = [NSMutableArray array];
    }
    return _notificationDates;
}

- (NSString *)previousText {
    if (_previousText == nil) {
        _previousText = [NSString string];
    }
    return _previousText;
}

- (UIButton *)noInfoButton {
    if (_noInfoButton == nil) {
        _noInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_noInfoButton setImage:[UIImage imageNamed:@"no_card"] forState:UIControlStateNormal];
        [_noInfoButton setImage:[UIImage imageNamed:@"no_card"] forState:UIControlStateHighlighted];
        [_noInfoButton sizeToFit];
        
        [_noInfoButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _noInfoButton.alpha = 0;
        _noInfoButton.center = self.view.center;
    }
    return _noInfoButton;
}

- (NSString *)filePath {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fullPath = [cachesPath stringByAppendingPathComponent:@"Cards.plist"];
        _filePath = fullPath;
    });
    return _filePath;
}

- (CCCoverView *)coverView {
    if (_coverView == nil) {
        _coverView = [[CCCoverView alloc] init];
        _coverView.frame = [UIScreen mainScreen].bounds;
        _coverView.delegate = self;
    }
    return _coverView;
}

- (NSMutableArray *)taskCards {
    if (_taskCards == nil) {
        _taskCards = [NSMutableArray array];
    }
    return _taskCards;
}

#pragma mark - 初始化模型数组

- (CCTaskCardItemGroups *)displayingItemGroups {
    if (_displayingItemGroups == nil) {
        _displayingItemGroups = [CCTaskCardItemGroups itemGroups];
        [self setDisplayingGroupsByDate:[NSDate date]];
        
    }
    return _displayingItemGroups;
}

#pragma mark - 根据日期获取当前需要展示的卡片列表

- (void)setDisplayingGroupsByDate:(NSDate *)date {
    if (self.displayingItemGroups.count > 0) {
        [self.displayingItemGroups removeAllGroups];
    }
    
    NSArray *taskCardsArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaskCardItems.plist" ofType:nil]];
    
    if (taskCardsArr) {
        for (NSMutableArray *arr in taskCardsArr) {
            NSMutableArray *itemArr = [CCTaskCardItem mj_objectArrayWithKeyValuesArray:arr];
            for (CCTaskCardItem * item in itemArr) {
                //如果是今天或者未来的，添加到显示数组
                NSDate *dateWithNoTime = [CCDateTool getDateWithoutDailyTimeFromDate:date];
                NSDate *cardDateWithNoTime = [CCDateTool getDateWithoutDailyTimeFromDate:item.cardDate];
                if ([cardDateWithNoTime timeIntervalSince1970] > [dateWithNoTime timeIntervalSince1970] || item.isDone == NO) {//今天之后的卡片或者未完成的卡片
                    [self.displayingItemGroups addItem:item];
                    //添加注册通知
                    [self addNotificationWithTaskCardItem:item];
                }
            }
        }
    }
}

/**
 根据模型注册通知

 @param item 模型
 */
- (void)addNotificationWithTaskCardItem:(CCTaskCardItem *)item {
    NSString *dateString = [item getKeyFromItem];
    
    [CCTaskCardItem registerLocalNotificationWithDate:item.cardDate content:item.cardTitle key:dateString];
    
    [self.notificationDates addObject:item.cardDate];
}


#pragma mark - 生命周期函数
static NSString *headerViewId = @"headerView";
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@", path);
    
    // Do any additional setup after loading the view from its nib.
    
//    self.view.backgroundColor = [UIColor redColor];
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"TimeLineViewController" owner:self options:nil] lastObject];
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    
    //设置添加按钮
    [self setupAddButton];

    
    //添加右滑手势
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [self.view addGestureRecognizer:swipeRight];
    
    //注册接收newCard完成按钮的通知
    [CCNotificationCenter addObserver:self selector:@selector(newCardComplete:) name:CCNewCardCompleteNotification object:nil];
    [CCNotificationCenter addObserver:self selector:@selector(dismissCalendarCoverView) name:@"CCCalendarDismissNotification" object:nil];
    [CCNotificationCenter addObserver:self selector:@selector(calendarDidShow) name:@"CCCalendarShowNotification" object:nil];
    [CCNotificationCenter addObserver:self selector:@selector(notesCoverViewClick:) name:CCCommonCoverViewWillDismissNotification object:self.notesCoverView];
    //监听到备注新增完成后刷新对应行
    [CCNotificationCenter addObserverForName:CCRemarkDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        CCTaskCardItem *item = note.object;
        NSIndexPath *indexPath = [self.displayingItemGroups indexPathForItem:item];
        [self.contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    //监听到头像变化的通知后刷新表格
    DefineWeakSelf;
    [CCNotificationCenter addObserverForName:CCAvatarChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.contentTableView reloadData];
    }];

    
}



- (void)viewWillAppear:(BOOL)animated {//将要显示view的时候，判断一下是否为空，如果为空，就展示noInfo的背景图片
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    if (self.displayingItemGroups.count == 0) {
        [self showNoInfoImage];
    }
}

#pragma mark - 移除通知监听

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - 初始化添加按钮

- (void)setupAddButton {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.backgroundColor = [UIColor redColor];
    [addButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //扩大add按钮的触控区域100 * 100;
    addButton.bounds = CGRectMake(0, 0, 100, 100);
    
    addButton.center = CGPointMake(ScreenW - 30, 42);
    
    [self.view addSubview:addButton];
    _addButton = addButton;
}


#pragma mark - 加号按钮点击
- (IBAction)addButtonClick:(id)sender {
    //让正在编辑的cell退出编辑模式
    [self.contentTableView setEditing:NO animated:YES];
    
    self.addingNew = !self.addingNew;
    
    if (self.addingNew) {//正在添加新卡片
        [self startAddingNewCard];
    } else {//点击了❎按钮
        [self endAddingNewCardWithDismissOption:CCCoverViewDismissOptionCancel];
    }

    
}

#pragma mark - 左上角的按钮点击
- (IBAction)notesButtonClick:(id)sender {

    //展示备忘录界面
    
    [self.view.window addSubview:self.notesVc.view];
    [UIView animateWithDuration:0.3 animations:^{
//        notesCoverView.alpha = 1;
        self.notesVc.view.CC_x = 0;
    }];
    
}

- (void)notesCoverViewClick:(NSNotification *)notification {
    
    NSString *identifier = notification.object;
    if (![identifier isEqualToString:@"NotesCoverViewClick"]) {
        return;
    }

    [UIView animateWithDuration:0.3 animations:^{
        //将notesVc移出屏幕
        self.notesVc.view.CC_x = - self.notesVc.view.CC_width;
    } completion:^(BOOL finished) {
        [self.notesVc.view removeFromSuperview];
    }];
}


#pragma mark - 开始新增模式
- (void)startAddingNewCard {
    DefineWeakSelf;
    [self.view.window addSubview:self.coverView];
    
    //将addButton置顶
    [self.view.window insertSubview:self.addButton aboveSubview:self.coverView];
    
    //将contentView下移
     [self.contentTableView setContentOffset:CGPointMake(0, -(EstimatedCardHeight + self.contentTableView.contentInset.top)) animated:YES];
    //将addButton旋转
    [UIView animateWithDuration:0.3 animations:^{
    
        weakSelf.addButton.transform = CGAffineTransformScale(self.addButton.transform, 1.5, 1.5);
        weakSelf.addButton.transform = CGAffineTransformRotate(self.addButton.transform, M_PI * 0.25);
        
    } completion:^(BOOL finished) {
    }];

    
    //        添加遮罩层
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.coverView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];

}

#pragma mark - 退出新增模式
- (void)endAddingNewCardWithDismissOption:(CCCoverViewDismissOption) option {
    DefineWeakSelf;
    //将tableView滚回
    [self.contentTableView setContentOffset:CGPointMake(0, -self.contentTableView.contentInset.top) animated:YES];
    //隐藏释放coverView
    [self.coverView dismissCoverViewWithOptions:option];
    self.coverView = nil;
    //重置新卡片的行数
    currentLineNumberOfNewCard = 0;
    //将按钮旋转回去
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.addButton.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [weakSelf.view addSubview:self.addButton];
    }];
}


//#pragma mark - 保存卡片内容到沙盒
//- (void)saveTaskCards {
//    
//    //模型转字典数组
//    NSMutableArray *allItems = [NSMutableArray array];
//    for (NSArray *arr in self.taskCardItems) {
//        NSArray *cardArr = [CCTaskCardItem mj_keyValuesArrayWithObjectArray:arr];
//        [allItems addObject:cardArr];
//    }
////    
////    NSArray *cardsArr = [CCTaskCardItem mj_keyValuesArrayWithObjectArray:self.taskCardItems];
//    
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    
//    NSString *fullPath = [cachesPath stringByAppendingPathComponent:@"Cards.plist"];
//    
//    NSLog(@"%@", cachesPath);
//    
//    [allItems writeToFile:fullPath atomically:YES];
//    
//
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
//    return self.taskCardItems.count;
    return self.displayingItemGroups.count;
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSArray *cardGroup = self.taskCardItems[section];
//    return cardGroup.count;
    CCTaskCardDayGroup *dayGroup = [self.displayingItemGroups dayGroupAtIndex:section];
    return dayGroup.count;
}

//设置section headerView


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DefaultGroupInset;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] init];

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = DefaultBgLineColor;
    CGFloat linePositionX = 0;
    
    //屏幕适配
    if (iPhone6_7) {
        linePositionX = 108.8;
    } else if (iPhone6P_7P) {
        linePositionX = 110;
    } else if (iPhone5_5s) {
        linePositionX = 95;
    }
    
    //获得本组高度
//    NSArray *arr = self.taskCardItems[section];
    CCTaskCardDayGroup *dayGroup = [self.displayingItemGroups dayGroupAtIndex:section];
    
    CGFloat sectionHeight = 0;
    for (NSInteger i = 0; i < dayGroup.count; i++) {
        CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
        sectionHeight += cellHeight;
    }
    
    line.frame = CGRectMake(linePositionX, 20, 0.5, sectionHeight + 25);
    [headerView addSubview:line];
    headerView.layer.zPosition = -1;
    
    //小黄点标记
    CCTaskCardItem *item = [dayGroup itemAtIndex:0];
    
    UIImageView *dateTagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sun"]];
    dateTagImageView.CC_centerX = line.CC_centerX;
    dateTagImageView.CC_centerY = DefaultGroupInset * 0.7;
    [headerView addSubview:dateTagImageView];
    //日期标记
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.font = DefaultDateLabelFont;
    dateLabel.textColor = DefaultDateLabelColor;
    dateLabel.text = [NSString stringWithFormat:@"%zd月%zd日", item.cardDate.month, item.cardDate.day];
    [dateLabel sizeToFit];
    dateLabel.CC_centerY = dateTagImageView.CC_centerY;
    dateLabel.CC_centerX = dateTagImageView.CC_centerX + 40;
    [headerView addSubview:dateLabel];
    
    if ([CCDateTool isSameDay:item.cardDate anotherDay:[NSDate date]]) {
        dateLabel.text = @"今天";
        dateTagImageView.image = [UIImage imageNamed:@"sun_today"];
    }


    return headerView;


}



- (CCTaskCardTabldViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    
    CCTaskCardTabldViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[CCTaskCardTabldViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    //获得对应模型
    CCTaskCardDayGroup *dayGroup = [self.displayingItemGroups dayGroupAtIndex:indexPath.section];
    CCTaskCardItem *item = [dayGroup itemAtIndex:indexPath.row];
    
    cell.taskCardItem = item;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //获得对应模型
    CCTaskCardDayGroup *dayGroup = [self.displayingItemGroups dayGroupAtIndex:indexPath.section];
    CCTaskCardItem *item = [dayGroup itemAtIndex:indexPath.row];
    
    return item.height > CCTimelineCellMinHeight ? item.height : CCTimelineCellMinHeight;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self deleteCardAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //获得对应模型
    CCTaskCardDayGroup *dayGroup = [self.displayingItemGroups dayGroupAtIndex:indexPath.section];
    CCTaskCardItem *item = [dayGroup itemAtIndex:indexPath.row];
    //添加遮罩
    CCCardDetailCoverView *cardCoverView = [[CCCardDetailCoverView alloc] init];
    cardCoverView.delegate = self;
    [cardCoverView showWithItem:item];
}

#pragma mark - CCCardDetailCoverViewDelegate
- (void)CCCardDetailCoverView:(CCCardDetailCoverView *)coverView didCompleteTaskItem:(CCTaskCardItem *)item {
    NSIndexPath *indexPath = [self.displayingItemGroups indexPathForItem:item];
    //刷新对应卡片的状态
    [self.contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //注销对应通知
    [self removeNotificationWithItem:item];
}

#pragma mark - CCCoverViewDelegate 
static NSInteger currentLineNumberOfNewCard = 0;
- (void)coverView:(CCCoverView *)coverView didChangeLineNumbers:(NSInteger)lineNumbers {
    if (lineNumbers != currentLineNumberOfNewCard) {
        CGFloat scrollOffset = DefaultSingleLineHeight * (lineNumbers - currentLineNumberOfNewCard);
        CGPoint currentContentOffset = self.contentTableView.contentOffset;
        [self.contentTableView setContentOffset:CGPointMake(0, currentContentOffset.y -= scrollOffset) animated:YES];
        currentLineNumberOfNewCard = lineNumbers;
        
    }

    
}

#pragma mark - newCardComplete监听到新卡片完成后调用

- (void)newCardComplete:(NSNotification *)notification {
    
    CCTaskCardItem *newCardItem = notification.object;
    
    //新增通知列表
    [self.notificationDates addObject:newCardItem.cardDate];
    //添加通知
    [CCTaskCardItem registerLocalNotificationWithDate:newCardItem.cardDate content:newCardItem.cardTitle key:[newCardItem getKeyFromItem]];
    
    NSInteger section = [self.displayingItemGroups addItem:newCardItem];
    
    
    NSIndexPath *indexPath;
    if (section > 0) {//新加组
        indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        [self.contentTableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        indexPath = [self.displayingItemGroups indexPathForItem:newCardItem];
        [self.contentTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    //自动滚动到新加的卡片
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [self.contentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES]; 
    });

    
    //将遮罩层移除
    [self endAddingNewCardWithDismissOption:CCCoverViewDismissOptionAddNew];
    
    //按钮模式设置为非新增模式
    self.addingNew = NO;
    
}


#pragma mark - 移除通知
- (void)removeNotificationWithItem:(CCTaskCardItem *)item {
    [self.notificationDates removeObject:item.cardDate];
    
    NSString *keyString = [item getKeyFromItem];
    
    [CCTaskCardItem cancelLocalNotificationWithKey:keyString];
}


#pragma mark - 添加／删除卡片逻辑

/**
 删除卡片

 @param indexPath 定位
 @param animation 动画效果
 */
- (void)deleteCardAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    
    //获得对应row的item，并移除对应的通知
    CCTaskCardDayGroup *dayGroup = [self.displayingItemGroups dayGroupAtIndex:indexPath.section];
    CCTaskCardItem *item = [dayGroup itemAtIndex:indexPath.row];

    //移除列表通知
    [self removeNotificationWithItem:item];
    
//    [arr removeObject:item];
    [self.displayingItemGroups removeItem:item withIndexPath:indexPath];
//    [dayGroup removeItem:item];
    
    if (dayGroup.count == 0) {//如果改日期没有卡片了，就将整个section删除
        [self.contentTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    }
    
    if (self.displayingItemGroups.count == 0) {
        [self showNoInfoImage];
    }
}

- (void)addCardAtIndexPath:(NSIndexPath *)indexPath isNewSection:(BOOL)isNewSection withRowAnimation:(UITableViewRowAnimation)animation {
    if (isNewSection) {
        [self.contentTableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        
        [self.contentTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    }
    
    
    [self removeNoinfoImage];
    
}

#pragma mark - 没有卡片时展示背景图片

/**
 展示背景图
 */
- (void)showNoInfoImage {
    [self.view addSubview:self.noInfoButton];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.noInfoButton.alpha = 1;
    }];
    
}
/**
 隐藏背景图
 */
- (void)removeNoinfoImage {
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        self.noInfoButton.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf.noInfoButton removeFromSuperview];
        weakSelf.noInfoButton = nil;
    }];
    
}


#pragma mark - 时间按钮点击
- (IBAction)dateButtonClick:(id)sender {
    
    CCCalerderPickerView *pickerView = [CCCalerderPickerView calenderPickerView];
    pickerView.delegate = self;
    _pickerView = pickerView;
    
    //添加遮罩
    UIButton *coverView = [UIButton buttonWithType:UIButtonTypeSystem];
    _calendarCoverView = coverView;
    coverView.frame = [UIScreen mainScreen].bounds;
    [coverView addTarget:self action:@selector(coverViewClick:) forControlEvents:UIControlEventTouchUpInside];
    coverView.backgroundColor = ColorWithRGB(0, 0, 0, 0.5);
    coverView.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:coverView];
    //添加日历控件
    [[UIApplication sharedApplication].keyWindow addSubview:pickerView];
    //显示遮罩
    [UIView animateWithDuration:0.3 animations:^{
        coverView.alpha = 1;
    }];
    [pickerView show];
}

#pragma mark - 遮罩点击事件
- (void)coverViewClick:(UIButton *)button {
    [self.pickerView dismiss];
}

- (void)dismissCalendarCoverView {
    [UIView animateWithDuration:0.3 animations:^{
        self.calendarCoverView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.calendarCoverView removeFromSuperview];
    }];
}

#pragma mark - 监听控件显示
- (void)calendarDidShow {
    //设置提示点
    NSMutableArray *dotItemArr = [NSMutableArray array];
    for (NSDate *date in self.notificationDates) {
        CCDotItem *item = [CCDotItem itemWithDate:date dotStyle:1];
        [dotItemArr addObject:item];
    }
    [self.pickerView setDotForDates:dotItemArr];
}

#pragma mark - 右滑调取备忘录手势
- (void)swipeRight:(UIPanGestureRecognizer *)pan {
    
    [self notesButtonClick:nil];
    
}

#pragma mark - CCCalerderPickerViewDelegate

- (void)CCCalerderPickerView:(CCCalerderPickerView *)calerderPickerView didSelectDate:(NSDate *)date {
    //设置时间标题栏
    self.selectedDate = date;
    //如果不是当天 展示一个回到当前的按钮
    if ([CCDateTool isSameDay:date anotherDay:[NSDate date]]) {
        [self showBackToTodayButton];
    }
    
    NSString *dateString = [NSString stringWithFormat:@"%ld年%ld月%ld日", date.year, date.month, date.day];
    [self.titleMonthButton setTitle:dateString forState:UIControlStateNormal];
    
    //更新当前展示的数据
    [self setDisplayingGroupsByDate:date];
    [self.contentTableView reloadData];
}

- (void)showBackToTodayButton {
    
}


@end
