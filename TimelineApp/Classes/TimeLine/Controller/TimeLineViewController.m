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

#define DefaultGroupInset 50
#define DefaultBgLineColor ColorWithRGB(210, 210, 210, 1)
#define DefaultDateLabelFont [UIFont systemFontOfSize:12];
#define DefaultDateLabelColor ColorWithRGB(72, 72, 95, 1);
#define EstimatedCardHeight 110


@interface TimeLineViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, CCCoverViewDelegate, CCCardDetailCoverViewDelegate>

@property (weak, nonatomic) IBOutlet CCContentTableView *contentTableView;

@property (nonatomic, strong) UIButton *noInfoButton;


//任务卡模型数组
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *taskCardItems;

@property (nonatomic, strong) NSMutableArray<CCTaskCardItem *> *firstTaskCards;

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



@end

@implementation TimeLineViewController


#pragma mark - lazy loading

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

- (NSMutableArray *)firstTaskCards {
    if (_firstTaskCards == nil) {
        _firstTaskCards = [NSMutableArray array];
    }
    return _firstTaskCards;
}

#pragma mark - 初始化模型数组
//初始化模型数组

- (NSMutableArray *)taskCardItems {
    if (_taskCardItems == nil) {
       
//        NSArray *taskCardsArr = [NSArray arrayWithContentsOfFile:self.filePath];
        
        NSArray *taskCardsArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaskCardItems.plist" ofType:nil]];

        //字典数组转模型数组
        if (taskCardsArr) {
            NSMutableArray *allTaskCards = [NSMutableArray array];
            for (NSMutableArray *arr in taskCardsArr) {
                NSMutableArray *itemArr = [CCTaskCardItem mj_objectArrayWithKeyValuesArray:arr];
                
                //添加注册通知
                for (CCTaskCardItem *item in itemArr) {
                    [self addNotificationWithTaskCardItem:item];
                }
                
                [allTaskCards addObject:itemArr];
            }
            self.taskCardItems = allTaskCards;
            
            [self sortTaskCardItemsByTime];
        } else {
            _taskCardItems = [NSMutableArray array];
        }
        
    }
    return _taskCardItems;
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
    //监听到头像变化的通知后刷新表格
    DefineWeakSelf;
    [CCNotificationCenter addObserverForName:CCAvatarChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.contentTableView reloadData];
    }];

    
}



