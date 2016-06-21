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
#import "RCDUserInfo.h"
#import "RCDRCIMDataSource.h"
#import "RCDataBaseManager.h"

@implementation RCDHttpTool


+ (RCDHttpTool*)shareInstance
{
    static RCDHttpTool* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        instance.allGroups = [NSMutableArray new];
    });
    return instance;
}

-(void) isMyFriendWithUserInfo:(RCDUserInfo *)userInfo
                  completion:(void(^)(BOOL isFriend)) completion
{
    [self getFriends:userInfo.userId complete:^(NSMutableArray *result) {
        for (RCDUserInfo *user in result) {
            if ([user.userId isEqualToString:userInfo.userId] && completion && [@"1" isEqualToString:user.status]) {
                if (completion) {
                    completion(YES);
                }
                return ;
            }
        }
        if(completion){
            completion(NO);
        }
    }];
}

//创建群组
-(void) createGroupWithGroupName:(NSString *)groupName
                 GroupMemberList:(NSArray *)groupMemberList
                        complete:(void (^)(NSString *))userId
{
    [AFHttpTool createGroupWithGroupName:groupName
                         groupMemberList:groupMemberList
                                 success:^(id response) {
                                     if ([response[@"code"] integerValue] == 200) {
                                         NSDictionary *result = response[@"result"];
                                         userId(result[@"id"]);
                                     }
                                     
                                 } failure:^(NSError *err) {
                                     userId(nil);
                                 }];
    
    
    
}

//设置群组头像
-(void) setGroupPortraitUri:(NSString *)portraitUri
                    groupId:(NSString *)groupId
                   complete:(void (^)(BOOL))result
{
    [AFHttpTool setGroupPortraitUri:portraitUri
                            groupId:groupId
                           success:^(id response) {
                               if ([response[@"code"] intValue] == 200) {
                                   result(YES);
                               }
                               
                           }failure:^(NSError *err) {
                               result(NO);
                           }];
}

//根据id获取单个群组
-(void) getGroupByID:(NSString *) groupID
   successCompletion:(void (^)(RCDGroupInfo *group)) completion
{
//    RCGroup *groupInfo=[[RCDataBaseManager shareInstance] getGroupByGroupId:groupID];
//    if(groupInfo==nil)
//    {
        [AFHttpTool getGroupByID:groupID success:^(id response) {
            NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
            NSDictionary *result = response[@"result"];
            if (result && [code isEqualToString:@"200"]) {
                RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                group.groupId = [result objectForKey:@"id"];
                group.groupName = [result objectForKey:@"name"];
                group.portraitUri = [result objectForKey:@"portraitUri"];
                if (group.portraitUri == nil || group.portraitUri.length == 0) {
                    group.portraitUri=@"";
                }
                group.creatorId = [result objectForKey:@"creatorId"];
                group.introduce = [result objectForKey:@"introduce"];
                if (group.introduce) {
                    group.introduce=@"";
                }
                group.number = [result objectForKey:@"memberCount"];
                group.maxNumber = [result objectForKey:@"max_number"];
                group.creatorTime = [result objectForKey:@"creat_datetime"];
                if (![[result objectForKey:@"deletedAt"] isKindOfClass:[NSNull class]]) {
                    group.isDismiss = @"YES";
                }
                else
                {
                    group.isDismiss = @"NO";
                }
                [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                if ([group.groupId isEqualToString:groupID] && completion) {
                    completion(group);
                }
            }
            
        } failure:^(NSError* err){
                RCDGroupInfo *group=[[RCDataBaseManager shareInstance] getGroupByGroupId:groupID];
            completion(group);
        }];
//    }else{
//        if (completion) {
//            completion(groupInfo);
//        }
//
//    }
}

-(void) getUserInfoByUserID:(NSString *) userID
                         completion:(void (^)(RCUserInfo *user)) completion
{
    
    RCUserInfo *userInfo=[[RCDataBaseManager shareInstance] getUserByUserId:userID];
    if (userInfo==nil) {
        [AFHttpTool getUserInfo:userID success:^(id response) {
            if (response) {
                NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
                
                if ([code isEqualToString:@"200"]) {
                    
                    NSDictionary *dic = response[@"result"];
                    // NSLog(@"isMainThread > %d", [NSThread isMainThread]);
                    RCUserInfo *user = [RCUserInfo new];
                    user.userId = dic[@"id"];
                    user.portraitUri = [dic objectForKey:@"portraitUri"];
                    user.name = [dic objectForKey:@"nickname"];
                    [[RCDataBaseManager shareInstance] insertUserToDB:user];
                    
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(user);
                        });
                    }
                }
                else
                {
                    RCUserInfo *user = [RCUserInfo new];

                    user.userId = userID;
                    user.portraitUri = @"";
                    user.name = [NSString stringWithFormat:@"name%@", userID];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(user);
                    });
                }
                
            }
            
        } failure:^(NSError *err) {
            NSLog(@"getUserInfoByUserID error");
            if (completion) {
                @try {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        RCUserInfo *user = [RCUserInfo new];
                        
                        user.userId = userID;
                        user.portraitUri = @"";
                        user.name = [NSString stringWithFormat:@"name%@", userID];

                        completion(user);
                    });
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }
                
            }
        }];
    
    }else
    {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(userInfo);
            });
        }

    }
