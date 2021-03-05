//
//  RCDReceiptDetailsTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/9/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDReceiptDetailsTableViewController.h"
#import "RCDPersonDetailViewController.h"
#import "RCDReceiptDetailsHeaderView.h"
#import "RCDUIBarButtonItem.h"
#import "RCDDBManager.h"
#import "RCDUserInfoManager.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import "RCDUserListCollectionView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDGroupManager.h"
#import "RCDGroupMemberCell.h"
#define CellHeight 56
@interface RCDReceiptDetailsTableViewController () <RCDReceiptDetailsHeaderViewDelegate>

@property (nonatomic, strong) RCDReceiptDetailsHeaderView *headerView;

@property (nonatomic, strong) NSArray *displayUserList;

@property (nonatomic, strong) NSArray *hasReadUserList;

@property (nonatomic, strong) NSArray *unreadUserList;

@end

@implementation RCDReceiptDetailsTableViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviItem];
    [self handleData];
    self.tableView.tableHeaderView = self.headerView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayUserList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupMemberCell *cell = [RCDGroupMemberCell cellWithTableView:tableView];
    [cell setDataModel:self.displayUserList[indexPath.row] groupId:self.message.targetId];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self didTipHeaderClicked:self.displayUserList[indexPath.row]];
}

#pragma mark - RCDReceiptDetailsHeaderViewDelegate
- (void)clickHasReadButton {
    self.displayUserList = self.hasReadUserList;
    [self.tableView reloadData];
}

- (void)clickUnreadButton {
    self.displayUserList = self.unreadUserList;
    [self.tableView reloadData];
}

#pragma mark - helper
- (void)didTipHeaderClicked:(NSString *)userId {
    if (self.message.conversationType == ConversationType_GROUP) {
        UIViewController *vc = [RCDPersonDetailViewController configVC:userId groupId:self.message.targetId];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIViewController *vc = [RCDPersonDetailViewController configVC:userId groupId:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNaviItem {
    self.navigationItem.title = RCDLocalizedString(@"Receipt_details");
    self.navigationItem.leftBarButtonItems = [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];;
}

- (void)handleData {
    RCMessage *message = [[RCIMClient sharedRCIMClient] getMessageByUId:self.message.messageUId];
    NSMutableDictionary *readReceiptUserList = message.readReceiptInfo.userIdList;
    NSArray *hasReadUserList = [readReceiptUserList allKeys];
    if (hasReadUserList.count > 1) {
        hasReadUserList = [self sortForHasReadList:readReceiptUserList];
    }
    self.hasReadUserList = hasReadUserList;
    self.unreadUserList = [self getUnreadUserList];
    self.displayUserList = self.unreadUserList;
    [self.tableView reloadData];
}

- (NSArray *)getUnreadUserList {
    NSArray *userList;
    NSMutableArray *allUsers = [RCDDBManager getGroupMembers:self.message.targetId].mutableCopy;
    if ([RCIM sharedRCIM].currentUserInfo.userId) {
        [allUsers removeObject:[RCIM sharedRCIM].currentUserInfo.userId];
    }
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.hasReadUserList];
    userList = [allUsers filteredArrayUsingPredicate:filterPredicate];
    return userList;
}

- (NSArray *)sortForHasReadList:(NSDictionary *)readReceiptUserDic {
    NSArray *result;
    NSArray *sortedKeys = [readReceiptUserDic keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    result = [sortedKeys copy];
    return result;
}

#pragma mark - getter & setter
- (RCDReceiptDetailsHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[RCDReceiptDetailsHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44) hasReadCount:self.hasReadUserList.count unreadCount:self.unreadUserList.count];
        _headerView.delegate = self;
    }
    return _headerView;
}
@end
