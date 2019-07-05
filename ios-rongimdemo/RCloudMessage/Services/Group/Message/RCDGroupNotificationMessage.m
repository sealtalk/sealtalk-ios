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
@interface RCDGroupNotificationMessage()
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

- (NSString *)conversationDigest{
    return [self formatContent];
}

+ (NSString *)getObjectName {
    return RCDGroupNotificationMessageIdentifier;
}

#pragma mark - helper
- (NSString *)getTargetNames{
    NSString *str = [NSString string];
    for (NSString *name in self.targetUserNames) {
        if ([name isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.name]) {
            str = [str stringByAppendingString:NSLocalizedStringFromTable(@"You", @"RongCloudKit", nil)];
        }else{
            str = [str stringByAppendingString:name];
        }
        if (![name isEqualToString:self.targetUserNames[self.targetUserNames.count-1]]) {
            str = [str stringByAppendingString:NSLocalizedStringFromTable(@"punctuation", @"RongCloudKit", nil)];
        }
        if (self.targetUserIds.count > self.targetUserNames.count) {
            str = [str stringByAppendingString:NSLocalizedStringFromTable(@"GroupEtc", @"RongCloudKit", nil)];
        }
    }
    return str;
}

- (NSString *)formatContent{
    NSString *content;
    NSString *operationName = self.operationName;
    BOOL isMeOperate = NO;
    if ([self.operatorUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        isMeOperate = YES;
        operationName = NSLocalizedStringFromTable(@"You", @"RongCloudKit", nil);
    }
    if([self.operation isEqualToString:RCDGroupCreate]){
        content = [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveCreated" : @"GroupCreated", @"RongCloudKit", nil), operationName];
    }else if ([self.operation isEqualToString:RCDGroupMemberAdd]){
        if (self.targetUserIds.count == 1 && [self.targetUserIds containsObject:self.operatorUserId ]) {
            content = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupJoin", @"RongCloudKit", nil),operationName];
        }else{
            content = [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveInvited" : @"GroupInvited", @"RongCloudKit", nil), operationName, [self getTargetNames]];
        }
    }else if ([self.operation isEqualToString:RCDGroupMemberJoin]){
        content = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupJoin", @"RongCloudKit", nil),operationName];
    }else if ([self.operation isEqualToString:RCDGroupMemberQuit]) {
        content = [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveQuit" : @"GroupQuit", @"RongCloudKit", nil), operationName];
    }else if ([self.operation isEqualToString:RCDGroupMemberKicked]) {
        content = [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveRemoved" : @"GroupRemoved", @"RongCloudKit", nil), operationName, [self getTargetNames]];
    }else if ([self.operation isEqualToString:RCDGroupRename]) {
        content = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupChanged", @"RongCloudKit", nil), operationName, self.targetGroupName];
    }else if ([self.operation isEqualToString:RCDGroupDismiss]) {
        content = [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveDismiss" : @"GroupDismiss", @"RongCloudKit", nil), operationName];
    }else if ([self.operation isEqualToString:RCDGroupOwnerTransfer]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"GroupHasNewOwner"), [self getTargetNames]];
    }else if ([self.operation isEqualToString:RCDGroupMemberManagerSet]) {
        content = [NSString stringWithFormat:RCDLocalizedString(@"GroupSetManagerMessage"), [self getTargetNames]];
    }
    return content;
}

@end
