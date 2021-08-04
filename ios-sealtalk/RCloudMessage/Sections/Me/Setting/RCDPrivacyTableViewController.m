//
//  RCDPrivacyTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/6/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDPrivacyTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDBlackListViewController.h"
#import "UIColor+RCColor.h"
#import "RCDUserInfoManager.h"
#import "UIView+MBProgressHUD.h"

#define RCDSearchByMobileTag 310
#define RCDSearchBySTAccountTag 311
#define RCDAddFriendAuthTag 312
#define RCDAddGroupAuthTag 313

@interface RCDPrivacyTableViewController () <RCDBaseSettingTableViewCellDelegate>
@property (nonatomic, strong) NSArray *sectionData;
@property (nonatomic, strong) RCDUserSetting *userSettings;
@end

@implementation RCDPrivacyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionData = @[
        @[
           RCDLocalizedString(@"AllowSearchByMobile"),
           RCDLocalizedString(@"AllowSearchBySealTalkNum"),
           RCDLocalizedString(@"AddFriendNeedAuth"),
           RCDLocalizedString(@"AllowAddGroup")
        ],
        @[ RCDLocalizedString(@"blacklist") ]
    ];
    self.navigationItem.title = RCDLocalizedString(@"SecurityAndprivacy");
    [self getCurrentUserSettings];
}

- (void)getCurrentUserSettings {
    __weak typeof(self) weakSelf = self;
    [RCDUserInfoManager getUserPrivacyFromServer:^(RCDUserSetting *setting) {
        if (!setting) {
            setting = [RCDUserInfoManager getUserPrivacy];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.userSettings = setting;
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.sectionData[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    NSString *title = self.sectionData[indexPath.section][indexPath.row];
    cell.leftLabel.text = title;
    if (!self.userSettings) {
        cell.switchButton.on = YES;
    }
    cell.baseSettingTableViewDelegate = self;
    if ([title isEqualToString:RCDLocalizedString(@"AllowSearchByMobile")]) {
        [cell setCellStyle:SwitchStyle];
        cell.switchButton.tag = RCDSearchByMobileTag;
        if (self.userSettings) {
            cell.switchButton.on = self.userSettings.allowMobileSearch;
        }
    } else if ([title isEqualToString:RCDLocalizedString(@"AllowSearchBySealTalkNum")]) {
        [cell setCellStyle:SwitchStyle];
        cell.switchButton.tag = RCDSearchBySTAccountTag;
        if (self.userSettings) {
            cell.switchButton.on = self.userSettings.allowSTAccountSearch;
        }
    } else if ([title isEqualToString:RCDLocalizedString(@"AddFriendNeedAuth")]) {
        [cell setCellStyle:SwitchStyle];
        cell.switchButton.tag = RCDAddFriendAuthTag;
        if (self.userSettings) {
            cell.switchButton.on = self.userSettings.needAddFriendVerify;
        }
    } else if ([title isEqualToString:RCDLocalizedString(@"AllowAddGroup")]) {
        [cell setCellStyle:SwitchStyle];
        cell.switchButton.tag = RCDAddGroupAuthTag;
        if (self.userSettings) {
            cell.switchButton.on = self.userSettings.needJoinGroupVerify;
        }
    } else if ([title isEqualToString:RCDLocalizedString(@"blacklist")]) {
        [cell setCellStyle:DefaultStyle];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.sectionData[indexPath.section][indexPath.row];
    if ([title isEqualToString:RCDLocalizedString(@"blacklist")]) {
        RCDBlackListViewController *vc = [[RCDBlackListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - RCDBaseSettingTableViewCellDelegate
- (void)onClickSwitchButton:(id)sender {
    UISwitch *swit = (UISwitch *)sender;
    if (swit.tag == RCDSearchByMobileTag) {
        [self setSearchMeByMobile:swit];
    } else if (swit.tag == RCDSearchBySTAccountTag) {
        [self setSearchMeBySTAccount:swit];
    } else if (swit.tag == RCDAddFriendAuthTag) {
        [self setAddFriendVerify:swit];
    } else if (swit.tag == RCDAddGroupAuthTag) {
        [self setJoinGroupVerify:swit];
    }
}

- (void)setSearchMeByMobile:(UISwitch *)sender {
    __weak typeof(self) weakSelf = self;
    [RCDUserInfoManager setSearchMeByMobile:sender.on
                                   complete:^(BOOL success) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (success) {
                                               [weakSelf.view showHUDMessage:RCDLocalizedString(@"setting_success")];
                                           } else {
                                               sender.on = !sender.on;
                                               [weakSelf.view showHUDMessage:RCDLocalizedString(@"SetFailure")];
                                           }
                                       });
                                   }];
}

- (void)setSearchMeBySTAccount:(UISwitch *)sender {
    __weak typeof(self) weakSelf = self;
    [RCDUserInfoManager setSearchMeBySTAccount:sender.on
                                      complete:^(BOOL success) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (success) {
                                                  [weakSelf.view showHUDMessage:RCDLocalizedString(@"setting_success")];
                                              } else {
                                                  sender.on = !sender.on;
                                                  [weakSelf.view showHUDMessage:RCDLocalizedString(@"SetFailure")];
                                              }
                                          });
                                      }];
}

- (void)setAddFriendVerify:(UISwitch *)sender {
    __weak typeof(self) weakSelf = self;
    [RCDUserInfoManager setAddFriendVerify:sender.on
                                  complete:^(BOOL success) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if (success) {
                                              [weakSelf.view showHUDMessage:RCDLocalizedString(@"setting_success")];
                                          } else {
                                              sender.on = !sender.on;
                                              [weakSelf.view showHUDMessage:RCDLocalizedString(@"SetFailure")];
                                          }
                                      });
                                  }];
}

- (void)setJoinGroupVerify:(UISwitch *)sender {
    __weak typeof(self) weakSelf = self;
    [RCDUserInfoManager setJoinGroupVerify:sender.on
                                  complete:^(BOOL success) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if (success) {
                                              [weakSelf.view showHUDMessage:RCDLocalizedString(@"setting_success")];
                                          } else {
                                              sender.on = !sender.on;
                                              [weakSelf.view showHUDMessage:RCDLocalizedString(@"SetFailure")];
                                          }
                                      });
                                  }];
}
@end
