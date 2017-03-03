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
#import "CCDateButton.h"
#import "CCBackTodayButton.h"
#import "CCTaskCardDayGroup.h"

#define DefaultGroupInset 50
#define DefaultBgLineColor ColorWithRGB(210, 210, 210, 1)
#define DefaultDateLabelFont [UIFont systemFontOfSize:12];
#define DefaultDateLabelColor ColorWithRGB(72, 72, 95, 1);
#define EstimatedCardHeight 110
#define CCTimelineCellMinHeight 75
#define HideBackButtonTimeInterval 2


@interface TimeLineViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, CCCardDetailCoverViewDelegate,CCCalerderPickerViewDelegate>

@property (weak, nonatomic) IBOutlet CCContentTableView *contentTableView;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (nonatomic, strong) UIButton *noInfoButton;

@property (nonatomic, strong) NSMutableArray *taskCardItems;
//当前日期显示的模型数组
@property (nonatomic, strong) NSMutableArray *displayingItemGroups;

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

/****返回今天按钮相关属性********/

//记录当前选择的日期是否为今天
@property (nonatomic, assign, getter=isSelectedDateToday) BOOL selectedDateToday;

@property (nonatomic, weak) CCBackTodayButton *backButton;

@property (nonatomic, assign, getter=isScrolling) BOOL scrolling;

@property (nonatomic, assign, getter=isBackButtonShowing) BOOL backButtonShowing;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat backButtonMinY;

@property (nonatomic, assign) CGFloat backButtonMaxDistance;

@property (nonatomic, strong) NSMutableArray *dotItemArr;

@end

@implementation TimeLineViewController


#pragma mark - lazy loading

- (NSMutableArray *)dotItemArr {
    if (_dotItemArr == nil) {
        _dotItemArr = [NSMutableArray array];
        
        for (CCTaskCardDayGroup *group in self.taskCardItems) {
            CCDotItem *dotItem;
            for (CCTaskCardItem *item in group.items) {
                if (item.isDone == NO) {//该天有未完成事项
                    dotItem = [CCDotItem itemWithDate:group.date dotStyle:CCDotStyleImportant];
                    [_dotItemArr addObject:dotItem];
                    break;
                }
            }
            
            if (!dotItem) {
                dotItem = [CCDotItem itemWithDate:group.date dotStyle:CCDotStyleNormal];
            }
            [_dotItemArr addObject:dotItem];
        }
    }
    return _dotItemArr;
}

- (CCBackTodayButton *)backButton {
    if (_backButton == nil) {
        CCBackTodayButton *backButton = [CCBackTodayButton buttonWithType:UIButtonTypeCustom];
        //按钮的初始位置
        self.backButtonMinY = self.contentTableView.CC_y + 20;
        self.backButtonMaxDistance = 300;
        backButton.frame = CGRectMake(ScreenW, self.backButtonMinY, backButton.CC_width, backButton.CC_height);
        [backButton addTarget:self action:@selector(backToTodayButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:backButton belowSubview:self.titleImageView];
        _backButton = backButton;
    }
    return _backButton;
}

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
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullPath = [cachesPath stringByAppendingPathComponent:@"Cards.plist"];
    _filePath = fullPath;
    return _filePath;
}

