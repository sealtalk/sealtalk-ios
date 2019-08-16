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
#import <Masonry/Masonry.h>
#import "RCDUtilities.h"
#import "UIView+MBProgressHUD.h"
#import <RongIMKit/RongIMKit.h>
#import "NormalAlertView.h"
#define AllMuteTag  300
#define GroupAuthTag 301
@interface RCDGroupManageController ()<RCDBaseSettingTableViewCellDelegate>
@property (nonatomic, strong) NSArray *managers;
@property (nonatomic, strong) NSArray *sectionData;
@property (nonatomic, strong) NSArray *footerTitles;
@property (nonatomic, strong) RCDGroupInfo *group;
@end

@implementation RCDGroupManageController

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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.sectionData[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RCDBaseSettingTableViewCellIdentifier"];
    if (!cell) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *title = self.sectionData[indexPath.section][indexPath.row];
    cell.leftLabel.text = title;
    if ([title isEqualToString:RCDLocalizedString(@"GroupSetManager")]) {
        [cell setCellStyle:DefaultStyle_RightLabel];
        cell.rightLabel.text = [NSString stringWithFormat:@"%lu/5",(unsigned long)self.managers.count];
        
    }else if ([title isEqualToString:RCDLocalizedString(@"GroupTransferOwner")]){
        [cell setCellStyle:DefaultStyle];
        
    }else if ([title isEqualToString:RCDLocalizedString(@"AllMute")]){
        [cell setCellStyle:SwitchStyle];
        cell.switchButton.tag = AllMuteTag;
        cell.switchButton.on = self.group.mute;
    }else if ([title isEqualToString:RCDLocalizedString(@"isOpenGroupAuth")]){
        [cell setCellStyle:SwitchStyle];
        cell.switchButton.tag = GroupAuthTag;
        cell.switchButton.on = self.group.needCertification;
    }
    cell.baseSettingTableViewDelegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    NSString *footerTip = self.footerTitles[section];
    if (footerTip.length == 0) {
        return 0;
    }else{
        return [RCDUtilities getStringHeight:footerTip font:[UIFont systemFontOfSize:14] viewWidth:self.view.frame.size.width-24]+12;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];
    NSString *footerTip = self.footerTitles[section];
    if (footerTip.length > 0) {
        UILabel *label = [[UILabel alloc] init];
        [view addSubview:label];
        label.backgroundColor = HEXCOLOR(0xf2f2f3);
        label.textColor = HEXCOLOR(0x939393);
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 0;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view).offset(6);
            make.left.equalTo(view).offset(12);
            make.right.equalTo(view).offset(-12);
        }];
        label.text = footerTip;
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = self.sectionData[indexPath.section][indexPath.row];
    if ([title isEqualToString:RCDLocalizedString(@"GroupSetManager")]) {
        [self pushGroupManagerListVC];
        
    }else if ([title isEqualToString:RCDLocalizedString(@"GroupTransferOwner")]){
        [self pushSelectNewOwnerVC];
        
    }
}
#pragma mark - RCDBaseSettingTableViewCellDelegate
- (void)onClickSwitchButton:(id)sender{
    UISwitch *swit = (UISwitch *)sender;
    if (swit.tag == AllMuteTag) {
        [self setGroupMute:swit];
    }else if (swit.tag == GroupAuthTag){
        if (swit.on == NO) {
            [NormalAlertView showAlertWithTitle:nil message:RCDLocalizedString(@"CloseGroupCerTipInfo") highlightText:nil describeTitle:nil leftTitle:RCDLocalizedString(@"cancel") rightTitle:RCDLocalizedString(@"confirm") cancel:^{
                swit.on = YES;
            } confirm:^{
                [self setGroupAuth:swit];
            }];
        }else{
            [self setGroupAuth:swit];
        }
    }
}

#pragma mark - helper
- (void)setGroupMute:(UISwitch *)sender{
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager setGroupAllMute:sender.on groupId:self.groupId complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [weakSelf.view showHUDMessage:RCDLocalizedString(@"setting_success")];
            }else{
                sender.on = !sender.on;
                [weakSelf.view showHUDMessage:RCDLocalizedString(@"SetFailure")];
            }
        });
    }];
}

- (void)setGroupAuth:(UISwitch *)sender{
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager setGroupCertification:sender.on groupId:self.groupId complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [weakSelf.view showHUDMessage:RCDLocalizedString(@"setting_success")];
            }else{
                sender.on = !sender.on;
                [weakSelf.view showHUDMessage:RCDLocalizedString(@"SetFailure")];
            }
        });
    }];
}

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
    self.group = [RCDGroupManager getGroupInfo:self.groupId];
    self.managers = [RCDGroupManager getGroupManagers:self.groupId];
    if ([self.managers containsObject:[RCIM sharedRCIM].currentUserInfo.userId]) {
        self.sectionData = @[@[RCDLocalizedString(@"AllMute")]];
        self.footerTitles = @[RCDLocalizedString(@"AllMuteTip")];
    }else{
        self.sectionData = @[@[RCDLocalizedString(@"GroupSetManager"),RCDLocalizedString(@"GroupTransferOwner")],
                             @[RCDLocalizedString(@"AllMute")],
                             @[RCDLocalizedString(@"isOpenGroupAuth")]];
        self.footerTitles = @[@"",
                              RCDLocalizedString(@"AllMuteTip"),
                              RCDLocalizedString(@"isOpenGroupAuthTip")];
    }
    [self.tableView reloadData];
}
@end
