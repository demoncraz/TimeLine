//
//  CCNotesViewController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/18.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNotesViewController.h"
#import "UIView+Frame.h"
#import "Masonry.h"
#import "CCNotesTitleView.h"
#import "CCCommonCoverView.h"
#import "CCAddNotesView.h"
#import "CCNotesItem.h"
#import "MJExtension.h"
#import "CCNotesTableViewCell.h"
#import "CCNotesCellMenuView.h"

#define NotesVcDefaultW ScreenW * 0.7

static NSString *notesCellId = @"notesCellId";

@interface CCNotesViewController ()<UITableViewDelegate, UITableViewDataSource, CCAddNotesViewDelegate>

@property (nonatomic, weak) CCNotesTitleView *titleView;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) CCAddNotesView *addNotesView;

@property (nonatomic, weak) CCAddNotesView *editNotesView;

@property (nonatomic, weak) CCCommonCoverView *notesCoverView;

@property (nonatomic, weak) CCCommonCoverView *addNotesCoverView;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) CCNotesTableViewCell *editingCell;

@property (nonatomic, weak) CCNotesCellMenuView *menuView;

@end

@implementation CCNotesViewController

#pragma mark - lazy loading

//- (CCNotesCellMenuView *)menuView {
//    if (_menuView == nil) {
//        _menuView = [[CCNotesCellMenuView alloc] init];
//        _menuView.frame = CGRectMake(self.tableView.CC_width, 0, self.tableView.CC_width, 50);
//    }
//    return _menuView;
//}

- (NSString *)filePath {
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullPath = [cachesPath stringByAppendingPathComponent:@"notes.plist"];
    _filePath = fullPath;
    return _filePath;
}

- (NSMutableArray *)items {
    if (_items == nil) {
        NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:self.filePath];
        if (arr) {
            _items = [CCNotesItem mj_objectArrayWithKeyValuesArray:arr];
        } else {
            _items = [NSMutableArray array];
        }
    }
    return _items;
}

- (void)viewDidLoad {
    [super viewDidLoad];


    //设置背景颜色
    self.view.backgroundColor = ColorWithRGB(121, 121, 136, 1);
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    //设置顶部栏
    [self setupTitleView];
    
    //设置TableView
    [self setupNotesTableView];
    
    //监听遮罩层点击事件
    [CCNotificationCenter addObserver:self selector:@selector(addCoverViewClick:) name:CCCommonCoverViewWillDismissNotification object:nil];
    
    //监听cell内部菜单按钮点击事件
    [CCNotificationCenter addObserver:self selector:@selector(notesCellEditButtonClick) name:CCNotesCellMenuEditButtonClickNotification object:nil];
    [CCNotificationCenter addObserver:self selector:@selector(notesCellDeleteButtonClick) name:CCNotesCellMenuDeleteButtonClickNotification object:nil];
    [CCNotificationCenter addObserver:self selector:@selector(notesCellMenuViewTouchBegan) name:CCNotesCellMenuTouchBeganNotification object:nil];
   
    //注册cell
    [self.tableView registerClass:[CCNotesTableViewCell class] forCellReuseIdentifier:notesCellId];
    
    //添加滑动手势
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeRight];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //添加遮罩
    self.notesCoverView = [CCCommonCoverView showWithIdentifier:@"NotesCoverViewClick"];
    
    self.view.frame = CGRectMake(-NotesVcDefaultW, 20, NotesVcDefaultW, ScreenH - 20);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self endEditingCell];
}


- (void)dealloc {
    [CCNotificationCenter removeObserver:self];
}



/**
 设置顶部栏
 */
- (void)setupTitleView {
    
    CCNotesTitleView *titleView = [[CCNotesTitleView alloc] init];
    [titleView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [titleView.addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@60);
    }];
    
    _titleView = titleView;
    
}

/**
 设置TableView
 */
- (void)setupNotesTableView {
    UITableView *tableView= [[UITableView alloc] init];
//    tableView.backgroundColor = [UIColor yellowColor];
    //设置代理和数据源
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    _tableView = tableView;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}


- (void)fullScreenButtonClick:(UIButton *)button {
    if (self.editingCell) {//如果有cell在编辑中，就退出编辑模式，刷新frame
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self.editingCell];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self endEditingCell];

    [UIView animateWithDuration:0.3 animations:^{
        if (!button.selected) {
           self.view.CC_width = ScreenW;
        } else {
            self.view.CC_x = -self.view.CC_width;
            [self.notesCoverView dismiss];
            [CCNotificationCenter postNotificationName:CCNotesDidCloseNotificaton object:nil];
        }
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        button.selected = !button.selected;
        if (!button.selected) {
            [self.view removeFromSuperview];
        }
    }];

}

