//
//  RCDGroupMembersTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/4/10.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupMemberListController.h"
#import "RCDContactTableViewCell.h"
#import "RCDPersonDetailViewController.h"
#import "RCDUIBarButtonItem.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "RCDGroupMemberCell.h"
#import "RCDGroupManager.h"
#import "RCDSearchController.h"
@interface RCDGroupMemberListController () <UISearchResultsUpdating>
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) RCDSearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResultList;
@end
@implementation RCDGroupMemberListController
#pragma mark - life cycle
- (instancetype)initWithGroupId:(NSString *)groupId {
    if (self = [super init]) {
        self.groupId = groupId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title =
        [NSString stringWithFormat:RCDLocalizedString(@"group_members_x"), (unsigned long)[self.groupMembers count]];

    self.navigationItem.leftBarButtonItems = [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];

    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 59, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 59, 0, 0)];
    }

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.searchResultList.count;
    }
    return self.groupMembers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupMemberCell *cell = [RCDGroupMemberCell cellWithTableView:tableView];
    NSString *userId = self.groupMembers[indexPath.row];
    if (self.searchController.active) {
        userId = self.searchResultList[indexPath.row];
    }
    [cell setDataModel:userId groupId:self.groupId];
    if ([userId isEqualToString:[RCDGroupManager getGroupOwner:self.groupId]]) {
        [cell setUserRole:RCDLocalizedString(@"GroupOwner")];
    } else if ([[RCDGroupManager getGroupManagers:self.groupId] containsObject:userId]) {
        [cell setUserRole:RCDLocalizedString(@"GroupManager")];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.searchController.active) {
        return NO;
    }
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.searchController.active) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 8);
    view.backgroundColor = RCDYCOLOR(0xffffff, 0x191919);
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userId = self.groupMembers[indexPath.row];
    if (self.searchController.active) {
        userId = self.searchResultList[indexPath.row];
    }
    UIViewController *vc = [RCDPersonDetailViewController configVC:userId groupId:self.groupId];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UISearchController Delegate -
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //谓词搜索过滤
    NSString *searchString = [self.searchController.searchBar text].lowercaseString;
    [self.searchResultList removeAllObjects];
    for (NSString *userId in self.groupMembers) {
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
        RCDGroupMember *member = [RCDGroupManager getGroupMember:userId groupId:self.groupId];
        if ([user.name.lowercaseString containsString:searchString] ||
            [friend.alias.lowercaseString containsString:searchString] ||
            [member.groupNickname containsString:searchString]) {
            [self.searchResultList addObject:userId];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - target action
- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter
- (RCDSearchController *)searchController {
    if (!_searchController) {
        _searchController = [[RCDSearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
    }
    return _searchController;
}

- (NSMutableArray *)searchResultList {
    if (!_searchResultList) {
        _searchResultList = [NSMutableArray array];
    }
    return _searchResultList;
}
@end
