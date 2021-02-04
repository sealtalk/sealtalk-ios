//
//  RCDGroupLeftUserListController.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupLeftUserListController.h"
#import "RCDGroupLeftUserListCell.h"
#import "RCDUserInfoManager.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDPersonDetailViewController.h"
#import "RCDGroupManager.h"
@interface RCDGroupLeftUserListController ()
@property (nonatomic, strong) NSArray *userlist;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation RCDGroupLeftUserListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"LeaveMembers");
    [self getUserList];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userlist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupLeftUserListCell *cell = [RCDGroupLeftUserListCell cellWithTableView:tableView];
    [cell setDataModel:self.userlist[indexPath.row] groupId:self.groupId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupLeftMember *member = self.userlist[indexPath.row];
    UIViewController *vc = [RCDPersonDetailViewController configVC:member.userId groupId:self.groupId];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - helper
- (void)getUserList {
    self.userlist = [RCDGroupManager getGroupLeftMemberList:self.groupId];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getGroupLeftMemberListFromServer:self.groupId
                                             complete:^(NSArray<RCDGroupLeftMember *> *list) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     if (list) {
                                                         weakSelf.userlist = list;
                                                         [weakSelf reloadTableView];
                                                     }
                                                 });
                                             }];
}

- (void)reloadTableView {
    [self.tableView reloadData];
    [self reloadEmptyView];
}

- (void)reloadEmptyView {
    [self.emptyLabel removeFromSuperview];
    if (self.userlist.count == 0) {
        [self.tableView addSubview:self.emptyLabel];
    }
}

#pragma mark - getter
- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height / 2 - 60,
                                                                self.tableView.frame.size.width, 28)];
        _emptyLabel.text = RCDLocalizedString(@"GroupNotLeftMember");
        _emptyLabel.textColor = HEXCOLOR(0x939393);
        _emptyLabel.font = [UIFont systemFontOfSize:20];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        [self.tableView addSubview:_emptyLabel];
    }
    return _emptyLabel;
}
@end
