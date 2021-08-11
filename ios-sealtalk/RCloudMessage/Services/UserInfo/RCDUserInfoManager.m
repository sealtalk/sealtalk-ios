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
#import "RCDDBManager.h"
#import <RongIMKit/RongIMKit.h>
#define RCDReceivePokeKey [NSString stringWithFormat:@"RCDReceivePokeKey=%@", [RCIM sharedRCIM].currentUserInfo.userId]
@implementation RCDUserInfoManager

#pragma mark - User

+ (RCDUserInfo *)getUserInfo:(NSString *)userId {
    RCDUserInfo *userInfo = [RCDDBManager getUser:userId];
    userInfo = [self generateDefaultPortraitIfNeed:userInfo];
    return userInfo;
}

+ (void)getUserInfoFromServer:(NSString *)userId complete:(void (^)(RCDUserInfo *))completeBlock {
    [RCDUserInfoAPI getUserInfo:userId
                       complete:^(RCDUserInfo *userInfo) {
                           if (!userInfo) {
                               userInfo = [RCDDBManager getUser:userId];
                               if (!userInfo) {
                                   userInfo = [[RCDUserInfo alloc] init];
                                   userInfo.userId = userId;
                                   userInfo.name = [self generateDefaultName:userId];
                               }
                               userInfo = [self generateDefaultPortraitIfNeed:userInfo];
                           } else {
                               userInfo = [self generateDefaultPortraitIfNeed:userInfo];
                               [self refreshIMUserInfo:userInfo];
                               [RCDDBManager saveUsers:@[ userInfo ]];
                           }
                           if (completeBlock) {
                               completeBlock(userInfo);
                           }
                       }];
}

+ (void)setCurrentUserName:(NSString *)name complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI
        setCurrentUserName:name
                  complete:^(BOOL success) {
                      if (success) {
                          RCDUserInfo *currentUser = [self getUserInfo:[RCIM sharedRCIM].currentUserInfo.userId];
                          currentUser.name = name;
                          [RCDDBManager saveUsers:@[ currentUser ]];
                          [RCIM sharedRCIM].currentUserInfo = currentUser;
                          [[RCIM sharedRCIM] refreshUserInfoCache:currentUser withUserId:currentUser.userId];
                      }
                      if (completeBlock) {
                          completeBlock(success);
                      }
                  }];
}

+ (void)setCurrentUserPortrait:(NSString *)portraitUri complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI
        setCurrentUserPortrait:portraitUri
                      complete:^(BOOL success) {
                          if (success) {
                              RCDUserInfo *currentUser = [self getUserInfo:[RCIM sharedRCIM].currentUserInfo.userId];
                              currentUser.portraitUri = portraitUri;
                              [RCDDBManager saveUsers:@[ currentUser ]];
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
            orStAccount:(NSString *)stAccount
               complete:(void (^)(RCDUserInfo *))completeBlock {
    [RCDUserInfoAPI findUserByPhone:phone region:region orStAccount:stAccount complete:completeBlock];
}

+ (void)findUserByPhone:(NSString *)phone
                 region:(NSString *)region
               complete:(void (^)(RCDUserInfo *userInfo))completeBlock {
    [RCDUserInfoAPI findUserByPhone:phone region:region complete:completeBlock];
}

+ (RCDUserInfo *)generateDefaultPortraitIfNeed:(RCDUserInfo *)userInfo {
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
                                                                    name:userInfo.name
                                                                portrait:userInfo.portraitUri];
            refreshUser.alias = friendInfo.displayName;
            [[RCIM sharedRCIM] refreshUserInfoCache:refreshUser withUserId:userInfo.userId];
        }
    }
}

+ (NSString *)generateDefaultName:(NSString *)userId {
    return [NSString stringWithFormat:@"name%@", userId];
}

#pragma mark - blacklist
//将某个用户加入黑名单
+ (void)addToBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock {
    [RCDUserInfoAPI addToBlacklist:userId
                          complete:^(BOOL success) {
                              [RCDDBManager addBlacklist:@[ userId ]];
                              if (completeBlock) {
                                  completeBlock(success);
                              }
                          }];
}

