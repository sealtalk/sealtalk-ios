//
//  RCDDBManager.h
//  SealTalk
//
//  Created by LiFei on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import "RCDGroupInfo.h"
#import "RCDFriendInfo.h"
#import "RCDGroupMember.h"
#import "RCDGroupNotice.h"
#import "RCDUserSetting.h"
#import "RCDChatConfig.h"
#import "RCDFriendDescription.h"
#import "RCDGroupLeftMember.h"
#import "RCDGroupMemberDetailInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCDDBManager : NSObject

+ (BOOL)openDB:(NSString *)path;

+ (void)closeDB;

#pragma mark - User

+ (void)saveUsers:(NSArray<RCDUserInfo *> *)userList;

+ (RCDUserInfo *)getUser:(NSString *)userId;

#pragma mark - Friend
+ (void)saveFriends:(NSArray<RCDFriendInfo *> *)friendList;

+ (void)deleteFriends:(NSArray<NSString *> *)userIdList;

+ (RCDFriendInfo *)getFriend:(NSString *)userId;

+ (void)clearFriends;

// 获取接收的好友请求
+ (int)getFriendRequesteds;

// 获取所有好友信息（已经成功添加好友）
+ (NSArray<RCDFriendInfo *> *)getAllFriends;

//获取所有好友信息（包含成功添加的以及尚未通过的）
+ (NSArray<RCDFriendInfo *> *)getAllFriendRequests;

#pragma mark - Blacklist
+ (void)addBlacklist:(NSArray<NSString *> *)userIdList;

+ (NSArray<NSString *> *)getBlacklist;

+ (void)removeBlacklist:(NSArray<NSString *> *)userIdList;

+ (void)clearBlacklist;

+ (void)saveGroups:(NSArray<RCDGroupInfo *> *)groupList;

#pragma mark - Group
+ (RCDGroupInfo *)getGroup:(NSString *)groupId;

+ (void)deleteGroup:(NSString *)groupId;

+ (NSArray<RCDGroupInfo *> *)getAllGroupList;

#pragma mark - My Group
+ (void)saveMyGroups:(NSArray<NSString *> *)groupIdList;

+ (NSArray<RCDGroupInfo *> *)getMyGroups;

+ (void)clearMyGroups;

#pragma mark - Group Member
+ (void)saveGroupMembers:(NSArray<RCDGroupMember *> *)memberList inGroup:(NSString *)groupId;

+ (void)clearGroupMembers:(NSString *)groupId;

+ (NSArray<NSString *> *)getGroupMembers:(NSString *)groupId;

+ (RCDGroupMember *)getGroupMember:(NSString *)userId inGroup:(NSString *)groupId;

+ (NSArray<NSString *> *)getGroupManagers:(NSString *)groupId;

+ (NSString *)getGroupOwner:(NSString *)groupId;

+ (void)saveChatConfig:(RCDChatConfig *)chatConfig;

+ (RCDChatConfig *)getChatConfigWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId;

+ (BOOL)getScreenCaptureNotification:(RCConversationType)type targetId:(NSString *)targetId;

+ (RCDGroupMessageClearStatus)getMessageClearStatus:(RCConversationType)type targetId:(NSString *)targetId;

+ (void)saveGroupLeftMemberList:(NSArray<RCDGroupLeftMember *> *)list groupId:(NSString *)groupId;

+ (void)clearGroupLeftMemberList:(NSString *)groupId;

+ (NSArray<RCDGroupLeftMember *> *)getGroupLeftMemberList:(NSString *)groupId;

+ (void)saveGroupMemberDetailInfo:(RCDGroupMemberDetailInfo *)memberDetail groupId:(NSString *)groupId;

+ (void)clearGroupMemberDetailInfo:(NSString *)userId groupId:(NSString *)groupId;

+ (void)clearGroupMemberDetailInfo:(NSString *)groupId;

+ (RCDGroupMemberDetailInfo *)getGroupMemberDetailInfo:(NSString *)userId groupId:(NSString *)groupId;

#pragma mark - groupNotice
+ (void)saveGroupNoticeList:(NSArray<RCDGroupNotice *> *)noticeList;

+ (NSArray<RCDGroupNotice *> *)getGroupNoticeList;

+ (NSInteger)getGroupNoticeUnreadCount;

+ (void)clearGroupNoticeList;

#pragma mark - userSetting
+ (void)saveUserSetting:(RCDUserSetting *)setting;

+ (RCDUserSetting *)getUserSetting;

#pragma mark - friendDescription
+ (void)saveFriendDescription:(RCDFriendDescription *)description;

+ (RCDFriendDescription *)getFriendDescription:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
