//
//  RCDPrivateSettingsTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/5/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDPrivateSettingsTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDSearchHistoryMessageController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUIBarButtonItem.h"
#import "RCDIMService.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "RCDUserListCollectionView.h"
#import "RCDPersonDetailViewController.h"
#import "RCDAddFriendViewController.h"
#import "RCDContactSelectedTableViewController.h"
#import "RCDTipFooterView.h"
#import "RCDDBManager.h"
#import "RCDChatManager.h"
#import "UIView+MBProgressHUD.h"

static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";

@interface RCDPrivateSettingsTableViewController () <RCDUserListCollectionViewDelegate>

@property (nonatomic, strong) RCDUserListCollectionView *headerView;
@property (nonatomic, strong) RCDFriendInfo *userInfo;
@property (nonatomic, strong) RCDTipFooterView *tipFooterView;
@property (nonatomic, strong) UIActivityIndicatorView *clearLoadingView;

@end

@implementation RCDPrivateSettingsTableViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNaviItem];
    [self loadUserInfo];
    [self setTableHeader];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
    case 0:
        rows = 1;
        break;
    case 1:
        rows = 2;
        break;
    case 2:
        rows = 1;
        break;
    case 3:
        rows = 1;
        break;
    default:
        break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    if (indexPath.section == 0) {
        cell.leftLabel.text = RCDLocalizedString(@"search_chat_history");
        [cell setCellStyle:DefaultStyle];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == 1) {
        switch (indexPath.row) {
        case 0: {
            [cell setCellStyle:SwitchStyle];
            cell.leftLabel.text = RCDLocalizedString(@"mute_notifications");
            cell.switchButton.hidden = NO;
            [self setCurrentNotificationStatus:cell.switchButton];
            [cell.switchButton removeTarget:self
                                     action:@selector(clickIsTopBtn:)
                           forControlEvents:UIControlEventValueChanged];

            [cell.switchButton addTarget:self
                                  action:@selector(clickNotificationBtn:)
                        forControlEvents:UIControlEventValueChanged];

        } break;

        case 1: {
            [cell setCellStyle:SwitchStyle];
            cell.leftLabel.text = RCDLocalizedString(@"stick_on_top");
            cell.switchButton.hidden = NO;
            RCConversation *currentConversation =
                [[RCIMClient sharedRCIMClient] getConversation:ConversationType_PRIVATE targetId:self.userId];
            cell.switchButton.on = currentConversation.isTop;
            [cell.switchButton addTarget:self
                                  action:@selector(clickIsTopBtn:)
                        forControlEvents:UIControlEventValueChanged];
        } break;
        default:
            break;
        }
        return cell;
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [cell setCellStyle:SwitchStyle];
            cell.leftLabel.text = RCDLocalizedString(@"ScreenCaptureNotification");
            cell.switchButton.hidden = NO;
            [self setSwitchStatusWithTableViewCell:cell];
            [cell.switchButton addTarget:self
                                  action:@selector(screenCaptureSwitchButtonDidPressed:)
                        forControlEvents:UIControlEventValueChanged];
            return cell;
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [cell setCellStyle:DefaultStyle];
            cell.leftLabel.text = RCDLocalizedString(@"clear_chat_history");
            cell.switchButton.hidden = YES;
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self pushSearchHistoryVC];
    }
    if (indexPath.section == 3 && indexPath.row == 0) {
        //清理历史消息
        UIAlertAction *cancelAction =
            [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction *_Nonnull action) {
                                                                  [self clearHistoryMessage];
                                                              }];
        [RCKitUtility showAlertController:RCDLocalizedString(@"clear_chat_history_alert")
                                  message:nil
                           preferredStyle:UIAlertControllerStyleActionSheet
                                  actions:@[ cancelAction, confirmAction ]
                         inViewController:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 3) {
        return 0;
    }
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return [self.tipFooterView
            heightForTipFooterViewWithTip:RCDLocalizedString(@"ScreenCaptureNotificationInfo")
                                     font:[UIFont fontWithName:@"PingFangSC-Regular" size:14]
                          constrainedSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 27, MAXFLOAT)];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        [self.tipFooterView renderWithTip:RCDLocalizedString(@"ScreenCaptureNotificationInfo")
                                     font:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
        return self.tipFooterView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - RCDUserListCollectionViewDelegate
- (void)didTipHeaderClicked:(NSString *)userId {
    RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:userId];
    if ((friendInfo != nil &&
         (friendInfo.status == RCDFriendStatusAgree || friendInfo.status == RCDFriendStatusBlock)) ||
        [userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
        detailViewController.userId = userId;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
        addViewController.targetUserId = userId;
        [self.navigationController pushViewController:addViewController animated:YES];
    }
}

- (void)addButtonDidClicked {
    RCDContactSelectedTableViewController *contactSelectedVC =
        [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"select_contact")
                                           isAllowsMultipleSelection:YES];
    contactSelectedVC.orignalGroupMembers = @[ self.userInfo ].mutableCopy;
    contactSelectedVC.groupOptionType = RCDContactSelectedGroupOptionTypeCreate;
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

- (void)clearHistoryMessage {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    RCDBaseSettingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self.clearLoadingView removeFromSuperview];
    [cell addSubview:self.clearLoadingView];
    [self.clearLoadingView startAnimating];
    __weak typeof(self) weakSelf = self;
    [[RCDIMService sharedService] clearHistoryMessage:ConversationType_PRIVATE
        targetId:weakSelf.userId
        successBlock:^{
            [weakSelf showAlertMessage:RCDLocalizedString(@"clear_chat_history_success")];
            weakSelf.clearMessageHistory();
            [self.clearLoadingView stopAnimating];
            [self.clearLoadingView removeFromSuperview];

        }
        errorBlock:^(RCErrorCode status) {
            [weakSelf showAlertMessage:RCDLocalizedString(@"clear_chat_history_fail")];
            [self.clearLoadingView stopAnimating];
            [self.clearLoadingView removeFromSuperview];
        }];
}

