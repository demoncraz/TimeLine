//
//  CCMeViewController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/15.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCMeViewController.h"
#import "CCProfileViewContoller.h"
#import "CCSettingsTableViewController.h"

static NSString * const cellId = @"cell";

@interface CCMeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation CCMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //监听头像变化的通知
    [CCNotificationCenter addObserver:self selector:@selector(avatarChange:) name:CCAvatarChangeNotification object:nil];
    
    //设置头像
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"avatarImage"];
    UIImage *avatarImage = [UIImage imageWithData:imageData];
    self.avatarImageView.image = avatarImage;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //设置状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    NSString *nameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    self.nameLabel.text = nameString ? nameString : @"未设置";
    
}

- (void)dealloc {
    [CCNotificationCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {//个人信息编辑
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CCProfileViewContoller" bundle:nil];
    
        CCProfileViewContoller *profileVc = [storyBoard instantiateInitialViewController];
        [profileVc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:profileVc animated:YES];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {//设置界面
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CCSettingsTableViewController" bundle:nil];
        CCSettingsTableViewController *settingVc = [storyBoard instantiateInitialViewController];
        [settingVc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:settingVc animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 监听头像发生变化的通知
- (void)avatarChange:(NSNotification *)notification {
    UIImage *image = notification.object;
    self.avatarImageView.image = image;
}



@end
