//
//  CCRemarkViewController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/22.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCRemarkViewController.h"
#import "UIBarButtonItem+BarButtonItem.h"
#import "CCRemarkTableViewCell.h"
#import "CCAddRemarkViewController.h"
#import "CCRemarkTitleCloseButton.h"

#define ButtonTransitAnimationDuration 0.1
#define RemarkTableViewSeparatorInsetLeft 50

typedef NS_ENUM(NSInteger, CCButtonTransitAnimationDirection) {
    CCButtonTransitAnimationDirectionLeft,
    CCButtonTransitAnimationDirectionRight
};


static NSString * const remarkCellId = @"remarkCellId";

@interface CCRemarkViewController ()<CCAddRemarkViewControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *editBarButton;

@property (nonatomic, weak) UIButton *addButton;

@property (nonatomic, weak) UIButton *editButton;

@property (nonatomic, strong) NSMutableDictionary *changedTextArr;

@property (nonatomic, strong) NSMutableArray *changedIndexPathes;

@end

/*************************/
/****交换位置信息的缓存类****/
@interface CCMoveIndexTemp : NSObject

@property (nonatomic, assign) NSInteger sourceIndex;

@property (nonatomic, assign) NSInteger destinationIndex;

+ (instancetype)indexTempWithSourceIndex: (NSInteger)sourceIndex destinationIndex:(NSInteger)destinationIndex;

@end

@implementation CCRemarkViewController

#pragma mark - lazy loading

- (NSMutableArray *)changedIndexPathes {
    if (_changedIndexPathes == nil) {
        _changedIndexPathes = [NSMutableArray array];
    }
    return _changedIndexPathes;
}


- (NSMutableDictionary *)changedTextArr {
    if (_changedTextArr == nil) {
        _changedTextArr = [NSMutableDictionary dictionary];
    }
    return _changedTextArr;
}

//- (NSMutableArray *)remarkItems {
//    if (_remarkItems == nil) {
//        _remarkItems = [NSMutableArray array];
//    }
//    return _remarkItems;
//}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"备注";
    
    [self setupNavBar];
    
    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CCRemarkTableViewCell class]) bundle:nil] forCellReuseIdentifier:remarkCellId];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, RemarkTableViewSeparatorInsetLeft, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [CCNotificationCenter addObserver:self selector:@selector(editingChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)dealloc {
    [CCNotificationCenter removeObserver:self];
}



- (void)editingChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    NSInteger index = textField.tag;
    //记录编辑过的文字和对应的行号
    [self.changedTextArr setObject:textField.text forKey:[NSString stringWithFormat:@"%ld", index]];

}

- (void)setupNavBar {
    //左边编辑按钮
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setImage:[UIImage imageNamed:@"remark_edit"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"remark_cancel"] forState:UIControlStateSelected];
    [editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [editButton sizeToFit];
    _editButton = editButton;
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    self.navigationItem.leftBarButtonItem = editBarButtonItem;
    
    //右边增加按钮
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage imageNamed:@"remark_add"] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"remark_done"] forState:UIControlStateSelected];
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [addButton sizeToFit];
    _addButton = addButton;
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = addBarButtonItem;
    
    //titleView关闭按钮
    CCRemarkTitleCloseButton *titleCloseButton = [CCRemarkTitleCloseButton buttonWithType:UIButtonTypeCustom];
    [titleCloseButton addTarget:self action:@selector(titleCloseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    titleCloseButton.frame = CGRectMake(0, 0, 60, 50);

    self.navigationItem.titleView = titleCloseButton;
}

- (void)titleCloseButtonClick {
    //发送通知
    [CCNotificationCenter postNotificationName:CCRemarkViewControllerWillDismissNotification object:nil];
    
    //dismiss vc

    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.CC_y = ScreenH;
    } completion:^(BOOL finished) {
        [self.navigationController.view removeFromSuperview];
    }];
}

