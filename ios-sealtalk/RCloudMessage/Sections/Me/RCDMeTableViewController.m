//
//  RCDMeTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/28.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDMeTableViewController.h"
#import "RCDAboutRongCloudTableViewController.h"
#import "RCDCommonDefine.h"
#import "RCDCustomerServiceViewController.h"
#import "RCDMeCell.h"
#import "RCDMeDetailsCell.h"
#import "RCDMeInfoTableViewController.h"
#import "RCDSettingsTableViewController.h"
#import "UIColor+RCColor.h"
#import "RCDLanguageManager.h"
#import "RCDLanguageSettingViewController.h"
#import "RCDCommonString.h"
#import "RCDQRCodeController.h"

//#define SERVICE_ID @"KEFU146001495753714"

@interface RCDMeTableViewController ()
@property (nonatomic, strong) NSDictionary *languageDic;
@end

@implementation RCDMeTableViewController
- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.languageDic = @{ @"en" : @"English", @"zh-Hans" : @"简体中文" };
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = RCDLocalizedString(@"me");
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (0 == section) {
        rows = 1;
    } else if (1 == section) {
        rows = 1;
    } else if (2 == section) {
        rows = 2;
    } else if (3 == section) {
        rows = 2;
    }
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        static NSString *detailsCellWithIdentifier = @"RCDMeDetailsCell";
        RCDMeDetailsCell *detailsCell = [self.tableView dequeueReusableCellWithIdentifier:detailsCellWithIdentifier];
        if (detailsCell == nil) {
            detailsCell = [[RCDMeDetailsCell alloc] init];
        }
        return detailsCell;
    }

    static NSString *reusableCellWithIdentifier = @"RCDMeCell";
    RCDMeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];

    if (cell == nil) {
        cell = [[RCDMeCell alloc] init];
    }
    if (1 == indexPath.section) {
        [cell setCellWithImageName:@"qr_setting" labelName:RCDLocalizedString(@"My_QR") rightLabelName:@""];
    }
    if (2 == indexPath.section) {
        if (0 == indexPath.row) {
            [cell setCellWithImageName:@"setting_up"
                             labelName:RCDLocalizedString(@"account_setting")
                        rightLabelName:@""];
        } else if (1 == indexPath.row) {
            NSString *currentLanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
            NSString *currentLanguageString = self.languageDic[currentLanguage];
            NSString *rightString = currentLanguageString ? currentLanguageString : RCDLocalizedString(@"language");
            [cell setCellWithImageName:@"icon_ multilingual"
                             labelName:RCDLocalizedString(@"language")
                        rightLabelName:rightString];
        }
    } else if (3 == indexPath.section) {
        if (0 == indexPath.row) {
            [cell setCellWithImageName:@"sevre_inactive" labelName:RCDLocalizedString(@"feedback") rightLabelName:@""];
        } else if (1 == indexPath.row) {
            [cell setCellWithImageName:@"about_rongcloud"
                             labelName:RCDLocalizedString(@"about_sealtalk")
                        rightLabelName:@""];
            BOOL isNeedUpdate = [[DEFAULTS objectForKey:RCDNeedUpdateKey] boolValue];
            if (isNeedUpdate) {
                [cell addRedpointImageView];
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 88.f;
    }
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        RCDMeInfoTableViewController *vc = [[RCDMeInfoTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (1 == indexPath.section) {
        RCDQRCodeController *qrCodeVC =
            [[RCDQRCodeController alloc] initWithTargetId:[RCIM sharedRCIM].currentUserInfo.userId
                                         conversationType:ConversationType_PRIVATE];
        [self.navigationController pushViewController:qrCodeVC animated:YES];
    } else if (2 == indexPath.section) {
        if (0 == indexPath.row) {
            RCDSettingsTableViewController *vc = [[RCDSettingsTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (1 == indexPath.row) {
            RCDLanguageSettingViewController *vc = [[RCDLanguageSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (3 == indexPath.section) {
        if (0 == indexPath.row) {
            [self chatWithCustomerService:SERVICE_ID];
        } else if (1 == indexPath.row) {
            RCDAboutRongCloudTableViewController *vc = [[RCDAboutRongCloudTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    return view;
}

- (void)chatWithCustomerService:(NSString *)kefuId {
    RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];

    // live800  KEFU146227005669524   live800的客服ID
    // zhichi   KEFU146001495753714   智齿的客服ID
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;

    chatService.targetId = kefuId;

    //上传用户信息，nickname是必须要填写的
    RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
    csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    csInfo.nickName = RCDLocalizedString(@"nickname");
    csInfo.loginName = @"登录名称";
    csInfo.name = [RCIMClient sharedRCIMClient].currentUserInfo.name;
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
    csInfo.referrer = @"10001";
    csInfo.enterUrl = @"testurl";
    csInfo.skillId = @"技能组";
    csInfo.listUrl = @[ @"用户浏览的第一个商品Url", @"用户浏览的第二个商品Url" ];
    csInfo.define = @"自定义信息";

    chatService.csInfo = csInfo;
    chatService.title = RCDLocalizedString(@"feedback");

    [self.navigationController pushViewController:chatService animated:YES];
}

- (void)initUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

@end
