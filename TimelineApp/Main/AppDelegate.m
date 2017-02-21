//
//  AppDelegate.m
//  TimelineApp
//
//  Created by demoncraz on 2017/1/28.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "AppDelegate.h"
#import "TimeLineViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSArray *notificationArr;

@end

@implementation AppDelegate

#pragma lazy loading
- (NSArray *)notificationArr {
    if (_notificationArr == nil) {
        _notificationArr = [NSArray array];
    }
    return _notificationArr;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    //注册通知权限
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    
    //取消之前所有的通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //设置头像
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"avatarImage"];
    if (!imageData) {
        UIImage *image = [UIImage imageNamed:@"avatar_default"];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"avatarImage"];
    }
    
    
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"在前台");
    } else if (application.applicationState == UIApplicationStateBackground) {
        NSLog(@"后台");
    } else if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"从后台进入前台");
    }
    
    NSLog(@"接收到通知了");
    
}


- (void)arrangeBadgeNumbers {
    self.notificationArr = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    //获取每个notification被schedule的时间 并进行排序
    NSMutableArray *dateArr = [NSMutableArray array];
    for (UILocalNotification *notification in self.notificationArr) {
        NSDate *expectedFireDate = notification.fireDate;
        [dateArr addObject:expectedFireDate];
    }
    [dateArr sortUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
        if ([date1 timeIntervalSince1970] > [date2 timeIntervalSince1970]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    //重新设置badge number
    for (UILocalNotification *notification in self.notificationArr) {
        NSInteger index = [dateArr indexOfObject:notification.fireDate];
        notification.applicationIconBadgeNumber = index + 1;
    }
    //重新schedule通知
    [[UIApplication sharedApplication] setScheduledLocalNotifications:self.notificationArr];
    
    
    
}



- (void)saveTaskCardItems {
    UITabBarController *tabBarController = (UITabBarController *)_window.rootViewController;
    TimeLineViewController *vc = tabBarController.childViewControllers[0];
    [vc performSelectorInBackground:@selector(saveTaskCards) withObject:nil];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [self arrangeBadgeNumbers];
    [self saveTaskCardItems];
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self arrangeBadgeNumbers];
    [self saveTaskCardItems];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    //清空badge
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [self arrangeBadgeNumbers];
    [self saveTaskCardItems];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
