//
//  RCDMeInfoTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/11/4.
//  Copyright © 2015年 RongCloud. All rights reserved.
//

#import "RCDMeInfoTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDBaseSettingTableViewCell.h"
#import "RCDCommonDefine.h"
#import "RCDEditUserNameViewController.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import "UIImage+RCImage.h"
#import "RCDCommonString.h"
#import "RCDUserInfoManager.h"
#import "RCDUploadManager.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDMeInfoTableViewController ()
@property(nonatomic, strong) NSData *data;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) MBProgressHUD *hud;
@end

@implementation RCDMeInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - action
- (void)refreshCurrentUserInfo:(NSString *)url {
    [DEFAULTS setObject:url forKey:RCDUserPortraitUriKey];
    [DEFAULTS synchronize];
}
- (void)updateCurrentUserPortraitUri:(NSString *)url {
    __weak typeof(self) ws = self;
    [RCDUserInfoManager setCurrentUserPortrait:url complete:^(BOOL result) {
        if (result == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws refreshCurrentUserInfo:url];
                [ws.tableView reloadData];
                [ws.hud hide:YES];
            });
        }else {
            [ws.hud hide:YES];
            [ws showAlertView:RCDLocalizedString(@"Upload_avatar_fail") cancelBtnTitle:RCDLocalizedString(@"confirm")];
        }
    }];
}
- (void)uploadImage {
    [self.hud show:YES];
    __weak typeof(self) ws = self;
    [RCDUploadManager uploadImage:self.data
                         complete:^(NSString *url) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (url.length > 0) {
                                     [ws updateCurrentUserPortraitUri:url];
                                 } else {
                                     //关闭HUD
                                     [ws.hud hide:YES];
                                     [ws showAlertView:RCDLocalizedString(@"Upload_avatar_fail") cancelBtnTitle:RCDLocalizedString(@"confirm")];
                                 }
                             });
                         }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    if(0 == indexPath.row) {
        NSString *portraitUrl = [DEFAULTS stringForKey:RCDUserPortraitUriKey];
        [cell setImageView:cell.rightImageView ImageStr:portraitUrl imageSize:CGSizeMake(65, 65) LeftOrRight:1];
        cell.rightImageCornerRadius = 5.f;
        cell.leftLabel.text = RCDLocalizedString(@"portrait");
    }else if (1 == indexPath.row) {
        [cell setCellStyle:DefaultStyle_RightLabel];
        cell.leftLabel.text = RCDLocalizedString(@"nickname")
        ;
        cell.rightLabel.text = [DEFAULTS stringForKey:RCDUserNickNameKey];
    }else if (2 == indexPath.row) {
        [cell setCellStyle:DefaultStyle_RightLabel_WithoutRightArrow];
        cell.leftLabel.text = RCDLocalizedString(@"mobile_number")
        ;
        cell.rightLabel.text = [DEFAULTS stringForKey:RCDUserNameKey];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.f;;
    if(0 == indexPath.row) {
        height = 88.f;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(0 == indexPath.row) {
        if ([self dealWithNetworkStatus]) {
            [self changePortrait];
        }
    }else if(1 == indexPath.row) {
        if ([self dealWithNetworkStatus]) {
            RCDEditUserNameViewController *vc = [[RCDEditUserNameViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)changePortrait {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:RCDLocalizedString(@"cancel")

                                               destructiveButtonTitle:RCDLocalizedString(@"take_picture")

                                                    otherButtonTitles:RCDLocalizedString(@"my_album")
, nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;

    switch (buttonIndex) {
    case 0:
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            NSLog(@"模拟器无法连接相机");
        }
        [self presentViewController:picker animated:YES completion:nil];
        break;

    case 1:
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
        break;

    default:
        break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication sharedApplication].statusBarHidden = NO;

    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    if ([mediaType isEqual:@"public.image"]) {
        //获取原图
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //获取截取区域
        CGRect captureRect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        //获取截取区域的图像
        UIImage *captureImage =
            [UIImage getSubImage:originImage Rect:captureRect imageOrientation:originImage.imageOrientation];
        UIImage *scaleImage = [UIImage scaleImage:captureImage toScale:0.8];
        self.data = UIImageJPEGRepresentation(scaleImage, 0.00001);
    }
    self.image = [UIImage imageWithData:self.data];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self uploadImage];
}

- (void)showAlertView:(NSString *)message cancelBtnTitle:(NSString *)cTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cTitle
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)dealWithNetworkStatus {
    BOOL isconnected = NO;
    RCNetworkStatus networkStatus = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if (networkStatus == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedStringFromTable(@"ConnectionIsNotReachable", @"RongCloudKit", nil)
                                                       delegate:nil
                                              cancelButtonTitle:RCDLocalizedString(@"confirm")

                                              otherButtonTitles:nil];
        [alert show];
        return isconnected;
    }
    return isconnected = YES;
}

- (void)initUI {
    self.tableView.tableFooterView = [UIView new];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.title = RCDLocalizedString(@"Personal_information");
    
    RCDUIBarButtonItem *leftBtn =
    [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"me")
                                               target:self action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (MBProgressHUD *)hud {
    if(!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
        _hud.labelText = RCDLocalizedString(@"Uploading_avatar");
    }
    return _hud;
}
@end
