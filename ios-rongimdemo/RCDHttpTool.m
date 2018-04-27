//
//  RCDHttpTool.m
//  RCloudMessage
//
//  Created by Liv on 15/4/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDHttpTool.h"
#import "AFHttpTool.h"
#import "RCDGroupInfo.h"
#import "RCDRCIMDataSource.h"
#import "RCDUserInfo.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "SortForTime.h"

@implementation RCDHttpTool

+ (RCDHttpTool *)shareInstance {
    static RCDHttpTool *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        instance.allGroups = [NSMutableArray new];
        instance.allFriends = [NSMutableArray new];
    });
    return instance;
}

//创建群组
- (void)createGroupWithGroupName:(NSString *)groupName
                 GroupMemberList:(NSArray *)groupMemberList
                        complete:(void (^)(NSString *))userId {
    [AFHttpTool createGroupWithGroupName:groupName
        groupMemberList:groupMemberList
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                NSDictionary *result = response[@"result"];
                userId(result[@"id"]);
            } else {
                userId(nil);
            }
        }
        failure:^(NSError *err) {
            userId(nil);
        }];
}

//设置群组头像
- (void)setGroupPortraitUri:(NSString *)portraitUri groupId:(NSString *)groupId complete:(void (^)(BOOL))result {
    [AFHttpTool setGroupPortraitUri:portraitUri
        groupId:groupId
        success:^(id response) {
            if ([response[@"code"] intValue] == 200) {
                result(YES);
            } else {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            result(NO);
        }];
}

//根据id获取单个群组
- (void)getGroupByID:(NSString *)groupID successCompletion:(void (^)(RCDGroupInfo *group))completion {
    [AFHttpTool getGroupByID:groupID
        success:^(id response) {
            NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
            NSDictionary *result = response[@"result"];
            if (result && [code isEqualToString:@"200"]) {
                RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                group.groupId = [result objectForKey:@"id"];
                group.groupName = [result objectForKey:@"name"];
                group.portraitUri = [result objectForKey:@"portraitUri"];
                if (!group.portraitUri || group.portraitUri.length <= 0) {
                    group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                }
                group.creatorId = [result objectForKey:@"creatorId"];
                group.introduce = [result objectForKey:@"introduce"];
                if (!group.introduce) {
                    group.introduce = @"";
                }
                group.number = [result objectForKey:@"memberCount"];
                group.maxNumber = [result objectForKey:@"max_number"];
                group.creatorTime = [result objectForKey:@"creat_datetime"];
                if (![[result objectForKey:@"deletedAt"] isKindOfClass:[NSNull class]]) {
                    group.isDismiss = @"YES";
                } else {
                    group.isDismiss = @"NO";
                }
                [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                if ([group.groupId isEqualToString:groupID] && completion) {
                    completion(group);
                } else if (completion) {
                    completion(nil);
                }
            } else {
                if (completion) {
                    completion(nil);
                }
            }
        }
        failure:^(NSError *err) {
            RCDGroupInfo *group = [[RCDataBaseManager shareInstance] getGroupByGroupId:groupID];
            if (!group.portraitUri || group.portraitUri.length <= 0) {
                group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
            }
            completion(group);
        }];
}

//根据userId获取单个用户信息
- (void)getUserInfoByUserID:(NSString *)userID completion:(void (^)(RCUserInfo *user))completion {
    RCUserInfo *userInfo = [[RCDataBaseManager shareInstance] getUserByUserId:userID];
    if (!userInfo) {
        [AFHttpTool getUserInfo:userID
            success:^(id response) {
                if (response) {
                    NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
                    if ([code isEqualToString:@"200"]) {
                        NSDictionary *dic = response[@"result"];
                        RCUserInfo *user = [RCUserInfo new];
                        user.userId = dic[@"id"];
                        user.name = [dic objectForKey:@"nickname"];
                        user.portraitUri = [dic objectForKey:@"portraitUri"];
                        if (!user.portraitUri || user.portraitUri.length <= 0) {
                            user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                        }
                        [[RCDataBaseManager shareInstance] insertUserToDB:user];
                        if (completion) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(user);
                            });
                        }
                    } else {
                        RCUserInfo *user = [RCUserInfo new];
                        user.userId = userID;
                        user.name = [NSString stringWithFormat:@"name%@", userID];
                        user.portraitUri = [RCDUtilities defaultUserPortrait:user];

                        if (completion) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(user);
                            });
                        }
                    }
                } else {
                    RCUserInfo *user = [RCUserInfo new];
                    user.userId = userID;
                    user.name = [NSString stringWithFormat:@"name%@", userID];
                    user.portraitUri = [RCDUtilities defaultUserPortrait:user];

                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(user);
                        });
                    }
                }
            }
            failure:^(NSError *err) {
                NSLog(@"getUserInfoByUserID error");
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        RCUserInfo *user = [RCUserInfo new];
                        user.userId = userID;
                        user.name = [NSString stringWithFormat:@"name%@", userID];
                        user.portraitUri = [RCDUtilities defaultUserPortrait:user];

                        completion(user);
                    });
                }
            }];
    } else {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!userInfo.portraitUri || userInfo.portraitUri.length <= 0) {
                    userInfo.portraitUri = [RCDUtilities defaultUserPortrait:userInfo];
                }
                completion(userInfo);
            });
        }
    }
}

