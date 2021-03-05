//
//  RCDGroupAPI.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDGroupInfo.h"
#import "RCDGroupMember.h"
#import "RCDGroupNotice.h"
#import "RCDGroupMemberDetailInfo.h"
#import "RCDGroupLeftMember.h"
#import "RCDEnum.h"

@class RCUserInfo;
@class RCDGroupAnnouncement;
NS_ASSUME_NONNULL_BEGIN
@interface RCDGroupAPI : NSObject
#pragma mark - Group
+ (void)createGroup:(NSString *)groupName
        portraitUri:(NSString *)portraitUri
          memberIds:(NSArray *)memberIds
           complete:(void (^)(NSString *groupId, RCDGroupAddMemberStatus status))complete;

+ (void)copyGroup:(NSString *)groupId
        groupName:(NSString *)groupName
      portraitUri:(NSString *)portraitUri
         complete:(void (^)(NSString *groupId, RCDGroupAddMemberStatus status))complete
            error:(void (^)(RCDGroupErrorCode errorCode))error;

+ (void)setGroupPortrait:(NSString *)portraitUri groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete;

//修改群组名称
+ (void)resetGroupName:(NSString *)groupName groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete;

//获取群信息
+ (void)getGroupInfo:(NSString *)groupId complete:(void (^)(RCDGroupInfo *groupInfo))complete;

//退出群组
+ (void)quitGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete;

//解散群组
+ (void)dismissGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete;

//发布群公告
+ (void)publishGroupAnnouncement:(NSString *)content
                         groupId:(NSString *)groupId
                        complete:(void (^)(BOOL success))complete;

+ (void)getGroupAnnouncement:(NSString *)groupId complete:(void (^)(RCDGroupAnnouncement *announcement))complete;

+ (void)setGroupAllMute:(BOOL)mute groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete;

+ (void)setGroupCertification:(BOOL)open groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete;

+ (void)getGroupNoticeList:(void (^)(BOOL success, NSArray<RCDGroupNotice *> *noticeList))complete;

+ (void)clearGroupNoticeList:(void (^)(BOOL success))complete;

+ (void)setGroupApproveAction:(RCDGroupInviteActionType)type
                     targetId:(NSString *)targetId
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL success))complete;

+ (void)setGroupMemberProtection:(BOOL)open groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete;

+ (void)getGroupLeftMemberList:(NSString *)groupId complete:(void (^)(NSArray<RCDGroupLeftMember *> *list))complete;
#pragma mark - Group member
//获取群组成员列表
+ (void)getGroupMembers:(NSString *)groupId
               complete:(void (^)(NSArray<RCDGroupMember *> *memberList))complete
                  error:(void (^)(RCDGroupErrorCode errorCode))errorBlock;

//获取我的群组
+ (void)getMyGroupList:(void (^)(NSArray<RCDGroupInfo *> *groupList))complete;

//加入群组
+ (void)joinGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete;

//添加群组成员
+ (void)addUsers:(NSArray *)userIds
         groupId:(NSString *)groupId
        complete:(void (^)(BOOL success, RCDGroupAddMemberStatus status))complete;

//将用户踢出群组
+ (void)kickUsers:(NSArray *)userIds groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete;

//群主转让
+ (void)transferGroupOwner:(NSString *)targetId groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete;

+ (void)addGroupManagers:(NSArray<NSString *> *)userIds
                 groupId:(NSString *)groupId
                complete:(void (^)(BOOL success))complete;

+ (void)removeGroupManagers:(NSArray<NSString *> *)userIds
                    groupId:(NSString *)groupId
                   complete:(void (^)(BOOL success))complete;

+ (void)setGroupMemberDetailInfo:(RCDGroupMemberDetailInfo *)memberInfo
                         groupId:(NSString *)groupId
                        complete:(void (^)(BOOL success))complete;

+ (void)getGroupMemberDetailInfo:(NSString *)userId
                         groupId:(NSString *)groupId
                        complete:(void (^)(RCDGroupMemberDetailInfo *member))complete;
#pragma mark - My Group
// 添加到我的群组
+ (void)addToMyGroups:(NSString *)groupId complete:(void (^)(BOOL success))complete;

+ (void)removeFromMyGroups:(NSString *)groupId complete:(void (^)(BOOL success))complete;
@end

NS_ASSUME_NONNULL_END