//将某个用户移出黑名单
+ (void)removeFromBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock {
    [RCDUserInfoAPI removeFromBlacklist:userId
                               complete:^(BOOL success) {
                                   [RCDDBManager removeBlacklist:@[ userId ]];
                                   if (completeBlock) {
                                       completeBlock(success);
                                   }
                               }];
}

//查询某个用户是否已经在黑名单中
+ (BOOL)isInBlacklist:(NSString *)userId {
    if ([[self getBlacklist] containsObject:userId]) {
        return YES;
    }
    return NO;
}

//从本地数据库获取黑名单列表
+ (NSArray<NSString *> *)getBlacklist {
    return [RCDDBManager getBlacklist];
}

// 从 server 获取黑名单列表
+ (void)getBlacklistFromServer:(void (^)(NSArray<NSString *> *blackUserIds))completeBlock {
    [RCDUserInfoAPI getBlacklist:^(NSArray<RCDUserInfo *> *blackUsers) {
        if (blackUsers) {
            [RCDDBManager clearBlacklist];
            NSMutableArray *list = [NSMutableArray array];
            for (RCDUserInfo *user in blackUsers) {
                [list addObject:user.userId];
            }
            if (blackUsers) {
                [RCDDBManager saveUsers:blackUsers];
            }
            if (completeBlock) {
                completeBlock(list.copy);
            }
        } else {
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

+ (void)getFriendInfoFromServer:(NSString *)userId complete:(void (^)(RCDFriendInfo *))completeBlock {
    [RCDUserInfoAPI getFriendInfo:userId
                         complete:^(RCDFriendInfo *friendInfo) {
                             if (friendInfo) {
                                 [RCDDBManager saveFriends:@[ friendInfo ]];
                                 RCUserInfo *user = [self getUserInfoFromFriendInfo:friendInfo];
                                 [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
                             } else {
                                 bool isInBlacklist = [RCDUserInfoManager isInBlacklist:userId];
                                 if (!isInBlacklist) {
                                     friendInfo = [[RCDFriendInfo alloc] init];
                                     friendInfo.userId = userId;
                                     friendInfo.name = [self generateDefaultName:userId];
                                     friendInfo.displayName = @"";
                                     friendInfo.portraitUri = [RCDUtilities defaultUserPortrait:friendInfo];
                                     [RCDDBManager saveFriends:@[ friendInfo ]];
                                     RCUserInfo *user = [self getUserInfoFromFriendInfo:friendInfo];
                                     [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
                                 }                                 
                             }
                             friendInfo.alias = friendInfo.displayName;
                             if (completeBlock) {
                                 completeBlock(friendInfo);
                             }
                         }];
}

+ (int)getFriendRequesteds {
    return [RCDDBManager getFriendRequesteds];
}

+ (NSArray<RCDFriendInfo *> *)getAllFriends {
    return [RCDDBManager getAllFriends];
}

+ (NSArray<RCDFriendInfo *> *)getAllFriendRequests {
    return [RCDDBManager getAllFriendRequests];
}

+ (void)setFriendNickname:(NSString *)nickname byUserId:(NSString *)userId complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI setFriendNickname:nickname
                             byUserId:userId
                             complete:^(BOOL success) {
                                 if (success) {
                                     RCDFriendInfo *friend = [RCDDBManager getFriend:userId];
                                     friend.displayName = nickname;
                                     [RCDDBManager saveFriends:@[ friend ]];
                                     RCUserInfo *user = [self getUserInfoFromFriendInfo:friend];
                                     [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
                                 }
                                 if (completeBlock) {
                                     completeBlock(success);
                                 }
                             }];
}

+ (void)setDescriptionWithUserId:(NSString *)friendId
                          remark:(NSString *)remark
                          region:(NSString *)region
                           phone:(NSString *)phone
                            desc:(NSString *)desc
                        imageUrl:(NSString *)imageUrl
                        complete:(void (^)(BOOL success))completeBlock {

    if (imageUrl == nil) {
        imageUrl = @"";
    }
    if (region.length <= 0) {
        region = @"86";
    }
    [RCDUserInfoAPI setDescriptionWithUserId:friendId
                                      remark:remark
                                      region:region
                                       phone:phone
                                        desc:desc
                                    imageUrl:imageUrl
                                    complete:^(BOOL success) {
                                        if (success) {
                                            RCDFriendInfo *friend = [RCDDBManager getFriend:friendId];
                                            friend.displayName = remark;
                                            [RCDDBManager saveFriends:@[ friend ]];

                                            RCDFriendDescription *friendDescription =
                                                [[RCDFriendDescription alloc] init];
                                            friendDescription.userId = friendId;
                                            friendDescription.displayName = remark;
                                            friendDescription.region = region;
                                            friendDescription.phone = phone;
                                            friendDescription.desc = desc;
                                            friendDescription.imageUrl = imageUrl;
                                            [RCDDBManager saveFriendDescription:friendDescription];
                                        }
                                        if (completeBlock) {
                                            completeBlock(success);
                                        }
                                    }];
}

+ (void)getDescriptionFromServer:(NSString *)friendId
                        complete:(void (^)(RCDFriendDescription *description))completeBlock {
    [RCDUserInfoAPI getDescriptionWithUserId:friendId
                                    complete:^(RCDFriendDescription *friendDescription) {
                                        if (friendDescription) {
                                            friendDescription.userId = friendId;
                                            [RCDDBManager saveFriendDescription:friendDescription];
                                        }
                                        if (completeBlock) {
                                            completeBlock(friendDescription);
                                        }
                                    }];
}

+ (RCDFriendDescription *)getFriendDescription:(NSString *)friendId {
    return [RCDDBManager getFriendDescription:friendId];
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
            complete:(void (^)(BOOL, NSString *))completeBlock {
    [RCDUserInfoAPI inviteFriend:userId
                     withMessage:message
                        complete:^(BOOL success, NSString *action) {
                            if (success) {
                                [self getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
                                    if (completeBlock) {
                                        completeBlock(success, action);
                                    }
                                }];
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

+ (void)ignoreFriendRequest:(NSString *)userId complete:(void (^)(BOOL success))completeBlock {
    [RCDUserInfoAPI ignoreFriendRequest:userId
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
        user.alias = friendInfo.displayName;
    }
    user.portraitUri = friendInfo.portraitUri;
    if (friendInfo.portraitUri.length <= 0) {
        user.portraitUri = [RCDUtilities defaultUserPortrait:friendInfo];
    }
    return user;
}

+ (void)deleteFriend:(NSString *)userId complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI
        deleteFriend:userId
            complete:^(BOOL success) {
                if (success) {
                    [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE targetId:userId];
                    [RCDDBManager deleteFriends:@[ userId ]];
                }
                if (completeBlock) {
                    completeBlock(success);
                }
            }];
}

+ (void)setSTAccount:(NSString *)stAccount
            complete:(void (^)(BOOL success))completeBlock
               error:(void (^)(RCDUserErrorCode errorCode))errorBlock {

    [RCDUserInfoAPI setSTAccount:stAccount
                        complete:^(BOOL success) {
                            if (success) {
                                RCDUserInfo *currentUser = [self getUserInfo:[RCIM sharedRCIM].currentUserInfo.userId];
                                currentUser.stAccount = stAccount;
                                [RCDDBManager saveUsers:@[ currentUser ]];
                            }
                            if (completeBlock) {
                                completeBlock(success);
                            }
                        }
                           error:errorBlock];
}

+ (void)setGender:(NSString *)gender complete:(void (^)(BOOL success))completeBlock {
    [RCDUserInfoAPI setGender:gender
                     complete:^(BOOL success) {
                         if (success) {
                             RCDUserInfo *currentUser = [self getUserInfo:[RCIM sharedRCIM].currentUserInfo.userId];
                             currentUser.gender = gender;
                             [RCDDBManager saveUsers:@[ currentUser ]];
                         }
                         if (completeBlock) {
                             completeBlock(success);
                         }
                     }];
}

// 批量删除好友
+ (void)batchFriendDelete:(NSArray *)friendIds complete:(void (^)(BOOL success))completeBlock {
    [RCDUserInfoAPI
        batchFriendDelete:friendIds
                 complete:^(BOOL success) {
                     if (success) {
                         for (NSString *friendId in friendIds) {
                             [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_PRIVATE
                                                                      targetId:friendId];
                             [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE targetId:friendId];
                         }
                         [RCDDBManager deleteFriends:friendIds];
                         [self getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
                             if (completeBlock) {
                                 completeBlock(success);
                             }
                         }];
                     } else {
                         if (completeBlock) {
                             completeBlock(success);
                         }
                     }
                 }];
}

#pragma mark - user setting
+ (void)setSearchMeByMobile:(BOOL)allow complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI setSearchMeByMobile:allow
                               complete:^(BOOL success) {
                                   if (success) {
                                       RCDUserSetting *setting = [self getUserPrivacy];
                                       setting.allowMobileSearch = allow;
                                       [RCDDBManager saveUserSetting:setting];
                                   }
                                   if (completeBlock) {
                                       completeBlock(success);
                                   }
                               }];
}

+ (void)setSearchMeBySTAccount:(BOOL)allow complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI setSearchMeBySTAccount:allow
                                  complete:^(BOOL success) {
                                      if (success) {
                                          RCDUserSetting *setting = [self getUserPrivacy];
                                          setting.allowSTAccountSearch = allow;
                                          [RCDDBManager saveUserSetting:setting];
                                      }
                                      if (completeBlock) {
                                          completeBlock(success);
                                      }
                                  }];
}

+ (void)setAddFriendVerify:(BOOL)needVerify complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI setAddFriendVerify:needVerify
                              complete:^(BOOL success) {
                                  if (success) {
                                      RCDUserSetting *setting = [self getUserPrivacy];
                                      setting.needAddFriendVerify = needVerify;
                                      [RCDDBManager saveUserSetting:setting];
                                  }
                                  if (completeBlock) {
                                      completeBlock(success);
                                  }
                              }];
}