- (void)viewWillAppear:(BOOL)animated {//将要显示view的时候，判断一下是否为空，如果为空，就展示noInfo的背景图片
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    if (self.taskCardItems.count == 0) {
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


#pragma mark - 将卡片按照时间顺序排列
- (void)sortTaskCardItemsByTime {
//    [self.firstTaskCards removeAllObjects];
    //为所有日期排序
    [self.taskCardItems sortUsingComparator:^NSComparisonResult(NSArray *obj1,  NSArray *obj2) {
        CCTaskCardItem *item1 = [obj1 firstObject];
        CCTaskCardItem *item2 = [obj2 firstObject];
        if ([item1.cardDate timeIntervalSince1970] > [item2.cardDate timeIntervalSince1970]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedAscending;
        }
    }];
    //为每天的卡片排序
    for (NSMutableArray *arr in self.taskCardItems) {
        [arr sortUsingComparator:^NSComparisonResult(CCTaskCardItem *item1, CCTaskCardItem *item2) {
            if ([item1.cardDate timeIntervalSince1970] > [item2.cardDate timeIntervalSince1970]) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedAscending;
            }
        }];
    }
    
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
    
    //将addButton旋转
    [UIView animateWithDuration:0.3 animations:^{
    
        weakSelf.addButton.transform = CGAffineTransformScale(self.addButton.transform, 1.5, 1.5);
        weakSelf.addButton.transform = CGAffineTransformRotate(self.addButton.transform, M_PI * 0.25);
        
    } completion:^(BOOL finished) {
    }];
    
    [self.contentTableView setContentOffset:CGPointMake(0, -(EstimatedCardHeight + self.contentTableView.contentInset.top)) animated:YES];
    
    
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


#pragma mark - 保存卡片内容到沙盒
- (void)saveTaskCards {
    
    //模型转字典数组
    NSMutableArray *allItems = [NSMutableArray array];
    for (NSArray *arr in self.taskCardItems) {
        NSArray *cardArr = [CCTaskCardItem mj_keyValuesArrayWithObjectArray:arr];
        [allItems addObject:cardArr];
    }
//    
//    NSArray *cardsArr = [CCTaskCardItem mj_keyValuesArrayWithObjectArray:self.taskCardItems];
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fullPath = [cachesPath stringByAppendingPathComponent:@"Cards.plist"];
    
    NSLog(@"%@", cachesPath);
    
    [allItems writeToFile:fullPath atomically:YES];
    

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.taskCardItems.count;
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *cardGroup = self.taskCardItems[section];
    return cardGroup.count;
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
    NSArray *arr = self.taskCardItems[section];
    CGFloat sectionHeight = 0;
    for (NSInteger i = 0; i < arr.count; i++) {
        CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
        sectionHeight += cellHeight;
    }
    
    line.frame = CGRectMake(linePositionX, 20, 0.5, sectionHeight + 25);
    [headerView addSubview:line];
    headerView.layer.zPosition = -1;
    
    //小黄点标记
    CCTaskCardItem *item = [arr firstObject];
    
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

    NSArray *cardGroup = self.taskCardItems[indexPath.section];
    CCTaskCardItem *item = cardGroup[indexPath.row];
    cell.dateTF.hidden = YES;
    cell.taskCardItem = item;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cardGroup = self.taskCardItems[indexPath.section];
    CCTaskCardItem *item = cardGroup[indexPath.row];
    return item.height;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self deleteCardAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = self.taskCardItems[indexPath.section];
    CCTaskCardItem *item = arr[indexPath.row];
    
    //添加遮罩
    CCCardDetailCoverView *cardCoverView = [[CCCardDetailCoverView alloc] init];
    cardCoverView.delegate = self;
    [cardCoverView showWithItem:item];
}

#pragma mark - CCCardDetailCoverViewDelegate
- (void)CCCardDetailCoverView:(CCCardDetailCoverView *)coverView didCompleteTaskItem:(CCTaskCardItem *)item {
    NSIndexPath *indexPath = [self getIndexPathForItem:item];
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
    
    BOOL isNewSection = YES;
    for (NSMutableArray<CCTaskCardItem *> *arr in self.taskCardItems) {
        if ([CCDateTool isSameDay:newCardItem.cardDate anotherDay:[arr firstObject].cardDate]) {//新建卡片日期已存在
            [arr addObject:newCardItem];
            isNewSection = NO;
            break;
        }
    }
    if (isNewSection) {//新建卡片日期不存在,需要新增加一个组
        NSMutableArray *newGroup = [NSMutableArray array];
        [newGroup addObject:newCardItem];
        [self.taskCardItems addObject:newGroup];
    }
    
    [self sortTaskCardItemsByTime];
    //获取section和row
    NSIndexPath *indexPath = [self getIndexPathForItem:newCardItem];
    
    //将新建的卡片模型添加到模型数组
    
    DefineWeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf addCardAtIndexPath:indexPath isNewSection:isNewSection withRowAnimation:UITableViewRowAnimationFade];
        //自动滚动到新加的卡片
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
    NSMutableArray *arr = self.taskCardItems[indexPath.section];
    CCTaskCardItem *item = arr[indexPath.row];
    

    //移除列表通知
    [self removeNotificationWithItem:item];
    
    [arr removeObject:item];
    if (arr.count == 0) {//如果改日期没有卡片了，就将整个section删除
        [self.taskCardItems removeObjectAtIndex:indexPath.section];
        [self.contentTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    }
    
    
//    [self sortTaskCardItemsByTime];
    
    
    if (self.taskCardItems.count == 0) {
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

- (NSIndexPath *)getIndexPathForItem:(CCTaskCardItem *) item {
    NSInteger section = -1;
    NSInteger row = -1;
    for (NSInteger i = 0; i < self.taskCardItems.count; i ++) {
        NSMutableArray *arr = self.taskCardItems[i];
        for (NSInteger j = 0; j < arr.count; j++) {
            CCTaskCardItem *anItem = arr[j];
            if (anItem == item) {
                section = i;
                row = j;
            }
        }
    }
    if (section < 0 || row < 0) {//没找到这个item
        return nil;
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}




@end
