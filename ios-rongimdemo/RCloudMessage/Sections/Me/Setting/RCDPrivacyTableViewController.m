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

@interface RCDPrivacyTableViewController ()

@end

@implementation RCDPrivacyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = RCDLocalizedString(@"privacy");

    self.tableView.tableFooterView = [UIView new];

    self.tableView.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    [cell setCellStyle:DefaultStyle];
    cell.leftLabel.text = RCDLocalizedString(@"blacklist");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBlackListViewController *vc = [[RCDBlackListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
