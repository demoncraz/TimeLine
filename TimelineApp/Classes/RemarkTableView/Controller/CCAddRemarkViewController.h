//
//  CCAddRemarkViewController.h
//  TimelineApp
//
//  Created by demoncraz on 2017/2/23.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCAddRemarkViewController;

@protocol CCAddRemarkViewControllerDelegate <NSObject>

- (void)CCAddRemarkViewController:(CCAddRemarkViewController *)addRemarkViewController didCompleteWithText:(NSString *)text tagImageName:(NSString *)tagImageName;

@end

@interface CCAddRemarkViewController : UIViewController

@property (nonatomic, weak) id<CCAddRemarkViewControllerDelegate> delegate;

@end
