//
//  RCDChatNotificationMessage.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/16.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatNotificationMessage.h"
#import "RCDUserInfoManager.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDGroupManager.h"
NSString *const RCDChatNotificationOpenScreenNtf = @"openScreenNtf";
NSString *const RCDChatNotificationCloseScreenNtf = @"closeScreenNtf";
NSString *const RCDChatNotificationSendScreenNtf = @"sendScreenNtf";
NSString *const RCDChatNotificationOpenRegularClearNtf = @"openRegularClear";
NSString *const RCDChatNotificationCloseRegularClearNtf = @"closeRegularClear";
@implementation RCDChatNotificationMessage
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISPERSISTED;
}

- (void)decodeWithData:(NSData *)data {
    __autoreleasing NSError *__error = nil;
    if (!data) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&__error];
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (!__error && dict) {
        self.operation = [dict objectForKey:@"operation"];
        self.operatorUserId = [dict objectForKey:@"operatorUserId"];
    } else {
        self.rawJSONData = data;
    }
}

+ (NSString *)getObjectName {
    return RCDChatNotificationMessageIdentifier;
}

- (NSString *)conversationDigest {
    return [self getDigest:@""];
}

- (NSString *)getDigest:(NSString *)groupId {
    NSString *content;
    NSString *operationName = [self getDisplayNames:@[ self.operatorUserId ] groupId:groupId];
    if ([self.operation isEqualToString:RCDChatNotificationOpenScreenNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"OpenScreenNtf"), operationName];
    } else if ([self.operation isEqualToString:RCDChatNotificationCloseScreenNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"CloseScreenNtf"), operationName];
    } else if ([self.operation isEqualToString:RCDChatNotificationSendScreenNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"InChatScreen"), operationName];
    } else if ([self.operation isEqualToString:RCDChatNotificationOpenRegularClearNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"OpenGroupMessageClear")];
    } else if ([self.operation isEqualToString:RCDChatNotificationCloseRegularClearNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"CloseGroupMessageClear")];
    } else {
        content = NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
    }
    return content;
}

- (NSString *)getDisplayNames:(NSArray<NSString *> *)userIds groupId:(NSString *)groupId {
    NSString *displayNames = @"";
    for (NSString *userId in userIds) {
        NSString *name;
        if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            name = NSLocalizedStringFromTable(@"You", @"RongCloudKit", nil);
        } else {
            RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
            if (friend && friend.displayName.length > 0) {
                name = friend.displayName;
            } else {
                RCDUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
                if (groupId.length > 0) {
                    RCDGroupMember *member = [RCDGroupManager getGroupMember:userId groupId:groupId];
                    if (member && member.groupNickname.length > 0) {
                        name = member.groupNickname;
                    } else {
                        name = user.name;
                    }
                } else {
                    name = user.name;
                }
            }
        }
        if (name.length == 0) {
            name = [NSString stringWithFormat:@"name%@", userId];
        }
        displayNames = [displayNames stringByAppendingString:name];
        if ([userIds indexOfObject:userId] >= 20 && userIds.count > 20) {
            displayNames =
                [displayNames stringByAppendingString:NSLocalizedStringFromTable(@"GroupEtc", @"RongCloudKit", nil)];
            break;
        } else if (![userId isEqualToString:userIds[userIds.count - 1]]) {
            displayNames =
                [displayNames stringByAppendingString:NSLocalizedStringFromTable(@"punctuation", @"RongCloudKit", nil)];
        }
    }
    return displayNames;
}

#pragma mark - helper
- (NSString *)formatContent {
    NSString *content;
    NSString *operationName = [RCDUserInfoManager getUserInfo:self.operatorUserId].name;
    if ([self.operatorUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        operationName = NSLocalizedStringFromTable(@"You", @"RongCloudKit", nil);
    } else {
        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:self.operatorUserId];
        if (friend && friend.displayName.length > 0) {
            operationName = friend.displayName;
        }
        if (operationName.length == 0) {
            operationName = [NSString stringWithFormat:@"name<%@>", self.operatorUserId];
        }
    }
    if ([self.operation isEqualToString:RCDChatNotificationOpenScreenNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"OpenScreenNtf"), operationName];
    } else if ([self.operation isEqualToString:RCDChatNotificationCloseScreenNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"CloseScreenNtf"), operationName];
    } else if ([self.operation isEqualToString:RCDChatNotificationSendScreenNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"InChatScreen"), operationName];
    } else if ([self.operation isEqualToString:RCDChatNotificationOpenRegularClearNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"OpenGroupMessageClear")];
    } else if ([self.operation isEqualToString:RCDChatNotificationCloseRegularClearNtf]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"CloseGroupMessageClear")];
    } else {
        content = NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
    }
    return content;
}

@end
