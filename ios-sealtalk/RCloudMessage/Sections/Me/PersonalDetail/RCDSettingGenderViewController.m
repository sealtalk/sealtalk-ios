//
//  RCDSettingGenderViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDSettingGenderViewController.h"
#import "UIColor+RCColor.h"
#import "RCDCommonString.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "UIView+MBProgressHUD.h"

#define RCDSettingGenderCellIdentifier @"RCDSettingGenderCell"

@interface RCDSettingGenderViewController ()

@property (nonatomic, assign) NSInteger selectedGender;

@end

@implementation RCDSettingGenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *gender = [DEFAULTS stringForKey:RCDUserGenderKey];
    if (!gender || [gender isEqualToString:@"male"]) {
        self.selectedGender = 0;
    } else {
        self.selectedGender = 1;
    }
    [self setNavi];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RCDSettingGenderCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    cell.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                    darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    cell.textLabel.textColor = RCDDYCOLOR(0x000000, 0x999999);
    cell.textLabel.text = indexPath.row == 0 ? RCDLocalizedString(@"male") : RCDLocalizedString(@"female");
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.selectedGender == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedGender = indexPath.row;
    [self.tableView reloadData];
}

#pragma mark - Target Action
- (void)save {
    NSString *gender = self.selectedGender == 0 ? @"male" : @"female";
    [RCDUserInfoManager setGender:gender
                         complete:^(BOOL success) {
                             rcd_dispatch_main_async_safe(^{
                                 if (success) {
                                     [DEFAULTS setObject:gender forKey:RCDUserGenderKey];
                                     [self.navigationController popViewControllerAnimated:YES];
                                     [self.view showHUDMessage:RCDLocalizedString(@"setting_success")];
                                 } else {
                                     [self.view showHUDMessage:RCDLocalizedString(@"set_fail")];
                                 }
                             });
                         }];
}

#pragma mark - Private Method
- (void)setNavi {
    self.title = RCDLocalizedString(@"Gender");
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"save")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(save)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

@end
