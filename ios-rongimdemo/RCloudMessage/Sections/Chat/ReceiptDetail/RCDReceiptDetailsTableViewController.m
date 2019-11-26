//
//  RCDReceiptDetailsTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/9/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDReceiptDetailsTableViewController.h"
#import "RCDPersonDetailViewController.h"
#import "RCDReceiptDetailsTableViewCell.h"
#import "RCDUIBarButtonItem.h"
#import "RCDDBManager.h"
#import "RCDUserInfoManager.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import "RCDReceiptDetailHeader.h"
#import "RCDUserListCollectionView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDGroupManager.h"
#define CellHeight 44
@interface RCDReceiptDetailsTableViewController () <RCDReceiptDetailsCellDelegate, RCDReceiptDetailHeaderDelegate,
                                                    RCDUserListCollectionViewDelegate>

@property (nonatomic, strong) RCDReceiptDetailHeader *headerMessageContentView;

@property (nonatomic, strong) RCDUserListCollectionView *footerUserListView;
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
    self.tableView.tableHeaderView = self.headerMessageContentView;
    self.tableView.tableFooterView = self.footerUserListView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDReceiptDetailsTableViewCell *cell = [RCDReceiptDetailsTableViewCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.hasReadUsersCount = self.hasReadUserList.count;
    cell.unreadUsersCount = self.unreadUserList.count;
    return cell;
}

#pragma mark - RCDReceiptDetailsCellDelegate
- (void)clickHasReadButton {
    [self.footerUserListView reloadData:self.hasReadUserList];
}

- (void)clickUnreadButton {
    [self.footerUserListView reloadData:self.unreadUserList];
}

#pragma mark - RCDReceiptDetailHeaderDelegate
- (void)receiptDetailHeaderDidUpdate:(BOOL)isClosed {
    self.tableView.scrollEnabled = !isClosed;
    self.tableView.tableHeaderView = self.headerMessageContentView;
    CGRect rect = self.footerUserListView.frame;
    rect.size.height = self.tableView.frame.size.height - self.headerMessageContentView.frame.size.height - CellHeight;
    self.tableView.tableFooterView = self.footerUserListView;
}

#pragma mark - RCDUserListCollectionViewDelegate
- (void)didTipHeaderClicked:(NSString *)userId {
    if (self.message.conversationType == ConversationType_GROUP) {
        UIViewController *vc = [RCDPersonDetailViewController configVC:userId groupId:self.message.targetId];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIViewController *vc = [RCDPersonDetailViewController configVC:userId groupId:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - helper
- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNaviItem {
    self.navigationItem.title = RCDLocalizedString(@"Receipt_details");
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                             target:self
                                                                             action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (void)handleData {
    RCMessage *message = [[RCIMClient sharedRCIMClient] getMessageByUId:self.message.messageUId];
    NSMutableDictionary *readReceiptUserList = message.readReceiptInfo.userIdList;
    NSArray *hasReadUserList = [readReceiptUserList allKeys];
    if (hasReadUserList.count > 1) {
        hasReadUserList = [self sortForHasReadList:readReceiptUserList];
    }
    self.hasReadUserList = hasReadUserList;
    self.displayUserList = self.hasReadUserList;
    self.unreadUserList = [self getUnreadUserList];
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
- (RCDReceiptDetailHeader *)headerMessageContentView {
    if (!_headerMessageContentView) {
        _headerMessageContentView = [[RCDReceiptDetailHeader alloc] initWithMessage:self.message];
        _headerMessageContentView.delegate = self;
    }
    return _headerMessageContentView;
}

- (RCDUserListCollectionView *)footerUserListView {
    if (!_footerUserListView) {
        CGFloat height =
            self.tableView.frame.size.height - self.headerMessageContentView.frame.size.height - CellHeight;
        CGRect tempRect = CGRectMake(0, 0, RCDScreenWidth, height);
        _footerUserListView = [[RCDUserListCollectionView alloc] initWithFrame:tempRect isAllowAdd:NO isAllowDelete:NO];
        if (self.message.conversationType == ConversationType_GROUP) {
            _footerUserListView.groupId = self.message.targetId;
        }
        _footerUserListView.userListCollectionViewDelegate = self;
        [_footerUserListView reloadData:self.hasReadUserList];
    }
    return _footerUserListView;
}
@end