//设置用户头像上传到demo server
- (void)setUserPortraitUri:(NSString *)portraitUri complete:(void (^)(BOOL))result {
    [AFHttpTool setUserPortraitUri:portraitUri
        success:^(id response) {
            if ([response[@"code"] intValue] == 200) {
                result(YES);
            } else {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            result(NO);
        }];
}

//获取当前用户所在的所有群组信息
- (void)getMyGroupsWithBlock:(void (^)(NSMutableArray *result))block {
    [AFHttpTool getMyGroupsSuccess:^(id response) {
        NSArray *allGroups = response[@"result"];
        NSMutableArray *tempArr = [NSMutableArray new];
        if (allGroups) {
            NSMutableArray *groups = [NSMutableArray new];
            [[RCDataBaseManager shareInstance] clearGroupfromDB];
            for (NSDictionary *dic in allGroups) {
                NSDictionary *groupInfo = dic[@"group"];
                RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                group.groupId = [groupInfo objectForKey:@"id"];
                group.groupName = [groupInfo objectForKey:@"name"];
                group.portraitUri = [groupInfo objectForKey:@"portraitUri"];
                if (!group.portraitUri || group.portraitUri.length == 0) {
                    group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                }
                group.creatorId = [groupInfo objectForKey:@"creatorId"];
                //                group.introduce = [dic objectForKey:@"introduce"];
                if (!group.introduce) {
                    group.introduce = @"";
                }
                group.number = [groupInfo objectForKey:@"memberCount"];
                group.maxNumber = @"500";
                if (!group.number) {
                    group.number = @"";
                }
                if (!group.maxNumber) {
                    group.maxNumber = @"";
                }
                [tempArr addObject:group];
                group.isJoin = YES;
                [groups addObject:group];
                //        dispatch_async(
                //            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                //              [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                //            });
            }
            [[RCDataBaseManager shareInstance] insertGroupsToDB:groups
                                                       complete:^(BOOL result) {
                                                           if (result == YES) {
                                                               if (block) {
                                                                   block(tempArr);
                                                               }
                                                           }
                                                       }];
        } else {
            block(nil);
        }
    }
        failure:^(NSError *err) {
            NSMutableArray *tempArr = [[RCDataBaseManager shareInstance] getAllGroup];
            for (RCDGroupInfo *group in tempArr) {
                if (!group.portraitUri || group.portraitUri.length <= 0) {
                    group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                }
            }
            block(tempArr);
        }];
}

//根据groupId获取群组成员信息
- (void)getGroupMembersWithGroupId:(NSString *)groupId Block:(void (^)(NSMutableArray *result))block {
    __block NSMutableArray *tempArr = [NSMutableArray new];
    [AFHttpTool getGroupMembersByID:groupId
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                NSArray *members = response[@"result"];
                for (NSDictionary *memberInfo in members) {
                    NSDictionary *tempInfo = memberInfo[@"user"];
                    RCDUserInfo *member = [[RCDUserInfo alloc] init];
                    member.userId = tempInfo[@"id"];
                    member.name = tempInfo[@"nickname"];
                    member.portraitUri = tempInfo[@"portraitUri"];
                    member.updatedAt = memberInfo[@"createdAt"];
                    member.displayName = memberInfo[@"displayName"];
                    if (!member.portraitUri || member.portraitUri <= 0) {
                        member.portraitUri = [RCDUtilities defaultUserPortrait:member];
                    }
                    [tempArr addObject:member];
                }
            }
            //按加成员入群组时间的升序排列
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                SortForTime *sort = [[SortForTime alloc] init];
                tempArr = [sort sortForUpdateAt:tempArr order:NSOrderedDescending];
                [[RCDataBaseManager shareInstance] insertGroupMemberToDB:tempArr
                                                                 groupId:groupId
                                                                complete:^(BOOL result) {
                                                                    if (result == YES) {
                                                                        if (block) {
                                                                            block(tempArr);
                                                                        }
                                                                    }
                                                                }];
            });
            
        }
                            failure:^(NSError *err) {
                                block(nil);
                            }];
}

