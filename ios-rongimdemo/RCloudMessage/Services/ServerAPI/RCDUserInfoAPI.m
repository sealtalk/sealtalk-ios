//
//  RCDUserInfoAPI.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDUserInfoAPI.h"
#import "RCDHTTPUtility.h"

@implementation RCDUserInfoAPI

+ (void)getUserInfo:(NSString *)userId
           complete:(void (^)(RCUserInfo *))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:[NSString stringWithFormat:@"user/%@", userId]
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         RCUserInfo *userInfo = [[RCUserInfo alloc] init];
                                         userInfo.userId = userId;
                                         userInfo.name = result.content[@"nickname"];
                                         userInfo.portraitUri = result.content[@"portraitUri"];
                                         if (completeBlock) {
                                             completeBlock(userInfo);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

+ (void)getFriendInfo:(NSString *)userId
             complete:(void (^)(RCDFriendInfo *))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:[NSString stringWithFormat:@"friendship/%@/profile", userId]
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
                                         friendInfo.userId = userId;
                                         friendInfo.displayName = result.content[@"displayName"];
                                         NSDictionary *userDic = result.content[@"user"];
                                         friendInfo.name = userDic[@"nickname"];
                                         friendInfo.portraitUri = userDic[@"portraitUri"];
                                         friendInfo.status = RCDFriendStatusAgree;
                                         friendInfo.phoneNumber = userDic[@"phone"];
                                         friendInfo.updateDt = [result.content[@"updatedTime"] longLongValue];
                                         if (completeBlock) {
                                             completeBlock(friendInfo);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

+ (void)setCurrentUserName:(NSString *)name complete:(void (^)(BOOL))completeBlock {
    if (!name) {
        SealTalkLog(@"name is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/set_nickname"
                               parameters:@{@"nickname" : name}
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (completeBlock) {
                                             completeBlock(YES);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(NO);
                                         }
                                     }
                                 }];
}

+ (void)setCurrentUserPortrait:(NSString *)portraitUri complete:(void (^)(BOOL))completeBlock {
    if (!portraitUri) {
        SealTalkLog(@"portraitUri is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/set_portrait_uri"
                               parameters:@{@"portraitUri" : portraitUri}
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (completeBlock) {
                                             completeBlock(YES);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(NO);
                                         }
                                     }
                                 }];
}

+ (void)setFriendNickname:(NSString *)nickname
                 byUserId:(NSString *)userId
                 complete:(void (^)(BOOL))completeBlock {
    if (!userId || !nickname) {
        SealTalkLog(@"userId or nickname is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/set_display_name"
                               parameters:@{@"friendId":userId, @"displayName":nickname}
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (completeBlock) {
                                             completeBlock(YES);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(NO);
                                         }
                                     }
                                 }];
}

+ (void)getFriendList:(void (^)(NSArray<RCDFriendInfo *> *))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"friendship/all"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *respFriendList = result.content;
                                         NSMutableArray *friendList = [[NSMutableArray alloc] init];
                                         for (NSDictionary *respFriend in respFriendList) {
                                             NSDictionary *userDic = respFriend[@"user"];
                                             RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
                                             friendInfo.userId = userDic[@"id"];
                                             friendInfo.name = userDic[@"nickname"];
                                             friendInfo.portraitUri = userDic[@"portraitUri"];
                                             friendInfo.displayName = respFriend[@"displayName"];
                                             friendInfo.status = [respFriend[@"status"] integerValue];
                                             friendInfo.phoneNumber = userDic[@"phone"];
                                             friendInfo.updateDt = [respFriend[@"updatedTime"] longLongValue];
                                             [friendList addObject:friendInfo];
                                         }
                                         if (completeBlock) {
                                             completeBlock(friendList);
                                         }
                                     }
                                 }];
}

+ (void)inviteFriend:(NSString *)userId
         withMessage:(NSString *)message
            complete:(void (^)(BOOL))completeBlock {
    if (!userId || !message) {
        SealTalkLog(@"userId or message is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/invite"
                               parameters:@{@"friendId":userId, @"message":message}
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (completeBlock) {
                                             completeBlock(YES);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(NO);
                                         }
                                     }
                                 }];
}

+ (void)acceptFriendRequest:(NSString *)userId
                   complete:(void (^)(BOOL))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/agree"
                               parameters:@{@"friendId":userId}
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (completeBlock) {
                                             completeBlock(YES);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(NO);
                                         }
                                     }
                                 }];
}

+ (void)deleteFriend:(NSString *)userId complete:(void (^)(BOOL))completeBlock{
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/delete"
                               parameters:@{@"friendId":userId}
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (completeBlock) {
                                             completeBlock(YES);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(NO);
                                         }
                                     }
                                 }];
}

+ (void)findUserByPhone:(NSString *)phone
                 region:(NSString *)region
               complete:(void (^)(RCUserInfo *))completeBlock {
    if (!phone || !region) {
        SealTalkLog(@"phone or region is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:[NSString stringWithFormat:@"user/find/%@/%@", region, phone]
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         RCUserInfo *userInfo = [[RCUserInfo alloc] init];
                                         userInfo.userId = result.content[@"id"];
                                         userInfo.name = result.content[@"nickname"];
                                         userInfo.portraitUri = result.content[@"portraitUri"];
                                         if (completeBlock) {
                                             completeBlock(userInfo);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

//将某个用户加入黑名单
+ (void)addToBlacklist:(NSString *)userId
              complete:(void (^)(BOOL success))completeBlock{
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/add_to_blacklist"
                               parameters:@{@"friendId":userId}
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

//将某个用户移出黑名单
+ (void)removeFromBlacklist:(NSString *)userId
                   complete:(void (^)(BOOL success))completeBlock{
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/remove_from_blacklist"
                               parameters:@{@"friendId":userId}
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

// 查询已经设置的黑名单列表
+ (void)getBlacklist:(void (^)(NSArray <RCUserInfo *> *blackUsers))completeBlock{
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/blacklist"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *list = result.content;
                                         NSMutableArray *users = [NSMutableArray array];
                                         for (NSDictionary *userJson in list) {
                                             NSDictionary *dic = userJson[@"user"];
                                             RCUserInfo *userInfo = [[RCUserInfo alloc] init];
                                             userInfo.userId = dic[@"id"];
                                             userInfo.name = dic[@"nickname"];
                                             userInfo.portraitUri = dic[@"portraitUri"];
                                             [users addObject:userInfo];
                                         }
                                         if (completeBlock) {
                                             completeBlock(users);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
    
}
@end
