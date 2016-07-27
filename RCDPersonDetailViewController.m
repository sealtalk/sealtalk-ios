//
//  RCDPersonDetailViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/4/9.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDPersonDetailViewController.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RCDChatViewController.h"
#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import <RongCallKit/RongCallKit.h>
#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RCUserInfo.h>

@interface RCDPersonDetailViewController () <UIActionSheetDelegate>
@property(nonatomic) BOOL inBlackList;
@end

@implementation RCDPersonDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  if (![self.userInfo.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"config"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(rightBarButtonItemClicked:)];
    self.videoCallBtn.hidden = NO;
    self.audioCallBtn.hidden = NO;
  }
  

  self.lblName.text = self.userInfo.name;
  if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
      [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
    self.ivAva.clipsToBounds = YES;
    self.ivAva.layer.cornerRadius = 30.f;
  } else {
    self.ivAva.clipsToBounds = YES;
    self.ivAva.layer.cornerRadius = 5.f;
  }
  if (self.userInfo.portraitUri.length == 0) {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:self.userInfo.userId
                             Nickname:self.userInfo.name];
    UIImage *portrait = [defaultPortrait imageFromView];
    self.ivAva.image = portrait;
  } else {
    [self.ivAva
        sd_setImageWithURL:[NSURL URLWithString:self.userInfo.portraitUri]
          placeholderImage:[UIImage imageNamed:@"icon_person"]];
  }

  __weak RCDPersonDetailViewController *weakSelf = self;
  [[RCIMClient sharedRCIMClient] getBlacklistStatus:self.userInfo.userId
      success:^(int bizStatus) {
        weakSelf.inBlackList = (bizStatus == 0);

      }
      error:^(RCErrorCode status) {
        NSArray *array = [[RCDataBaseManager shareInstance] getBlackList];
        for (RCUserInfo *blackInfo in array) {
          if ([blackInfo.userId isEqualToString:weakSelf.userInfo.userId]) {
            weakSelf.inBlackList = YES;
          }
        }
      }];

  self.conversationBtn.layer.borderWidth = 0.5;
  self.audioCallBtn.layer.borderWidth = 0.5;
  self.videoCallBtn.layer.borderWidth = 0.5;

  self.conversationBtn.layer.borderColor = [HEXCOLOR(0x0181dd) CGColor];
  self.audioCallBtn.layer.borderColor = [HEXCOLOR(0xc9c9c9) CGColor];
  self.videoCallBtn.layer.borderColor = [HEXCOLOR(0xc9c9c9) CGColor];
}

- (IBAction)btnConversation:(id)sender {
  //创建会话
  RCDChatViewController *chatViewController =
      [[RCDChatViewController alloc] init];
  chatViewController.conversationType = ConversationType_PRIVATE;
  chatViewController.targetId = self.userInfo.userId;
  chatViewController.title = self.userInfo.name;
  chatViewController.needPopToRootView = YES;
  chatViewController.displayUserNameInCell = NO;
  [self.navigationController pushViewController:chatViewController
                                       animated:YES];
}

- (IBAction)btnVoIP:(id)sender {
  //语音通话
  [[RCCall sharedRCCall] startSingleCall:self.userInfo.userId
                               mediaType:RCCallMediaAudio];
}

- (IBAction)btnVideoCall:(id)sender {
  //视频通话
  [[RCCall sharedRCCall] startSingleCall:self.userInfo.userId
                               mediaType:RCCallMediaVideo];
}

- (void)rightBarButtonItemClicked:(id)sender {

  if (self.inBlackList) {
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"取消黑名单", nil];
    [actionSheet showInView:self.view];
  } else {
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"加入黑名单", nil];
    [actionSheet showInView:self.view];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
  case 0: {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    //黑名单
    __weak RCDPersonDetailViewController *weakSelf = self;
    if (!self.inBlackList) {
      hud.labelText = @"正在加入黑名单";
      [[RCIMClient sharedRCIMClient] addToBlacklist:self.userInfo.userId
          success:^{
            weakSelf.inBlackList = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
              [hud hide:YES];
            });
            [[RCDataBaseManager shareInstance]
                insertBlackListToDB:weakSelf.userInfo];

          }
          error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [hud hide:YES];
              UIAlertView *alertView =
                  [[UIAlertView alloc] initWithTitle:nil
                                             message:@"加入黑名单失败"
                                            delegate:nil
                                   cancelButtonTitle:@"确定"
                                   otherButtonTitles:nil, nil];
              [alertView show];
            });

            weakSelf.inBlackList = NO;
          }];
    } else {
      hud.labelText = @"正在从黑名单移除";
      [[RCIMClient sharedRCIMClient] removeFromBlacklist:self.userInfo.userId
          success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
              [hud hide:YES];
            });
            [[RCDataBaseManager shareInstance]
                removeBlackList:weakSelf.userInfo.userId];

            weakSelf.inBlackList = NO;
          }
          error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [hud hide:YES];
              UIAlertView *alertView =
                  [[UIAlertView alloc] initWithTitle:nil
                                             message:@"从黑名单移除失败"
                                            delegate:nil
                                   cancelButtonTitle:@"确定"
                                   otherButtonTitles:nil, nil];
              [alertView show];
            });

            weakSelf.inBlackList = YES;
          }];
    }

  } break;
  }
}

@end
