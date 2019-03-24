//
//  RCDMessageNotifyTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/20.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDMessageNotifySettingTableViewController.h"
#import "MBProgressHUD.h"
#import "RCDMessageNoDisturbSettingController.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDMessageNotifySettingTableViewController ()

@property(nonatomic, assign) BOOL isReceiveNotification;

@end

@implementation RCDMessageNotifySettingTableViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (spansMin >= 1439) {
                self.isReceiveNotification = NO;
                [self.tableView reloadData];
            } else {
                self.isReceiveNotification = YES;
                [self.tableView reloadData];
            }
        });
    }
        error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //       cell.switchButton.on = YES;
                self.isReceiveNotification = YES;
                [self.tableView reloadData];
            });
        }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = RCDLocalizedString(@"new_message_notification")
;

    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    cell.baseSettingTableViewDelegate = self;
    switch (indexPath.section) {
    case 0: {
        switch (indexPath.row) {
        case 0: {
            [cell setCellStyle:SwitchStyle];
            cell.leftLabel.text = RCDLocalizedString(@"Receive_new_message_notifications")
;
            cell.switchButton.on = self.isReceiveNotification;
        } break;

        case 1: {
            [cell setCellStyle:DefaultStyle];
            cell.leftLabel.text = RCDLocalizedString(@"mute_notifications");
            if (self.isReceiveNotification == YES) {
                cell.backgroundColor = [UIColor whiteColor];
            } else {
                cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
            }
        } break;

        default:
            break;
        }
    } break;

    default:
        break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 取消选中

    if (indexPath.row == 1 && indexPath.section == 0) {
        if (self.isReceiveNotification == YES) {
            RCDMessageNoDisturbSettingController *noMessage = [[RCDMessageNoDisturbSettingController alloc] init];
            [self.navigationController pushViewController:noMessage animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

- (void)onClickSwitchButton:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = RCDLocalizedString(@"setting");
    UISwitch *switchBtn = (UISwitch *)sender;
    if (!switchBtn.on) {
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:@"00:00:00"
            spanMins:1439
            success:^{
                NSLog(@"setNotificationQuietHours succeed");

                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    self.isReceiveNotification = NO;
                    [self.tableView reloadData];
                });
            }
            error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RCDLocalizedString(@"alert")
                                                                    message:RCDLocalizedString(@"set_fail")
                                                                   delegate:nil
                                                          cancelButtonTitle:RCDLocalizedString(@"cancel")

                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.isReceiveNotification = YES;
                        [self.tableView reloadData];
                    });
                    [hud hide:YES];
                });
            }];
    } else {
        [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                self.isReceiveNotification = YES;
                [self.tableView reloadData];
            });
        }
            error:^(RCErrorCode status) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RCDLocalizedString(@"alert")
                                                                    message:@"取消失败"
                                                                   delegate:nil
                                                          cancelButtonTitle:RCDLocalizedString(@"cancel")

                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.isReceiveNotification = NO;
                        [self.tableView reloadData];
                    });
                    [hud hide:YES];
                });
            }];
    }
}

@end
