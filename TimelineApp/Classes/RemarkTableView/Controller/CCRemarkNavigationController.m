//
//  CCRemarkNavigationController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/23.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCRemarkNavigationController.h"

@interface CCRemarkNavigationController ()

@end

@implementation CCRemarkNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.CC_y = ScreenH;
    self.view.CC_height = 500;
    self.view.CC_width = ScreenW;
    self.view.CC_centerX = [UIApplication sharedApplication].keyWindow.CC_centerX;
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = CCDefaultBlueColor;
    self.navigationBar.titleTextAttributes = @{
                                               NSForegroundColorAttributeName : [UIColor whiteColor]
                                               };
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
