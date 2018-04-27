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
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"
#import <RongIMLib/RongIMLib.h>

@interface RCDSettingsTableViewController () <UIAlertViewDelegate>

@end

@implementation RCDSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];

    self.navigationItem.title = @"帐号设置";
    RCDUIBarButtonItem *leftBtn =
    [[RCDUIBarButtonItem alloc] initWithLeftBarButton:@"我" target:self action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger row;
    switch (section) {
    case 0:
        row = 4;
        break;

    case 1:
        row = 1;
        break;

    case 2:
        row = 1;
        break;

    default:
        break;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    [cell setCellStyle:DefaultStyle];
    switch (indexPath.section) {
    case 0: {
        switch (indexPath.row) {
        case 0: {

            cell.leftLabel.text = @"密码修改";
        } break;

        case 1: {
            cell.leftLabel.text = @"隐私";
        } break;

        case 2: {
            cell.leftLabel.text = @"新消息通知";
        } break;

        case 3: {
            cell.leftLabel.text = @"推送设置";
        } break;

        default:
            break;
        }
    } break;

    case 1: {
        cell.leftLabel.text = @"清除缓存";
    } break;

    case 2: {
        return [self createQuitCell];
    } break;

    default:
        break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 取消选中
    switch (indexPath.section) {
    case 0: {
        switch (indexPath.row) {
        case 0: {
            RCDChangePasswordViewController *vc = [[RCDChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;

        case 1: {
            RCDPrivacyTableViewController *vc = [[RCDPrivacyTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;

        case 2: {
            RCDMessageNotifySettingTableViewController *vc = [[RCDMessageNotifySettingTableViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;

        case 3: {
            RCDPushSettingViewController *vc = [[RCDPushSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;

        default:
            break;
        }
    } break;

    case 1: {
        switch (indexPath.row) {
        case 0: {
            //清除缓存
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"是否清理缓存？"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            alertView.tag = 1011;
            [alertView show];

        } break;

        default:
            break;
        }
    } break;

    case 2: {
        switch (indexPath.row) {
        case 0: {
            //退出登录
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"是否退出登录？"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            alertView.tag = 1010;
            [alertView show];
        } break;

        default:
            break;
        }
    }
    default:
        break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 1010) {
        [self logout];
    }

    if (buttonIndex == 1 && alertView.tag == 1011) {
        [self clearCache];
    }
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"缓存清理成功！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

//退出登录
- (void)logout {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
#define DEFAULTS [NSUserDefaults standardUserDefaults]
    //    [DEFAULTS removeObjectForKey:@"userName"];
    //    [DEFAULTS removeObjectForKey:@"userPwd"];
    [DEFAULTS removeObjectForKey:@"userToken"];
    [DEFAULTS removeObjectForKey:@"userCookie"];
    [DEFAULTS removeObjectForKey:@"isLogin"];
    [DEFAULTS synchronize];

    [[RCDataBaseManager shareInstance] closeDBForDisconnect];

    RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.view.window.rootViewController = navi;
    [[RCIMClient sharedRCIMClient] logout];
    //[[RCIMClient sharedRCIMClient]disconnect:NO];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cn.rongcloud.im.share"];
    [userDefaults removeObjectForKey:@"Cookie"];
    [userDefaults synchronize];
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)createQuitCell {
    UITableViewCell *quitCell = [[UITableViewCell alloc] init];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
    label.text = @"退出登录";
    label.translatesAutoresizingMaskIntoConstraints = NO;
    quitCell.contentView.layer.borderWidth = 0.5;
    quitCell.contentView.layer.borderColor = [[UIColor colorWithHexString:@"dfdfdf" alpha:1.0] CGColor];

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

@end
