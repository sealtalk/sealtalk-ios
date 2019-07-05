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

@interface RCDUserInfoAPI : NSObject

+ (void)getUserInfo:(NSString *)userId
           complete:(void (^)(RCUserInfo *userInfo))completeBlock;

+ (void)getFriendInfo:(NSString *)userId
             complete:(void (^)(RCDFriendInfo *friendInfo))completeBlock;

+ (void)setCurrentUserName:(NSString *)name
                  complete:(void (^)(BOOL success))completeBlock;

+ (void)setCurrentUserPortrait:(NSString *)portraitUri
                      complete:(void (^)(BOOL success))completeBlock;

+ (void)setFriendNickname:(NSString *)nickname
                 byUserId:(NSString *)userId
                 complete:(void (^)(BOOL success))completeBlock;

+ (void)getFriendList:(void (^)(NSArray<RCDFriendInfo *> *friendList))completeBlock;

+ (void)inviteFriend:(NSString *)userId
         withMessage:(NSString *)message
            complete:(void (^)(BOOL success))completeBlock;

+ (void)acceptFriendRequest:(NSString *)userId
                   complete:(void (^)(BOOL success))completeBlock;

+ (void)deleteFriend:(NSString *)userId
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

// 查询已经设置的黑名单列表
+ (void)getBlacklist:(void (^)(NSArray <RCUserInfo *> *blackUsers))completeBlock;
@end