//    __block NSArray * regDataArray;
//    [AFHttpTool getFriendsSuccess:^(id response) {
//        if (response) {
//            NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
//
//            if ([code isEqualToString:@"200"]) {
//
//                regDataArray = response[@"result"];
//               // NSLog(@"isMainThread > %d", [NSThread isMainThread]);
//                
//                dispatch_group_leave(groupQueue);
//                
//            }
//            
//        }
//
//    } failure:^(NSError *err) {
//        NSLog(@"getUserInfoByUserID error");
//    }];
//    
//    dispatch_group_notify(groupQueue, dispatch_get_main_queue(), ^{
//        
//        dispatch_queue_t queue = dispatch_queue_create("handleResponseData.friends", DISPATCH_QUEUE_SERIAL);
//        
//        dispatch_async(queue, ^{
//
//            for(int i = 0;i < regDataArray.count;i++){
//                NSDictionary *dic = [regDataArray objectAtIndex:i];
//                //NSLog(@"userID > %@, id > %@, i > %d", userID, [dic objectForKey:@"id"], i);
//                if ([userID isEqualToString:[dic objectForKey:@"id"]]) {
//                   // NSLog(@"Matched i > %d, dic>%@", i, dic);
//                    RCUserInfo *userInfo = [RCUserInfo new];
//                    NSNumber *idNum = [dic objectForKey:@"id"];
//                    userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
//                    userInfo.portraitUri = [dic objectForKey:@"portrait"];
//                    userInfo.name = [dic objectForKey:@"username"];
//                    [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
//                    
//                    if (completion) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            completion(userInfo);
//                        });
//                    }
//                    
//                }
////                }else{
////                    NSLog(@"no matched userid > %d", i);
////                }
//            }
//        });
//    });
//    
}

-(void) setUserPortraitUri:(NSString *)portraitUri
              complete:(void (^)(BOOL))result
{
   [AFHttpTool setUserPortraitUri:portraitUri
                          success:^(id response) {
                          if ([response[@"code"] intValue] == 200) {
                              result(YES);
                          }
                          
                          }failure:^(NSError *err) {
                              result(NO);
                      }];
}

