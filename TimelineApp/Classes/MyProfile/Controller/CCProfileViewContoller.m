//
//  CCProfileViewContoller.m
//  TimelineApp
//
//  Created by demoncraz on 2017/2/15.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCProfileViewContoller.h"
#import "CCEditingViewController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <Photos/Photos.h>

@interface CCProfileViewContoller ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;


@end

@implementation CCProfileViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"编辑个人信息";
    
    //监听头像变化的通知
    [CCNotificationCenter addObserver:self selector:@selector(avatarChange:) name:CCAvatarChangeNotification object:nil];
    //设置头像
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"avatarImage"];
    UIImage *avatarImage = [UIImage imageWithData:imageData];
    self.avatarImageView.image = avatarImage;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //设置昵称
    NSString *nameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    self.nicknameLabel.text = nameString ? nameString : @"未设置";
    

}

- (void)dealloc {
    [CCNotificationCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {//更换头像
        [self showAlertSheet];
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {//更换昵称
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:NSStringFromClass([CCEditingViewController class]) bundle:nil];
        UITableViewController *editVc = [storyBoard instantiateInitialViewController];
        editVc.title = [self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        [self.navigationController pushViewController:editVc animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma  mark - 显示底部弹窗
- (void)showAlertSheet {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *picAction = [UIAlertAction actionWithTitle:@"从相册选取" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectImageWithPhoto];
    }];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectImageWithCamera];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:cancelAction];
    [alertVc addAction:picAction];
    [alertVc addAction:cameraAction];
    
    [self presentViewController:alertVc animated:YES completion:nil];
    
}

#pragma mark - 从相册中选取
- (void)selectImageWithPhoto {
    //先判断是否有权限
    /*
     typedef NS_ENUM(NSInteger, PHAuthorizationStatus) {
     PHAuthorizationStatusNotDetermined = 0,
     PHAuthorizationStatusRestricted,
     PHAuthorizationStatusDenied,
     PHAuthorizationStatusAuthorized
     }*/
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined || status == PHAuthorizationStatusAuthorized) {
        UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
        imagePickerVc.allowsEditing = YES;
        imagePickerVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerVc.delegate = self;
        [self.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
    }
    
}
#pragma mark - 拍照
- (void)selectImageWithCamera {
    UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
    imagePickerVc.allowsEditing = YES;
    imagePickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerVc.delegate = self;
    [self.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    //UIImagePickerControllerEditedImage
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.5);
    //设置图片
    self.avatarImageView.image = selectedImage;
    //储存头像图片
    
    [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"avatarImage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:CCAvatarChangeNotification object:selectedImage];
}

#pragma mark - 监听头像发生变化的通知
- (void)avatarChange:(NSNotification *)notification {
    UIImage *image = notification.object;
    self.avatarImageView.image = image;
}

@end
