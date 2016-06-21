//
//  RCDMeInfoTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/11/4.
//  Copyright © 2015年 RongCloud. All rights reserved.
//

#import "RCDMeInfoTableViewController.h"
#import "UIColor+RCColor.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDChatViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDEditUserNameViewController.h"
#import "RCDCommonDefine.h"
#import "RCDChangePasswordViewController.h"
#import "DefaultPortraitView.h"
#import "RCDHttpTool.h"
#import "UIImageView+WebCache.h"
#import "RCDataBaseManager.h"
#import "MBProgressHUD.h"

@interface RCDMeInfoTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentUserNickNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *currentUserPortraitView;

@end

@implementation RCDMeInfoTableViewController
{
    NSData *data;
    UIImage *image;
    MBProgressHUD* hud;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView=[UIView new];
    //设置分割线颜色
    self.tableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];

    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.currentUserPortraitView.layer.masksToBounds =YES;
    self.currentUserPortraitView.layer.cornerRadius = 6.0;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[RCDRCIMDataSource shareInstance]getUserInfoWithUserId:[RCIMClient sharedRCIMClient].currentUserInfo.userId completion:^(RCUserInfo *userInfo) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.currentUserNickNameLabel.text=userInfo.name;
//        });
//    }];
    self.currentUserNickNameLabel.text = [DEFAULTS stringForKey:@"userNickName"];
//    if ([RCIM sharedRCIM].currentUserInfo.portraitUri.length == 0) {
//        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [defaultPortrait setColorAndLabel:[RCIM sharedRCIM].currentUserInfo.userId Nickname:[RCIM sharedRCIM].currentUserInfo.name];
//            UIImage *portrait = [defaultPortrait imageFromView];
//            self.currentUserPortraitView.image = portrait;
//        });
//    }
//    else
//    {
//        [self.currentUserPortraitView sd_setImageWithURL:[NSURL URLWithString:[RCIM sharedRCIM].currentUserInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"icon_person"]];
//    }
    NSString *portraitUrl = [DEFAULTS stringForKey:@"userPortraitUri"];
    if ([portraitUrl isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:[RCIM sharedRCIM].currentUserInfo.userId Nickname:[DEFAULTS stringForKey:@"userNickName"]];
        UIImage *portrait = [defaultPortrait imageFromView];
        self.currentUserPortraitView.image = portrait;
        NSData *data = UIImagePNGRepresentation(portrait);
        [RCDHTTPTOOL uploadImageToQiNiu:[RCIM sharedRCIM].currentUserInfo.userId
                              ImageData:data
                                success:^(NSString *url) {
                                    [DEFAULTS setObject:url forKey:@"userPortraitUri"];
                                    [DEFAULTS synchronize];
                                    RCUserInfo *user = [RCUserInfo new];
                                    user.userId = [RCIM sharedRCIM].currentUserInfo.userId;
                                    user.portraitUri = url;
                                    user.name =[DEFAULTS stringForKey:@"userNickName"];
                                    [[RCIM sharedRCIM] refreshUserInfoCache:user
                                                                 withUserId:user.userId];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.currentUserPortraitView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:portrait];
                                    });
                                } failure:^(NSError *err) {
                                    
                                }];
    }
    else{
        [self.currentUserPortraitView sd_setImageWithURL:[NSURL URLWithString:[DEFAULTS stringForKey:@"userPortraitUri"]] placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE && [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
    self.currentUserPortraitView.layer.masksToBounds = YES;
    self.currentUserPortraitView.layer.cornerRadius = 30.f;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 取消选中
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSLog(@"show the edit user name view");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDEditUserNameViewController *editUserNameVC = [storyboard instantiateViewControllerWithIdentifier:@"editUserNameVC"];
        [self.navigationController pushViewController:editUserNameVC animated:YES];
    }
    if (indexPath.section == 0 && indexPath.row == 2) {
        NSLog(@"show the change password view");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDChangePasswordViewController *changePasswordVC = [storyboard instantiateViewControllerWithIdentifier:@"changePasswordVC"];
        [self.navigationController pushViewController:changePasswordVC animated:YES];
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self changePortrait];
    }
}

-(void) changePortrait
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"拍照"
                                  otherButtonTitles:@"我的相册", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    switch (buttonIndex) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else
            {
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


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    
    
    if ([mediaType isEqual:@"public.image"])
    {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
        UIImage *scaleImage = [self scaleImage:originImage toScale:0.8];
        
        //        if (UIImagePNGRepresentation(scaleImage) == nil)
        //        {
        //            data = UIImageJPEGRepresentation(scaleImage, 0.00001);
        //        }
        //        else
        //        {
        //            data = UIImagePNGRepresentation(scaleImage);
        //        }
        data = UIImageJPEGRepresentation(scaleImage, 0.00001);
    }
    
    image = [UIImage imageWithData:data];
    [self dismissViewControllerAnimated:YES completion:nil];
    hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"上传头像中...";
    [hud show:YES];

    [RCDHTTPTOOL uploadImageToQiNiu:[RCIM sharedRCIM].currentUserInfo.userId
                          ImageData:data
                            success:^(NSString *url) {
                                    [RCDHTTPTOOL setUserPortraitUri:url
                                                       complete:^(BOOL result) {
                                                           if (result == YES) {
                                                               [RCIM sharedRCIM].currentUserInfo.portraitUri = url;
                                                               RCUserInfo *userInfo = [RCIM sharedRCIM].currentUserInfo;
                                                               userInfo.portraitUri = url;
                                                               [DEFAULTS setObject:url forKey:@"userPortraitUri"];
                                                               [DEFAULTS synchronize];
                                                               [[RCIM sharedRCIM] refreshUserInfoCache:userInfo
                                                                                            withUserId:[RCIM sharedRCIM].currentUserInfo.userId];
                                                               [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"setCurrentUserPortrait" object:image];
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   self.currentUserPortraitView.image = image;
                                                               //关闭HUD
                                                               [hud hide:YES];
                                                                   });
                                                           }
                                                           if (result == NO) {
                                                               //关闭HUD
                                                               [hud hide:YES];
                                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                                               message:@"上传头像失败"
                                                                                                              delegate:self
                                                                                                     cancelButtonTitle:@"确定" otherButtonTitles: nil];
                                                               [alert show];
                                                           }
                                                       }];
                                
                                
                            } failure:^(NSError *err) {
                                //关闭HUD
                                [hud hide:YES];
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                message:@"上传头像失败"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"确定" otherButtonTitles: nil];
                                [alert show];
                            }];
}

-(UIImage *)scaleImage:(UIImage *)tempImage toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(tempImage.size.width*scaleSize,tempImage.size.height*scaleSize));
    [tempImage drawInRect:CGRectMake(0, 0, tempImage.size.width * scaleSize, tempImage.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


@end
