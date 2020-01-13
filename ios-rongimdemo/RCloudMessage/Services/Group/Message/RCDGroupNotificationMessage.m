//
//  RCDGroupNotificationMessage.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupNotificationMessage.h"
#import "RCDUserInfoManager.h"
#import "RCDGroupManager.h"
#import <RongIMKit/RongIMKit.h>
NSString *const RCDGroupCreate = @"Create";
NSString *const RCDGroupMemberAdd = @"Add";
NSString *const RCDGroupMemberQuit = @"Quit";
NSString *const RCDGroupDismiss = @"Dismiss";
NSString *const RCDGroupMemberKicked = @"Kicked";
NSString *const RCDGroupRename = @"Rename";
NSString *const RCDGroupBulletin = @"Bulletin";
NSString *const RCDGroupOwnerTransfer = @"Transfer";
NSString *const RCDGroupMemberJoin = @"Join";
NSString *const RCDGroupMemberManagerSet = @"SetManager";
NSString *const RCDGroupMemberManagerRemove = @"RemoveManager";
NSString *const RCDGroupMemberProtectionOpen = @"openMemberProtection";
NSString *const RCDGroupMemberProtectionClose = @"closeMemberProtection";
@interface RCDGroupNotificationMessage ()
@property (nonatomic, copy) NSString *targetGroupName;
@property (nonatomic, strong) NSArray *targetUserNames;
@property (nonatomic, copy) NSString *operationName;
@end
@implementation RCDGroupNotificationMessage
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
        self.operationName = dict[@"data"][@"operatorNickname"];
        self.targetUserIds = dict[@"data"][@"targetUserIds"];
        self.targetGroupName = dict[@"data"][@"targetGroupName"];
        self.targetUserNames = dict[@"data"][@"targetUserDisplayNames"];
    } else {
        self.rawJSONData = data;
    }
}

- (NSString *)conversationDigest {
    return [self getDigest:nil];
}

+ (NSString *)getObjectName {
    return RCDGroupNotificationMessageIdentifier;
}

- (NSString *)getDigest:(NSString *)groupId {
    NSString *content;
    NSString *operationName = [self getDisplayNames:@[ self.operatorUserId ] groupId:groupId];
    NSString *targetNames = [self getDisplayNames:self.targetUserIds groupId:groupId];
    BOOL isMeOperate = NO;
    if ([self.operatorUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        isMeOperate = YES;
    }
    if ([self.operation isEqualToString:RCDGroupCreate]) {
        content =
            [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveCreated" : @"GroupCreated",
                                                                  @"RongCloudKit", nil),
                                       operationName];
    } else if ([self.operation isEqualToString:RCDGroupMemberAdd]) {
        if (self.targetUserIds.count == 1 && [self.targetUserIds containsObject:self.operatorUserId]) {
            content = [NSString
                stringWithFormat:NSLocalizedStringFromTable(@"GroupJoin", @"RongCloudKit", nil), operationName];
        } else {
            content = [NSString
                stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveInvited" : @"GroupInvited",
                                                            @"RongCloudKit", nil),
                                 operationName, targetNames];
        }
    } else if ([self.operation isEqualToString:RCDGroupMemberJoin]) {
        content =
            [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupJoin", @"RongCloudKit", nil), operationName];
    } else if ([self.operation isEqualToString:RCDGroupMemberQuit]) {
        content = [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveQuit" : @"GroupQuit",
                                                                        @"RongCloudKit", nil),
                                             operationName];
    } else if ([self.operation isEqualToString:RCDGroupMemberKicked]) {
        content =
            [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveRemoved" : @"GroupRemoved",
                                                                  @"RongCloudKit", nil),
                                       operationName, targetNames];
    } else if ([self.operation isEqualToString:RCDGroupRename]) {
        content = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupChanged", @"RongCloudKit", nil),
                                             operationName, self.targetGroupName];
    } else if ([self.operation isEqualToString:RCDGroupDismiss]) {
        content =
            [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveDismiss" : @"GroupDismiss",
                                                                  @"RongCloudKit", nil),
                                       operationName];
    } else if ([self.operation isEqualToString:RCDGroupOwnerTransfer]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"GroupHasNewOwner"), targetNames];
    } else if ([self.operation isEqualToString:RCDGroupMemberManagerSet]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"GroupSetManagerMessage"), targetNames];
    } else if ([self.operation isEqualToString:RCDGroupMemberProtectionOpen]) {
        content = RCDLocalizedString(@"openMemberProtection");
    } else if ([self.operation isEqualToString:RCDGroupMemberProtectionClose]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"closeMemberProtection"), operationName];
    } else {
        content = NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
    }
    return content;
}

#pragma mark - helper
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
            if (name.length == 0 && [userId isEqualToString:self.operatorUserId]) {
                name = self.operationName;
            }
            if (name.length == 0 && [self.targetUserIds isEqualToArray:userIds]) {
                NSInteger index = [userIds indexOfObject:userId];
                if(self.targetUserNames.count > index){
                    name = self.targetUserNames[index];
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

@end