- (void)getAllGroupsWithCompletion:(void (^)(NSMutableArray* result))completion
{

    [AFHttpTool getAllGroupsSuccess:^(id response) {
        NSMutableArray *tempArr = [NSMutableArray new];
        NSArray *allGroups = response[@"result"];
        if (allGroups) {
            [[RCDataBaseManager shareInstance] clearGroupsData];
            for (NSDictionary *dic in allGroups) {
                RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                group.groupId = [dic objectForKey:@"id"];
                group.groupName = [dic objectForKey:@"name"];
                group.portraitUri = [dic objectForKey:@"portrait"];
                if (group.portraitUri) {
                    group.portraitUri=@"";
                }
                group.creatorId = [dic objectForKey:@"create_user_id"];
                group.introduce = [dic objectForKey:@"introduce"];
                if (group.introduce) {
                    group.introduce=@"";
                }
                group.number = [dic objectForKey:@"number"];
                group.maxNumber = [dic objectForKey:@"max_number"];
                group.creatorTime = [dic objectForKey:@"creat_datetime"];
                [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                [tempArr addObject:group];
            }
            
            //获取加入状态
            [self getMyGroupsWithBlock:^(NSMutableArray *result) {
                for (RCDGroupInfo *group in result) {
                    for (RCDGroupInfo *groupInfo in tempArr) {
                        if ([group.groupId isEqualToString:groupInfo.groupId]) {
                            groupInfo.isJoin = YES;
                           [[RCDataBaseManager shareInstance] insertGroupToDB:groupInfo];
                        }
                        
                    }
                }
                if (completion) {
                    [_allGroups removeAllObjects];
                    [_allGroups addObjectsFromArray:tempArr];
                    
                    completion(tempArr);
                }

            }];
        }

    } failure:^(NSError* err){
        NSMutableArray *cacheGroups=[[NSMutableArray alloc]initWithArray:[[RCDataBaseManager shareInstance] getAllGroup]];
        completion(cacheGroups);
    }];
}


-(void) getMyGroupsWithBlock:(void(^)(NSMutableArray* result)) block
{
    [AFHttpTool getMyGroupsSuccess:^(id response) {
        NSArray *allGroups = response[@"result"];
        NSMutableArray *tempArr = [NSMutableArray new];
        if (allGroups) {
            for (NSDictionary *dic in allGroups) {
                NSDictionary *groupInfo = dic[@"group"];
                RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                group.groupId = [groupInfo objectForKey:@"id"];
                group.groupName = [groupInfo objectForKey:@"name"];
                group.portraitUri = [groupInfo objectForKey:@"portraitUri"];
                if (group.portraitUri == nil || group.portraitUri.length == 0) {
                    group.portraitUri=@"";
                }
                group.creatorId = [groupInfo objectForKey:@"creatorId"];
//                group.introduce = [dic objectForKey:@"introduce"];
                if (group.introduce) {
                    group.introduce=@"";
                }
                group.number = [groupInfo objectForKey:@"memberCount"];
//                group.maxNumber = [dic objectForKey:@"max_number"];
                group.maxNumber = @"500";
//                group.creatorTime = [dic objectForKey:@"creat_datetime"];
                if (!group.number) {
                    group.number=@"";
                }
                if (!group.maxNumber) {
                    group.maxNumber=@"";
                }
                [tempArr addObject:group];
                group.isJoin = YES;
                [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                //[_allGroups addObject:group];
            }
            
            if (block) {
                block(tempArr);
            }
        }

    } failure:^(NSError *err) {
        NSMutableArray *tempArr = [NSMutableArray new];
        tempArr = [[RCDataBaseManager shareInstance] getAllGroup];
        block(tempArr);
    }];
}

-(void) getGroupMembersWithGroupId:(NSString *)groupId Block:(void(^)(NSMutableArray* result)) block
{
    [AFHttpTool getGroupMembersByID:groupId
                            success:^(id response)
    {
        NSMutableArray *tempArr = [NSMutableArray new];
        if ([response[@"code"] integerValue] == 200) {
            NSArray *members = response[@"result"];
            for (NSDictionary *memberInfo in members) {
                NSDictionary *tempInfo = memberInfo[@"user"];
                RCUserInfo *member = [[RCUserInfo alloc] init];
                member.userId = tempInfo[@"id"];
                member.name = tempInfo[@"nickname"];
                member.portraitUri = tempInfo[@"portraitUri"];
                [tempArr addObject:member];
            }
        }
        
        if (block) {
            block(tempArr);
        }
        
        
    } failure:^(NSError *err) {
        
    }];
}

//加入群组
- (void)joinGroupWithGroupId:(NSString *)groupID
                    complete:(void (^)(BOOL))result
{
    [AFHttpTool joinGroupWithGroupId:groupID
                          success:^(id response) {
                              if ([response[@"code"] integerValue] == 200) {
                                  result(YES);
                              }
                          }
                          failure:^(NSError *err) {
                              result(NO);
                          }];
}


//添加群组成员
- (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSMutableArray *)usersId
                 complete:(void (^)(BOOL))result
{
    [AFHttpTool addUsersIntoGroup:groupID
                          usersId:usersId
                          success:^(id response) {
                              if ([response[@"code"] integerValue] == 200) {
                                  result(YES);
                              }
                          }
                          failure:^(NSError *err) {
                             result(NO);
                          }];
}

//将用户踢出群组
- (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSMutableArray *)usersId
                   complete:(void (^)(BOOL))result
{
    [AFHttpTool kickUsersOutOfGroup:groupID
                            usersId:usersId
                            success:^(id response) {
                              if ([response[@"code"] integerValue] == 200) {
                                  result(YES);
                              }
                          }
                          failure:^(NSError *err) {
                              result(NO);
                          }];
}

//退出群组
-(void) quitGroupWithGroupId:(NSString *) groupID
                    complete:(void (^)(BOOL))result
{
    [AFHttpTool quitGroupWithGroupId:groupID
                             success:^(id response) {
                                 if ([response[@"code"] integerValue] == 200) {
                                     result (YES);
                                 }
                                 
                             } failure:^(NSError *err) {
                                 result(NO);
                             }];
}

//解散群组
-(void) dismissGroupWithGroupId:(NSString *) groupID
                    complete:(void (^)(BOOL))result
{
    [AFHttpTool dismissGroupWithGroupId:groupID
                             success:^(id response) {
                                 if ([response[@"code"] integerValue] == 200) {
                                     result (YES);
                                 }
                                 
                             } failure:^(NSError *err) {
                                 result(NO);
                             }];
}

//修改群组名称
-(void)renameGroupWithGoupId:(NSString *) groupID
                   groupName:(NSString *) groupName
                    complete:(void (^)(BOOL))result
{
    [AFHttpTool renameGroupWithGroupId:groupID
                             GroupName:groupName
                               success:^(id response) {
                                   if ([response[@"code"] integerValue] == 200) {
                                       result (YES);
                                   }
                               } failure:^(NSError *err) {
                                   result(NO);
                               }];
    
    
}

- (void)joinGroup:(int)groupID  withGroupName:(NSString *)groupName complete:(void (^)(BOOL))joinResult
{
    [AFHttpTool joinGroupByID:groupID success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        if (joinResult) {
            if ([code isEqualToString:@"200"]) {
                [[RCIMClient sharedRCIMClient]joinGroup:[NSString stringWithFormat:@"%d",groupID] groupName:groupName success:^{
                    for (RCDGroupInfo *group in _allGroups) {
                        if ([group.groupId isEqualToString:[NSString stringWithFormat:@"%d",groupID]]) {
                            group.isJoin=YES;
                            [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        joinResult(YES);
                    });

                } error:^(RCErrorCode status) {
                    joinResult(NO);
                }];
                
            }else{
                joinResult(NO);
            }
            
        }
    } failure:^(id response) {
        if (joinResult) {
            joinResult(NO);
        }
    }];
}

- (void)quitGroup:(int)groupID complete:(void (^)(BOOL))result
{
    [AFHttpTool quitGroupByID:groupID success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (result) {
            if ([code isEqualToString:@"200"]) {
                [[RCIMClient sharedRCIMClient] quitGroup:[NSString stringWithFormat:@"%d",groupID] success:^{
                    result(YES);
                    for (RCDGroupInfo *group in _allGroups) {
                        if ([group.groupId isEqualToString:[NSString stringWithFormat:@"%d",groupID]]) {
                            group.isJoin=NO;
                            [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                        }
                    }
                } error:^(RCErrorCode status) {
                    result(NO);
                }];
            }else{
                result(NO);
            }
            
        }
    } failure:^(id response) {
        if (result) {
            result(NO);
        }
    }];
}

- (void)updateGroupById:(int)groupID withGroupName:(NSString*)groupName andintroduce:(NSString*)introduce complete:(void (^)(BOOL))result

{
    __block typeof(id) weakGroupId = [NSString stringWithFormat:@"%d", groupID];
    [AFHttpTool updateGroupByID:groupID withGroupName:groupName andGroupIntroduce:introduce success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (result) {
            if ([code isEqualToString:@"200"]) {
                
                for (RCDGroupInfo *group in _allGroups) {
                    if ([group.groupId isEqualToString:weakGroupId]) {
                        group.groupName=groupName;
                        group.introduce=introduce;
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    result(YES);
                });
                
            }else{
                result(NO);
            }
            
        }
    } failure:^(id response) {
        if (result) {
            result(NO);
        }
    }];
}

- (void)getSquareInfoCompletion:(void (^)(NSMutableArray* result))completion
{
    [AFHttpTool getSquareInfoSuccess:^(id response) {
        if ([response[@"code"] integerValue] == 200) {
            completion(response[@"result"]);
        }
        
        
    } Failure:^(NSError *err) {
        
    }];
}


- (void)getFriends:(NSString *)userId complete:(void (^)(NSMutableArray*))friendList
{
    NSMutableArray* list = [NSMutableArray new];
    
    [AFHttpTool getFriendListFromServer:userId
                                Success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        if (friendList) {
            if ([code isEqualToString:@"200"]) {
                [_allFriends removeAllObjects];
                NSArray * regDataArray = response[@"result"];
                [[RCDataBaseManager shareInstance] clearFriendsData];
                for(int i = 0;i < regDataArray.count;i++){
                    NSDictionary *dic = [regDataArray objectAtIndex:i];
//                    if([[dic objectForKey:@"status"] intValue] != 1)
//                        continue;
                    NSDictionary *userDic = dic[@"user"];
                    RCDUserInfo*userInfo = [RCDUserInfo new];
                    userInfo.userId = userDic[@"id"];
                    userInfo.portraitUri = userDic[@"portraitUri"];
                    userInfo.name = userDic[@"nickname"];
                    userInfo.status = [NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]];
                    [list addObject:userInfo];
                    [_allFriends addObject:userInfo];
                    
                    RCUserInfo *user = [RCUserInfo new];
                    user.userId = userDic[@"id"];
                    user.portraitUri = userDic[@"portraitUri"];;
                    user.name = userDic[@"nickname"];
                    [[RCDataBaseManager shareInstance] insertUserToDB:user];
                    [[RCDataBaseManager shareInstance] insertFriendToDB:userInfo];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    friendList(list);
                });
                
            }else{
                friendList(list);
            }
            
        }
    } failure:^(id response) {
        if (friendList) {
            NSMutableArray *cacheList=[[NSMutableArray alloc]initWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
            friendList(cacheList);
        }
    }];
}

