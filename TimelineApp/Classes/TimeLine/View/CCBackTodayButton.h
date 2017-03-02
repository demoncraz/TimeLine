//
//  CCBackTodayButton.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/28.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCBackTodayButton : UIButton

- (void)hideButtonWithCompletion:(void(^)())completion;

- (void)showButton;

@end
