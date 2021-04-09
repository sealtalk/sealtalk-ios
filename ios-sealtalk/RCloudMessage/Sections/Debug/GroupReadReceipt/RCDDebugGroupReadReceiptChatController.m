//
//  RCDDebugGroupReadReceiptChatController.m
//  SealTalk
//
//  Created by 张改红 on 2021/2/23.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugGroupReadReceiptChatController.h"
#import "RCDDebugReceiptDetailsController.h"
#import "UIView+MBProgressHUD.h"
#import "RCDTipMessageCell.h"
#import "RCDGroupNotificationMessage.h"
#import "RCDChatNotificationMessage.h"

@interface RCDDebugGroupReadReceiptChatController ()<RCMessageCellDelegate, RCGroupReadReceiptV2Delegate>
@end

@implementation RCDDebugGroupReadReceiptChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerClass:RCDTipMessageCell.class forMessageClass:RCDGroupNotificationMessage.class];
    [self registerClass:RCDTipMessageCell.class forMessageClass:RCDChatNotificationMessage.class];
    [RCGroupReadReceiptV2Manager sharedManager].groupReadReceiptV2Delegate = self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - RCMessageCellDelegate
- (void)didTapReceiptCountView:(RCMessageModel *)model {
    RCDDebugReceiptDetailsController *vc = [[RCDDebugReceiptDetailsController alloc] init];
    vc.message = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - RCGroupReadReceiptV2Delegate
- (void)onMessageReceiptResponse:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId messageUId:(NSString *)messageUId readCount:(int)readCount totalCount:(int)totalCount{
    if ([self.targetId isEqualToString:targetId] &&
        self.conversationType == conversationType) {
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            RCMessageModel *model = self.conversationDataRepository[i];
            if ([model.messageUId isEqualToString:messageUId]) {
                model.readReceiptCount = readCount;
                model.readReceiptInfo = [[RCReadReceiptInfo alloc] init];
                model.readReceiptInfo.isReceiptRequestMessage = YES;
                RCMessageCell *cell = (RCMessageCell *)[self.conversationMessageCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                if (cell) {
                    [cell setDataModel:model];
                }
            }
        }
    }
}

#pragma mark - Super
- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:cell.model.messageId];
    if (cell.model.messageDirection == MessageDirection_SEND && [cell isKindOfClass:[RCMessageCell class]]) {
        RCMessageCell *msgCell = (RCMessageCell *)cell;
        cell.model.isCanSendReadReceipt = NO;
        [msgCell.receiptView removeFromSuperview];
        msgCell.receiptStatusLabel.hidden = NO;
        msgCell.receiptStatusLabel.userInteractionEnabled = YES;
        msgCell.receiptStatusLabel.text = [NSString
                                           stringWithFormat:RCLocalizedString(@"readNum"), msg.groupReadReceiptInfoV2.readCount];
    }
}

- (void)updateLastMessageReadReceiptStatus:(long)messageId content:(RCMessageContent *)content{
    
}

#pragma mark - Privite
- (void)sendReadReceiptResponse{
    NSMutableArray *readReceiptarray = [NSMutableArray array];
    NSMutableArray *readReceiptModelarray = [NSMutableArray array];
    for (int i = 0; i < self.conversationDataRepository.count; i++) {
        RCMessageModel *rcMsgModel = [self.conversationDataRepository objectAtIndex:i];
        RCMessage *rcMsg = [[RCIMClient sharedRCIMClient] getMessage:rcMsgModel.messageId];
        if (([[rcMsg.content class] persistentFlag] & MessagePersistent_ISCOUNTED) == MessagePersistent_ISCOUNTED &&  rcMsg.messageDirection == MessageDirection_RECEIVE && !rcMsg.groupReadReceiptInfoV2.hasRespond) {
            [readReceiptarray addObject:rcMsg];
            [readReceiptModelarray addObject:rcMsgModel];
        }
    }

    if (readReceiptarray.count > 0) {
        __weak typeof(self) weakSelf = self;
        [[RCGroupReadReceiptV2Manager sharedManager] sendReadReceiptResponse:self.conversationType
                                                                    targetId:self.targetId
                                                                   channelId:nil
                                                                 messageList:readReceiptarray
                                                                     success:^{
        
        } error:^(RCErrorCode nErrorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view showHUDMessage:[NSString stringWithFormat:@"error code : %ld",nErrorCode]];
            });
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [super scrollViewDidEndDecelerating:scrollView];
    [self sendReadReceiptResponse];
}

- (void)scrollToBottomAnimated:(BOOL)animated{
    [super scrollToBottomAnimated:animated];
    [self sendReadReceiptResponse];
}
@end