-(void) searchUserByPhone:(NSString *)phone
                 complete:(void (^)(NSMutableArray*))userList
{
    NSMutableArray* list = [NSMutableArray new];
    [AFHttpTool findUserByPhone:phone
                        success:^(id response) {
                            if (userList) {
                                if ([response[@"code"] intValue] == 200) {
                                    id result = response[@"result"];
                                    if([result respondsToSelector:@selector(intValue)]) return ;
                                    if([result respondsToSelector:@selector(objectForKey:)])
                                    {
                                        RCDUserInfo*userInfo = [RCDUserInfo new];
                                        userInfo.userId = [result objectForKey:@"id"];
                                        userInfo.portraitUri = [result objectForKey:@"portraitUri"];
                                        userInfo.name = [result objectForKey:@"nickname"];
                                        [list addObject:userInfo];
                                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                                            userList(list);
                                        });
                                    }

                                }
                            }
                        } failure:^(NSError *err) {
                            
                        }];
}

- (void)searchFriendListByEmail:(NSString*)email complete:(void (^)(NSMutableArray*))friendList
{
    NSMutableArray* list = [NSMutableArray new];
    [AFHttpTool searchFriendListByEmail:email success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (friendList) {
            if ([code isEqualToString:@"200"]) {
                
                id result = response[@"result"];
                if([result respondsToSelector:@selector(intValue)]) return ;
                if([result respondsToSelector:@selector(objectForKey:)])
                {
                    RCDUserInfo*userInfo = [RCDUserInfo new];
                    NSNumber *idNum = [result objectForKey:@"id"];
                    userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                    userInfo.portraitUri = [result objectForKey:@"portrait"];
                    userInfo.name = [result objectForKey:@"username"];
                    [list addObject:userInfo];
                    
                }
                else
                {
                    NSArray * regDataArray = response[@"result"];
                    
                    for(int i = 0;i < regDataArray.count;i++){
                        
                        NSDictionary *dic = [regDataArray objectAtIndex:i];
                        RCDUserInfo*userInfo = [RCDUserInfo new];
                        NSNumber *idNum = [dic objectForKey:@"id"];
                        userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                        userInfo.portraitUri = [dic objectForKey:@"portrait"];
                        userInfo.name = [dic objectForKey:@"username"];
                        [list addObject:userInfo];
                    }

                }
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    friendList(list);
                });
                
            }else{
                friendList(list);
            }
            
        }
    } failure:^(id response) {
        if (friendList) {
            friendList(list);
        }
    }];
}

