//
//  CCCardDetailView.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/22.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTaskCardItem.h"

@interface CCCardDetailView : UIView

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic, strong) CCTaskCardItem *item;

@property (weak, nonatomic) IBOutlet UIButton *remarkButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

+ (instancetype)cardDetailView;

@end
