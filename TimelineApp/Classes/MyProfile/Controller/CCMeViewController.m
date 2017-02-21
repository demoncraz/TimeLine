//
//  CCMeViewController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/15.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCMeViewController.h"
#import "CCProfileViewContoller.h"

static NSString * const cellId = @"cell";

@interface CCMeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLable;

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
    
    [self getCurrentVersion];

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
    
        CCProfileViewContoller *profileVc = [storyBoard instantiateInitialViewController];;
        [profileVc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:profileVc animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 监听头像发生变化的通知
- (void)avatarChange:(NSNotification *)notification {
    UIImage *image = notification.object;
    self.avatarImageView.image = image;
}

#pragma mark - 获取当前版本号
- (void)getCurrentVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    //CFBundleShortVersionString
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    self.versionLable.text = version;
    
}

@end