- (void)searchFriendListByName:(NSString*)name complete:(void (^)(NSMutableArray*))friendList
{
    NSMutableArray* list = [NSMutableArray new];
    [AFHttpTool searchFriendListByName:name success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (friendList) {
            if ([code isEqualToString:@"200"]) {
                
                NSArray * regDataArray = response[@"result"];
                for(int i = 0;i < regDataArray.count;i++){
                    
                    NSDictionary *dic = [regDataArray objectAtIndex:i];
                    RCDUserInfo*userInfo = [RCDUserInfo new];
                    NSNumber *idNum = [dic objectForKey:@"id"];
                    userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                    userInfo.portraitUri = [dic objectForKey:@"portrait"];
                    userInfo.name = [dic objectForKey:@"username"];
                    [list addObject:userInfo];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    friendList(list);
                });
                
            }else{
                friendList(list);
            }
            
        }
    } failure:^(id response) {
        if (friendList) {
            friendList(list);
        }
    }];
}
- (void)requestFriend:(NSString*)userId complete:(void (^)(BOOL))result
{
    [AFHttpTool inviteUser:userId
                   success:^(id response) {
                       if (result) {
                                       if ([response[@"code"] intValue] == 200) {
                                           dispatch_async(dispatch_get_main_queue(), ^(void) {
                                               result(YES);
                                           });
                                           
                                       }else{
                                           result(NO);
                                       }
                       }
                   } failure:^(NSError *err) {
                       result(NO);
                   }];
//    [AFHttpTool requestFriend:userId success:^(id response) {
//        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
//        
//        if (result) {
//            if ([code isEqualToString:@"200"]) {
//                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    result(YES);
//                });
//                
//            }else{
//                result(NO);
//            }
//            
//        }
//    } failure:^(id response) {
//        if (result) {
//            result(NO);
//        }
//    }];
}
- (void)processInviteFriendRequest:(NSString*)userId  complete:(void (^)(BOOL))result
{
//    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSTimeInterval a=[dat timeIntervalSince1970];
//    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    
    [AFHttpTool processInviteFriendRequest:userId
                                   success:^(id response) {
                                       if ([response[@"code"] intValue] == 200) {
                                           dispatch_async(dispatch_get_main_queue(), ^(void) {
                                               result(YES);
                                           });
                                       }
                                   } failure:^(id response) {
                                       if (result) {
                                           result(NO);
                                       }
                                   }];
    
//    [AFHttpTool processInviteFriendRequest:userId
//                              currentUseId:[RCIM sharedRCIM].currentUserInfo.userId
//                                      time:timeString
//                                   success:^(id response) {
//                                       if ([response[@"code"] intValue] == 200) {
//                                           dispatch_async(dispatch_get_main_queue(), ^(void) {
//                                               result(YES);
//                                           });
//                                       }
//                                   } failure:^(id response) {
//                                       if (result) {
//                                           result(NO);
//                                       }
//                                   }];
}


