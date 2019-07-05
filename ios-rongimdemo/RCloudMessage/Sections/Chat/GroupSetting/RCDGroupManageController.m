//
//  RCDGroupManageController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupManageController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDGroupManagerListController.h"
#import "RCDGroupSelectNewOwnerController.h"
#import "RCDGroupManager.h"
@interface RCDGroupManageController ()
@property (nonatomic, strong) NSArray *managers;
@end

@implementation RCDGroupManageController
- (instancetype)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"GroupManage");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.backgroundColor = HEXCOLOR(0xf2f2f3);
    
    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCDBaseSettingTableViewCellIdentifier"];
    if (!cell) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.leftLabel.text = RCDLocalizedString(@"GroupSetManager");
        [cell setCellStyle:DefaultStyle_RightLabel];
        cell.rightLabel.text = [NSString stringWithFormat:@"%lu/5",(unsigned long)self.managers.count];
    }else{
        cell.leftLabel.text = RCDLocalizedString(@"GroupTransferOwner");
        [cell setCellStyle:DefaultStyle];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 43;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self pushGroupManagerListVC];
    }else{
        [self pushSelectNewOwnerVC];
    }
}

#pragma mark - helper
- (void)pushGroupManagerListVC{
    RCDGroupManagerListController *groupManagerListVC = [[RCDGroupManagerListController alloc] init];
    groupManagerListVC.groupId = self.groupId;
    [self.navigationController pushViewController:groupManagerListVC animated:YES];
}

- (void)pushSelectNewOwnerVC{
    RCDGroupSelectNewOwnerController *selectNewOwnerVC = [[RCDGroupSelectNewOwnerController alloc] initWithGroupId:self.groupId];
    [self.navigationController pushViewController:selectNewOwnerVC animated:YES];
}

- (void)refreshData{
    self.managers = [RCDGroupManager getGroupManagers:self.groupId];
    [self.tableView reloadData];
}
@end
