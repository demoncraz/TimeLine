//
//  CCTaskCardTabldViewCell.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/6.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCTaskCardTabldViewCell.h"
#import "Masonry.h"
#import "GetCurrentTime.h"
#import "CCCardContentView.h"


@interface CCTaskCardTabldViewCell ()<UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, assign, getter=isDeleteMode) BOOL deleteMode;

@property (nonatomic, strong) NSMutableArray *remarkItems;

@property (nonatomic, weak) CCCardContentView *cardView;

@end

@implementation CCTaskCardTabldViewCell

#pragma mark - lazy loading


#pragma mark - 设置数据
- (void)setTaskCardItem:(CCTaskCardItem *)taskCardItem {
    _taskCardItem = taskCardItem;
    [self.cardView setDataWithTaskCardItem:taskCardItem];
    
}



#pragma mark - 利用模型快速创建taskCard对象
+ (instancetype)taskCardCellWithItem:(CCTaskCardItem *)item {
    CCTaskCardTabldViewCell *taskCardCell = [[CCTaskCardTabldViewCell alloc] init];
    taskCardCell.taskCardItem = item;
    return taskCardCell;
    
}


#pragma mark - lazy loading

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
        }];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupTaskCard];
    }
    return self;
}


#pragma mark - 自定义删除按钮




- (void)setupTaskCard {
    
    self.backgroundColor = [UIColor clearColor];

    CCCardContentView *cardView = [[CCCardContentView alloc] init];
//    [cardView setDataWithTaskCardItem:self.taskCardItem];
    _cardView = cardView;
    [self.contentView addSubview:cardView];
    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.contentView);
    }];
    

    
}

#pragma mark - 加载自定义delete按钮

/**state
 UITableViewCellStateDefaultMask                     = 0,
 UITableViewCellStateShowingEditControlMask          = 1 << 0,
 UITableViewCellStateShowingDeleteConfirmationMask   = 1 << 1
 *
 */
- (void)willTransitionToState:(UITableViewCellStateMask)state {
    //将要进入编辑模式时候call 懒加载的view自定义
    
    if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            
            for (UIView *view in self.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
                    
                    view.clipsToBounds = NO;
                
                    UIButton *buttonView = (UIButton *)[view.subviews firstObject];
                    [buttonView setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    buttonView.clipsToBounds = NO;
                    //给默认的deleteButton添加背景图片
                    UIImageView *buttonImageView = [[UIImageView alloc] init];
                    buttonImageView.backgroundColor = ColorWithRGB(68, 141, 231, 1);
                    
//                    buttonImageView.userInteractionEnabled = YES;

                    buttonImageView.layer.cornerRadius = 3;
                    buttonImageView.image = [UIImage imageNamed:@"delete_button_white"];
                    buttonImageView.contentMode = UIViewContentModeCenter;
                    buttonImageView.frame = CGRectMake(-10, 12, buttonView.frame.size.width - 3, buttonView.frame.size.height - 15);
                    [buttonView addSubview:buttonImageView];
                    
                    buttonView.backgroundColor = [UIColor clearColor];
                    buttonView.superview.backgroundColor = [UIColor clearColor];
   
                    
                }
            }
            
        });

    }
    
    

}






@end