- (void)processRequestFriend:(NSString*)userId withIsAccess:(BOOL)isAccess complete:(void (^)(BOOL))result
{
    [AFHttpTool processRequestFriend:userId withIsAccess:isAccess success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (result) {
            if ([code isEqualToString:@"200"]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    result(YES);
                });
                
            }else{
                result(NO);
            }
        }
    } failure:^(id response) {
        if (result) {
            result(NO);
        }
    }];
}

- (void)deleteFriend:(NSString*)userId complete:(void (^)(BOOL))result
{
    [AFHttpTool deleteFriend:userId success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (result) {
            if ([code isEqualToString:@"200"]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    result(YES);
                });
                [[RCDataBaseManager shareInstance]deleteFriendFromDB:userId];
                
            }else{
                result(NO);
            }
            
        }
    } failure:^(id response) {
        if (result) {
            result(NO);
        }
    }];
}

-(void) AddToBlacklist:(NSString*) userId
              complete:(void (^)(BOOL result))result
{
    [AFHttpTool addToBlacklist:userId
                       success:^(id response) {
                           NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
                           if ([code isEqualToString:@"200"]) {
                                   result(YES);
                           }
                       } failure:^(NSError *err) {
                           if (result) {
                               result(NO);
                           }
                       }];
}

-(void) RemoveToBlacklist:(NSString*) userId
              complete:(void (^)(BOOL result))result
{
    [AFHttpTool removeToBlacklist:userId
                       success:^(id response) {
                           NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
                           if ([code isEqualToString:@"200"]) {
                               result(YES);
                           }
                       } failure:^(NSError *err) {
                           if (result) {
                               result(NO);
                           }
                       }];
}

