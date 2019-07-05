//
//  RCDUserInfoManager.m
//  RCloudMessage
//
//  Created by Jue on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDUserInfoManager.h"
#import "RCDGroupInfo.h"
#import "RCDUtilities.h"
#import "RCDUserInfoAPI.h"
#import "RCDDBManager.h"
#import <RongIMKit/RongIMKit.h>

@implementation RCDUserInfoManager

#pragma mark - User

+ (RCUserInfo *)getUserInfo:(NSString *)userId {
    RCUserInfo *userInfo = [RCDDBManager getUser:userId];
    userInfo = [self generateDefaultPortraitIfNeed:userInfo];
    return userInfo;
}

+ (void)getUserInfoFromServer:(NSString *)userId
                     complete:(void (^)(RCUserInfo *))completeBlock {
    [RCDUserInfoAPI getUserInfo:userId
                       complete:^(RCUserInfo *userInfo) {
                           if (!userInfo) {
                               userInfo = [[RCUserInfo alloc] init];
                               userInfo.userId = userId;
                               userInfo.name = [self generateDefaultName:userId];
                           }
                           [RCDDBManager saveUsers:@[userInfo]];
                           userInfo = [self generateDefaultPortraitIfNeed:userInfo];
                           [self refreshIMUserInfo:userInfo];
                           if (completeBlock) {
                               completeBlock(userInfo);
                           }
                       }];
}

+ (void)setCurrentUserName:(NSString *)name complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI setCurrentUserName:name complete:^(BOOL success) {
        if (success) {
            RCUserInfo *currentUser = [RCIM sharedRCIM].currentUserInfo;
            currentUser.name = name;
            [RCDDBManager saveUsers:@[currentUser]];
            [RCIM sharedRCIM].currentUserInfo = currentUser;
            [[RCIM sharedRCIM] refreshUserInfoCache:currentUser withUserId:currentUser.userId];
        }
        if (completeBlock) {
            completeBlock(success);
        }
    }];
}

+ (void)setCurrentUserPortrait:(NSString *)portraitUri complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI setCurrentUserPortrait:portraitUri complete:^(BOOL success) {
        if (success) {
            RCUserInfo *currentUser = [RCIM sharedRCIM].currentUserInfo;
            currentUser.portraitUri = portraitUri;
            [RCDDBManager saveUsers:@[currentUser]];
            [RCIM sharedRCIM].currentUserInfo = currentUser;
            [[RCIM sharedRCIM] refreshUserInfoCache:currentUser withUserId:currentUser.userId];
        }
        if (completeBlock) {
            completeBlock(success);
        }
    }];
}

+ (void)findUserByPhone:(NSString *)phone
                 region:(NSString *)region
               complete:(void (^)(RCUserInfo *userInfo))completeBlock {
    [RCDUserInfoAPI findUserByPhone:phone
                             region:region
                           complete:completeBlock];
}

+ (RCUserInfo *)generateDefaultPortraitIfNeed:(RCUserInfo *)userInfo {
    if (userInfo) {
        if (userInfo.portraitUri.length <= 0) {
            userInfo.portraitUri = [RCDUtilities defaultUserPortrait:userInfo];
        }
    }
    return userInfo;
}