#pragma mark - helper
- (void)setTableHeader {
    self.tableView.tableHeaderView = self.headerView;
    [self.headerView reloadData:@[ self.userId ]];
}

- (void)setNaviItem {
    self.title = RCDLocalizedString(@"chat_detail");
    RCDUIBarButtonItem *leftButton =
        [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                   target:self
                                                   action:@selector(leftBarButtonItemPressed)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)leftBarButtonItemPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertMessage:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)loadUserInfo {
    if (![self.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        self.userInfo = [RCDUserInfoManager getFriendInfo:self.userId];
    }
}

- (void)clickNotificationBtn:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:ConversationType_PRIVATE
        targetId:self.userId
        isBlocked:swch.on
        success:^(RCConversationNotificationStatus nStatus) {

        }
        error:^(RCErrorCode status){

        }];
}

- (void)clickIsTopBtn:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_PRIVATE targetId:self.userId isTop:swch.on];
}

- (void)setCurrentNotificationStatus:(UISwitch *)switchButton {
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:ConversationType_PRIVATE
        targetId:self.userId
        success:^(RCConversationNotificationStatus nStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switchButton.on = !nStatus;
            });
        }
        error:^(RCErrorCode status){

        }];
}

- (void)pushSearchHistoryVC {
    RCDSearchHistoryMessageController *searchViewController = [[RCDSearchHistoryMessageController alloc] init];
    searchViewController.conversationType = ConversationType_PRIVATE;
    searchViewController.targetId = self.userId;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)screenCaptureSwitchButtonDidPressed:(id)sender {
    UISwitch *screenCaptureSwitch = (UISwitch *)sender;
    BOOL switchStatus = screenCaptureSwitch.on;
    [RCDChatManager setScreenCaptureNotification:switchStatus
                                conversationType:ConversationType_PRIVATE
                                        targetId:self.userId
                                        complete:^(BOOL result) {
                                            if (!result) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    screenCaptureSwitch.on = [RCDDBManager
                                                        getScreenCaptureNotification:ConversationType_PRIVATE
                                                                            targetId:self.userId];
                                                    ;
                                                });
                                            } else {
                                                [self showHUDMessage:RCDLocalizedString(@"setting_success")];
                                            }
                                        }];
}

- (void)showHUDMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDMessage:message];
    });
}

- (void)setSwitchStatusWithTableViewCell:(RCDBaseSettingTableViewCell *)cell {
    cell.switchButton.on = [RCDDBManager getScreenCaptureNotification:ConversationType_PRIVATE targetId:self.userId];
    [RCDChatManager getScreenCaptureNotification:ConversationType_PRIVATE
        targetId:self.userId
        complete:^(BOOL result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.switchButton.on = result;
            });
        }
        error:^{

        }];
}

#pragma mark - getter & setter
- (RCDUserListCollectionView *)headerView {
    if (!_headerView) {
        CGRect tempRect = CGRectMake(0, 0, RCDScreenWidth, 100);
        _headerView = [[RCDUserListCollectionView alloc] initWithFrame:tempRect isAllowAdd:YES isAllowDelete:NO];
        _headerView.userListCollectionViewDelegate = self;
    }
    return _headerView;
}

- (RCDTipFooterView *)tipFooterView {
    if (!_tipFooterView) {
        _tipFooterView = [[RCDTipFooterView alloc] init];
    }
    return _tipFooterView;
}

- (UIActivityIndicatorView *)clearLoadingView {
    if (!_clearLoadingView) {
        UIActivityIndicatorView *activityIndicatorView =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if (@available(iOS 13.0, *)) {
            activityIndicatorView =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        }
        activityIndicatorView.frame = CGRectMake(self.tableView.bounds.size.width - 55, 0, 44, 44);
        activityIndicatorView.frame = CGRectMake(self.tableView.bounds.size.width - 55, 0, 44, 44);
        _clearLoadingView = activityIndicatorView;
    }
    return _clearLoadingView;
}

@end
