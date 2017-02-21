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

#define DefaultGroupInset 30
#define DefaultBgLineColor ColorWithRGB(210, 210, 210, 1)
#define DefaultDateLabelFont [UIFont systemFontOfSize:12];
#define DefaultDateLabelColor ColorWithRGB(72, 72, 95, 1);
#define EstimatedCardHeight 110


@interface TimeLineViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, CCCoverViewDelegate>

@property (weak, nonatomic) IBOutlet CCContentTableView *contentTableView;

@property (nonatomic, strong) UIButton *noInfoButton;


//任务卡模型数组
@property (nonatomic, strong) NSMutableArray<CCTaskCardItem *> *taskCardItems;

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

- (NSMutableArray *)taskCardItems {
    if (_taskCardItems == nil) {
       
        NSArray *taskCardsArr = [NSArray arrayWithContentsOfFile:self.filePath];
//        NSArray *taskCardsArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TaskCardItems.plist" ofType:nil]];
        
        if (taskCardsArr) {
            //字典数组转模型
            NSMutableArray *taskCardItemArr = [CCTaskCardItem mj_objectArrayWithKeyValuesArray:taskCardsArr];
            _taskCardItems = taskCardItemArr;
            
            //添加通知
            for (CCTaskCardItem *item in self.taskCardItems) {
                
                NSString *dateString = [item getKeyFromItem];
                
                [CCTaskCardItem registerLocalNotificationWithDate:item.cardDate content:item.cardTitle key:dateString];
                
                [self.notificationDates addObject:item.cardDate];
                
            }
            
            [self sortTaskCardItemsByTime];
        } else {
            _taskCardItems = [NSMutableArray array];
        }
        
        
    }
    return _taskCardItems;
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
//    self.view.backgroundColor = [UIColor redColor];
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"TimeLineViewController" owner:self options:nil] lastObject];
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.contentTableView.contentInset = UIEdgeInsetsMake(20, 0, 44, 0);
    
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
    [self.firstTaskCards removeAllObjects];
    
    [self.taskCardItems sortUsingComparator:^NSComparisonResult(CCTaskCardItem *item1, CCTaskCardItem *item2) {
        if ([item1.cardDate timeIntervalSince1970] > [item2.cardDate timeIntervalSince1970]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedAscending;
        }
    }];
    
    //记录的每一天的第一张卡片，存放到firstTaskCards数组中
    if (self.taskCardItems.count > 0) {
        NSDate *firstDate = [self.taskCardItems firstObject].cardDate;
        [self.firstTaskCards addObject:[self.taskCardItems firstObject]];
        for (NSInteger i = 0; i < self.taskCardItems.count; i++) {
            CCTaskCardItem *item = self.taskCardItems[i];
            if([CCDateTool dayDifferenceFrom:firstDate toAnotherDay:item.cardDate] >= 1) {
                [self.firstTaskCards addObject:item];
                firstDate = item.cardDate;
            }
        }
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
        //            weakSelf.coverView.taskCard.transform = CGAffineTransformIdentity;
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
    NSArray *cardsArr = [CCTaskCardItem mj_keyValuesArrayWithObjectArray:self.taskCardItems];
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fullPath = [cachesPath stringByAppendingPathComponent:@"Cards.plist"];
    
    NSLog(@"%@", cachesPath);
    
    [cardsArr writeToFile:fullPath atomically:YES];
    

}


#pragma mark - newCardComplete监听到新卡片完成后调用

- (void)newCardComplete:(NSNotification *)notification {
    
    CCTaskCardItem *newCardItem = notification.object;
    
    //新增通知列表
    [self.notificationDates addObject:newCardItem.cardDate];
    
    
    //添加通知
    [CCTaskCardItem registerLocalNotificationWithDate:newCardItem.cardDate content:newCardItem.cardTitle key:[newCardItem getKeyFromItem]];
    
    
    //先计算出新卡片要放置的行号
//    NSInteger row = 0;
    
//    for (CCTaskCardItem *item in self.taskCardItems) {
//        if ([item.cardDate timeIntervalSince1970] < [newCardItem.cardDate timeIntervalSince1970]) {
//            row ++;
//        }
//    }
    [self.taskCardItems addObject:newCardItem];
    [self sortTaskCardItemsByTime];
    
    NSInteger row = [self.taskCardItems indexOfObject:newCardItem];
    
    //将新建的卡片模型添加到模型数组
//    [self.taskCardItems insertObject:newCardItem atIndex:row];
    
    DefineWeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf addCardAtRow:row withRowAnimation:UITableViewRowAnimationTop];
        //自动滚动到新加的卡片
        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:row] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });

    
    //将遮罩层移除
    [self endAddingNewCardWithDismissOption:CCCoverViewDismissOptionAddNew];

    //按钮模式设置为非新增模式
    self.addingNew = NO;
        
    
    
    
}


