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

@interface RCDMessageNotifySettingTableViewController ()

@property(nonatomic, assign) BOOL isReceiveNotification;

@end

@implementation RCDMessageNotifySettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = RCDLocalizedString(@"new_message_notification");

    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = RCDLocalizedString(@"setting");
    UISwitch *switchBtn = (UISwitch *)sender;
    if (!switchBtn.on) {
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:@"00:00:00" spanMins:1439 success:^{
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
               [self showAlert:RCDLocalizedString(@"alert") message:RCDLocalizedString(@"set_fail") cancelBtnTitle:RCDLocalizedString(@"cancel") otherBtnTitle:nil tag:-1];
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
                  [self showAlert:RCDLocalizedString(@"alert") message:@"取消失败" cancelBtnTitle:RCDLocalizedString(@"cancel") otherBtnTitle:nil tag:-1];
                  self.isReceiveNotification = NO;
                  [self.tableView reloadData];
              });
          }];
    }
}

#pragma mark - Table view Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    cell.baseSettingTableViewDelegate = self;
    if(0 == indexPath.row) {
        [cell setCellStyle:SwitchStyle];
        cell.leftLabel.text = RCDLocalizedString(@"Receive_new_message_notifications")
        ;
        cell.switchButton.on = self.isReceiveNotification;
    }else if(1 == indexPath.row) {
        [cell setCellStyle:DefaultStyle];
        cell.leftLabel.text = RCDLocalizedString(@"mute_notifications");
        if (self.isReceiveNotification == YES) {
            cell.backgroundColor = [UIColor whiteColor];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        }
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
    return 15.f;
}

- (void)showAlert:(NSString *)title message:(NSString *)message cancelBtnTitle:(NSString *)cBtnTitle otherBtnTitle:(NSString *)oBtnTitle tag:(int)tag {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cBtnTitle otherButtonTitles:oBtnTitle, nil];
    if(tag > 0){
        alertView.tag = tag;
    }
    [alertView show];
}

@end
