//
//  RCDUserInfoAPI.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDUserInfoAPI.h"
#import "RCDHTTPUtility.h"
#import "RCDCommonString.h"
@implementation RCDUserInfoAPI

+ (void)getUserInfo:(NSString *)userId complete:(void (^)(RCDUserInfo *))completeBlock {
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
                                         RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
                                         userInfo.userId = userId;
                                         userInfo.name = result.content[@"nickname"];
                                         userInfo.portraitUri = result.content[@"portraitUri"];
                                         userInfo.stAccount = result.content[@"stAccount"];
                                         userInfo.gender = result.content[@"gender"];
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

+ (void)getFriendInfo:(NSString *)userId complete:(void (^)(RCDFriendInfo *))completeBlock {
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
                                         friendInfo.alias = friendInfo.displayName;
                                         NSDictionary *userDic = result.content[@"user"];
                                         friendInfo.name = userDic[@"nickname"];
                                         friendInfo.portraitUri = userDic[@"portraitUri"];
                                         friendInfo.status = RCDFriendStatusAgree;
                                         friendInfo.phoneNumber = userDic[@"phone"];
                                         friendInfo.updateDt = [userDic[@"updatedTime"] longLongValue];
                                         friendInfo.stAccount = userDic[@"stAccount"];
                                         friendInfo.gender = userDic[@"gender"];
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
                               parameters:@{
                                   @"nickname" : name
                               }
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
                               parameters:@{
                                   @"portraitUri" : portraitUri
                               }
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

+ (void)setFriendNickname:(NSString *)nickname byUserId:(NSString *)userId complete:(void (^)(BOOL))completeBlock {
    if (!userId || !nickname) {
        SealTalkLog(@"userId or nickname is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/set_display_name"
                               parameters:@{
                                   @"friendId" : userId,
                                   @"displayName" : nickname
                               }
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

+ (void)setSTAccount:(NSString *)stAccount
            complete:(void (^)(BOOL success))completeBlock
               error:(void (^)(RCDUserErrorCode errorCode))errorBlock {
    if (!stAccount) {
        SealTalkLog(@"stAccount is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/set_st_account"
                               parameters:@{
                                   @"stAccount" : stAccount
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (completeBlock) {
                                             completeBlock(YES);
                                         }
                                     } else {
                                         if (result.httpCode == 400) {
                                             errorBlock(RCDUserErrorCodeInvalidFormat);
                                         } else if (result.errorCode == 1000) {
                                             errorBlock(RCDUserErrorCodeStAccountIsExist);
                                         } else {
                                             errorBlock(RCDUserErrorCodeUnknown);
                                         }
                                     }
                                 }];
}

+ (void)setGender:(NSString *)gender complete:(void (^)(BOOL success))completeBlock {
    if (!gender) {
        SealTalkLog(@"stAccount is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/set_gender"
                               parameters:@{
                                   @"gender" : gender
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
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
                                             friendInfo.alias = friendInfo.displayName;
                                             friendInfo.status = [respFriend[@"status"] integerValue];
                                             friendInfo.phoneNumber = userDic[@"phone"];
                                             friendInfo.stAccount = userDic[@"stAccount"];
                                             friendInfo.gender = userDic[@"gender"];
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
            complete:(void (^)(BOOL, NSString *))completeBlock {
    if (!userId || !message) {
        SealTalkLog(@"userId or message is nil");
        if (completeBlock) {
            completeBlock(NO, @"");
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/invite"
                               parameters:@{
                                   @"friendId" : userId,
                                   @"message" : message
                               }
                                 response:^(RCDHTTPResult *result) {
                                     NSString *action = result.content[@"action"];
                                     if (completeBlock) {
                                         completeBlock(result.success, action);
                                     }
                                 }];
}

+ (void)acceptFriendRequest:(NSString *)userId complete:(void (^)(BOOL))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/agree"
                               parameters:@{
                                   @"friendId" : userId
                               }
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

+ (void)ignoreFriendRequest:(NSString *)userId complete:(void (^)(BOOL success))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/ignore"
                               parameters:@{
                                   @"friendId" : userId
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)deleteFriend:(NSString *)userId complete:(void (^)(BOOL))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/delete"
                               parameters:@{
                                   @"friendId" : userId
                               }
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
            orStAccount:(NSString *)stAccount
               complete:(void (^)(RCDUserInfo *))completeBlock {
    if (!phone && !region && !stAccount) {
        SealTalkLog(@"phone region and stAccount is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    NSString *params = @"";
    if (stAccount) {
        params = [NSString stringWithFormat:@"st_account=%@", stAccount];
    } else {
        params = [NSString stringWithFormat:@"region=%@&phone=%@", region, phone];
    }

    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:[NSString stringWithFormat:@"user/find_user?%@", params]
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (result.content) {
                                             RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
                                             userInfo.userId = result.content[@"id"];
                                             userInfo.name = result.content[@"nickname"];
                                             userInfo.portraitUri = result.content[@"portraitUri"];
                                             userInfo.stAccount = result.content[@"stAccount"];
                                             userInfo.gender = result.content[@"gender"];
                                             if (completeBlock) {
                                                 completeBlock(userInfo);
                                             }
                                         }else{
                                             if (completeBlock) {
                                                 completeBlock(nil);
                                             }
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

+ (void)findUserByPhone:(NSString *)phone region:(NSString *)region complete:(void (^)(RCDUserInfo *))completeBlock {
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
                                         RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
                                         userInfo.userId = result.content[@"id"];
                                         userInfo.name = result.content[@"nickname"];
                                         userInfo.portraitUri = result.content[@"portraitUri"];
                                         userInfo.stAccount = result.content[@"stAccount"];
                                         userInfo.gender = result.content[@"gender"];
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

+ (void)getContactsInfo:(NSArray *)phoneNumberList complete:(void (^)(NSArray *contactsList))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/get_contacts_info"
                               parameters:@{
                                   @"contactList" : phoneNumberList
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *list = result.content;
                                         if (completeBlock) {
                                             completeBlock(list);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

// 批量删除好友
+ (void)batchFriendDelete:(NSArray *)friendIds complete:(void (^)(BOOL success))completeBlock {
    if (!friendIds) {
        SealTalkLog(@"friendIds is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/batch_delete"
                               parameters:@{
                                   @"friendIds" : friendIds
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

//将某个用户加入黑名单
+ (void)addToBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/add_to_blacklist"
                               parameters:@{
                                   @"friendId" : userId
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

//将某个用户移出黑名单
+ (void)removeFromBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/remove_from_blacklist"
                               parameters:@{
                                   @"friendId" : userId
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

// 查询已经设置的黑名单列表
+ (void)getBlacklist:(void (^)(NSArray<RCDUserInfo *> *blackUsers))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/blacklist"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *list = result.content;
                                         NSMutableArray *users = [NSMutableArray array];
                                         for (NSDictionary *userJson in list) {
                                             NSDictionary *dic = userJson[@"user"];
                                             RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
                                             userInfo.userId = dic[@"id"];
                                             userInfo.name = dic[@"nickname"];
                                             userInfo.portraitUri = dic[@"portraitUri"];
                                             userInfo.stAccount = dic[@"stAccount"];
                                             userInfo.gender = dic[@"gender"];
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

#pragma mark - user setting
+ (void)setSearchMeByMobile:(BOOL)allow complete:(void (^)(BOOL))completeBlock {
    [self setUserPrivacy:@{ @"phoneVerify" : @(allow ? 1 : 0) } complete:completeBlock];
}

+ (void)setSearchMeBySTAccount:(BOOL)allow complete:(void (^)(BOOL))completeBlock {
    [self setUserPrivacy:@{ @"stSearchVerify" : @(allow ? 1 : 0) } complete:completeBlock];
}

+ (void)setAddFriendVerify:(BOOL)needVerify complete:(void (^)(BOOL))completeBlock {
    [self setUserPrivacy:@{ @"friVerify" : @(needVerify ? 1 : 0) } complete:completeBlock];
}

+ (void)setJoinGroupVerify:(BOOL)needVerify complete:(void (^)(BOOL))completeBlock {
    [self setUserPrivacy:@{ @"groupVerify" : @(needVerify ? 1 : 0) } complete:completeBlock];
}

+ (void)setReceivePokeMessage:(BOOL)allowReceive complete:(void (^)(BOOL))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/set_poke"
                               parameters:@{
                                   @"pokeStatus" : @(allowReceive ? 1 : 0)
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)getReceivePokeMessageStatus:(void (^)(BOOL))success error:(void (^)())error {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/get_poke"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *dic = result.content;
                                         BOOL allow = [dic[@"pokeStatus"] boolValue];
                                         if (success) {
                                             success(allow);
                                         }
                                     } else {
                                         if (error) {
                                             error();
                                         }
                                     }
                                 }];
}

+ (void)getUserPrivacy:(void (^)(RCDUserSetting *))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/get_privacy"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *dic = result.content;
                                         RCDUserSetting *setting = [[RCDUserSetting alloc] initWithJson:dic];
                                         if (completeBlock) {
                                             completeBlock(setting);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

#pragma mark - Friend Description
+ (void)setDescriptionWithUserId:(NSString *)friendId
                          remark:(NSString *)remark
                          region:(NSString *)region
                           phone:(NSString *)phone
                            desc:(NSString *)desc
                        imageUrl:(NSString *)imageUrl
                        complete:(void (^)(BOOL success))completeBlock {
    if (!friendId) {
        SealTalkLog(@"friendId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }

    NSDictionary *params = @{
        @"friendId" : friendId,
        @"displayName" : remark,
        @"region" : region,
        @"phone" : phone,
        @"description" : desc,
        @"imageUri" : imageUrl
    };

    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/set_friend_description"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)getDescriptionWithUserId:(NSString *)friendId
                        complete:(void (^)(RCDFriendDescription *friendDescription))completeBlock {
    if (!friendId) {
        SealTalkLog(@"friendId is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }

    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/get_friend_description"
                               parameters:@{
                                   @"friendId" : friendId
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *dict = result.content;
                                         RCDFriendDescription *description =
                                             [[RCDFriendDescription alloc] initWithJson:dict];
                                         description.userId = friendId;
                                         if (completeBlock) {
                                             completeBlock(description);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

#pragma mark - private
+ (void)setUserPrivacy:(NSDictionary *)param complete:(void (^)(BOOL success))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/set_privacy"
                               parameters:param
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}
@end
