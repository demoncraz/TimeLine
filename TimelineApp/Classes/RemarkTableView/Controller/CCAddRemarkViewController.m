//
//  CCAddRemarkViewController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/23.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCAddRemarkViewController.h"
#import "CCTagButton.h"
#import "Masonry.h"

#define TagButtonW 80
#define TagButtonH 30

@interface CCAddRemarkViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) NSArray *tagTitleArr;

@property (nonatomic, weak) UIButton *doneButton;

@property (nonatomic, weak) UIButton *selTagButton;



@end

@implementation CCAddRemarkViewController

#pragma mark - lazy loading

- (NSArray *)tagTitleArr {
    if (_tagTitleArr == nil) {
        _tagTitleArr = @[@"默认",@"姓名",@"地址",@"电话",@"信息",@"重要",@"数据",@"物品"];
    }
    return _tagTitleArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTextView];
    
    [self setupNav];
    
    [self setupTags];
    
}

/**
 设置文本框
 */
- (void)setupTextView {
    //设置文本框代理
    self.textView.delegate = self;
    //样式
    self.textView.layer.borderColor = CCDefaultGreyClor.CGColor;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.cornerRadius = 3;
//    self.textView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.textView.layer.shadowOffset = CGSizeMake(0.5, 1);
//    self.textView.layer.shadowOpacity = 0.3;
//    self.textView.layer.masksToBounds = NO;
}

/**
 设置导航栏
 */
- (void)setupNav {
    
    self.title = @"新增备注";
    //左上角返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = item;
    
    //右上角完成按钮
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    [doneButton sizeToFit];
    doneButton.hidden = YES;
    _doneButton = doneButton;
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];

    self.navigationItem.rightBarButtonItem = doneButtonItem;
}

/**
 设置标签按钮
 */
- (void)setupTags {
//
    
    UIView *containerView = [[UIView alloc] init];
//    containerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(20);
        make.left.right.equalTo(self.textView);
        make.height.equalTo(@200);
    }];
    
    //设置位置

    CGFloat totalWidth = ScreenW - 40;
    NSInteger cols = 4;
    CGFloat xMargin = (totalWidth - (TagButtonW * cols)) / (cols - 1);
    CGFloat yMargin = 10;
//    NSInteger i = 5;
    
    for (NSInteger i = 0; i < self.tagTitleArr.count; i ++) {
        CGFloat x = (i % cols)* (TagButtonW + xMargin);
        CGFloat y = (i / cols) * (TagButtonH + yMargin);
        CCTagButton *tagButton = [CCTagButton buttonWithType:UIButtonTypeCustom];
        NSString *imageName = [self getImageNameWithTitle:self.tagTitleArr[i]];
        NSString *selectedImageName = [self getSelectedImageNameWithTitle:self.tagTitleArr[i]];
        [tagButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [tagButton setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
        tagButton.title = self.tagTitleArr[i];
        tagButton.frame = CGRectMake(x, y, TagButtonW, TagButtonH);
        [tagButton addTarget:self action:@selector(tagButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:tagButton];
        
        //默认选中第一个默认按钮
        if (i == 0) {
            tagButton.selected = YES;
            self.selTagButton = tagButton;
        }
    }
    
    
}


/**
 根据title返回tag图片名

 @param title tag标题
 @return 图片名
 */
- (NSString *)getImageNameWithTitle:(NSString *)title {
    return [NSString stringWithFormat:@"remark_%@", title];
}

- (NSString *)getSelectedImageNameWithTitle:(NSString *)title {
    return [NSString stringWithFormat:@"remark_%@_white", title];
}



/**
 标签按钮点击事件

 @param button 标签按钮
 */
- (void)tagButtonClick:(UIButton *)button {
    self.selTagButton.selected = NO;
    button.selected = YES;
    self.selTagButton = button;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneClick {
    if (self.textView.text.length > 0) {
        NSString *textString = self.textView.text;
        NSString *tagName = self.selTagButton.titleLabel.text;
        [self.delegate CCAddRemarkViewController:self didCompleteWithText:textString tagImageName:[self getImageNameWithTitle:tagName]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.doneButton.hidden = (textView.text.length == 0);
}

@end
