//
//  CCRemarkTableViewCell.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/23.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCRemarkTableViewCell.h"

@interface CCRemarkTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextField *contentTextField;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;

@end

@implementation CCRemarkTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    //重写setEditing方法，cell中的文字只有在编辑模式下可以修改;
    self.userInteractionEnabled = editing;
    if(!editing) {
        [self.contentTextField endEditing:YES];
        [self.contentTextField resignFirstResponder];
    }
    [super setEditing:editing animated:animated];
}

- (void)setItem:(CCRemarkItem *)item {
    _item = item;
    self.contentTextField.text = item.text;
    self.categoryImageView.image = [UIImage imageNamed:item.imageName];
    
}

- (void)setRow:(NSInteger)row {
    _row = row;
    self.contentTextField.tag = row;
}

@end
