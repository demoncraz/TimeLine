//
//  CCCardRecoverView.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/27.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCardRecoverView : UIView
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

+ (instancetype)cardRecoverView;

@end
