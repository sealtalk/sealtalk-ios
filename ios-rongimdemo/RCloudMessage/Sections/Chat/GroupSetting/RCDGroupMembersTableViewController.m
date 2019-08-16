//
//  RCDGroupMembersTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/4/10.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupMembersTableViewController.h"
#import "DefaultPortraitView.h"
#import "RCDAddFriendViewController.h"
#import "RCDContactTableViewCell.h"
#import "RCDPersonDetailViewController.h"
#import "RCDUIBarButtonItem.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "RCDGroupMemberCell.h"
#import "RCDGroupManager.h"
@interface RCDGroupMembersTableViewController()
@property (nonatomic, strong) NSString *groupId;
@end
@implementation RCDGroupMembersTableViewController
#pragma mark - life cycle
- (instancetype)initWithGroupId:(NSString *)groupId{
    if (self = [super init]) {
        self.groupId = groupId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.title = [NSString stringWithFormat:RCDLocalizedString(@"group_members_x"),(unsigned long)[self.groupMembers count]];
    
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupMembers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupMemberCell *cell = [RCDGroupMemberCell cellWithTableView:tableView];
    [cell setDataModel:self.groupMembers[indexPath.row]];
    if ([self.groupMembers[indexPath.row] isEqualToString:[RCDGroupManager getGroupOwner:self.groupId]]) {
        [cell setUserRole:RCDLocalizedString(@"GroupOwner")];
    }else if([[RCDGroupManager getGroupManagers:self.groupId] containsObject:self.groupMembers[indexPath.row]]){
        [cell setUserRole:RCDLocalizedString(@"GroupManager")];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCUserInfo *user = [RCDUserInfoManager getUserInfo:self.groupMembers[indexPath.row]];
    RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:self.groupMembers[indexPath.row]];
    if ((friendInfo != nil && (friendInfo.status == RCDFriendStatusAgree || friendInfo.status == RCDFriendStatusBlock)) || [user.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]){
        RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
        [self.navigationController pushViewController:detailViewController animated:YES];
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:self.groupMembers[indexPath.row]];
        detailViewController.userId = user.userId;
    } else {
        RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
        addViewController.targetUserInfo = [RCDUserInfoManager getUserInfo:self.groupMembers[indexPath.row]];
        [self.navigationController pushViewController:addViewController animated:YES];
    }
}

#pragma mark - target action
- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
