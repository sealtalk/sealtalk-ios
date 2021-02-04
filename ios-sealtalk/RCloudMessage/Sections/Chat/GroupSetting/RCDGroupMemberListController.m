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
@interface RCDGroupMemberListController () <UISearchResultsUpdating>
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) UISearchController *searchController;
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
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                             target:self
                                                                             action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;

    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
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
    return 55.0;
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
            [friend.displayName.lowercaseString containsString:searchString] ||
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
- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        //提醒字眼
        _searchController.searchBar.placeholder = NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil);
        //设置顶部搜索栏的背景色
        _searchController.searchBar.barTintColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
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
