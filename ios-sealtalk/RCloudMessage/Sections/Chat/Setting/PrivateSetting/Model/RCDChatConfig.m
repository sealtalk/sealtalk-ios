//
//  RCDChatConfig.m
//  SealTalk
//
//  Created by hrx on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatConfig.h"

#define KEY_CHAT_SCREENCAPTURE_NOTIFICATION @"screen_capture_notification"
#define KEY_CHAT_MESSAGE_CLEAR_STATUS @"message_clear_status"

@implementation RCDChatConfig

+ (instancetype)chatConfigWithConversationType:(RCConversationType)conversationType
                                      targetId:(NSString *)targetId
                     screenCaptureNotification:(BOOL)screenCaptureNotification {
    return [[[self class] alloc] initWithChatConfigWithConversationType:conversationType
                                                               targetId:targetId
                                              screenCaptureNotification:screenCaptureNotification];
}

- (instancetype)initWithChatConfigWithConversationType:(RCConversationType)conversationType
                                              targetId:(NSString *)targetId
                             screenCaptureNotification:(BOOL)screenCaptureNotification {
    if (self = [super init]) {
        self.conversationType = conversationType;
        self.targetId = targetId;
        self.screenCaptureNotification = screenCaptureNotification;
    }
    return self;
}

+ (instancetype)chatConfigWithConversationType:(RCConversationType)conversationType
                                      targetId:(NSString *)targetId
                     screenCaptureNotification:(BOOL)screenCaptureNotification
                            messageClearStatus:(RCDGroupMessageClearStatus)clearStatus {
    return [[[self class] alloc] initWithChatConfigWithConversationType:conversationType
                                                               targetId:targetId
                                              screenCaptureNotification:screenCaptureNotification
                                                     messageClearStatus:clearStatus];
}

- (instancetype)initWithChatConfigWithConversationType:(RCConversationType)conversationType
                                              targetId:(NSString *)targetId
                             screenCaptureNotification:(BOOL)screenCaptureNotification
                                    messageClearStatus:(RCDGroupMessageClearStatus)clearStatus {
    if (self = [super init]) {
        self.conversationType = conversationType;
        self.targetId = targetId;
        self.screenCaptureNotification = screenCaptureNotification;
        self.messageClearStatus = clearStatus;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        if (decoder == nil) {
            return self;
        }
        self.screenCaptureNotification = [decoder decodeBoolForKey:KEY_CHAT_SCREENCAPTURE_NOTIFICATION];
        self.messageClearStatus = [decoder decodeIntegerForKey:KEY_CHAT_MESSAGE_CLEAR_STATUS];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeBool:self.screenCaptureNotification forKey:KEY_CHAT_SCREENCAPTURE_NOTIFICATION];
    [encoder encodeInteger:self.messageClearStatus forKey:KEY_CHAT_MESSAGE_CLEAR_STATUS];
}

@end