- (void)editButtonClick:(UIButton *)button {
    //切换编辑状态
    [self.tableView setEditing:!button.selected animated:YES];
    //清除编辑缓存
    [self.changedTextArr removeAllObjects];

    if (button.selected) {//取消了编辑，复原；
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }
    
    //切换编辑按钮状态的动画
    [self setSelectedTransitAnimationForButton:self.editButton withDirection:CCButtonTransitAnimationDirectionLeft];
    
    [self setSelectedTransitAnimationForButton:self.addButton withDirection:CCButtonTransitAnimationDirectionRight];

}

#pragma mark - 按钮点击
- (void)addButtonClick:(UIButton *)button {
    if (button.selected) {//选中状态，点击保存变更并退出编辑模式
        //更新模型数据
        [self.changedIndexPathes removeAllObjects];
        
        if (self.changedTextArr.allKeys.count > 0) {
            [self.changedTextArr enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *newText, BOOL * _Nonnull stop) {
                NSInteger index = [key integerValue];
                //取出模型修改数据
                CCRemarkItem *item = self.item.remarkItems[index];
                item.text = newText;
                //通知timeline列表刷新
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.changedIndexPathes addObject:indexPath];
            }];
        }
        
        //通知首页时间轴更新
        [CCNotificationCenter postNotificationName:CCRemarkDidChangeNotification object:self.item];
        
        [self.tableView reloadRowsAtIndexPaths:self.changedIndexPathes withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView setEditing:NO animated:YES];
        //切换编辑按钮状态的动画
        [self setSelectedTransitAnimationForButton:self.editButton withDirection:CCButtonTransitAnimationDirectionLeft];
        
        [self setSelectedTransitAnimationForButton:self.addButton withDirection:CCButtonTransitAnimationDirectionRight];
    }
    
    
    else {//切换到增加新备注页面
        CCAddRemarkViewController *addRemarkVc = [[CCAddRemarkViewController alloc] init];
        addRemarkVc.delegate = self;
        [self.navigationController pushViewController:addRemarkVc animated:YES];
    }
    
}



//切换编辑按钮状态的动画
- (void)setSelectedTransitAnimationForButton:(UIButton *)button withDirection:(CCButtonTransitAnimationDirection)direction {
    NSInteger flag = (direction == CCButtonTransitAnimationDirectionLeft) ? -1 : 1;
    [UIView animateWithDuration:ButtonTransitAnimationDuration animations:^{
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 80 * flag, 0, 0);
        [button layoutIfNeeded];
    } completion:^(BOOL finished) {
        button.selected = !button.selected;//选中状态
        [UIView animateWithDuration:ButtonTransitAnimationDuration animations:^{
            button.contentEdgeInsets = UIEdgeInsetsZero;
            [button layoutIfNeeded];
        }];
    }];
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.item.remarkItems.count;;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCRemarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:remarkCellId forIndexPath:indexPath];
    cell.item = self.item.remarkItems[indexPath.row];

    return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.item.remarkItems exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [CCNotificationCenter postNotificationName:CCRemarkDidChangeNotification object:self.item];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleNone;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.item.remarkItems removeObjectAtIndex:indexPath.row];
        [CCNotificationCenter postNotificationName:CCRemarkDidChangeNotification object:self.item];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - CCAddRemarkViewControllerDelegate

- (void)CCAddRemarkViewController:(CCAddRemarkViewController *)addRemarkViewController didCompleteWithText:(NSString *)text tagImageName:(NSString *)tagImageName {
    [self.item.remarkItems addObject:[CCRemarkItem itemWithText:text imageName:tagImageName]];
    [CCNotificationCenter postNotificationName:CCRemarkDidChangeNotification object:self.item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.item.remarkItems.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

@end



@implementation CCMoveIndexTemp

+ (instancetype)indexTempWithSourceIndex: (NSInteger)sourceIndex destinationIndex:(NSInteger)destinationIndex {
    CCMoveIndexTemp *indexTemp = [[CCMoveIndexTemp alloc] init];
    indexTemp.sourceIndex = sourceIndex;
    indexTemp.destinationIndex = destinationIndex;
    return indexTemp;
}
/****交换位置信息的缓存类****/
@end
