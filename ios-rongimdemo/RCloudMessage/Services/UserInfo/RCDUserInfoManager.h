//
//  RCDUserInfoManager.h
//  RCloudMessage
//
//  Created by Jue on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDFriendInfo.h"
#import <Foundation/Foundation.h>

@interface RCDUserInfoManager : NSObject

#pragma mark - User
//从本地数据库获取用户信息
+ (RCUserInfo *)getUserInfo:(NSString *)userId;

//从 server 拉取用户信息
+ (void)getUserInfoFromServer:(NSString *)userId
                     complete:(void (^)(RCUserInfo *userInfo))completeBlock;

//设置当前用户昵称
+ (void)setCurrentUserName:(NSString *)name
                  complete:(void (^)(BOOL success))completeBlock;

//设置当前用户头像
+ (void)setCurrentUserPortrait:(NSString *)portraitUri
                      complete:(void (^)(BOOL success))completeBlock;

+ (void)findUserByPhone:(NSString *)phone
                 region:(NSString *)region
               complete:(void (^)(RCUserInfo *userInfo))completeBlock;

#pragma mark - blacklist
//将某个用户加入黑名单
+ (void)addToBlacklist:(NSString *)userId
              complete:(void (^)(BOOL success))completeBlock;

//将某个用户移出黑名单
+ (void)removeFromBlacklist:(NSString *)userId
                   complete:(void (^)(BOOL success))completeBlock;

//查询某个用户是否已经在黑名单中
+ (BOOL)isInBlacklist:(NSString *)userId;

//从本地数据库获取黑名单列表
+ (NSArray <NSString *> *)getBlacklist;

// 从 server 获取黑名单列表
+ (void)getBlacklistFromServer:(void (^)(NSArray <NSString *> *blackUserIds))completeBlock;


#pragma mark - Friend
//从本地数据库获取好友信息
+ (RCDFriendInfo *)getFriendInfo:(NSString *)userId;

//从 server 拉取好友信息
+ (void)getFriendInfoFromServer:(NSString *)userId
                       complete:(void (^)(RCDFriendInfo *friendInfo))completeBlock;

//从本地数据库获取所有好友信息（已经成功添加好友）
+ (NSArray<RCDFriendInfo *>*)getAllFriends;

//获取所有好友信息（包含成功添加的以及尚未通过的）
+ (NSArray<RCDFriendInfo *>*)getAllFriendRequests;

//从 server 获取所有好友信息（包含成功添加的以及尚未通过的）
+ (void)getFriendListFromServer:(void (^)(NSArray<RCDFriendInfo *> *friendList))completeBlock;

//设置好友备注
+ (void)setFriendNickname:(NSString *)nickname
                 byUserId:(NSString *)userId
                 complete:(void (^)(BOOL success))completeBlock;

//由 RCDFriendInfo 转换成 RCUserInfo，使用 RCDFriendInfo 的 displayName 替换 RCUserInfo 的 name
+ (RCUserInfo *)getUserInfoFromFriendInfo:(RCDFriendInfo *)friendInfo;

+ (void)inviteFriend:(NSString *)userId
         withMessage:(NSString *)message
            complete:(void (^)(BOOL success))completeBlock;

+ (void)acceptFriendRequest:(NSString *)userId
                   complete:(void (^)(BOOL success))completeBlock;

+ (void)deleteFriend:(NSString *)userId
            complete:(void (^)(BOOL success))completeBlock;

@end
