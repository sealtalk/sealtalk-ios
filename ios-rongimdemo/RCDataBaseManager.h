//
//  RCDataBaseManager.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/6/3.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDGroupInfo.h"
#import "RCDUserInfo.h"
#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

@interface RCDataBaseManager : NSObject

+ (RCDataBaseManager *)shareInstance;

- (void)closeDBForDisconnect;

//存储用户信息
- (void)insertUserToDB:(RCUserInfo *)user;

- (void)insertUserListToDB:(NSMutableArray *)userList complete:(void (^)(BOOL))result;

//插入黑名单列表
- (void)insertBlackListToDB:(RCUserInfo *)user;

- (void)insertBlackListUsersToDB:(NSMutableArray *)userList complete:(void (^)(BOOL))result;

//获取黑名单列表
- (NSArray *)getBlackList;

//移除黑名单
- (void)removeBlackList:(NSString *)userId;

//清空黑名单缓存信息
- (void)clearBlackListData;

//从表中获取用户信息
- (RCUserInfo *)getUserByUserId:(NSString *)userId;

//从表中获取所有用户信息
- (NSArray *)getAllUserInfo;

//存储群组信息
- (void)insertGroupToDB:(RCGroup *)group;

- (void)insertGroupsToDB:(NSMutableArray *)groupList complete:(void (^)(BOOL))result;

//从表中获取群组信息
- (RCDGroupInfo *)getGroupByGroupId:(NSString *)groupId;

//删除表中的群组信息
- (void)deleteGroupToDB:(NSString *)groupId;

//从表中获取所有群组信息
- (NSMutableArray *)getAllGroup;

//存储群组成员信息
- (void)insertGroupMemberToDB:(NSMutableArray *)groupMemberList
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL))result;

//从表中获取群组成员信息
- (NSMutableArray *)getGroupMember:(NSString *)groupId;

//存储好友信息
- (void)insertFriendToDB:(RCDUserInfo *)friendInfo;

- (void)insertFriendListToDB:(NSMutableArray *)FriendList complete:(void (^)(BOOL))result;

//清空表中的所有的群组信息
- (BOOL)clearGroupfromDB;

//清空群组缓存数据
- (void)clearGroupsData;

//清空好友缓存数据
- (void)clearFriendsData;

//从表中获取所有好友信息 //RCUserInfo
- (NSArray *)getAllFriends;

//从表中获取某个好友的信息
- (RCDUserInfo *)getFriendInfo:(NSString *)friendId;

//删除好友信息
- (void)deleteFriendFromDB:(NSString *)userId;

@end