//加入群组(暂时没有用到这个接口)
- (void)joinGroupWithGroupId:(NSString *)groupID complete:(void (^)(BOOL))result {
    [AFHttpTool joinGroupWithGroupId:groupID
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                result(YES);
            } else {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            result(NO);
        }];
}

//添加群组成员
- (void)addUsersIntoGroup:(NSString *)groupID usersId:(NSMutableArray *)usersId complete:(void (^)(BOOL))result {
    [AFHttpTool addUsersIntoGroup:groupID
        usersId:usersId
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                result(YES);
            } else {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            result(NO);
        }];
}

//将用户踢出群组
- (void)kickUsersOutOfGroup:(NSString *)groupID usersId:(NSMutableArray *)usersId complete:(void (^)(BOOL))result {
    [AFHttpTool kickUsersOutOfGroup:groupID
        usersId:usersId
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                result(YES);
            } else {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            result(NO);
        }];
}

//退出群组
- (void)quitGroupWithGroupId:(NSString *)groupID complete:(void (^)(BOOL))result {
    [AFHttpTool quitGroupWithGroupId:groupID
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                result(YES);
            } else {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            result(NO);
        }];
}

//解散群组
- (void)dismissGroupWithGroupId:(NSString *)groupID complete:(void (^)(BOOL))result {
    [AFHttpTool dismissGroupWithGroupId:groupID
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                result(YES);
            } else {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            result(NO);
        }];
}

//修改群组名称
- (void)renameGroupWithGoupId:(NSString *)groupID groupName:(NSString *)groupName complete:(void (^)(BOOL))result {
    [AFHttpTool renameGroupWithGroupId:groupID
        GroupName:groupName
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                result(YES);
            } else {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            result(NO);
        }];
}

- (void)getSquareInfoCompletion:(void (^)(NSMutableArray *result))completion {
    [AFHttpTool getSquareInfoSuccess:^(id response) {
        if ([response[@"code"] integerValue] == 200) {
            completion(response[@"result"]);
        } else {
            completion(nil);
        }
    }
        Failure:^(NSError *err) {
            completion(nil);
        }];
}

