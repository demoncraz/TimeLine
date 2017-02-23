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

#define ButtonTransitAnimationDuration 0.1
#define RemarkTableViewSeparatorInsetLeft 70

typedef NS_ENUM(NSInteger, CCButtonTransitAnimationDirection) {
    CCButtonTransitAnimationDirectionLeft,
    CCButtonTransitAnimationDirectionRight
};


static NSString * const remarkCellId = @"remarkCellId";

@interface CCRemarkViewController ()

@property (nonatomic, strong) UIBarButtonItem *editBarButton;

@property (nonatomic, weak) UIButton *addButton;

@property (nonatomic, weak) UIButton *editButton;

@property (nonatomic, strong) NSMutableArray *remarkItems;

@property (nonatomic, strong) NSMutableDictionary *changedTextArr;

@property (nonatomic, strong) NSMutableArray *moveIndexTemps;

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

- (NSMutableArray *)moveIndexTemps {
    if (_moveIndexTemps == nil) {
        _moveIndexTemps = [NSMutableArray array];
    }
    return _moveIndexTemps;
}

- (NSMutableDictionary *)changedTextArr {
    if (_changedTextArr == nil) {
        _changedTextArr = [NSMutableDictionary dictionary];
    }
    return _changedTextArr;
}

- (NSMutableArray *)remarkItems {
    if (_remarkItems == nil) {
        _remarkItems = [NSMutableArray array];
        for (NSInteger i = 0; i < 20; i++) {
            CCRemarkItem *item = [CCRemarkItem itemWithText:[NSString stringWithFormat:@"%ld", i] imageName:@"delete_button"];
            [_remarkItems addObject:item];
        }
    }
    return _remarkItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"备注";
    
    
    [self setupNavBar];
    
    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CCRemarkTableViewCell class]) bundle:nil] forCellReuseIdentifier:remarkCellId];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, RemarkTableViewSeparatorInsetLeft, 0, 0);
    
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
}

- (void)editButtonClick:(UIButton *)button {
    //切换编辑状态
    [self.tableView setEditing:!button.selected animated:YES];
    //清除编辑缓存
    [self.changedTextArr removeAllObjects];
    //清除交换位置信息缓存
    if (self.moveIndexTemps.count > 0) {
        [self.moveIndexTemps removeAllObjects];
    }
    if (button.selected) {//取消了编辑，复原；
        [self.tableView reloadData];
    }
    
    //切换编辑按钮状态的动画
    [self setSelectedTransitAnimationForButton:self.editButton withDirection:CCButtonTransitAnimationDirectionLeft];
    
    [self setSelectedTransitAnimationForButton:self.addButton withDirection:CCButtonTransitAnimationDirectionRight];

}


- (void)addButtonClick:(UIButton *)button {
    if (button.selected) {//选中状态，点击保存变更并退出编辑模式
        //更新模型数据
        [self.changedIndexPathes removeAllObjects];
        
        if (self.changedTextArr.allKeys.count > 0) {
            [self.changedTextArr enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *newText, BOOL * _Nonnull stop) {
                NSInteger index = [key integerValue];
                //取出模型修改数据
                CCRemarkItem *item = self.remarkItems[index];
                item.text = newText;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.changedIndexPathes addObject:indexPath];
            }];
        }
        //交换模型位置
        NSMutableDictionary *indexTemps = [NSMutableDictionary dictionary];//用来记录交换过位置的所有cell的index
        for (CCMoveIndexTemp *temp in self.moveIndexTemps) {
            [self.remarkItems exchangeObjectAtIndex:temp.sourceIndex withObjectAtIndex:temp.destinationIndex];
            [indexTemps setObject:@"" forKey:[NSString stringWithFormat:@"%ld",temp.sourceIndex]];
            [indexTemps setObject:@"" forKey:[NSString stringWithFormat:@"%ld",temp.destinationIndex]];
        }
        
        [indexTemps enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[key integerValue] inSection:0];
            [self.changedIndexPathes addObject:indexPath];
        }];
        

        
        //完成后清空缓存
        [self.moveIndexTemps removeAllObjects];
        
        [self.tableView reloadRowsAtIndexPaths:self.changedIndexPathes withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView setEditing:NO animated:YES];
        //切换编辑按钮状态的动画
        [self setSelectedTransitAnimationForButton:self.editButton withDirection:CCButtonTransitAnimationDirectionLeft];
        
        [self setSelectedTransitAnimationForButton:self.addButton withDirection:CCButtonTransitAnimationDirectionRight];
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
    return self.remarkItems.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCRemarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:remarkCellId forIndexPath:indexPath];
    cell.item = self.remarkItems[indexPath.row];
    cell.row = indexPath.row;
    return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //先把交换位置的信息缓存下来，点击完成按钮后再保存
    CCMoveIndexTemp *indexTemp = [CCMoveIndexTemp indexTempWithSourceIndex:sourceIndexPath.row destinationIndex:destinationIndexPath.row];
    [self.moveIndexTemps addObject:indexTemp];
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
        [self.remarkItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
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
