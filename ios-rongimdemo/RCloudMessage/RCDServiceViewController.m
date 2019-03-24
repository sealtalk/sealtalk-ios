//
//  RCDServiceViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/12/1.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDServiceViewController.h"
//#import "RCChatViewController.h"
#import <RongIMKit/RongIMKit.h>
//#import "RCHandShakeMessage.h"
#import "RCDCommonDefine.h"
#import "RCDCustomerServiceViewController.h"

@interface RCDServiceViewController () <UITextFieldDelegate>

@property(nonatomic, strong) UITextField *kefuIdField;
@end

@implementation RCDServiceViewController

- (IBAction)acService:(UIButton *)sender {
    RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];
//#define SERVICE_ID @"KEFU145801184889727"
#define SERVICE_ID @"KEFU146001495753714"
    chatService.userName = RCDLocalizedString(@"customer");
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;
#if RCDDebugTestFunction
    NSString *kefuId = self.kefuIdField.text;
    [[NSUserDefaults standardUserDefaults] setObject:kefuId forKey:@"KefuId"];
    chatService.targetId = kefuId;
#else
    chatService.targetId = SERVICE_ID;
#endif

    //上传用户信息，nickname是必须要填写的
    RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
    csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    csInfo.nickName = RCDLocalizedString(@"nickname")
;
    csInfo.loginName = @"登录名称";
    csInfo.name = @"用户名称";
    csInfo.grade = @"11级";
    csInfo.gender = @"男";
    csInfo.birthday = @"2016.5.1";
    csInfo.age = @"36";
    csInfo.profession = @"software engineer";
    csInfo.portraitUrl = [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
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
    csInfo.listUrl = @[ @"用户浏览的第一个商品Url", @"用户浏览的第二个商品Url" ];
    csInfo.define = @"自定义信息";

    chatService.csInfo = csInfo;
    chatService.title = chatService.userName;

    [self.navigationController pushViewController:chatService animated:YES];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //设置为不用默认渲染方式
        self.tabBarItem.image =
            [[UIImage imageNamed:@"icon_server"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage =
            [[UIImage imageNamed:@"icon_server_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMessageNotification:)
                                                     name:RCKitDispatchMessageNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,
    //    self.view.bounds.size.width, 44)];
    //    titleView.backgroundColor = [UIColor clearColor];
    //    titleView.font = [UIFont boldSystemFontOfSize:19];
    //    titleView.textColor = [UIColor whiteColor];
    //    titleView.textAlignment = NSTextAlignmentCenter;
    //    titleView.text = RCDLocalizedString(@"customer");
    //    self.tabBarController.navigationItem.titleView = titleView;
    self.tabBarController.navigationItem.title = RCDLocalizedString(@"customer");
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}
// live800 KEFU146227005669524
// zhichi KEFU146001495753714
//

- (void)viewDidLoad {
    [super viewDidLoad];

#if RCDDebugTestFunction
    if (!self.kefuIdField) {
        self.kefuIdField = [[UITextField alloc] initWithFrame:CGRectMake(10, 50, 200, 30)];
        [self.kefuIdField setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.kefuIdField];
        NSString *kefuId = [[NSUserDefaults standardUserDefaults] objectForKey:@"KefuId"];
        if (kefuId == nil) {
            kefuId = @"KEFU146001495753714"; //@"KEFUxiaoqiaoLive8001";
        }
        [self.kefuIdField setText:kefuId];
        [self.kefuIdField setDelegate:self];
        self.kefuIdField.returnKeyType = UIReturnKeyDone;
    }
#endif
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.tabBarItem.badgeValue = nil;
}
- (void)didReceiveMessageNotification:(NSNotification *)notification {
    __weak typeof(self) __weakSelf = self;
    RCMessage *message = notification.object;
    if (message.conversationType == ConversationType_CUSTOMERSERVICE) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            int count = [[RCIMClient
            //            sharedRCIMClient]getUnreadCount:@[@(ConversationType_CUSTOMERSERVICE)]];
            //            if (count>0) {
            __weakSelf.tabBarItem.badgeValue = @"";
            //            }
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKitDispatchMessageNotification object:nil];
}

@end
