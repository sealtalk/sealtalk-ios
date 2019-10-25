//
//  RCDUserInfoAPI.h
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import "RCDFriendInfo.h"
#import "RCDEnum.h"
#import "RCDUserSetting.h"
#import "RCDUserInfo.h"
#import "RCDFriendDescription.h"

@interface RCDUserInfoAPI : NSObject

+ (void)getUserInfo:(NSString *)userId complete:(void (^)(RCDUserInfo *userInfo))completeBlock;

+ (void)getFriendInfo:(NSString *)userId complete:(void (^)(RCDFriendInfo *friendInfo))completeBlock;

+ (void)setCurrentUserName:(NSString *)name complete:(void (^)(BOOL success))completeBlock;

+ (void)setCurrentUserPortrait:(NSString *)portraitUri complete:(void (^)(BOOL success))completeBlock;

+ (void)setFriendNickname:(NSString *)nickname
                 byUserId:(NSString *)userId
                 complete:(void (^)(BOOL success))completeBlock;

+ (void)setSTAccount:(NSString *)stAccount
            complete:(void (^)(BOOL success))completeBlock
               error:(void (^)(RCDUserErrorCode errorCode))errorBlock;

+ (void)setGender:(NSString *)gender complete:(void (^)(BOOL success))completeBlock;

+ (void)getFriendList:(void (^)(NSArray<RCDFriendInfo *> *friendList))completeBlock;

// action: 添加好友请求状态 Added: 已添加 None: 在对方黑名单中 Sent: 请求已发送 AddDirectly: 直接添加对方
+ (void)inviteFriend:(NSString *)userId
         withMessage:(NSString *)message
            complete:(void (^)(BOOL success, NSString *action))completeBlock;

+ (void)acceptFriendRequest:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

+ (void)ignoreFriendRequest:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

+ (void)deleteFriend:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

+ (void)findUserByPhone:(NSString *)phone
                 region:(NSString *)region
            orStAccount:(NSString *)stAccount
               complete:(void (^)(RCDUserInfo *userInfo))completeBlock;

+ (void)findUserByPhone:(NSString *)phone
                 region:(NSString *)region
               complete:(void (^)(RCDUserInfo *userInfo))completeBlock;

// 获取通讯录朋友信息列表
+ (void)getContactsInfo:(NSArray *)phoneNumberList complete:(void (^)(NSArray *contactsList))completeBlock;

// 批量删除好友
+ (void)batchFriendDelete:(NSArray *)friendIds complete:(void (^)(BOOL success))completeBlock;

#pragma mark - blacklist
//将某个用户加入黑名单
+ (void)addToBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

//将某个用户移出黑名单
+ (void)removeFromBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock;

// 查询已经设置的黑名单列表
+ (void)getBlacklist:(void (^)(NSArray<RCDUserInfo *> *blackUsers))completeBlock;

#pragma mark - user setting
+ (void)setSearchMeByMobile:(BOOL)allow complete:(void (^)(BOOL success))completeBlock;

+ (void)setSearchMeBySTAccount:(BOOL)allow complete:(void (^)(BOOL success))completeBlock;

+ (void)setAddFriendVerify:(BOOL)needVerify complete:(void (^)(BOOL success))completeBlock;

+ (void)setJoinGroupVerify:(BOOL)needVerify complete:(void (^)(BOOL success))completeBlock;

+ (void)setReceivePokeMessage:(BOOL)allowReceive complete:(void (^)(BOOL success))completeBlock;

+ (void)getReceivePokeMessageStatus:(void (^)(BOOL allowReceive))success error:(void (^)())error;

+ (void)getUserPrivacy:(void (^)(RCDUserSetting *setting))completeBlock;

#pragma mark - Friend Description
+ (void)setDescriptionWithUserId:(NSString *)friendId
                          remark:(NSString *)remark
                          region:(NSString *)region
                           phone:(NSString *)phone
                            desc:(NSString *)desc
                        imageUrl:(NSString *)imageUrl
                        complete:(void (^)(BOOL success))completeBlock;

+ (void)getDescriptionWithUserId:(NSString *)friendId
                        complete:(void (^)(RCDFriendDescription *friendDescription))completeBlock;

@end
