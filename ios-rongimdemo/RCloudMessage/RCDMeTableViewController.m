//
//  RCDMeTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/28.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDMeTableViewController.h"
#import "AFHttpTool.h"
#import "DefaultPortraitView.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDCustomerServiceViewController.h"
#import "RCDHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"
#import <RongIMLib/RongIMLib.h>

#warning 红包相关
#import "RedpacketViewControl.h"

@interface RCDMeTableViewController ()
@property(weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property(weak, nonatomic) IBOutlet UIImageView *currentUserPortrait;
@property(nonatomic) BOOL hasNewVersion;
@property(nonatomic) NSString *versionUrl;
@property(nonatomic, strong) NSString *versionString;

@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic, strong) NSMutableData *receiveData;

@end

@implementation RCDMeTableViewController {
  UIImage *userPortrait;
  BOOL isSyncCurrentUserInfo;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.tableFooterView = [UIView new];
  //设置分割线颜色
  self.tableView.separatorColor =
      [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
  if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
  }
  //    self.currentUserNameLabel.text = [DEFAULTS objectForKey:@"userName"];;
  self.tabBarController.navigationItem.rightBarButtonItem = nil;
  self.tabBarController.navigationController.navigationBar.tintColor =
      [UIColor whiteColor];

  self.currentUserPortrait.layer.masksToBounds = YES;
  self.currentUserPortrait.layer.cornerRadius = 5.f;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(setUserPortrait:)
                                               name:@"setCurrentUserPortrait"
                                             object:nil];

  isSyncCurrentUserInfo = NO;
  self.currentUserNameLabel.text = [DEFAULTS stringForKey:@"userNickName"];
  [self.currentUserPortrait
      sd_setImageWithURL:[NSURL
                             URLWithString:[DEFAULTS
                                               stringForKey:@"userPortraitUri"]]
        placeholderImage:[UIImage imageNamed:@"icon_person"]];
  
  self.needUpdateImage.layer.cornerRadius = 5.f;
  NSString *isNeedUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"isNeedUpdate"];
  if ([isNeedUpdate isEqualToString:@"YES"]) {
    self.needUpdateImage.hidden = NO;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.tabBarController.navigationItem.title = @"我";
  self.tabBarController.navigationItem.rightBarButtonItems = nil;
  [self syncCurrentUserInfo];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self chatWithCustomerService];
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        if (self.hasNewVersion) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.versionUrl]];
            self.hasNewVersion = NO;
            self.versionUrl = nil;
        } else {
//            [self checkNewVersion];
        }
    }else if (indexPath.section == 1 && indexPath.row == 1){
#warning 红包相关
        RedpacketViewControl * redpacketControl = [[RedpacketViewControl alloc] init];
        redpacketControl.conversationController = self;
        [redpacketControl presentChangeMoneyViewController];
    }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return 15.f;
  }
  return 5.f;
}

- (void)setUserPortrait:(NSNotification *)notifycation {
  userPortrait = [notifycation object];
}