-(void)getBlacklistcomplete:(void (^)(NSMutableArray *))blacklist
{
    [AFHttpTool getBlacklistsuccess:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        if ([code isEqualToString:@"200"]) {
            NSMutableArray *result = response[@"result"];
            blacklist(result);
        }
    } failure:^(NSError *err) {
        blacklist(nil);
    }];
}

- (void)updateName:(NSString*) userName
          success:(void (^)(id response))success
           failure:(void (^)(NSError* err))failure {
    [AFHttpTool updateName:userName success:^(id response) {
        success(response);
    } failure:^(NSError *err) {
        failure(err);
    }];
}

- (void)updateUserInfo:(NSString *) userID
               success:(void (^)(RCUserInfo * user))success
               failure:(void (^)(NSError* err))failure{
    [AFHttpTool getUserById:userID success:^(id response) {
        if (response) {
            NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
            if ([code isEqualToString:@"200"]) {
                NSDictionary *dic = response[@"result"];
                // NSLog(@"isMainThread > %d", [NSThread isMainThread]);
                RCUserInfo *user = [RCUserInfo new];
                NSNumber *idNum = [dic objectForKey:@"id"];
                user.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                user.portraitUri = [dic objectForKey:@"portrait"];
                user.name = [dic objectForKey:@"username"];
                [[RCDataBaseManager shareInstance] insertUserToDB:user];
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(user);
                    });
                }
            }
        }
        
    } failure:^(NSError *err) {
         failure(err);
    }];

}

-(void)uploadImageToQiNiu:(NSString *)userId
                ImageData:(NSData *)image
                  success:(void (^)(NSString *url))success
                  failure:(void (^)(NSError* err))failure{

    [AFHttpTool uploadFile:image
                    userId:userId
                   success:^(id response)
    {
        if ([response[@"key"] length] > 0) {
            NSString *key = response[@"key"];
            NSString *QiNiuDomai = [DEFAULTS objectForKey:@"QiNiuDomain"];
            NSString *imageUrl = [NSString stringWithFormat:@"http://%@/%@",QiNiuDomai,key];
            success(imageUrl);
        }
                   } failure:^(NSError *err)
    {
                       
                   }];

    
    
}
@end
