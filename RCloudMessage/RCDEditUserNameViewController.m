//
//  RCDEditUserNameViewController.m
//  RCloudMessage
//
//  Created by litao on 15/11/4.
//  Copyright © 2015年 RongCloud. All rights reserved.
//

#import "RCDEditUserNameViewController.h"
#import "UIColor+RCColor.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDChatViewController.h"
#import "RCDRCIMDataSource.h"
#import "MBProgressHUD.h"
#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"
#import "AFHttpTool.h"
#import "RCDCommonDefine.h"

@interface RCDEditUserNameViewController ()

@end

@implementation RCDEditUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RCDRCIMDataSource shareInstance]getUserInfoWithUserId:[RCIMClient sharedRCIMClient].currentUserInfo.userId completion:^(RCUserInfo *userInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userName.text=userInfo.name;
        });
    }];
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 34)];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(saveUserName:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [rightBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)saveUserName:(id)sender {
    MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"修改中...";
    [hud show:YES];
    __weak __typeof(&*self)weakSelf = self;
    NSString *errorMsg = @"";
    if (self.userName.text.length == 0) {
        errorMsg = @"用户名不能为空!";
    }else if (self.userName.text.length >32) {
        errorMsg = @"用户名不能大于32位!";
    }
    if ([errorMsg length]>0) {
        [hud hide:YES];
//        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
            [alert show];
            
//        });
    }else{
        NSString *userId = [DEFAULTS objectForKey:@"userId"];
        [AFHttpTool modifyNickname:userId
                          nickname:weakSelf.userName.text success:^(id response) {
                              if ([response[@"code"] intValue] == 200) {
                                  RCUserInfo *userInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
                                  userInfo.name = weakSelf.userName.text;
                                  [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
                                  [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                                  
                                  [weakSelf.navigationController popViewControllerAnimated:YES];
                              }
                          } failure:^(NSError *err) {
                              [hud hide:YES];
                              UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"修改失败，请检查输入的名称" delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
                              [alert show];
                          }];
        
//        [RCDHTTPTOOL updateName:self.userName.text success:^(id response) {
//            [hud show:NO];
//            RCUserInfo *userInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
//            userInfo.name = weakSelf.userName.text;
//            [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
//            [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
//            
//            [weakSelf.navigationController popViewControllerAnimated:YES];
//        } failure:^(NSError *err) {
//            [hud hide:YES];
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"修改失败，请检查输入的名称" delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
//            [alert show];
//        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
