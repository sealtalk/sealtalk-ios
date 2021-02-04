//
//  RCDGroupManagerListController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupManagerListController.h"
#import "RCDGroupManager.h"
#import "RCDGroupManagerCell.h"
#import "NormalAlertView.h"
#import "RCDUserInfoManager.h"
#import "RCDGroupMemberSelectController.h"
#import "RCDCommonString.h"
#import "UIView+MBProgressHUD.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDUtilities.h"
@interface RCDGroupManagerListController () <RCDGroupManagerCellDelegate>
@property (nonatomic, strong) NSArray *managers;
@end

@implementation RCDGroupManagerListController
- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"GroupManagerTitle");
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    [self registerNotification];
    [self refreshData];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (self.managers.count < 5) {
        return self.managers.count + 1;
    }
    return self.managers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupManagerCell *cell = [RCDGroupManagerCell cellWithTableView:tableView];
    if (indexPath.section == 0) {
        [cell setDataModel:[RCDGroupManager getGroupOwner:self.groupId] groupId:self.groupId];
    } else if (indexPath.section == 1 && indexPath.row < self.managers.count) {
        [cell setDataModel:self.managers[indexPath.row] groupId:self.groupId];
        [cell deleteButtonShow];
        cell.delegate = self;
    } else {
        [cell setDataModel:@"" groupId:self.groupId];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    label.textColor = RCDDYCOLOR(0x939393, 0x666666);
    label.font = [UIFont systemFontOfSize:14];
    if (section == 0) {
        label.text = [NSString stringWithFormat:@"   %@", RCDLocalizedString(@"GroupOwner")];
    } else {
        label.text = [NSString stringWithFormat:@"   %@(%lu/5)", RCDLocalizedString(@"GroupManagerTitle"),
                                                (unsigned long)self.managers.count];
    }
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == self.managers.count) {
        [self pushSelectManagerVC];
    }
}

#pragma mark - RCDGroupManagerCellDelegate
- (void)didSelectUserId:(NSString *)userId {
    RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
    RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:user.userId];
    NSString *name = user.name;
    if (friend.displayName.length > 0) {
        name = friend.displayName;
    }
    [NormalAlertView
        showAlertWithMessage:[NSString stringWithFormat:RCDLocalizedString(@"GroupManagerDeleteTitle"), name]
        highlightText:name
        leftTitle:RCDLocalizedString(@"cancel")
        rightTitle:RCDLocalizedString(@"confirm")
        cancel:^{

        }
        confirm:^{
            [self deleteGroupManager:userId];
        }];
}

- (void)deleteGroupManager:(NSString *)userId {

    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        [self.view showHUDMessage:RCDLocalizedString(@"network_can_not_use_please_check")];
        return;
    }

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //删除管理员
    [RCDGroupManager removeGroupManagers:@[ userId ]
                                 groupId:self.groupId
                                complete:^(BOOL success) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        if (success) {
                                            NSMutableArray *array = self.managers.mutableCopy;
                                            [array removeObject:userId];
                                            self.managers = array.copy;
                                            [self.tableView reloadData];

                                        } else {
                                            [self.view showHUDMessage:RCDLocalizedString(@"Failed")];
                                        }
                                    });
                                }];
}

- (void)pushSelectManagerVC {
    RCDGroupMemberSelectController *selectVC =
        [[RCDGroupMemberSelectController alloc] initWithGroupId:self.groupId type:(RCDGroupMemberSelectTypeAddManager)];
    [self.navigationController pushViewController:selectVC animated:YES];
}

- (void)refreshData {
    self.managers = [RCDGroupManager getGroupManagers:self.groupId];
    [self.tableView reloadData];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGroupMemberUpdateNotification:)
                                                 name:RCDGroupMemberUpdateKey
                                               object:nil];
}

- (void)didGroupMemberUpdateNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.object;
    if ([dic[@"targetId"] isEqualToString:self.groupId]) {
        [self refreshData];
    }
}
@end
