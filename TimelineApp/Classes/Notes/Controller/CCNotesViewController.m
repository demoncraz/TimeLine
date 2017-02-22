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
#import "CCNotesTableView.h"
#import "CCCommonCoverView.h"
#import "CCAddNotesView.h"
#import "CCNotesItem.h"

#define NotesVcDefaultW ScreenW * 0.7

@interface CCNotesViewController ()<UITableViewDelegate, UITableViewDataSource, CCAddNotesViewDelegate>

@property (nonatomic, weak) CCNotesTitleView *titleView;

@property (nonatomic, weak) CCNotesTableView *tableView;

@property (nonatomic, weak) CCAddNotesView *addNotesView;

@property (nonatomic, weak) CCCommonCoverView *notesCoverView;

@property (nonatomic, weak) CCCommonCoverView *addNotesCoverView;

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation CCNotesViewController

#pragma mark - lazy loading

- (NSMutableArray *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //添加遮罩
    self.notesCoverView = [CCCommonCoverView showWithIdentifier:@"NotesCoverViewClick"];
    
    self.view.frame = CGRectMake(-NotesVcDefaultW, 20, NotesVcDefaultW, ScreenH - 20);
}


- (void)dealloc {
    [CCNotificationCenter removeObserver:self];
}



/**
 设置顶部栏
 */
- (void)setupTitleView {
//    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    
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
    CCNotesTableView *tableView= [[CCNotesTableView alloc] init];
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
    CCAddNotesView *addNotesView = [CCAddNotesView addNotesView];
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

#pragma mark - CCAddNotesViewDelegate
- (void)addNotesViewWillDismiss:(CCAddNotesView *)addNotesView {
    [self dismissAddNotesView];
    [self.addNotesCoverView dismiss];
}

- (void)addNotesView:(CCAddNotesView *)addNotesView didConfirmWithContent:(NSString *)content createDate:(NSDate *)date{
    [self dismissAddNotesView];
    [self.addNotesCoverView dismiss];
    if (content && content.length > 0) {
        CCNotesItem *newItem = [CCNotesItem itemWithText:content date:date];
        [self.items addObject:newItem];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
//    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *notesCellId = @"notesCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notesCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notesCellId];
    }
    CCNotesItem *item = self.items[indexPath.row];
    cell.textLabel.text = item.text;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


@end
