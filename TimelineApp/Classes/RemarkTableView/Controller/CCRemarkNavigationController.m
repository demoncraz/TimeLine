//
//  CCRemarkNavigationController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/23.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCRemarkNavigationController.h"
#import "CCRemarkViewController.h"

@interface CCRemarkNavigationController ()

@property (nonatomic, weak) CCRemarkViewController *remarkVc;

@end

@implementation CCRemarkNavigationController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        CCRemarkViewController *remarkVc = [[CCRemarkViewController alloc] init];
        _remarkVc = remarkVc;
        [self pushViewController:remarkVc animated:NO];
    }
    return self;
}

- (void)setRemarkItems:(NSMutableArray *)remarkItems {
    _remarkItems = remarkItems;
    self.remarkVc.remarkItems = remarkItems;
}

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