+ (void)refreshIMUserInfo:(RCUserInfo *)userInfo {
    if (userInfo) {
        RCDFriendInfo *friendInfo = [RCDDBManager getFriend:userInfo.userId];
        if (friendInfo.displayName.length <= 0) {
            [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
        } else {
            RCUserInfo *refreshUser = [[RCUserInfo alloc] initWithUserId:userInfo.userId
                                                                    name:friendInfo.displayName
                                                                portrait:userInfo.portraitUri];
            [[RCIM sharedRCIM] refreshUserInfoCache:refreshUser withUserId:userInfo.userId];
        }
    }
}

+ (NSString *)generateDefaultName:(NSString *)userId {
    return [NSString stringWithFormat:@"name%@", userId];
}

#pragma mark - blacklist
//将某个用户加入黑名单
+ (void)addToBlacklist:(NSString *)userId
              complete:(void (^)(BOOL success))completeBlock{
    [RCDUserInfoAPI addToBlacklist:userId complete:^(BOOL success) {
        [RCDDBManager addBlacklist:@[userId]];
        [RCDDBManager deleteFriends:@[userId]];
        if (completeBlock) {
            completeBlock(success);
        }
    }];
}

//将某个用户移出黑名单
+ (void)removeFromBlacklist:(NSString *)userId
                   complete:(void (^)(BOOL success))completeBlock{
    [RCDUserInfoAPI removeFromBlacklist:userId complete:^(BOOL success) {
        [RCDDBManager removeBlacklist:@[userId]];
        if (completeBlock) {
            completeBlock(success);
        }
    }];
}

//查询某个用户是否已经在黑名单中
+ (BOOL)isInBlacklist:(NSString *)userId{
    if ([[self getBlacklist] containsObject:userId]) {
        return YES;
    }
    return NO;
}

//从本地数据库获取黑名单列表
+ (NSArray <NSString *> *)getBlacklist{
    return [RCDDBManager getBlacklist];
}

// 从 server 获取黑名单列表
+ (void)getBlacklistFromServer:(void (^)(NSArray <NSString *> *blackUserIds))completeBlock{
    [RCDUserInfoAPI getBlacklist:^(NSArray<RCUserInfo *> *blackUsers) {
        if (blackUsers) {
            [RCDDBManager clearBlacklist];
            NSMutableArray *list = [NSMutableArray array];
            for (RCUserInfo *user in blackUsers) {
                [list addObject:user.userId];
            }
            if (blackUsers) {
                [RCDDBManager saveUsers:blackUsers];
            }
            if (completeBlock) {
                completeBlock(list.copy);
            }
        }else{
            if (completeBlock) {
                completeBlock(nil);
            }
        }
    }];
}

#pragma mark - Friend

+ (RCDFriendInfo *)getFriendInfo:(NSString *)userId {
    RCDFriendInfo *friendInfo = [RCDDBManager getFriend:userId];
    return friendInfo;
}

+ (void)getFriendInfoFromServer:(NSString *)userId
                       complete:(void (^)(RCDFriendInfo *))completeBlock {
    [RCDUserInfoAPI getFriendInfo:userId
                         complete:^(RCDFriendInfo *friendInfo) {
                             if (friendInfo) {
                                 [RCDDBManager saveFriends:@[friendInfo]];
                             }else{
                                 friendInfo = [self getFriendInfo:userId];
                             }
                             RCUserInfo *user = [self getUserInfoFromFriendInfo:friendInfo];
                             [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
                             if (completeBlock) {
                                 completeBlock(friendInfo);
                             }
                         }];
}

+ (NSArray<RCDFriendInfo *> *)getAllFriends {
    return [RCDDBManager getAllFriends];
}

+ (NSArray<RCDFriendInfo *> *)getAllFriendRequests {
    return [RCDDBManager getAllFriendRequests];
}

+ (void)setFriendNickname:(NSString *)nickname
                 byUserId:(NSString *)userId
                 complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI setFriendNickname:nickname byUserId:userId complete:^(BOOL success) {
        if (success) {
            RCDFriendInfo *friend = [RCDDBManager getFriend:userId];
            friend.displayName = nickname;
            [RCDDBManager saveFriends:@[friend]];
            RCUserInfo *user = [self getUserInfoFromFriendInfo:friend];
            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
        }
        if (completeBlock) {
            completeBlock(success);
        }
    }];
}

+ (void)getFriendListFromServer:(void (^)(NSArray<RCDFriendInfo *> *))completeBlock {
    [RCDUserInfoAPI getFriendList:^(NSArray<RCDFriendInfo *> *friendList) {
        [RCDDBManager clearFriends];
        [RCDDBManager saveFriends:friendList];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            for (RCDFriendInfo *friendInfo in friendList) {
                RCUserInfo *userInfo = [self getUserInfoFromFriendInfo:friendInfo];
                [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
            }
        });
        if (completeBlock) {
            completeBlock(friendList);
        }
    }];
}

+ (void)inviteFriend:(NSString *)userId
         withMessage:(NSString *)message
            complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI inviteFriend:userId
                     withMessage:message
                        complete:^(BOOL success) {
                            if (success) {
                                [self getFriendListFromServer:nil];
                            }
                            if (completeBlock) {
                                completeBlock(success);
                            }
                        }];
}

+ (void)acceptFriendRequest:(NSString *)userId complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI acceptFriendRequest:userId
                               complete:^(BOOL success) {
                                   if (success) {
                                       [self getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
                                           if (completeBlock) {
                                               completeBlock(YES);
                                           }
                                       }];
                                   } else {
                                       if (completeBlock) {
                                           completeBlock(NO);
                                       }
                                   }
                               }];
}

+ (RCUserInfo *)getUserInfoFromFriendInfo:(RCDFriendInfo *)friendInfo {
    RCUserInfo *user = [[RCUserInfo alloc] init];
    user.userId = friendInfo.userId;
    user.name = friendInfo.name;
    if (friendInfo.displayName.length > 0) {
        user.name = friendInfo.displayName;
    }
    user.portraitUri = friendInfo.portraitUri;
    if(friendInfo.portraitUri.length <= 0){
        user.portraitUri = [RCDUtilities defaultUserPortrait:friendInfo];
    }
    return user;
}

+ (void)deleteFriend:(NSString *)userId complete:(void (^)(BOOL))completeBlock{
    [RCDUserInfoAPI deleteFriend:userId complete:^(BOOL success) {
        if (success) {
            [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE targetId:userId];
            [RCDDBManager deleteFriends:@[userId]];
        }
        if (completeBlock) {
            completeBlock(success);
        }
    }];
}
@end
