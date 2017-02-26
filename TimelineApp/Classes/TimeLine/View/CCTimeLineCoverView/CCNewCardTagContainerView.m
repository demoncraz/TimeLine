//
//  CCNewCardTagContainerView.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/24.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNewCardTagContainerView.h"
#import "CCNewCardTagButton.h"

#define CCTagButtonDefaultH 30
#define CCTagButtonDefaultW 60
#define CCTagButtonMarginMin 10
#define CCRemarkItemLineH 40

@interface CCNewCardTagContainerView ()<UITextFieldDelegate>

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, strong) NSMutableArray *selectedTagButtons;

@property (nonatomic, strong) NSMutableArray *unselectedTagButtons;

@property (nonatomic, strong) NSMutableArray *tagTextFields;

@property (nonatomic, strong) NSMutableArray *deleteButtons;

@property (nonatomic, assign, getter=isAnimating) BOOL animating;

@property (nonatomic, assign) CGRect nextFrame;

@property (nonatomic, assign) CGRect keyBoardRect;


@end

@implementation CCNewCardTagContainerView

#pragma mark - lazy loading

- (NSMutableArray *)remarkItems {
    if (_remarkItems == nil) {
        _remarkItems = [NSMutableArray array];
    }
    return _remarkItems;
}

- (NSMutableArray *)deleteButtons {
    if (_deleteButtons == nil) {
        _deleteButtons = [NSMutableArray array];
    }
    return _deleteButtons;
}

- (NSMutableArray *)tagTextFields {
    if (_tagTextFields == nil) {
        _tagTextFields = [NSMutableArray array];
    }
    return _tagTextFields;
}


- (NSMutableArray *)unselectedTagButtons {
    if (_unselectedTagButtons == nil) {
        _unselectedTagButtons = [NSMutableArray array];
        for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:[CCNewCardTagButton class]]) {
                [_unselectedTagButtons addObject:subView];
            }
        }
    }
    return _unselectedTagButtons;
}

- (NSMutableArray *)selectedTagButtons {
    if (_selectedTagButtons == nil) {
        _selectedTagButtons = [NSMutableArray array];
    }
    return _selectedTagButtons;
}

- (NSArray *)tags {
    if (_tags == nil) {
        _tags = @[@"姓名",@"地址",@"电话",@"重要",@"信息",@"物品"];
    }
    return _tags;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupTagButtons];
        
        //监听键盘弹出
        [CCNotificationCenter addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSDictionary *infoDict = note.userInfo;
            NSValue *value = [infoDict objectForKey:UIKeyboardFrameEndUserInfoKey];
            self.keyBoardRect = [value CGRectValue];
        }];
    }
    return self;
}


- (void)setupTagButtons {
    NSInteger count = self.tags.count;
    CGFloat buttonMargin = CCTagButtonMarginMin;
    CGFloat tagButtonW = (ScreenW - (2 * CCTagButtonMarginMin) - (count - 1) * buttonMargin) / count;
    CGFloat tagButtonH = CCTagButtonDefaultH;
    CGFloat tagButtonX = 0;
    for (NSInteger i = 0; i < count; i++) {
        tagButtonX = i * (buttonMargin + tagButtonW);
        CCNewCardTagButton *tagButton = [CCNewCardTagButton buttonWithType:UIButtonTypeCustom];
        tagButton.frame = CGRectMake(tagButtonX, 0, tagButtonW, tagButtonH);
        tagButton.title = self.tags[i];
        tagButton.tag = i;
        [tagButton addTarget:self action:@selector(tagButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tagButton];
    }
}

#pragma mark - 标签按钮点击

- (void)tagButtonClick:(CCNewCardTagButton *)tagButton {
    if ([self.selectedTagButtons containsObject:tagButton]) return;
    if (self.isAnimating == YES) return;
    self.animating = YES;
    
    self.nextFrame = CGRectMake(0, CCRemarkItemLineH * (self.selectedTagButtons.count + 1), CCTagButtonDefaultW, CCTagButtonDefaultH);

    [self.selectedTagButtons addObject:tagButton];
    [self.unselectedTagButtons removeObject:tagButton];

    
    
    [UIView animateWithDuration:0.3 animations:^{
        tagButton.frame = self.nextFrame;
        [self arrangeTagButtons];
    } completion:^(BOOL finished) {
        [self adjustHeight];
        //添加输入框
        [self setupTagTextField];
        self.animating = NO;
    }];
    //添加备注
    CCRemarkItem *item = [CCRemarkItem itemWithText:nil imageName:[NSString stringWithFormat:@"remark_%@", tagButton.titleLabel.text]];
    [self.remarkItems addObject:item];
    
}

- (void)setupTagTextField {
    CCNewCardTagButton *tagButton = self.selectedTagButtons.lastObject;
    //添加文本框
    UITextField *tagTextField = [[UITextField alloc] init];
    
    //设置文本框样式
    tagTextField.font = [UIFont systemFontOfSize:14];
    tagTextField.textColor = [UIColor whiteColor];
    tagTextField.tintColor = [UIColor whiteColor];
    tagTextField.textAlignment = NSTextAlignmentLeft;
    tagTextField.returnKeyType = UIReturnKeyDone;
    
    if ([tagButton.titleLabel.text isEqualToString:@"电话"]) {
        tagTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    [tagTextField addTarget:self action:@selector(textChage:) forControlEvents:UIControlEventEditingChanged];
    tagTextField.delegate = self;
    
    //计算frame
    tagTextField.frame = CGRectMake(CGRectGetMaxX(self.nextFrame) + CCTagButtonMarginMin, self.nextFrame.origin.y, self.CC_width - CCTagButtonDefaultW - CCTagButtonDefaultH - 10, self.nextFrame.size.height);
    [self.tagTextFields addObject:tagTextField];
    [self addSubview:tagTextField];
    [tagTextField becomeFirstResponder];

    //添加删除按钮
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(self.CC_width - CCTagButtonDefaultH, self.nextFrame.origin.y, CCTagButtonDefaultH, CCTagButtonDefaultH);
//    deleteButton.backgroundColor = [UIColor brownColor];
    [deleteButton setImage:[UIImage imageNamed:@"delete_button_white"] forState:UIControlStateNormal];
    deleteButton.adjustsImageWhenHighlighted = NO;
    deleteButton.contentEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [self.deleteButtons addObject:deleteButton];
    [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
    
}


- (void)deleteButtonClick:(UIButton *)button {
    NSInteger index = [self.deleteButtons indexOfObject:button];
    CCNewCardTagButton *tagButton = self.selectedTagButtons[index];
    [self.selectedTagButtons removeObject:tagButton];
    
    //恢复这个标签按钮的位置
    NSInteger insertIndex = 0;
    for (UIButton *button in self.unselectedTagButtons) {
        if (button.tag < tagButton.tag) insertIndex ++;
    }
    [self.unselectedTagButtons insertObject:tagButton atIndex:insertIndex];
    
    //移除textField
    UITextField *tagTextField = self.tagTextFields[index];
    [tagTextField removeFromSuperview];
    [self.tagTextFields removeObject:tagTextField];
    //移除deleteButton
    [button removeFromSuperview];
    [self.deleteButtons removeObject:button];
    //移除对应的备注item
    [self.remarkItems removeObjectAtIndex:index];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self arrangeTagButtons];
        [self arrangeTextFields];
    } completion:^(BOOL finished) {
        [self adjustHeight];
    }];
}

