//
//  RCDMessageNotifyTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/20.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDMessageNotifySettingTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDMessageNoDisturbSettingController.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "UIView+MBProgressHUD.h"
#define RCDReceiveNotification 200
#define RCDReceivePokeMessage 201
@interface RCDMessageNotifySettingTableViewController ()

@property (nonatomic, assign) BOOL isReceiveNotification;

@end

@implementation RCDMessageNotifySettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = RCDLocalizedString(@"new_message_notification");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (spansMin >= 1439) {
                self.isReceiveNotification = NO;
            } else {
                self.isReceiveNotification = YES;
            }
            [self.tableView reloadData];
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

- (void)onClickSwitchButton:(id)sender {
    UISwitch *swit = (UISwitch *)sender;
    if (swit.tag == RCDReceiveNotification) {
        [self setReceiveNotification:swit];
    } else if (swit.tag == RCDReceivePokeMessage) {
        [self setReceivePokeMessage:swit];
    }
}

#pragma mark - Table view Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    cell.baseSettingTableViewDelegate = self;
    if (indexPath.section == 0) {
        if (0 == indexPath.row) {
            [cell setCellStyle:SwitchStyle];
            cell.leftLabel.text = RCDLocalizedString(@"Receive_new_message_notifications");
            cell.switchButton.on = self.isReceiveNotification;
            cell.switchButton.tag = RCDReceiveNotification;
        } else if (1 == indexPath.row) {
            [cell setCellStyle:DefaultStyle];
            cell.leftLabel.text = RCDLocalizedString(@"mute_notifications");
            //            if (self.isReceiveNotification == YES) {
            //                cell.backgroundColor = [UIColor whiteColor];
            //            } else {
            //                cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
            //            }
        }
    } else {
        cell.switchButton.tag = RCDReceivePokeMessage;
        [cell setCellStyle:SwitchStyle];
        cell.leftLabel.text = RCDLocalizedString(@"ReceivePokeMessage");
        cell.switchButton.on = [RCDUserInfoManager getReceivePokeMessageStatus];
        [RCDUserInfoManager getReceivePokeMessageStatusFromServer:^(BOOL allowReceive) {
            cell.switchButton.on = allowReceive;
        }
            error:^{

            }];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 && indexPath.section == 0) {
        if (self.isReceiveNotification == YES) {
            RCDMessageNoDisturbSettingController *noMessage = [[RCDMessageNoDisturbSettingController alloc] init];
            [self.navigationController pushViewController:noMessage animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return 15.f;
    }
    return 0.01f;
}

#pragma mark - private
- (void)setReceiveNotification:(UISwitch *)switchBtn {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = RCDLocalizedString(@"setting");
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
                    [hud hide:YES];
                    [self showAlert:RCDLocalizedString(@"alert")
                               message:RCDLocalizedString(@"set_fail")
                        cancelBtnTitle:RCDLocalizedString(@"cancel")
                         otherBtnTitle:nil];
                    self.isReceiveNotification = YES;
                    [self.tableView reloadData];
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
                    [hud hide:YES];
                    [self showAlert:RCDLocalizedString(@"alert")
                               message:@"取消失败"
                        cancelBtnTitle:RCDLocalizedString(@"cancel")
                         otherBtnTitle:nil];
                    self.isReceiveNotification = NO;
                    [self.tableView reloadData];
                });
            }];
    }
}

- (void)setReceivePokeMessage:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [RCDUserInfoManager setReceivePokeMessage:switchButton.on
                                     complete:^(BOOL success) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (success) {
                                                 [weakSelf.view showHUDMessage:RCDLocalizedString(@"setting_success")];
                                             } else {
                                                 switchButton.on = !switchButton.on;
                                                 [weakSelf.view showHUDMessage:RCDLocalizedString(@"SetFailure")];
                                             }
                                         });
                                     }];
}

- (void)showAlert:(NSString *)title
          message:(NSString *)message
   cancelBtnTitle:(NSString *)cBtnTitle
    otherBtnTitle:(NSString *)oBtnTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:cBtnTitle style:UIAlertActionStyleDefault handler:nil]];
        if (oBtnTitle) {
            [alertController
                addAction:[UIAlertAction actionWithTitle:oBtnTitle style:UIAlertActionStyleDefault handler:nil]];
        }
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

@end
