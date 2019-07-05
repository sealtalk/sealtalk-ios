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
static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";

@interface RCDPrivateSettingsTableViewController ()<RCDUserListCollectionViewDelegate>
@property (nonatomic, strong) RCDUserListCollectionView *headerView;
@property (nonatomic, strong) RCDFriendInfo *userInfo;
@end

@implementation RCDPrivateSettingsTableViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = HEXCOLOR(0xf0f0f6);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setNaviItem];
    [self loadUserInfo];
    [self setTableHeader];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
    case 0:
        rows = 1;
        break;
    case 1:
        rows = 3;
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
            RCConversation *currentConversation = [[RCIMClient sharedRCIMClient] getConversation:ConversationType_PRIVATE targetId:self.userId];
            cell.switchButton.on = currentConversation.isTop;
            [cell.switchButton addTarget:self
                                  action:@selector(clickIsTopBtn:)
                        forControlEvents:UIControlEventValueChanged];
        } break;

        case 2: {
            [cell setCellStyle:SwitchStyle];
            cell.leftLabel.text = RCDLocalizedString(@"clear_chat_history");
            cell.switchButton.hidden = YES;
        } break;

        default:
            break;
        }

        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self pushSearchHistoryVC];
    }
    if (indexPath.section == 1 && indexPath.row == 2) {
        //清理历史消息
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:RCDLocalizedString(@"clear_chat_history_alert") delegate:self cancelButtonTitle:RCDLocalizedString(@"cancel") destructiveButtonTitle:RCDLocalizedString(@"confirm") otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        actionSheet.tag = 100;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - RCDUserListCollectionViewDelegate
- (void)didTipHeaderClicked:(NSString *)userId{
    RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:userId];
    if ((friendInfo != nil && friendInfo.status == RCDFriendStatusAgree) || [userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]){
        RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
        detailViewController.userId = userId;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
        RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
        addViewController.targetUserInfo = user;
        [self.navigationController pushViewController:addViewController animated:YES];
    }
}

- (void)addButtonDidClicked{
    RCDContactSelectedTableViewController *contactSelectedVC = [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"select_contact") isAllowsMultipleSelection:YES];
    contactSelectedVC.orignalGroupMembers = @[self.userInfo].mutableCopy;
    contactSelectedVC.groupOptionType = RCDContactSelectedGroupOptionTypeCreate;
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}


#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RCDBaseSettingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIActivityIndicatorView *activityIndicatorView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        float cellWidth = cell.bounds.size.width;
        UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(cellWidth - 50, 15, 40, 40)];
        [loadingView addSubview:activityIndicatorView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicatorView startAnimating];
            [cell addSubview:loadingView];
        });
        __weak typeof(self) weakSelf = self;
        [[RCDIMService sharedService] clearHistoryMessage:ConversationType_PRIVATE targetId:weakSelf.userId successBlock:^{
            [weakSelf showAlertMessage:RCDLocalizedString(@"clear_chat_history_success")];
            weakSelf.clearMessageHistory();
            [loadingView removeFromSuperview];
            
        } errorBlock:^(RCErrorCode status) {
            [weakSelf showAlertMessage:RCDLocalizedString(@"clear_chat_history_fail")];
            [loadingView removeFromSuperview];
        }];
    }
}

#pragma mark - helper
- (void)setTableHeader{
    self.tableView.tableHeaderView = self.headerView;
    [self.headerView reloadData:@[self.userId]];
}

- (void)setNaviItem{
    self.title = RCDLocalizedString(@"chat_detail");
    RCDUIBarButtonItem *leftButton = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back") target:self                action:@selector(leftBarButtonItemPressed)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)leftBarButtonItemPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertMessage:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:RCDLocalizedString(@"confirm") otherButtonTitles:nil, nil];
    [alertView show];
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

                                                             }error:^(RCErrorCode status){

                                                             }];
}

- (void)clickIsTopBtn:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_PRIVATE targetId:self.userId isTop:swch.on];
}

- (void)setCurrentNotificationStatus:(UISwitch *)switchButton{
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:ConversationType_PRIVATE targetId:self.userId success:^(RCConversationNotificationStatus nStatus) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switchButton.on = !nStatus;
        });
    }error:^(RCErrorCode status){
        
    }];
}

- (void)pushSearchHistoryVC{
    RCDSearchHistoryMessageController *searchViewController = [[RCDSearchHistoryMessageController alloc] init];
    searchViewController.conversationType = ConversationType_PRIVATE;
    searchViewController.targetId = self.userId;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - getter & setter
- (RCDUserListCollectionView *)headerView{
    if (!_headerView) {
        CGRect tempRect =
        CGRectMake(0, 0, RCDScreenWidth, 100);
        _headerView = [[RCDUserListCollectionView alloc] initWithFrame:tempRect isAllowAdd:YES isAllowDelete:NO];
        _headerView.userListCollectionViewDelegate = self;
    }
    return _headerView;
}
@end
