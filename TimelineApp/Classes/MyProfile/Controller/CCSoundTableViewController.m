//
//  CCSoundTableViewController.m
//  TimelineApp
//
//  Created by demoncraz on 2017/3/3.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCSoundTableViewController.h"
#import <AVFoundation/AVFoundation.h>

static BOOL isPlayingSound = NO;

@interface CCSoundTableViewController () {
    AVAudioPlayer *player;
}

@property (nonatomic, strong) NSArray *soundArr;

@property (nonatomic, strong) NSString *selectedSoundName;

@property (nonatomic, weak) UITableViewCell *selectedCell;


@end

@implementation CCSoundTableViewController

#pragma mark - lazy loading

- (NSString *)selectedSoundName {
    if (_selectedSoundName == nil) {
        NSString *soundName = [[NSUserDefaults standardUserDefaults] objectForKey:@"alertSoundName"];
        if (soundName) {
            _selectedSoundName = soundName;
        } else {
            _selectedSoundName = @"默认";
        }
    }
    return _selectedSoundName;
}

- (NSArray *)soundArr {
    if (_soundArr == nil) {
        _soundArr = @[@"默认", @"钢琴", @"神秘", @"敲击", @"水晶"];
    }
    return _soundArr;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    player = nil;
    //保存选择
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedSoundName forKey:@"alertSoundName"];
}


- (void)playSoundWithSoundName:(NSString *)soundName {
    NSString *path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"m4a"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//    [player play];
    [player prepareToPlay];
    [player play];
}

#pragma mark - data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.soundArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"soundCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"soundCell"];
    }
    
    cell.textLabel.text = self.soundArr[indexPath.row];
    
    if ([cell.textLabel.text isEqualToString:self.selectedSoundName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedCell = cell;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //取消选中
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.selectedCell) {
        if ([player isPlaying]) {
            [player stop];
            return;
        } else {
            [self playSoundWithSoundName:cell.textLabel.text];
            return;
        }
    }
    
    [self playSoundWithSoundName:cell.textLabel.text];
    
    self.selectedCell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedCell = cell;
    self.selectedSoundName = cell.textLabel.text;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%d", isPlayingSound);
}

@end
