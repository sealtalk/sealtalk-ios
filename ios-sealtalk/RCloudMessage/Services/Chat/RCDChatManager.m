//
//  RCDChatManager.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatManager.h"
#import "RCDChatAPI.h"
#import "RCDChatConfig.h"
#import "RCDDBManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIColor+RCColor.h"
#import "RCDChatNotificationMessage.h"
#import "RCDClearMessage.h"
#import "RCDCommonString.h"
@implementation RCDChatManager

//设置会话截屏通知
+ (void)setScreenCaptureNotification:(BOOL)open
                    conversationType:(RCConversationType)type
                            targetId:(NSString *)targetId
                            complete:(void (^)(BOOL))complete {
    [RCDChatAPI setChatConfigWithConversationType:type
                                         targetId:targetId
                        screenCaptureNotification:open
                                         complete:^(BOOL success) {
                                             if (success) {
                                                 [RCDChatManager saveScreenCaptureNotification:success
                                                                              conversationType:type
                                                                                      targetId:targetId];
                                             }
                                             if (complete) {
                                                 complete(success);
                                             }
                                         }];
}

//获取会话截屏通知状态
+ (void)getScreenCaptureNotification:(RCConversationType)type
                            targetId:(NSString *)targetId
                            complete:(void (^)(BOOL))complete
                               error:(void (^)())error {
    [RCDChatAPI getChatConfigWithConversationType:type
        targetId:targetId
        success:^(BOOL open) {
            if (open) {
                [RCDChatManager saveScreenCaptureNotification:open conversationType:type targetId:targetId];
            }
            if (complete) {
                complete(open);
            }
        }
        error:^{
            if (error) {
                error();
            }
        }];
}

+ (void)sendScreenCaptureNotification:(RCConversationType)conversationType
                             targetId:(NSString *)targetId
                             complete:(void (^)(BOOL))complete {
    [RCDChatAPI sendScreenCaptureNotification:conversationType targetId:targetId complete:complete];
}

+ (void)setGroupMessageClearStatus:(RCDGroupMessageClearStatus)status
                           groupId:(NSString *)groupId
                          complete:(void (^)(BOOL success))complete {
    [RCDChatAPI setGroupMessageClearStatus:status
                                   groupId:groupId
                                  complete:^(BOOL success) {
                                      if (success) {
                                          [self saveChatConfigWithConversationType:ConversationType_GROUP
                                                                          targetId:groupId
                                                           groupMessageClearStatus:status];
                                      }
                                      if (complete) {
                                          complete(success);
                                      }
                                  }];
}

+ (void)getGroupMessageClearStatus:(NSString *)groupId complete:(void (^)(RCDGroupMessageClearStatus status))complete {
    [RCDChatAPI getGroupMessageClearStatus:groupId
                                  complete:^(RCDGroupMessageClearStatus status) {
                                      if (status != RCDGroupMessageClearStatusUnknown) {
                                          [self saveChatConfigWithConversationType:ConversationType_GROUP
                                                                          targetId:groupId
                                                           groupMessageClearStatus:status];
                                      }
                                      if (complete) {
                                          complete(status);
                                      }
                                  }];
}

#pragma mark - receive message listener
+ (BOOL)isHoldChatNotificationMessage:(RCMessage *)message {
    if ([message.content isMemberOfClass:[RCDChatNotificationMessage class]]) {
        RCDChatNotificationMessage *msg = (RCDChatNotificationMessage *)message.content;
        if (![msg.operation isEqualToString:RCDChatNotificationSendScreenNtf]) {
            [self getScreenCaptureNotification:message.conversationType
                targetId:message.targetId
                complete:^(BOOL open) {

                }
                error:^{

                }];
        }
        return YES;
    } else if ([message.content isMemberOfClass:[RCDClearMessage class]]) {
        RCDClearMessage *msg = (RCDClearMessage *)message.content;
        [[RCIMClient sharedRCIMClient] clearHistoryMessages:message.conversationType
            targetId:message.targetId
            recordTime:msg.clearTime
            clearRemote:YES
            success:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:RCDGroupClearMessageKey object:nil];
                });
            }
            error:^(RCErrorCode status){

            }];
    }
    return NO;
}
#pragma mark - helper
+ (void)saveScreenCaptureNotification:(BOOL)screenCaptureNotification
                     conversationType:(RCConversationType)type
                             targetId:(NSString *)targetId {
    RCDChatConfig *chatConfig = nil;
    if (screenCaptureNotification) {
        chatConfig = [RCDDBManager getChatConfigWithConversationType:type targetId:targetId];
        if (chatConfig) {
            chatConfig.screenCaptureNotification = screenCaptureNotification;
        } else {
            chatConfig = [RCDChatConfig chatConfigWithConversationType:type
                                                              targetId:targetId
                                             screenCaptureNotification:screenCaptureNotification];
        }
        [RCDDBManager saveChatConfig:chatConfig];
    }
}

+ (void)saveChatConfigWithConversationType:(RCConversationType)type
                                  targetId:(NSString *)targetId
                   groupMessageClearStatus:(RCDGroupMessageClearStatus)status {
    RCDChatConfig *chatConfig = nil;
    chatConfig = [RCDDBManager getChatConfigWithConversationType:type targetId:targetId];
    if (chatConfig) {
        chatConfig.messageClearStatus = status;
    } else {
        chatConfig = [RCDChatConfig chatConfigWithConversationType:type
                                                          targetId:targetId
                                         screenCaptureNotification:NO
                                                messageClearStatus:status];
    }
    [RCDDBManager saveChatConfig:chatConfig];
}
@end
