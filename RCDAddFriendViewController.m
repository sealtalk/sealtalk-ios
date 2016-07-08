//
//  RCDAddFriendViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/4/16.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAddFriendViewController.h"
#import "DefaultPortraitView.h"
#import "RedpacketDemoViewController.h"
#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"

@interface RCDAddFriendViewController ()

@end

@implementation RCDAddFriendViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  self.lblName.text = self.targetUserInfo.name;
  if ([self.targetUserInfo.portraitUri isEqualToString:@""]) {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:self.targetUserInfo.userId
                             Nickname:self.targetUserInfo.name];
    UIImage *portrait = [defaultPortrait imageFromView];
    self.ivAva.image = portrait;
  } else {
    [self.ivAva
        sd_setImageWithURL:[NSURL URLWithString:self.targetUserInfo.portraitUri]
          placeholderImage:[UIImage imageNamed:@"icon_person"]];
  }
  self.ivAva.layer.masksToBounds = YES;
  self.ivAva.layer.cornerRadius = 6.f;
  self.ivAva.contentMode = UIViewContentModeScaleAspectFill;
  NSMutableArray *cacheList = [[NSMutableArray alloc]
      initWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
  BOOL isFriend = NO;
  for (RCDUserInfo *user in cacheList) {
    if ([user.userId isEqualToString:self.targetUserInfo.userId] &&
        [user.status isEqualToString:@"20"]) {
      isFriend = YES;
      break;
    }
  }
  if (isFriend == YES) {
    _addFriendBtn.hidden = YES;
  } else {
    _startChat.hidden = YES;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (IBAction)actionAddFriend:(id)sender {
  [RCDHTTPTOOL requestFriend:_targetUserInfo.userId
                    complete:^(BOOL result) {
                      //    [RCDHTTPTOOL requestFriend:@"OioOHsuTN"
                      //    complete:^(BOOL result) {
                      if (result) {
                        UIAlertView *alertView = [[UIAlertView alloc]
                                initWithTitle:nil
                                      message:@"请求已发送"
                                     delegate:nil
                            cancelButtonTitle:@"确定"
                            otherButtonTitles:nil, nil];
                        [alertView show];
                      } else {
                        UIAlertView *alertView = [[UIAlertView alloc]
                                initWithTitle:nil
                                      message:@"请求失败，请重试"
                                     delegate:nil
                            cancelButtonTitle:@"确定"
                            otherButtonTitles:nil, nil];
                        [alertView show];
                      }
                    }];
}

- (IBAction)actionStartChat:(id)sender {
  RedpacketDemoViewController *conversationVC = [[RedpacketDemoViewController alloc] init];
  conversationVC.conversationType = ConversationType_PRIVATE;
  conversationVC.targetId = self.targetUserInfo.userId;
  conversationVC.title = self.targetUserInfo.name;
  [self.navigationController pushViewController:conversationVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