- (void)getFriendscomplete:(void (^)(NSMutableArray *))friendList {
    NSMutableArray *list = [NSMutableArray new];

    [AFHttpTool getFriendListFromServerSuccess:^(id response) {
        if (((NSArray *)response[@"result"]).count == 0) {
            friendList(nil);
            return;
        }
        NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
        if (friendList) {
            if ([code isEqualToString:@"200"]) {
                [_allFriends removeAllObjects];
                NSArray *regDataArray = response[@"result"];
                [[RCDataBaseManager shareInstance] clearFriendsData];
                NSMutableArray *userInfoList = [NSMutableArray new];
                NSMutableArray *friendInfoList = [NSMutableArray new];
                for (int i = 0; i < regDataArray.count; i++) {
                    NSDictionary *dic = [regDataArray objectAtIndex:i];

                    NSDictionary *userDic = dic[@"user"];
                    if ([userDic isKindOfClass:[NSDictionary class]] &&
                        ![userDic[@"id"] isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                        RCDUserInfo *userInfo = [RCDUserInfo new];
                        userInfo.userId = userDic[@"id"];
                        userInfo.name = userDic[@"nickname"];
                        userInfo.portraitUri = userDic[@"portraitUri"];
                        userInfo.displayName = dic[@"displayName"];
                        if (!userInfo.portraitUri || userInfo.portraitUri <= 0) {
                            userInfo.portraitUri = [RCDUtilities defaultUserPortrait:userInfo];
                        }
                        userInfo.status = [NSString stringWithFormat:@"%@", [dic objectForKey:@"status"]];
                        userInfo.updatedAt = [NSString stringWithFormat:@"%@", [dic objectForKey:@"updatedAt"]];
                        [list addObject:userInfo];
                        [_allFriends addObject:userInfo];

                        RCUserInfo *user = [RCUserInfo new];
                        user.userId = userDic[@"id"];
                        user.name = userDic[@"nickname"];
                        user.portraitUri = userDic[@"portraitUri"];
                        if (!user.portraitUri || user.portraitUri <= 0) {
                            user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                        }
                        [userInfoList addObject:user];
                        [friendInfoList addObject:userInfo];
                    }
                }
                [[RCDataBaseManager shareInstance] insertUserListToDB:userInfoList
                                                             complete:^(BOOL result){

                                                             }];
                [[RCDataBaseManager shareInstance]
                    insertFriendListToDB:friendInfoList
                                complete:^(BOOL result) {
                                    if (result == YES) {
                                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                                            friendList(list);
                                        });
                                    }
                                }];
            } else {
                friendList(list);
            }
        }
    }
        failure:^(id response) {
            if (friendList) {
                NSMutableArray *cacheList =
                    [[NSMutableArray alloc] initWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
                for (RCDUserInfo *userInfo in cacheList) {
                    if (!userInfo.portraitUri || userInfo.portraitUri <= 0) {
                        userInfo.portraitUri = [RCDUtilities defaultUserPortrait:userInfo];
                    }
                }
                friendList(cacheList);
            }
        }];
}

- (void)searchUserByPhone:(NSString *)phone complete:(void (^)(NSMutableArray *))userList {
    NSMutableArray *list = [NSMutableArray new];
    [AFHttpTool findUserByPhone:phone
        success:^(id response) {
            if (userList && [response[@"code"] intValue] == 200) {
                id result = response[@"result"];
                if ([result respondsToSelector:@selector(intValue)])
                    return;
                if ([result respondsToSelector:@selector(objectForKey:)]) {
                    RCDUserInfo *userInfo = [RCDUserInfo new];
                    userInfo.userId = [result objectForKey:@"id"];
                    userInfo.name = [result objectForKey:@"nickname"];
                    userInfo.portraitUri = [result objectForKey:@"portraitUri"];
                    if (!userInfo.portraitUri || userInfo.portraitUri <= 0) {
                        userInfo.portraitUri = [RCDUtilities defaultUserPortrait:userInfo];
                    }
                    [list addObject:userInfo];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        userList(list);
                    });
                }
            } else if (userList) {
                userList(nil);
            }
        }
        failure:^(NSError *err) {
            userList(nil);
        }];
}

- (void)requestFriend:(NSString *)userId complete:(void (^)(BOOL))result {
    [AFHttpTool inviteUser:userId
        success:^(id response) {
            if (result && [response[@"code"] intValue] == 200) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    result(YES);
                });
            } else if (result) {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            if (result) {
                result(NO);
            }
        }];
}

- (void)processInviteFriendRequest:(NSString *)userId complete:(void (^)(BOOL))result {
    [AFHttpTool processInviteFriendRequest:userId
        success:^(id response) {
            if (result && [response[@"code"] intValue] == 200) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    result(YES);
                });
            } else if (result) {
                result(NO);
            }
        }
        failure:^(id response) {
            if (result) {
                result(NO);
            }
        }];
}

