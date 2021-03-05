//
//  RCDSettingViewController.m
//  SealTalk
//
//  Created by 张改红 on 2020/7/23.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDSettingViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDUIBarButtonItem.h"
#import "RCDIMService.h"
#import <RongIMKit/RongIMKit.h>
static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";
@interface RCDSettingViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *clearLoadingView;
@end

@implementation RCDSettingViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNaviItem];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
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
            [[RCIMClient sharedRCIMClient] getConversation:self.conversationType targetId:self.targetId];
            cell.switchButton.on = currentConversation.isTop;
            [cell.switchButton addTarget:self
                                  action:@selector(clickIsTopBtn:)
                        forControlEvents:UIControlEventValueChanged];
        } break;
        case 2:{
            [cell setCellStyle:DefaultStyle];
            cell.leftLabel.text = RCDLocalizedString(@"clear_chat_history");
            cell.switchButton.hidden = YES;
        }break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        //清理历史消息
        [RCActionSheetView showActionSheetView:RCDLocalizedString(@"clear_chat_history_alert") cellArray:@[RCDLocalizedString(@"confirm")] cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
            [self clearHistoryMessage];
        } cancelBlock:^{
            
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - RCDUserListCollectionViewDelegate
- (void)clearHistoryMessage {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    RCDBaseSettingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self.clearLoadingView removeFromSuperview];
    [cell addSubview:self.clearLoadingView];
    [self.clearLoadingView startAnimating];
    __weak typeof(self) weakSelf = self;
    [[RCDIMService sharedService] clearHistoryMessage:self.conversationType
        targetId:weakSelf.targetId
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
- (void)setNaviItem {
    self.title = RCDLocalizedString(@"chat_detail");
    [self.navigationItem setLeftBarButtonItems:[RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(leftBarButtonItemPressed)]];
}

- (void)leftBarButtonItemPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertMessage:(NSString *)msg {
    [RCAlertView showAlertController:nil message:msg cancelTitle:RCDLocalizedString(@"confirm")];
}

- (void)clickNotificationBtn:(id)sender {
    UISwitch *swch = sender;
    RCConnectionStatus connectStatus = [[RCIM sharedRCIM] getConnectionStatus];
    if (connectStatus != ConnectionStatus_Connected) {
        swch.on = !swch.on;
        [RCAlertView showAlertController:nil message:RCDLocalizedString(@"Set failed") cancelTitle:RCDLocalizedString(@"confirm")];
        return;
    }
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:self.conversationType
        targetId:self.targetId
        isBlocked:swch.on
        success:^(RCConversationNotificationStatus nStatus) {
        }
        error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                swch.on = !swch.on;
            });
        }];
}

- (void)clickIsTopBtn:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:self.conversationType targetId:self.targetId isTop:swch.on];
}

- (void)setCurrentNotificationStatus:(UISwitch *)switchButton {
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:self.conversationType
        targetId:self.targetId
        success:^(RCConversationNotificationStatus nStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switchButton.on = !nStatus;
            });
        }
        error:^(RCErrorCode status){

        }];
}

#pragma mark - getter & setter
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
