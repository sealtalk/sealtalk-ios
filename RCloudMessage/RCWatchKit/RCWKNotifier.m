/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCWKNotifier.m
//  Created by litao on 15/4/7.

#import "RCWKNotifier.h"
#import "RCWKAppExtenalDefine.h"

@interface RCWKNotifier ()
- (void)notifyWatchKitMessageChanged;
- (void)notifyWatchKitConnectionStatusChanged;
@end

@implementation RCWKNotifier
+ (instancetype)sharedWKNotifier {
    static RCWKNotifier *pDefaultNotifier;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (pDefaultNotifier == nil) {
            pDefaultNotifier = [[RCWKNotifier alloc] init];
        }
    });
    return pDefaultNotifier;
}

- (void)notifyWatchKitEvent:(NSString *)appEvent {
    if (self.isWatchAttached) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)appEvent,
                                             NULL, NULL, true);
    }
}

- (void)notifyWatchKitMessageChanged {
    [self notifyWatchKitEvent:RC_MESSAGE_CHANGED_EVENT];
}
- (void)notifyWatchKitUserInfoChanged {
    [self notifyWatchKitEvent:RC_USER_INFO_CHANGED_EVENT];
}
- (void)notifyWatchKitGroupChanged {
    [self notifyWatchKitEvent:RC_GROUP_INFO_CHANGED_EVENT];
}
- (void)notifyWatchKitFriendChanged {
    [self notifyWatchKitEvent:RC_FRIEND_CHANGED_EVENT];
}
- (void)notifyWatchKitLoadImageDone:(NSString *)userID {
    [self notifyWatchKitEvent:RC_LOAD_IMAGE_DONE_EVENT];
}
- (void)notifyWatchKitConnectionStatusChanged {
    [self notifyWatchKitEvent:RC_CONNECTION_STATUS_CHANGED_EVENT];
}

#pragma mark - RCWatchKitStatusDelegate
- (void)notifyWatchKitReceivedMessage:(RCMessage *)receivedMsg
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitQuitDiscussion:(NSString *)discussionId
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitRemoveMemberFromDiscussion:(NSString *)discussionId
                                          userId:(NSString *)userId
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitAddMemberToDiscussion:(NSString *)discussionId
                                 userIdList:(NSArray *)userIdList
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitCreateDiscussion:(NSString *)name
                            userIdList:(NSArray *)userIdList
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitClearConversations:(NSArray *)conversationTypeList
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitClearMessages:(RCConversationType)conversationType targetId:(NSString *)targetId
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitClearUnReadStatus:(RCConversationType)conversationType targetId:(NSString *)targetId
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitDeleteMessages:(NSArray *)messageIds
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitSendMessage:(RCMessage *)message
{
    [self notifyWatchKitMessageChanged];
}
- (void)notifyWatchKitUploadFileProgress:(int)progress  messageId:(long)messageId
{
    
}
- (void)notifyWatchKitConnectionStatusChanged:(RCConnectionStatus) status
{
    [self notifyWatchKitConnectionStatusChanged];
}
@end
