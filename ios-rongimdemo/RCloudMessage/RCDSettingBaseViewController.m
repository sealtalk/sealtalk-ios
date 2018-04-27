//
//  RCDSettingBaseViewController.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDSettingBaseViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDUIBarButtonItem.h"
@interface RCDSettingBaseViewController () <UIActionSheetDelegate>
@end

@implementation RCDSettingBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //默认隐藏顶部视图
    self.headerHidden = YES;

    //设置switch状态
    [self setSwitchState];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Setting", @"RongCloudKit", nil); //@"设置";
    
    RCDUIBarButtonItem *leftButton = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:@"返回" target:self                    action:@selector(backBarButtonItemClicked:)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)backBarButtonItemClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setSwitchState {

    //设置新消息通知状态
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:self.conversationType
                                                            targetId:self.targetId
                                                             success:^(RCConversationNotificationStatus nStatus) {

                                                                 BOOL enableNotification = NO;
                                                                 if (nStatus == NOTIFY) {
                                                                     enableNotification = YES;
                                                                 }
                                                                 self.switch_newMessageNotify = enableNotification;

                                                             }
                                                               error:^(RCErrorCode status){

                                                               }];

    //设置置顶聊天状态
    RCConversation *conversation =
        [[RCIMClient sharedRCIMClient] getConversation:self.conversationType targetId:self.targetId];
    self.switch_isTop = conversation.isTop;
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickNewMessageNotificationSwitch:(id)sender {
    UISwitch *swch = sender;
    __weak RCDSettingBaseViewController *weakSelf = self;
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:self.conversationType
                                                            targetId:self.targetId
                                                           isBlocked:!swch.on
                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                 BOOL enableNotification = NO;
                                                                 if (nStatus == NOTIFY) {
                                                                     enableNotification = YES;
                                                                 }
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     weakSelf.switch_newMessageNotify =
                                                                         enableNotification;
                                                                 });

                                                             }
                                                               error:^(RCErrorCode status){

                                                               }];
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickClearMessageHistory:(id)sender {

    _clearMsgHistoryActionSheet =
        [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"IsDeleteHistoryMsg", @"RongCloudKit", nil)
                                    delegate:self
                           cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil)
                      destructiveButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                           otherButtonTitles:nil, nil];
    [_clearMsgHistoryActionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self clearHistoryMessage];
    }
}
- (void)clearHistoryMessage {
    
    BOOL __block isClear = false;
    __weak typeof(self) weakSelf = self;
    NSArray *latestMessages = [[RCIMClient sharedRCIMClient] getLatestMessages:self.conversationType targetId:self.targetId count:1];
    if (latestMessages.count > 0) {
        RCMessage *message = (RCMessage *)[latestMessages firstObject];
        [[RCIMClient sharedRCIMClient]clearRemoteHistoryMessages:self.conversationType
                                                        targetId:weakSelf.targetId
                                                      recordTime:message.sentTime
                                                         success:^{
                                                             isClear = [[RCIMClient sharedRCIMClient] clearMessages:weakSelf.conversationType targetId:weakSelf.targetId];
                                                         }
                                                           error:nil
         ];
    }

    //清除消息之后回调操作，例如reload 会话列表
    if (self.clearHistoryCompletion) {
        self.clearHistoryCompletion(isClear);
    }
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickIsTopSwitch:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:self.conversationType targetId:self.targetId isTop:swch.on];
}

// override
- (void)settingTableViewHeader:(RCDConversationSettingTableViewHeader *)settingTableViewHeader
       indexPathOfSelectedItem:(NSIndexPath *)indexPathOfSelectedItem
            allTheSeletedUsers:(NSArray *)users {
}

// override
- (void)deleteTipButtonClicked:(NSIndexPath *)indexPath {
}

@end