- (void)addButtonClick:(UIButton *)button {
    
    //添加遮罩
    self.addNotesCoverView = [CCCommonCoverView showWithIdentifier:@"AddNotesCoverView"];
    //添加新备忘录输入窗
    CCAddNotesView *addNotesView = [[CCAddNotesView alloc] initWithItem:nil];
    addNotesView.delegate = self;
    _addNotesView = addNotesView;
    [self.view.window addSubview:addNotesView];
    [UIView animateWithDuration:0.3 animations:^{
        addNotesView.alpha = 1;
        [addNotesView startEdting];
    }];
    
}

- (void)addCoverViewClick:(NSNotification *)notification {
//    if (!notification) return;
    NSString *identifier = notification.object;
    if (![identifier isEqualToString:@"AddNotesCoverView"]) return;
    [self dismissAddNotesView];
}

- (void)dismissAddNotesView {
    [UIView animateWithDuration:0.3 animations:^{
        self.addNotesView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.addNotesView removeFromSuperview];
    }];
}
- (void)dismissEditNotesView {
    [UIView animateWithDuration:0.3 animations:^{
        self.editNotesView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.editNotesView removeFromSuperview];
    }];
}


#pragma mark - CCAddNotesViewDelegate
- (void)addNotesViewWillDismiss:(CCAddNotesView *)addNotesView {
    [self dismissAddNotesView];
    [self dismissEditNotesView];
    [self.addNotesCoverView dismiss];
}

- (void)addNotesView:(CCAddNotesView *)addNotesView didConfirmWithContent:(NSString *)content createDate:(NSDate *)date notesItem:(CCNotesItem *)notesItem{
    if (notesItem == nil) {
        [self dismissAddNotesView];
    } else {
        [self dismissEditNotesView];
    }
    [self.addNotesCoverView dismiss];
    if (notesItem == nil) {//新增模式 - 完成
        if (content && content.length > 0) {
            CCNotesItem *newItem = [CCNotesItem itemWithText:content date:date];
            [self.items addObject:newItem];
            [self.tableView reloadData];
        }
    } else {//编辑模式 - 完成
        notesItem.text = content;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.items indexOfObject:notesItem] inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
//    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCNotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notesCellId];
    CCNotesItem *item = self.items[indexPath.row];
    cell.notesItem = item;
    if (cell.isEditingMode) {
        [cell setEditingMode:NO animated:NO];
    }
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"test");
}


#pragma mark - 左滑手势
- (void)swipeLeft:(UISwipeGestureRecognizer *)swipe {
    
    if (self.editingCell) {
        [self.editingCell setEditingMode:NO animated:YES];
    }
    
    CGPoint location = [swipe locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    CCNotesTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.editingCell) return;
    
    [cell setEditingMode:YES animated:YES];
    
    self.editingCell = cell;
    
}

#pragma mark - 右滑
- (void)swipeRight:(UISwipeGestureRecognizer *)swipe {
    CGPoint location = [swipe locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    CCNotesTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.editingCell) {
        [self endEditingCell];
    }

}

#pragma mark - 左滑菜单点击事件
- (void)notesCellEditButtonClick {
    
    //添加遮罩
    self.addNotesCoverView = [CCCommonCoverView showWithIdentifier:@"AddNotesCoverView"];
    //添加新备忘录输入窗
    CCAddNotesView *editNotesView = [[CCAddNotesView alloc] initWithItem:self.editingCell.notesItem];
    editNotesView.delegate = self;
    _editNotesView = editNotesView;
    [self.view.window addSubview:editNotesView];
    [UIView animateWithDuration:0.3 animations:^{
        editNotesView.alpha = 1;
        [editNotesView startEdting];
    }];
    
    [self endEditingCell];
}

- (void)notesCellDeleteButtonClick {
    
    CCNotesTableViewCell *cell = self.editingCell;
    CCNotesItem *item = cell.notesItem;
    NSInteger index = [self.items indexOfObject:item];
    [self.items removeObjectAtIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    self.editingCell = nil;

}

- (void)notesCellMenuViewTouchBegan {
    [self endEditingCell];
}

- (void)endEditingCell {
    if (self.editingCell) {
        [self.editingCell setEditingMode:NO animated:YES];
        self.editingCell = nil;
    }
}

#pragma mark - 本地化数据
- (void)saveNotesData {
    
    NSArray *notesArr= [CCNotesItem mj_keyValuesArrayWithObjectArray:self.items];
    
    [notesArr writeToFile:self.filePath atomically:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self endEditingCell];
}


@end
