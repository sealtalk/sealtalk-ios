//
//  RCDSettingsTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/20.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDSettingsTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDChangePasswordViewController.h"
#import "RCDLoginViewController.h"
#import "RCDMessageNotifySettingTableViewController.h"
#import "RCDPrivacyTableViewController.h"
#import "RCDPushSettingViewController.h"
#import "RCDUIBarButtonItem.h"
#import "UIColor+RCColor.h"
#import "RCDLoginManager.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDCommonString.h"
#import "RCDCleanChatHistoryViewController.h"
#import "RCDChatBackgroundViewController.h"

@interface RCDSettingsTableViewController ()

@end

@implementation RCDSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
}

#pragma mark - Table view Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger row = 0;
    if (0 == section) {
        row = 4;
    } else if (1 == section) {
        row = 3;
    } else if (2 == section) {
        row = 1;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (2 == indexPath.section) {
        return [self createQuitCell];
    }

    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    [cell setCellStyle:DefaultStyle];
    NSString *text = @"";
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            text = RCDLocalizedString(@"change_password");
        } else if (1 == indexPath.row) {
            text = RCDLocalizedString(@"SecurityAndprivacy");
        } else if (2 == indexPath.row) {
            text = RCDLocalizedString(@"new_message_notification");
        } else if (3 == indexPath.row) {
            text = RCDLocalizedString(@"push_setting");
        }
    } else {
        if (indexPath.row == 0) {
            text = RCDLocalizedString(@"ChatBackground");
        } else if (indexPath.row == 1) {
            text = RCDLocalizedString(@"clear_cache");
        } else {
            text = RCDLocalizedString(@"CleanChatHistory");
        }
    }
    cell.leftLabel.text = text;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            RCDChangePasswordViewController *vc = [[RCDChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (1 == indexPath.row) {
            RCDPrivacyTableViewController *vc = [[RCDPrivacyTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (2 == indexPath.row) {
            RCDMessageNotifySettingTableViewController *vc = [[RCDMessageNotifySettingTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (3 == indexPath.row) {
            RCDPushSettingViewController *vc = [[RCDPushSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (1 == indexPath.section) {
        if (indexPath.row == 0) {
            RCDChatBackgroundViewController *chatBgVC = [[RCDChatBackgroundViewController alloc] init];
            [self.navigationController pushViewController:chatBgVC animated:YES];
        } else if (indexPath.row == 1) {
            //清除缓存
            [self showAlert:RCDLocalizedString(@"clear_cache_alert")
                cancelBtnTitle:RCDLocalizedString(@"cancel")
                 otherBtnTitle:RCDLocalizedString(@"confirm")
                           tag:1011];
        } else {
            RCDCleanChatHistoryViewController *cleanVC = [[RCDCleanChatHistoryViewController alloc] init];
            [self.navigationController pushViewController:cleanVC animated:YES];
        }
    } else if (2 == indexPath.section) {
        //退出登录
        [self showAlert:RCDLocalizedString(@"logout_alert")
            cancelBtnTitle:RCDLocalizedString(@"cancel")
             otherBtnTitle:RCDLocalizedString(@"confirm")
                       tag:1010];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

//清理缓存
- (void)clearCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        //这里清除 Library/Caches 里的所有文件，融云的缓存文件及图片存放在 Library/Caches/RongCloud 下
        NSString *cachPath =
            [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];

        for (NSString *p in files) {
            NSError *error;
            NSString *path = [cachPath stringByAppendingPathComponent:p];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        }
        [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];
    });
}

- (void)clearCacheSuccess {
    [self showAlert:RCDLocalizedString(@"clear_cache_succrss")
        cancelBtnTitle:RCDLocalizedString(@"confirm")
         otherBtnTitle:nil
                   tag:-1];
}

//退出登录
- (void)logout {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [DEFAULTS removeObjectForKey:RCDIMTokenKey];
    [DEFAULTS synchronize];

    [RCDLoginManager logout:^(BOOL success){
    }];

    RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.view.window.rootViewController = navi;
    [[RCIM sharedRCIM] logout];

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cn.rongcloud.im.share"];
    [userDefaults removeObjectForKey:RCDCookieKey];
    [userDefaults synchronize];
}

- (void)showAlert:(NSString *)message
   cancelBtnTitle:(NSString *)cBtnTitle
    otherBtnTitle:(NSString *)oBtnTitle
              tag:(int)tag {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:cBtnTitle style:UIAlertActionStyleDefault handler:nil]];
        if (oBtnTitle) {
            [alertController addAction:[UIAlertAction actionWithTitle:oBtnTitle
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *_Nonnull action) {
                                                                  if (tag == 1010) {
                                                                      [self logout];
                                                                  } else if (tag == 1011) {
                                                                      [self clearCache];
                                                                  }
                                                              }]];
        }
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)createQuitCell {
    UITableViewCell *quitCell = [[UITableViewCell alloc] init];
    quitCell.selectionStyle = UITableViewCellSelectionStyleNone;
    quitCell.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                        darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    label.text = RCDLocalizedString(@"logout");
    label.translatesAutoresizingMaskIntoConstraints = NO;

    [quitCell setSeparatorInset:UIEdgeInsetsMake(0, 100, 0, 1000)];
    [quitCell.contentView addSubview:label];
    [quitCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:quitCell.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0]];

    [quitCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:quitCell.contentView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0]];
    return quitCell;
}

- (void)initUI {
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.navigationItem.title = RCDLocalizedString(@"account_setting");
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"me")
                                                                             target:self
                                                                             action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

@end