- (void)chatWithCustomerService {
  RCDCustomerServiceViewController *chatService =
      [[RCDCustomerServiceViewController alloc] init];
//#define SERVICE_ID @"KEFU145760441681012" //智齿Test kefu id
  
#define SERVICE_ID @"KEFU146001495753714"
  // live800  KEFU146227005669524   live800的客服ID
  // zhichi   KEFU146001495753714   智齿的客服ID
  chatService.userName = @"客服";
  chatService.conversationType = ConversationType_CUSTOMERSERVICE;

  chatService.targetId = SERVICE_ID;

  //上传用户信息，nickname是必须要填写的
  RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
  csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
  csInfo.nickName = @"昵称";
  csInfo.loginName = @"登录名称";
  csInfo.name = @"用户名称";
  csInfo.grade = @"11级";
  csInfo.gender = @"男";
  csInfo.birthday = @"2016.5.1";
  csInfo.age = @"36";
  csInfo.profession = @"software engineer";
  csInfo.portraitUrl =
      [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
  csInfo.province = @"beijing";
  csInfo.city = @"beijing";
  csInfo.memo = @"这是一个好顾客!";

  csInfo.mobileNo = @"13800000000";
  csInfo.email = @"test@example.com";
  csInfo.address = @"北京市北苑路北泰岳大厦";
  csInfo.QQ = @"88888888";
  csInfo.weibo = @"my weibo account";
  csInfo.weixin = @"myweixin";

  csInfo.page = @"卖化妆品的页面来的";
  csInfo.referrer = @"客户端";
  csInfo.enterUrl = @"testurl";
  csInfo.skillId = @"技能组";
  csInfo.listUrl = @[@"用户浏览的第一个商品Url",
                      @"用户浏览的第二个商品Url"];
  csInfo.define = @"自定义信息";

  chatService.csInfo = csInfo;
  chatService.title = chatService.userName;

  [self.navigationController pushViewController:chatService animated:YES];
}

- (void)syncCurrentUserInfo {
  [AFHttpTool getUserInfo:[RCIM sharedRCIM].currentUserInfo.userId
      success:^(id response) {
        if ([response[@"code"] intValue] == 200) {
          NSDictionary *result = response[@"result"];
          NSString *userId = result[@"id"];
          NSString *nickname = result[@"nickname"];
          NSString *portraitUri = result[@"portraitUri"];
          RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:userId
                                                           name:nickname
                                                       portrait:portraitUri];
          if (!user.portraitUri || user.portraitUri.length <= 0) {
            user.portraitUri = [RCDUtilities defaultUserPortrait:user];
          }
          [[RCDataBaseManager shareInstance] insertUserToDB:user];
          [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
          [RCIM sharedRCIM].currentUserInfo = user;
          [DEFAULTS setObject:user.portraitUri forKey:@"userPortraitUri"];
          [DEFAULTS setObject:user.name forKey:@"userNickName"];
          [DEFAULTS synchronize];
          isSyncCurrentUserInfo = YES;
          [self setNicknameAndPortrait];
        }
      }
      failure:^(NSError *err) {
        isSyncCurrentUserInfo = YES;
        [self setNicknameAndPortrait];
      }];
}

- (void)setNicknameAndPortrait {
  NSString *portraitUrl = [DEFAULTS stringForKey:@"userPortraitUri"];
  if ([portraitUrl isEqualToString:@""]) {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:[RCIM sharedRCIM].currentUserInfo.userId
                             Nickname:[DEFAULTS stringForKey:@"userNickName"]];
    UIImage *portrait = [defaultPortrait imageFromView];
    self.currentUserPortrait.image = portrait;
    NSData *data = UIImagePNGRepresentation(portrait);
    [RCDHTTPTOOL uploadImageToQiNiu:[RCIM sharedRCIM].currentUserInfo.userId
        ImageData:data
        success:^(NSString *url) {
          [DEFAULTS setObject:url forKey:@"userPortraitUri"];
          [DEFAULTS synchronize];
          RCUserInfo *user = [RCUserInfo new];
          user.userId = [RCIM sharedRCIM].currentUserInfo.userId;
          user.portraitUri = url;
          user.name = [DEFAULTS stringForKey:@"userNickName"];
          [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
          dispatch_async(dispatch_get_main_queue(), ^{
            [self.currentUserPortrait
                sd_setImageWithURL:[NSURL URLWithString:url]
                  placeholderImage:portrait];
          });
        }
        failure:^(NSError *err){

        }];
  } else {
    [self.currentUserPortrait
        sd_setImageWithURL:
            [NSURL URLWithString:[DEFAULTS stringForKey:@"userPortraitUri"]]
          placeholderImage:[UIImage imageNamed:@"icon_person"]];
  }
  if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
      [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
    self.currentUserPortrait.layer.masksToBounds = YES;
    self.currentUserPortrait.layer.cornerRadius = 30.f;
  }
  self.currentUserNameLabel.text = [DEFAULTS stringForKey:@"userNickName"];
}
@end