#pragma mark - 排列剩下的tagButton

- (void)arrangeTagButtons {
    
    NSInteger count = self.unselectedTagButtons.count;
    CGFloat buttonMargin = CCTagButtonMarginMin * (self.selectedTagButtons.count + 1);
    CGFloat buttonH = CCTagButtonDefaultH;
    CGFloat buttonW = 0;
    CGFloat buttonX = 0;
    
    for (NSInteger i = 0; i < count; i++) {
        UIButton *tagButton = self.unselectedTagButtons[i];
        if (count >= 3) {//个数大于三时，间距不变
            buttonW = (self.CC_width - buttonMargin * (count + 1)) / count;
            buttonX = i * (buttonW) + buttonMargin * (i + 1);
        } else {//个数小于三时，button不再缩小
            CGFloat newMargin = (self.CC_width - count * tagButton.CC_width) / (count + 1);
            buttonW = tagButton.CC_width;
            buttonX = newMargin + (buttonW + newMargin) * i;
        }
        tagButton.frame = CGRectMake(buttonX, 0, buttonW, buttonH);
    }
}

#pragma mark - 排列剩下的textField和deleteButton
- (void)arrangeTextFields {
    for (NSInteger i = 0; i < self.tagTextFields.count; i ++) {
        UITextField *tagTextFields = self.tagTextFields[i];
        UIButton *deleteButton = self.deleteButtons[i];
        CCNewCardTagButton *tagButton = self.selectedTagButtons[i];
        tagTextFields.CC_y = CCRemarkItemLineH * (i + 1);
        deleteButton.CC_y = tagTextFields.CC_y;
        tagButton.CC_y = tagTextFields.CC_y;
    };
}

#pragma mark - view自适应大小
- (void)adjustHeight {
    //containerView自适应大小
    if (self.selectedTagButtons.count > 0) {
        self.CC_height = CGRectGetMaxY([[self.selectedTagButtons lastObject] frame]);
    } else {
        self.CC_height = CCTagButtonDefaultH;
    }
    //输入框被键盘遮住时 将cover上移以显示输入的内容
    CGFloat difference = 0;
    if (CGRectGetMaxY(self.frame) > ScreenH - self.keyBoardRect.size.height) {
        difference = CGRectGetMaxY(self.frame) - (ScreenH - self.keyBoardRect.size.height);
    } else {
        difference = 0;
    }
    self.superview.CC_height = ScreenH + difference > self.superview.CC_height ? ScreenH + difference : self.superview.CC_height;
    [UIView animateWithDuration:0.2 animations:^{
        self.superview.CC_y = -difference;
    }];

}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textChage:(UITextField *)textField {
    NSInteger index = [self.tagTextFields indexOfObject:textField];
    CCRemarkItem *item = self.remarkItems[index];
    item.text = textField.text;
}

@end
