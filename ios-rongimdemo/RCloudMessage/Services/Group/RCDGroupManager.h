//
//  RCDGroupManager.h
//  SealTalk
//
//  Created by LiFei on 2019/6/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDGroupInfo.h"
#import "RCDGroupMember.h"
#import "RCDGroupAnnouncement.h"
@class RCMessage;

@interface RCDGroupManager : NSObject
#pragma mark - Group
//创建群组
+ (void)createGroup:(NSString *)groupName
          memberIds:(NSArray *)memberIds
           complete:(void (^)(NSString *))complete;

//设置群组头像
+ (void)setGroupPortrait:(NSString *)portraitUri
                 groupId:(NSString *)groupId
                complete:(void (^)(BOOL success))complete;

//修改群组名称
+ (void)setGroupName:(NSString *)groupName
             groupId:(NSString *)groupId
            complete:(void (^)(BOOL success))complete;

//从本地数据库获取群信息
+ (RCDGroupInfo *)getGroupInfo:(NSString *)groupId;

//从 server 获取群信息
+ (void)getGroupInfoFromServer:(NSString *)groupId
                      complete:(void (^)(RCDGroupInfo *groupInfo))complete;

//退出群组
+ (void)quitGroup:(NSString *)groupId
         complete:(void (^)(BOOL success))complete;

//解散群组
+ (void)dismissGroup:(NSString *)groupId
            complete:(void (^)(BOOL success))complete;

//发布群公告
+ (void)publishGroupAnnouncement:(NSString *)content
                         groupId:(NSString *)groupId
                        complete:(void (^)(BOOL success))complete;

//获取群公告
+ (void)getGroupAnnouncement:(NSString *)groupId
                    complete:(void (^)(RCDGroupAnnouncement *))complete;

#pragma mark - Group Member
//从本地数据库获取群成员 idList
+ (NSArray<NSString *> *)getGroupMembers:(NSString *)groupId;

//从 server 获取群成员 idList
+ (void)getGroupMembersFromServer:(NSString *)groupId
                         complete:(void (^)(NSArray<NSString *> *memberIdList))complete;

//从本地数据库获取群成员详细信息
+ (RCDGroupMember *)getGroupMember:(NSString *)userId groupId:(NSString *)groupId;

//获取管理员列表
+ (NSArray<NSString *>*)getGroupManagers:(NSString *)groupId;

//获取群主
+ (NSString *)getGroupOwner:(NSString *)groupId;

//加入群组
+ (void)joinGroup:(NSString *)groupId
         complete:(void (^)(BOOL success))complete;

//添加群组成员
+ (void)addUsers:(NSArray *)userIds
         groupId:(NSString *)groupId
        complete:(void (^)(BOOL success))complete;

//将用户踢出群组
+ (void)kickUsers:(NSArray *)userIds
          groupId:(NSString *)groupId
         complete:(void (^)(BOOL success))complete;

//群主转让
+ (void)transferGroupOwner:(NSString *)targetId
                   groupId:(NSString *)groupId
                  complete:(void (^)(BOOL success))complete;

+ (void)addGroupManagers:(NSArray<NSString *> *)userIds
                 groupId:(NSString *)groupId
                complete:(void (^)(BOOL success))complete;

+ (void)removeGroupManagers:(NSArray<NSString *> *)userIds
                    groupId:(NSString *)groupId
                   complete:(void (^)(BOOL success))complete;

+ (NSArray<RCDGroupInfo *>*)getAllGroupList;
#pragma mark - My Group
//从本地数据库获取群列表
+ (NSArray<RCDGroupInfo *> *)getMyGroupList;

//从 server 获取群列表
+ (void)getMyGroupListFromServer:(void (^)(NSArray<RCDGroupInfo *> *groupList))complete;

// 添加到我的群组
+ (void)addToMyGroups:(NSString *)groupId
             complete:(void (^)(BOOL success))complete;
//从我的群组中移除
+ (void)removeFromMyGroups:(NSString *)groupId
                  complete:(void (^)(BOOL success))complete;

+ (BOOL)isInMyGroups:(NSString *)groupId;

#pragma mark - Group Notification
+ (BOOL)isHoldGroupNotificationMessage:(RCMessage *)message;
@end

