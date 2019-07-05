//
//  RCDGroupAPI.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupAPI.h"
#import "RCDHTTPUtility.h"
#import "RCDUtilities.h"
#import "RCDGroupAnnouncement.h"

@implementation RCDGroupAPI
+ (void)createGroup:(NSString *)groupName memberIds:(NSArray *)memberIds complete:(void (^)(NSString *))complete{
    if (!groupName || !memberIds) {
        SealTalkLog(@"groupName or memberIds is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{@"name" : groupName, @"memberIds" : memberIds};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/create"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (complete) {
                                             complete(result.content[@"id"]);
                                         }
                                     }else{
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}

+ (void)resetGroupName:(NSString *)groupName groupId:(NSString *)groupId complete:(void (^)(BOOL))complete{
    if (!groupId || !groupName) {
        SealTalkLog(@"groupId or groupName is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId, @"name" : groupName};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/rename"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+(void)setGroupPortrait:(NSString *)portraitUri groupId:(NSString *)groupId complete:(void (^)(BOOL))complete{
    if (!groupId || !portraitUri) {
        SealTalkLog(@"groupId or portraitUri is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId, @"portraitUri" : portraitUri};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_portrait_uri"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)getGroupInfo:(NSString *)groupId complete:(void (^)(RCDGroupInfo *groupInfo))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:[NSString stringWithFormat:@"group/%@", groupId]
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *content = result.content;
                                         RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                                         group.groupId = [content objectForKey:@"id"];
                                         group.groupName = [content objectForKey:@"name"];
                                         group.portraitUri = [content objectForKey:@"portraitUri"];
                                         if (!group.portraitUri || group.portraitUri.length <= 0) {
                                             group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                                         }
                                         group.creatorId = [content objectForKey:@"creatorId"];
                                         group.introduce = [content objectForKey:@"introduce"];
                                         if (!group.introduce) {
                                             group.introduce = @"";
                                         }
                                         group.number = [[content objectForKey:@"memberCount"] stringValue] ;
                                         group.maxNumber = [content objectForKey:@"max_number"];
                                         NSString *deletedAt = [content objectForKey:@"deletedAt"];
                                         if (deletedAt.length > 0) {
                                             group.isDismiss = YES;
                                         } else {
                                             group.isDismiss = NO;
                                         }
                                         if ([group.groupId isEqualToString:groupId] && complete) {
                                             complete(group);
                                         } else if (complete) {
                                             complete(nil);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}


+ (void)getGroupMembers:(NSString *)groupId complete:(void (^)(NSArray<RCDGroupMember *> * ))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:[NSString stringWithFormat:@"group/%@/members", groupId]
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *list = result.content;
                                         NSMutableArray *array = [[NSMutableArray alloc] init];
                                         for (NSDictionary *dic in list) {
                                             NSDictionary *userDic = dic[@"user"];
                                             RCDGroupMember *member = [[RCDGroupMember alloc] initWithUserId:userDic[@"id"] name:userDic[@"nickname"] portrait:userDic[@"portraitUri"]];
                                             member.role = [dic[@"role"] integerValue];
                                             member.createDt = [dic[@"timestamp"] longLongValue];
                                             member.updateDt = [dic[@"updatedTime"] longLongValue];
                                             [array addObject:member];
                                         }
                                         if(complete){
                                             complete(array.copy);
                                         }
                                     }else{
                                         if(complete){
                                             complete(nil);
                                         }
                                     }
                                 }];
}

+ (void)getMyGroupList:(void (^)(NSArray<RCDGroupInfo *> *))complete{
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/favgroups"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSMutableArray *groupList = [NSMutableArray new];
                                         NSArray *list = result.content[@"list"];
                                         for (NSDictionary *dic in list) {
                                             RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                                             group.groupId = [dic objectForKey:@"id"];
                                             group.groupName = [dic objectForKey:@"name"];
                                             group.portraitUri = [dic objectForKey:@"portraitUri"];
                                             if (!group.portraitUri || group.portraitUri.length == 0) {
                                                 group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                                             }
                                             group.creatorId = [dic objectForKey:@"creatorId"];
                                             //                group.introduce = [dic objectForKey:@"introduce"];
                                             if (!group.introduce) {
                                                 group.introduce = @"";
                                             }
                                             group.number = [dic objectForKey:@"memberCount"];
                                             group.maxNumber = @"500";
                                             if (!group.number) {
                                                 group.number = @"";
                                             }
                                             if (!group.maxNumber) {
                                                 group.maxNumber = @"";
                                             }
                                             [groupList addObject:group];
                                         }
                                         if (complete) {
                                             complete(groupList.copy);
                                         }
                                     }else{
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                     
                                 }];
}

//加入群组
+ (void)joinGroup:(NSString *)groupId
         complete:(void (^)(BOOL success))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/join"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

//添加群组成员
+ (void)addUsers:(NSArray *)userIds
         groupId:(NSString *)groupId
        complete:(void (^)(BOOL success))complete{
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId, @"memberIds" : userIds};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/add"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

//将用户踢出群组
+ (void)kickUsers:(NSArray *)userIds
          groupId:(NSString *)groupId
         complete:(void (^)(BOOL success))complete{
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId, @"memberIds" : userIds};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/kick"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

//退出群组
+ (void)quitGroup:(NSString *)groupId
         complete:(void (^)(BOOL success))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/quit"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

//解散群组
+ (void)dismissGroup:(NSString *)groupId
            complete:(void (^)(BOOL success))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/dismiss"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)addToMyGroups:(NSString *)groupId complete:(void (^)(BOOL))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/fav"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)removeFromMyGroups:(NSString *)groupId complete:(void (^)(BOOL))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodDelete
                                URLString:@"group/fav"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)publishGroupAnnouncement:(NSString *)content groupId:(NSString *)groupId complete:(void (^)(BOOL))complete{
    if (!groupId || !content) {
        SealTalkLog(@"groupId or content is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId, @"bulletin": content};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_bulletin"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)getGroupAnnouncement:(NSString *)groupId complete:(void (^)(RCDGroupAnnouncement *))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"group/get_bulletin"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *json = result.content;
                                         RCDGroupAnnouncement *announe = [[RCDGroupAnnouncement alloc] initWithJson:json];
                                         if (complete) {
                                             complete(announe);
                                         }
                                     }else{
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}

+ (void)transferGroupOwner:(NSString *)targetId groupId:(NSString *)groupId complete:(void (^)(BOOL))complete{
    if (!groupId || !targetId) {
        SealTalkLog(@"groupId or targetId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId, @"userId": targetId};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/transfer"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)addGroupManagers:(NSArray<NSString *> *)userIds groupId:(NSString *)groupId complete:(void (^)(BOOL))complete{
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId, @"memberIds": userIds};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_manager"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)removeGroupManagers:(NSArray<NSString *> *)userIds groupId:(NSString *)groupId complete:(void (^)(BOOL))complete{
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{@"groupId" : groupId, @"memberIds": userIds};
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/remove_manager"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}
@end
