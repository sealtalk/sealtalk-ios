//
//  RCDGroupNoticeListController.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupNoticeListController.h"
#import "RCDGroupManager.h"
#import "UIView+MBProgressHUD.h"
#import "RCDGroupNoticeCell.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDCommonString.h"
#import "NormalAlertView.h"
#import "RCDGroupNotificationMessage.h"
@interface RCDGroupNoticeListController () <RCDGroupNoticeCellDelegate>
@property (nonatomic, strong) NSArray *noticeList;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation RCDGroupNoticeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"GroupNoti");
    [self regiterNotification];
    [self setNaviItem];
    [self getData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.noticeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupNoticeCell *cell = [RCDGroupNoticeCell cellWithTableView:tableView];
    [cell setDataModel:self.noticeList[indexPath.row]];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}
#pragma mark - RCDGroupNoticeCellDelegate
- (void)didClickAgreeButton:(RCDGroupNoticeCell *)cell {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager
        setGroupApproveAction:(RCDGroupInviteActionTypeAgree)
                     targetId:cell.notice.targetId
                      groupId:cell.notice.groupId
                     complete:^(BOOL success) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                             if (success) {
                                 [cell reloadCell:RCDGroupInviteStatusAgreed];
                                 if (cell.notice.noticeType == RCDGroupNoticeTypeInviteeApproving) {
                                     [RCDGroupManager
                                         getGroupMembersFromServer:cell.notice.groupId
                                                          complete:^(NSArray<NSString *> *memberIdList) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  if (!memberIdList) {
                                                                      [NormalAlertView
                                                                          showAlertWithTitle:nil
                                                                                     message:RCDLocalizedString(
                                                                                                 @"GroupNoticeAgreeTip")
                                                                               describeTitle:nil
                                                                                confirmTitle:RCDLocalizedString(
                                                                                                 @"confirm")
                                                                                     confirm:^{
                                                                                     }];
                                                                  }
                                                              });
                                                          }];
                                 }
                             } else {
                                 [weakSelf.view showHUDMessage:RCDLocalizedString(@"Failed")];
                             }
                         });
                     }];
}

- (void)didClickIgnoreButton:(RCDGroupNoticeCell *)cell {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager setGroupApproveAction:(RCDGroupInviteActionTypeIgnore)
                                  targetId:cell.notice.targetId
                                   groupId:cell.notice.groupId
                                  complete:^(BOOL success) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                          if (success) {
                                              [cell reloadCell:RCDGroupInviteStatusIgnored];
                                          } else {
                                              [weakSelf.view showHUDMessage:RCDLocalizedString(@"Failed")];
                                          }
                                      });
                                  }];
}

#pragma mark - helper
- (void)regiterNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGroupNotice)
                                                 name:RCDGroupNoticeUpdateKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGroupMemberUpdateNotification:)
                                                 name:RCDGroupMemberUpdateKey
                                               object:nil];
}

- (void)didGroupMemberUpdateNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.object;
    NSString *operation = dic[@"operation"];
    if (operation && ![operation isEqualToString:RCDGroupRename] && ![operation isEqualToString:RCDGroupBulletin]) {
        [self getData];
    }
}

- (void)getData {
    self.noticeList = [RCDGroupManager getGroupNoticeList];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getGroupNoticeListFromServer:^(NSArray<RCDGroupNotice *> *noticeList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.noticeList = noticeList;
            [weakSelf.tableView reloadData];
            [weakSelf reloadEmptyView];
        });
    }];
}

- (void)updateGroupNotice {
    self.noticeList = [RCDGroupManager getGroupNoticeList];
    [self.tableView reloadData];
    [self reloadEmptyView];
}

- (void)reloadEmptyView {
    [self.emptyLabel removeFromSuperview];
    if (self.noticeList.count == 0) {
        [self.tableView addSubview:self.emptyLabel];
    }
}

- (void)setNaviItem {
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"config"]
                                                                style:(UIBarButtonItemStylePlain)
                                                               target:self
                                                               action:@selector(didTapRightNaviBar)];
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)didTapRightNaviBar {
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:RCDLocalizedString(@"ClearGroupInviteListInfo")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *_Nonnull action) {
                                                            [self clearGroupNoticeList];
                                                        }];
    [RCKitUtility showAlertController:nil
                              message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet
                              actions:@[ cancelAction, clearAction ]
                     inViewController:self];
}

- (void)clearGroupNoticeList {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager clearGroupNoticeList:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (success) {
                weakSelf.noticeList = nil;
                [weakSelf.tableView reloadData];
                [weakSelf reloadEmptyView];
                [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE
                                                         targetId:RCDGroupNoticeTargetId];
            } else {
                [weakSelf.view showHUDMessage:RCDLocalizedString(@"Failed")];
            }
        });
    }];
}

#pragma mark - getter
- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height / 2 - 60,
                                                                self.tableView.frame.size.width, 28)];
        _emptyLabel.text = RCDLocalizedString(@"GroupNotiListEmpty");
        _emptyLabel.textColor = HEXCOLOR(0x939393);
        _emptyLabel.font = [UIFont systemFontOfSize:20];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        [self.tableView addSubview:_emptyLabel];
    }
    return _emptyLabel;
}
@end