- (CCCoverView *)coverView {
    if (_coverView == nil) {
        _coverView = [[CCCoverView alloc] init];
        _coverView.frame = [UIScreen mainScreen].bounds;
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

- (NSMutableArray *)taskCardItems {

    if (_taskCardItems == nil) {
        
        NSArray *taskCardArr = [NSMutableArray arrayWithContentsOfFile:self.filePath];
        
//        NSArray *taskCardArr = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaskCardItems_2.plist" ofType:nil]];
        
        if (taskCardArr) {
            _taskCardItems = [CCTaskCardDayGroup mj_objectArrayWithKeyValuesArray:taskCardArr];
        } else {
            _taskCardItems = [NSMutableArray array];
        }
        
    }
    return _taskCardItems;
}

- (NSMutableArray *)displayingItemGroups {
    if (_displayingItemGroups == nil) {
        _displayingItemGroups = [NSMutableArray array];
        [self setDisplayingGroupsByDate:[NSDate date] shouldUpdateNotes:YES];
        
    }
    return _displayingItemGroups;
}

#pragma mark - 根据日期获取当前需要展示的卡片列表

- (void)setDisplayingGroupsByDate:(NSDate *)date shouldUpdateNotes:(BOOL)yesOrNo{
    if (self.displayingItemGroups.count > 0) {
        [self.displayingItemGroups removeAllObjects];
    }
    
//    NSArray *taskCardsArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaskCardItems.plist" ofType:nil]];
    
    for (CCTaskCardDayGroup *group in self.taskCardItems) {
        NSDate *dateWithNoTime = [CCDateTool getDateWithoutDailyTimeFromDate:date];

        NSDate *groupDateWithNoTime = [CCDateTool getDateWithoutDailyTimeFromDate:group.date];
        
        for (CCTaskCardItem *item in group.items) {
            if ([groupDateWithNoTime timeIntervalSince1970] >= [dateWithNoTime timeIntervalSince1970] || item.isDone == NO) {
                [self addItem:item toDateGroups:self.displayingItemGroups];
                if (yesOrNo) {
                    [self addNotificationWithTaskCardItem:item];
                }
            }
        }
    
    }

}

#pragma mark - 为日期组添加新元素
- (NSDictionary *)addItem:(CCTaskCardItem *)item toDateGroups:(NSMutableArray<CCTaskCardDayGroup *> *)groups {
    NSInteger sectionIndex = 0;
    NSInteger rowIndex = 0;
    BOOL isNewSection = NO;
    for (NSInteger i = 0; i < groups.count; i ++) {
        CCTaskCardDayGroup *group = groups[i];
        
        if ([CCDateTool isSameDay:item.cardDate anotherDay:group.date]) {//存在着一天的组
            for (CCTaskCardItem *anItem in group.items) {
                if ([anItem.cardDate timeIntervalSince1970] < [item.cardDate timeIntervalSince1970]) {
                    rowIndex ++;
                }
            }
            
            [group.items insertObject:item atIndex:rowIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            return @{@"indexPath" : indexPath,
                     @"isNewSection" : @(isNewSection)
                     };
        }
        
        if ([group.date timeIntervalSince1970] < [item.cardDate timeIntervalSince1970]) sectionIndex ++;
    }
    
    //没有这样一天
    CCTaskCardDayGroup *newGroup = [CCTaskCardDayGroup dayGroupWithDate:item.cardDate];
    [newGroup.items addObject:item];
    [groups insertObject:newGroup atIndex:sectionIndex];
    isNewSection = YES;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    
    return @{@"indexPath" : indexPath,
             @"isNewSection" : @(isNewSection)
             };
}

#pragma mark - 为数组删除模型
- (void)deleteItem:(CCTaskCardItem *)item withIndexPath:(NSIndexPath *)indexPath fromDateGroups:(NSMutableArray *)groups{
    CCTaskCardDayGroup *group = groups[indexPath.section];
    [group.items removeObjectAtIndex:indexPath.row];
    //当日没有其他任务
    if (group.items.count == 0) {
        //删除当天的标记
        CCDotItem *theDotItem;
        for (CCDotItem *dotItem in self.dotItemArr) {
            if ([CCDateTool isSameDay:dotItem.date anotherDay:group.date]) {
                theDotItem = dotItem;
                break;
            }
        }
        [self.dotItemArr removeObject:theDotItem];
        
        [groups removeObject:group];
    }
    
}


#pragma mark - 根据模型获得indexPath
- (NSIndexPath *)getIndexPathForItem:(CCTaskCardItem *)item inGroups:(NSMutableArray *)groups {
    
    NSInteger section = 0;
    NSInteger row = 0;
    
    for (NSInteger i = 0; i < groups.count; i++) {
        CCTaskCardDayGroup *group = groups[i];
        if ([CCDateTool isSameDay:item.cardDate anotherDay:group.date]) {
            for (NSInteger j = 0; j < group.items.count; j++) {
                CCTaskCardItem *anItem = group.items[j];
                if (anItem == item) {
                    section = i;
                    row = j;
                    break;
                }
            }
        }
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
    
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
    
    //初始化为今天
    self.selectedDateToday = YES;
    
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
        NSIndexPath *indexPath = [self getIndexPathForItem:item inGroups:self.displayingItemGroups];
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
    self.timer = nil;
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

    //将按钮旋转回去
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.addButton.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [weakSelf.view addSubview:self.addButton];
    }];
}


#pragma mark - 保存卡片内容到沙盒
- (void)saveData {
    //本地化卡片数据
    NSArray *arr = [CCTaskCardDayGroup mj_keyValuesArrayWithObjectArray:self.taskCardItems];
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fullPath = [cachesPath stringByAppendingPathComponent:@"Cards.plist"];
    
    [arr writeToFile:fullPath atomically:YES];
    
    //本地化备忘录
    [self.notesVc saveNotesData];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
//    return self.taskCardItems.count;
    return self.displayingItemGroups.count;
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CCTaskCardDayGroup *group = self.displayingItemGroups[section];
    return group.items.count;
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
    CCTaskCardDayGroup *dayGroup = self.displayingItemGroups[section];
    
    CGFloat sectionHeight = 0;
    for (NSInteger i = 0; i < dayGroup.items.count; i++) {
        CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
        sectionHeight += cellHeight;
    }
    
    line.frame = CGRectMake(linePositionX, 20, 0.5, sectionHeight + 25);
    [headerView addSubview:line];
    headerView.layer.zPosition = -1;
    
    //小黄点标记
    CCTaskCardItem *item = dayGroup.items[0];
    
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
    CCTaskCardDayGroup *dayGroup = self.displayingItemGroups[indexPath.section];
    CCTaskCardItem *item = dayGroup.items[indexPath.row];
    
    cell.taskCardItem = item;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //获得对应模型
    
    CCTaskCardDayGroup *dayGroup = self.displayingItemGroups[indexPath.section];
    CCTaskCardItem *item = dayGroup.items[indexPath.row];
    
    return item.height > CCTimelineCellMinHeight ? item.height : CCTimelineCellMinHeight;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self deleteCardAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //获得对应模型
    CCTaskCardDayGroup *dayGroup = self.displayingItemGroups[indexPath.section];
    CCTaskCardItem *item = dayGroup.items[indexPath.row];
    //添加遮罩
    CCCardDetailCoverView *cardCoverView = [[CCCardDetailCoverView alloc] init];
    cardCoverView.delegate = self;
    [cardCoverView showWithItem:item];
}

#pragma mark - CCCardDetailCoverViewDelegate

- (void)CCCardDetailCoverView:(CCCardDetailCoverView *)coverView didChangeCompletion:(BOOL)isCompleted withTaskItem:(CCTaskCardItem *)item {
    NSIndexPath *indexPath = [self getIndexPathForItem:item inGroups:self.displayingItemGroups];
    //刷新对应卡片的状态
    [self.contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //刷新标题dot列表
    CCTaskCardDayGroup *group = self.displayingItemGroups[indexPath.section];
    for (CCDotItem *dotItem in self.dotItemArr) {
        if([CCDateTool isSameDay:dotItem.date anotherDay:group.date]) {
            if (!isCompleted) {//点击恢复未完成
                dotItem.dotStyle = CCDotStyleImportant;
            } else {//点击了完成
                NSInteger unfinishedItems = 0;
                for (CCTaskCardItem *item in group.items) {
                    if (item.isDone == NO) unfinishedItems++;
                }
                if (unfinishedItems == 0) {
                    dotItem.dotStyle = CCDotStyleNormal;
                }
            }
        }
    }
    //注销对应通知
    if (isCompleted) {
        [self removeNotificationWithItem:item];
    } else {
        [self addNotificationWithTaskCardItem:item];
    }
    
}

- (void)CCCardDetailCoverView:(CCCardDetailCoverView *)coverView didConfirmRecoverItem:(CCTaskCardItem *)item {
    
}


#pragma mark - newCardComplete监听到新卡片完成后调用

- (void)newCardComplete:(NSNotification *)notification {
    
    CCTaskCardItem *newCardItem = notification.object;
    
    //新增通知列表
    [self.notificationDates addObject:newCardItem.cardDate];
    //添加通知
    [CCTaskCardItem registerLocalNotificationWithDate:newCardItem.cardDate content:newCardItem.cardTitle key:[newCardItem getKeyFromItem]];
    
    //添加到展示列表
    NSDictionary *dict = [self addItem:newCardItem toDateGroups:self.displayingItemGroups];
    [self addItem:newCardItem toDateGroups:self.taskCardItems];
    
    NSIndexPath *indexPath = dict[@"indexPath"];
    NSInteger isNewSection = [dict[@"isNewSection"] integerValue];
    
    if (isNewSection == 1) {//新组
        [self.contentTableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.contentTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [self.contentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
    
    //更新标记dot列表
    [self updateDotsWithDateGroup:self.displayingItemGroups[indexPath.section]];
    
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
    CCTaskCardDayGroup *dayGroup = self.displayingItemGroups[indexPath.section];
    CCTaskCardItem *item = dayGroup.items[indexPath.row];

    //移除列表通知
    [self removeNotificationWithItem:item];
    //从展示列表删除
    [self deleteItem:item withIndexPath:indexPath fromDateGroups:self.displayingItemGroups];
    //更新标记dot列表
    [self updateDotsWithDateGroup:dayGroup];
    
    //从总列表缓存删除
    NSIndexPath *totalIndexPath = [self getIndexPathForItem:item inGroups:self.taskCardItems];
    [self deleteItem:item withIndexPath:totalIndexPath fromDateGroups:self.taskCardItems];
    
    if (dayGroup.items.count == 0) {//如果改日期没有卡片了，就将整个section删除
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

#pragma mark - 更新dot列表
- (void)updateDotsWithDateGroup:(CCTaskCardDayGroup *)group {
    NSInteger unfinishedItems = 0;
    for (CCTaskCardItem *item in group.items) {
        if (item.isDone == NO) {
            unfinishedItems ++;
        }
    }
    //找到对应的dotItem
    BOOL isExistingDate = NO;
    for (CCDotItem *dotItem in self.dotItemArr) {
        if ([CCDateTool isSameDay:dotItem.date anotherDay:group.date]) {
            isExistingDate = YES;
            dotItem.dotStyle = unfinishedItems > 0 ? CCDotStyleImportant : CCDotStyleNormal;
        }
    }
    if (!isExistingDate) {//新增dot
        CCDotItem *dotItem = [CCDotItem itemWithDate:group.date dotStyle:CCDotStyleImportant];
        [self.dotItemArr addObject:dotItem];
    }

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
    //设置标记点
    [self.pickerView setDotForDates:self.dotItemArr];
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
    if (![CCDateTool isSameDay:date anotherDay:[NSDate date]]) {
        [self showBackToTodayButton];
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:HideBackButtonTimeInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self hideBackToTodayButton];
        }];
        
        self.selectedDateToday = NO;
    } else {
        self.selectedDateToday = YES;
    }
    
    NSString *dateString = [NSString stringWithFormat:@"%ld年%ld月%ld日", date.year, date.month, date.day];
    [self.titleMonthButton setTitle:dateString forState:UIControlStateNormal];
    
    //更新当前展示的数据
    [self setDisplayingGroupsByDate:date shouldUpdateNotes:NO];
    [self.contentTableView reloadData];
}

#pragma mark - 隐藏和展示返回今天的浮窗按钮

- (void)showBackToTodayButton {
//    if (self.backButtonShowing) return;
//    self.backButtonShowing = YES;
    [self.backButton showButton];
    [UIView animateWithDuration:0.1 animations:^{
        self.backButton.CC_x = ScreenW - 60;
//        self.backButton.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
}

- (void)hideBackToTodayButton {
    DefineWeakSelf;
//    if (self.backButtonShowing == NO) return;
//    self.backButtonShowing = NO;
    [self.backButton hideButtonWithCompletion:^{
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.backButton.CC_x = ScreenW;
        }];
    }];
}

- (void)backToTodayButtonClick {
    [self CCCalerderPickerView:self.pickerView didSelectDate:[NSDate date]];
    
    [CCNotificationCenter postNotificationName:CCBackToTodayButtonClickNotification object:nil];
    
    [self hideBackToTodayButton];
    [self.timer invalidate];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f", scrollView.contentOffset.y);
    //如果是今天就不展示返回今天按钮
    if (self.isSelectedDateToday) return;
    
    //按钮跟随滚动
    self.backButton.CC_y = self.backButtonMinY + scrollView.contentOffset.y * 0.7;
    
    CGFloat maxContentOffsetY = (scrollView.contentSize.height - scrollView.CC_height) > 0 ? (scrollView.contentSize.height - scrollView.CC_height + self.contentTableView.contentInset.bottom) : 0;
  
    if (maxContentOffsetY == 0) {
        self.backButton.CC_y = self.backButtonMinY + scrollView.contentOffset.y * 0.7;
    } else {
//        CGFloat maxDistance = self.backButtonMaxDistance * 0.5;
        CGFloat maxDistance = self.contentTableView.contentSize.height / (self.contentTableView.CC_height * 2) * (self.backButtonMaxDistance * 0.5);
        if (maxDistance > self.backButtonMaxDistance) maxDistance = self.backButtonMaxDistance;
        self.backButton.CC_y = self.backButtonMinY + maxDistance * scrollView.contentOffset.y / maxContentOffsetY;
    }

    [self showBackToTodayButton];
    //注销定时器
    [self.timer invalidate];

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self scrollEnded:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollEnded:scrollView];
}

- (void)scrollEnded:(UIScrollView *)scrollView {
    //计算是否处于bounce状态
    CGFloat maxOffsetY = (scrollView.contentSize.height - scrollView.CC_height) > 0 ? (scrollView.contentSize.height - scrollView.CC_height + self.contentTableView.contentInset.bottom) : 0;
    if (scrollView.contentOffset.y < 0 || scrollView.contentOffset.y > maxOffsetY) return;
//    if (self.timer) return;
    //停止滚动后2秒隐藏按钮
    self.timer = [NSTimer scheduledTimerWithTimeInterval:HideBackButtonTimeInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self hideBackToTodayButton];
//        self.timer = nil;
        
    }];
}


@end
