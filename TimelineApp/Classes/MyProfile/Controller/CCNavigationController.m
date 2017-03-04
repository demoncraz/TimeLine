//
//  CCNavigationController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/15.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCNavigationController.h"

@interface CCNavigationController ()

@end

@implementation CCNavigationController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //统一设置返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    viewController.navigationItem.leftBarButtonItem = item;
    
    [super pushViewController:viewController animated:animated];
    
}

                                                       
- (void)back {
    [self popViewControllerAnimated:YES];
}


@end