- (void)AddToBlacklist:(NSString *)userId complete:(void (^)(BOOL result))result {
    [AFHttpTool addToBlacklist:userId
        success:^(id response) {
            NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
            if (result && [code isEqualToString:@"200"]) {
                result(YES);
            } else if (result) {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            if (result) {
                result(NO);
            }
        }];
}

- (void)RemoveToBlacklist:(NSString *)userId complete:(void (^)(BOOL result))result {
    [AFHttpTool removeToBlacklist:userId
        success:^(id response) {
            NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
            if (result && [code isEqualToString:@"200"]) {
                result(YES);
            } else if (result) {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            if (result) {
                result(NO);
            }
        }];
}

- (void)getBlacklistcomplete:(void (^)(NSMutableArray *))blacklist {
    [AFHttpTool getBlacklistsuccess:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
        if (blacklist && [code isEqualToString:@"200"]) {
            NSMutableArray *result = response[@"result"];
            blacklist(result);
        } else if (blacklist) {
            blacklist(nil);
        }
    }
        failure:^(NSError *err) {
            if (blacklist) {
                blacklist(nil);
            }
        }];
}

- (void)updateName:(NSString *)userName success:(void (^)(id response))success failure:(void (^)(NSError *err))failure {
    [AFHttpTool updateName:userName
        success:^(id response) {
            success(response);
        }
        failure:^(NSError *err) {
            failure(err);
        }];
}

- (void)updateUserInfo:(NSString *)userID
               success:(void (^)(RCDUserInfo *user))success
               failure:(void (^)(NSError *err))failure {
    [AFHttpTool getFriendDetailsByID:userID
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                NSDictionary *dic = response[@"result"];
                NSDictionary *infoDic = dic[@"user"];
                RCUserInfo *user = [RCUserInfo new];
                user.userId = infoDic[@"id"];
                user.name = [infoDic objectForKey:@"nickname"];
                NSString *portraitUri = [infoDic objectForKey:@"portraitUri"];
                if (!portraitUri || portraitUri.length <= 0) {
                    portraitUri = [RCDUtilities defaultUserPortrait:user];
                }
                user.portraitUri = portraitUri;
                [[RCDataBaseManager shareInstance] insertUserToDB:user];

                RCDUserInfo *Details = [[RCDataBaseManager shareInstance] getFriendInfo:userID];
                if (Details == nil) {
                    Details = [[RCDUserInfo alloc] init];
                }
                Details.name = [infoDic objectForKey:@"nickname"];
                Details.portraitUri = portraitUri;
                Details.displayName = dic[@"displayName"];
                [[RCDataBaseManager shareInstance] insertFriendToDB:Details];
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(Details);
                    });
                }
            }
        }
        failure:^(NSError *err) {
            failure(err);
        }];
    //  [AFHttpTool getUserInfo:userID
    //      success:^(id response) {
    //        if (response) {
    //          NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
    //          if ([code isEqualToString:@"200"]) {
    //            NSDictionary *dic = response[@"result"];
    //            RCUserInfo *user = [RCUserInfo new];
    //            user.userId = dic[@"id"];
    //            user.name = [dic objectForKey:@"nickname"];
    //            user.portraitUri = [dic objectForKey:@"portraitUri"];
    //            if (!user.portraitUri || user.portraitUri.length <= 0) {
    //              user.portraitUri = [RCDUtilities defaultUserPortrait:user];
    //            }
    //            [[RCDataBaseManager shareInstance] insertUserToDB:user];
    //            if (success) {
    //              dispatch_async(dispatch_get_main_queue(), ^{
    //                success(user);
    //              });
    //            }
    //          }
    //        }
    //      }
    //      failure:^(NSError *err) {
    //        failure(err);
    //      }];
}