/**
 根据模型计算cell高度
 */
- (CGFloat)heightWithTaskCardItem:(CCTaskCardItem *)item {
    NSString *contentString = item.cardContent;
    CGSize textSize = [contentString boundingRectWithSize:CGSizeMake(CCTaskCardContentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size:12]} context:nil].size;
    
    return textSize.height + 60;
    
}

#pragma mark - 计算是否为当前月的第一条卡片
- (BOOL)isFirstTaskCardOfDay:(NSDate *)date {
    
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.taskCardItems.count;
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CCTaskCardItem *item = self.taskCardItems[section];
    
//    if (section == 0) return 50;
    
    if ([self.firstTaskCards containsObject:item]) {
        return DefaultGroupInset;
    } else {
        return 1;
    }
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
    
    if (section == 0) {
        line.frame = CGRectMake(linePositionX, -200, 0.5, 270);
    } else {
        line.frame = CGRectMake(linePositionX, -35, 0.5, 80);
    }
    [headerView addSubview:line];
    headerView.layer.zPosition = -1;
    
    CCTaskCardItem *item = self.taskCardItems[section];
    if ([self.firstTaskCards containsObject:item]) {
        
        //小黄点标记
        UIImageView *dateTagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sun"]];
        dateTagImageView.CC_centerX = line.CC_centerX;
        dateTagImageView.CC_centerY = DefaultGroupInset * 0.5;
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
    }
    
    return headerView;
}

- (CCTaskCardTabldViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    
    CCTaskCardTabldViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[CCTaskCardTabldViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    
    cell.taskCardItem = self.taskCardItems[indexPath.section];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCTaskCardItem *item = self.taskCardItems[indexPath.section];
    
    return [self heightWithTaskCardItem:item];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self deleteCardAtRow:indexPath.section withRowAnimation:UITableViewRowAnimationTop];
    }
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

#pragma mark - 添加／删除卡片逻辑

/**
 删除卡片

 @param row 删除行
 @param animation 动画效果
 */
- (void)deleteCardAtRow:(NSInteger)row withRowAnimation:(UITableViewRowAnimation)animation {
    
    //获得对应row的item，并移除对应的通知
    CCTaskCardItem *item = self.taskCardItems[row];
    
    //如果删除的是带标记的卡片,需要判断本日是否还有其他卡片
    NSDate *cardDate;
    if ([self.firstTaskCards containsObject:item]) {
        cardDate = item.cardDate;
    }
    

    //移除列表通知
    [self.notificationDates removeObject:item.cardDate];
    
    NSString *keyString = [item getKeyFromItem];
    
    [CCTaskCardItem cancelLocalNotificationWithKey:keyString];
    
    [self.taskCardItems removeObjectAtIndex:row];
    [self sortTaskCardItemsByTime];
    
    if (self.taskCardItems.count == 0) {
        [self showNoInfoImage];
    }
}

- (void)addCardAtRow:(NSInteger)row withRowAnimation:(UITableViewRowAnimation)animation {
    
    [self.contentTableView insertSections:[NSIndexSet indexSetWithIndex:row] withRowAnimation:animation];
    
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


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}



- (void)textChange:(UITextField *)textField {
    CCTaskCardItem *item = [self.taskCardItems firstObject];
    NSInteger row = [self.taskCardItems indexOfObject:item];
    item.cardContent = textField.text;
    [self.contentTableView reloadSections:[NSIndexSet indexSetWithIndex:row] withRowAnimation:UITableViewRowAnimationNone];
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




@end
