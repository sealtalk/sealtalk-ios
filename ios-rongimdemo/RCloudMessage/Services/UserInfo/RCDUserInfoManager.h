//
//  RCDUserInfoManager.h
//  RCloudMessage
//
//  Created by Jue on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDFriendInfo.h"
#import <Foundation/Foundation.h>
#import "RCDUserInfoAPI.h"
#import "RCDUserSetting.h"
@interface RCDUserInfoManager : NSObject

#pragma mark - User
//从本地数据库获取用户信息
+ (RCDUserInfo *)getUserInfo:(NSString *)userId;

//从 server 拉取用户信息
+ (void)getUserInfoFromServer:(NSString *)userId complete:(void (^)(RCDUserInfo *userInfo))completeBlock;

//设置当前用户昵称
+ (void)setCurrentUserName:(NSString *)name complete:(void (^)(BOOL success))completeBlock;

//设置当前用户头像
+ (void)setCurrentUserPortrait:(NSString *)portraitUri complete:(void (^)(BOOL success))completeBlock;

+ (void)findUserByPhone:(NSString *)phone
                 region:(NSString *)region
            orStAccount:(NSString *)stAccount
               complete:(void (^)(RCDUserInfo *userInfo))completeBlock;

+ (void)findUserByPhone:(NSString *)phone
                 region:(NSString *)region
               complete:(void (^)(RCDUserInfo *userInfo))completeBlock;

#pragma mark - blacklist
//将某个用户加入黑名单
+ (void)addToBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

//将某个用户移出黑名单
+ (void)removeFromBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

//查询某个用户是否已经在黑名单中
+ (BOOL)isInBlacklist:(NSString *)userId;

//从本地数据库获取黑名单列表
+ (NSArray<NSString *> *)getBlacklist;

// 从 server 获取黑名单列表
+ (void)getBlacklistFromServer:(void (^)(NSArray<NSString *> *blackUserIds))completeBlock;

#pragma mark - Friend
//从本地数据库获取好友信息
+ (RCDFriendInfo *)getFriendInfo:(NSString *)userId;

//从 server 拉取好友信息
+ (void)getFriendInfoFromServer:(NSString *)userId complete:(void (^)(RCDFriendInfo *friendInfo))completeBlock;

//从本地数据库获取接收的好友请求
+ (int)getFriendRequesteds;

//从本地数据库获取所有好友信息（已经成功添加好友）
+ (NSArray<RCDFriendInfo *> *)getAllFriends;

//获取所有好友信息（包含成功添加的以及尚未通过的）
+ (NSArray<RCDFriendInfo *> *)getAllFriendRequests;

//从 server 获取所有好友信息（包含成功添加的以及尚未通过的）
+ (void)getFriendListFromServer:(void (^)(NSArray<RCDFriendInfo *> *friendList))completeBlock;

//设置好友备注
+ (void)setFriendNickname:(NSString *)nickname
                 byUserId:(NSString *)userId
                 complete:(void (^)(BOOL success))completeBlock;

// 设置好友备注和描述
+ (void)setDescriptionWithUserId:(NSString *)friendId
                          remark:(NSString *)remark
                          region:(NSString *)region
                           phone:(NSString *)phone
                            desc:(NSString *)desc
                        imageUrl:(NSString *)imageUrl
                        complete:(void (^)(BOOL success))completeBlock;
// 获取好友备注和描述
+ (void)getDescriptionFromServer:(NSString *)friendId
                        complete:(void (^)(RCDFriendDescription *description))completeBlock;

+ (RCDFriendDescription *)getFriendDescription:(NSString *)friendId;

//由 RCDFriendInfo 转换成 RCUserInfo，使用 RCDFriendInfo 的 displayName 替换 RCUserInfo 的 name
+ (RCUserInfo *)getUserInfoFromFriendInfo:(RCDFriendInfo *)friendInfo;

+ (void)inviteFriend:(NSString *)userId
         withMessage:(NSString *)message
            complete:(void (^)(BOOL success, NSString *action))completeBlock;

+ (void)acceptFriendRequest:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

+ (void)ignoreFriendRequest:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

+ (void)deleteFriend:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

+ (void)setSTAccount:(NSString *)stAccount
            complete:(void (^)(BOOL success))completeBlock
               error:(void (^)(RCDUserErrorCode errorCode))errorBlock;

+ (void)setGender:(NSString *)gender complete:(void (^)(BOOL success))completeBlock;

// 批量删除好友
+ (void)batchFriendDelete:(NSArray *)friendIds complete:(void (^)(BOOL success))completeBlock;

#pragma mark - user setting
+ (void)setSearchMeByMobile:(BOOL)allow complete:(void (^)(BOOL success))completeBlock;

+ (void)setSearchMeBySTAccount:(BOOL)allow complete:(void (^)(BOOL success))completeBlock;

+ (void)setAddFriendVerify:(BOOL)needVerify complete:(void (^)(BOOL success))completeBlock;

+ (void)setJoinGroupVerify:(BOOL)needVerify complete:(void (^)(BOOL success))completeBlock;

+ (void)setReceivePokeMessage:(BOOL)allowReceive complete:(void (^)(BOOL success))completeBlock;

+ (BOOL)getReceivePokeMessageStatus;

+ (void)getReceivePokeMessageStatusFromServer:(void (^)(BOOL allowReceive))success error:(void (^)())error;

+ (RCDUserSetting *)getUserPrivacy;

+ (void)getUserPrivacyFromServer:(void (^)(RCDUserSetting *setting))completeBlock;
@end