- (void)uploadImageToQiNiu:(NSString *)userId
                 ImageData:(NSData *)image
                   success:(void (^)(NSString *url))success
                   failure:(void (^)(NSError *err))failure {
    [AFHttpTool uploadFile:image
        userId:userId
        success:^(id response) {
            NSString *imageUrl = nil;
            if ([response[@"key"] length] > 0) {
                NSString *key = response[@"key"];
                NSString *QiNiuDomai = [DEFAULTS objectForKey:@"QiNiuDomain"];
                imageUrl = [NSString stringWithFormat:@"http://%@/%@", QiNiuDomai, key];
            } else {
                NSDictionary *downloadInfo = response[@"rc_url"];
                if (downloadInfo) {
                    NSString *fileInfo = downloadInfo[@"path"];
                    if ([downloadInfo[@"type"] intValue] == 0) {
                        NSString *url = response[@"domain"];
                        if ([url hasSuffix:@"/"]) {
                            url = [url substringToIndex:url.length - 1];
                        }
                        if ([fileInfo hasPrefix:@"/"]) {
                            imageUrl = [url stringByAppendingString:fileInfo];
                        } else {
                            imageUrl = [url stringByAppendingPathComponent:fileInfo];
                        }
                    }
                }
            }
            success(imageUrl);
        }
        failure:^(NSError *err) {
            failure(err);
        }];
}

- (void)getVersioncomplete:(void (^)(NSDictionary *))versionInfo {
    [AFHttpTool getVersionsuccess:^(id response) {
        if (response) {
            NSDictionary *iOSResult = response[@"iOS"];
            NSString *sealtalkBuild = iOSResult[@"build"];
            NSString *applistURL = iOSResult[@"url"];

            NSDictionary *result;
            NSString *currentBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

            NSDate *currentBuildDate = [self stringToDate:currentBuild];
            NSDate *buildDtate = [self stringToDate:sealtalkBuild];
            NSTimeInterval secondsInterval = [currentBuildDate timeIntervalSinceDate:buildDtate];
            if (secondsInterval < 0) {
                result =
                    [NSDictionary dictionaryWithObjectsAndKeys:@"YES", @"isNeedUpdate", applistURL, @"applist", nil];
            } else {
                result = [NSDictionary dictionaryWithObjectsAndKeys:@"NO", @"isNeedUpdate", nil];
            }
            versionInfo(result);
        }
    }
        failure:^(NSError *err) {
            versionInfo(nil);
        }];
}
- (NSDate *)stringToDate:(NSString *)build {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
    NSDate *date = [dateFormatter dateFromString:build];
    return date;
}

//设置好友备注
- (void)setFriendDisplayName:(NSString *)friendId displayName:(NSString *)displayName complete:(void (^)(BOOL))result {
    [AFHttpTool setFriendDisplayName:friendId
        displayName:displayName
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                result(YES);
            } else {
                result(NO);
            }
        }
        failure:^(NSError *err) {
            result(NO);
        }];
}

//获取用户详细资料
- (void)getFriendDetailsWithFriendId:(NSString *)friendId
                             success:(void (^)(RCDUserInfo *user))success
                             failure:(void (^)(NSError *err))failure {
    [AFHttpTool getFriendDetailsByID:friendId
        success:^(id response) {
            if ([response[@"code"] integerValue] == 200) {
                NSDictionary *dic = response[@"result"];
                NSDictionary *infoDic = dic[@"user"];
                RCUserInfo *user = [RCUserInfo new];
                user.userId = infoDic[@"id"];
                user.name = [infoDic objectForKey:@"nickname"];
                NSString *portraitUri = [infoDic objectForKey:@"portraitUri"];
                if (!portraitUri || portraitUri.length <= 0) {
                    portraitUri = [RCDUtilities defaultUserPortrait:user];
                }
                user.portraitUri = portraitUri;
                [[RCDataBaseManager shareInstance] insertUserToDB:user];

                RCDUserInfo *Details = [[RCDataBaseManager shareInstance] getFriendInfo:friendId];
                if (Details == nil) {
                    Details = [[RCDUserInfo alloc] init];
                }
                Details.name = [infoDic objectForKey:@"nickname"];
                Details.portraitUri = portraitUri;
                Details.displayName = dic[@"displayName"];
                [[RCDataBaseManager shareInstance] insertFriendToDB:Details];
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(Details);
                    });
                }
            }
        }
        failure:^(NSError *err) {
            failure(err);
        }];
}

@end