+ (void)setJoinGroupVerify:(BOOL)needVerify complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI setJoinGroupVerify:needVerify
                              complete:^(BOOL success) {
                                  if (success) {
                                      RCDUserSetting *setting = [self getUserPrivacy];
                                      setting.needJoinGroupVerify = needVerify;
                                      [RCDDBManager saveUserSetting:setting];
                                  }
                                  if (completeBlock) {
                                      completeBlock(success);
                                  }
                              }];
}

+ (void)setReceivePokeMessage:(BOOL)allowReceive complete:(void (^)(BOOL))completeBlock {
    [RCDUserInfoAPI setReceivePokeMessage:allowReceive
                                 complete:^(BOOL success) {
                                     if (success) {
                                         [[NSUserDefaults standardUserDefaults] setObject:@(!allowReceive)
                                                                                   forKey:RCDReceivePokeKey];
                                     }
                                     if (completeBlock) {
                                         completeBlock(success);
                                     }
                                 }];
}

+ (BOOL)getReceivePokeMessageStatus {
    BOOL allow = ![[NSUserDefaults standardUserDefaults] boolForKey:RCDReceivePokeKey];
    return allow;
}

+ (void)getReceivePokeMessageStatusFromServer:(void (^)(BOOL))success error:(void (^)())error {
    [RCDUserInfoAPI getReceivePokeMessageStatus:^(BOOL allowReceive) {
        [[NSUserDefaults standardUserDefaults] setObject:@(!allowReceive) forKey:RCDReceivePokeKey];
    }
                                          error:error];
}

+ (RCDUserSetting *)getUserPrivacy {
    RCDUserSetting *userSetting = [RCDDBManager getUserSetting];
    if (!userSetting) {
        userSetting = [[RCDUserSetting alloc] init];
        userSetting.userId = [RCIM sharedRCIM].currentUserInfo.userId;
        userSetting.allowMobileSearch = YES;
        userSetting.allowSTAccountSearch = YES;
        userSetting.needAddFriendVerify = YES;
        userSetting.needJoinGroupVerify = YES;
    }
    return userSetting;
}

+ (void)getUserPrivacyFromServer:(void (^)(RCDUserSetting *))completeBlock {
    [RCDUserInfoAPI getUserPrivacy:^(RCDUserSetting *setting) {
        if (setting) {
            [RCDDBManager saveUserSetting:setting];
        }
        if (completeBlock) {
            completeBlock(setting);
        }
    }];
}
@end
