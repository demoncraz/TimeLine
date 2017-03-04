//
//  CCSettingsTableViewController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/3/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCSettingsTableViewController.h"
#import "CCSoundTableViewController.h"

@interface CCSettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation CCSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *soundName = [[NSUserDefaults standardUserDefaults] objectForKey:@"alertSoundName"];
    if (soundName) {
        self.detailLabel.text = soundName;
    } else {
        self.detailLabel.text = @"默认";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.section == 0) {
        //设置声音
        CCSoundTableViewController *soundVc = [[CCSoundTableViewController alloc] init];
        soundVc.title = @"修改提示声音";
        [self.navigationController pushViewController:soundVc animated:YES];
    }
}




@end
