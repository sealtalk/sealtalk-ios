//
//  RCDGroupNotificationMessage.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
extern NSString *const RCDGroupCreate;
extern NSString *const RCDGroupMemberAdd;
extern NSString *const RCDGroupMemberQuit;
extern NSString *const RCDGroupMemberKicked;
extern NSString *const RCDGroupRename;
extern NSString *const RCDGroupBulletin;
extern NSString *const RCDGroupOwnerTransfer;
extern NSString *const RCDGroupDismiss;
extern NSString *const RCDGroupMemberJoin;
extern NSString *const RCDGroupMemberManagerSet;
extern NSString *const RCDGroupMemberManagerRemove;
extern NSString *const RCDGroupMemberProtectionOpen;
extern NSString *const RCDGroupMemberProtectionClose;
#define RCDGroupNotificationMessageIdentifier @"ST:GrpNtf"

/*!
 群组通知消息
 */
@interface RCDGroupNotificationMessage : RCMessageContent

@property (nonatomic, copy) NSString *operation;

@property (nonatomic, copy) NSString *operatorUserId;

@property (nonatomic, strong) NSArray<NSString *> *targetUserIds;

@property (nonatomic, copy) NSString *message;

- (NSString *)getDigest:(NSString *)groupId;
@end
