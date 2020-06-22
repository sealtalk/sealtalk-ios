//
//  SecondViewController.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDGroupViewController.h"
#import "RCDChatViewController.h"
#import "RCDGroupManager.h"
#import "RCDGroupTableViewCell.h"
#import "UIColor+RCColor.h"

@interface RCDGroupViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation RCDGroupViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    [self setupNavi];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

#pragma mark - Private Method
- (void)loadData {
    self.groups = [NSMutableArray arrayWithArray:[RCDGroupManager getMyGroupList]];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getMyGroupListFromServer:^(NSArray<RCDGroupInfo *> *_Nonnull groupList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (groupList) {
                weakSelf.groups = groupList.mutableCopy;
            }
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //设置tableView样式
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
}

- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"group");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCDGroupInfo *groupInfo = self.groups[indexPath.row];
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.targetId = groupInfo.groupId;
    chatVC.conversationType = ConversationType_GROUP;
    chatVC.userName = groupInfo.groupName;
    chatVC.title = groupInfo.groupName;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RCDGroupCell";
    RCDGroupTableViewCell *cell = (RCDGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[RCDGroupTableViewCell alloc] init];
    }

    RCDGroupInfo *group = self.groups[indexPath.row];
    [cell setModel:group];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCDGroupTableViewCell cellHeight];
}

@end
