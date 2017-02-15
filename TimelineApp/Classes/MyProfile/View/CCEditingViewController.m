//
//  CCEditingViewController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/15.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCEditingViewController.h"

@interface CCEditingViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation CCEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile_done"] style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClick)];
    doneButtonItem.enabled = self.textField.text.length > 0;
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    //设置输入框
    self.textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    [self.textField becomeFirstResponder];
    [self.textField addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - 完成按钮点击
- (void)doneButtonClick {
    NSString *nameString = self.textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:nameString forKey:@"nickname"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)textChange {
    self.navigationItem.rightBarButtonItem.enabled = self.textField.text.length > 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
