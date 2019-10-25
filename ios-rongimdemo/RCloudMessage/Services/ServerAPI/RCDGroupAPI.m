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
#pragma mark - Group
+ (void)createGroup:(NSString *)groupName
        portraitUri:(NSString *)portraitUri
          memberIds:(NSArray *)memberIds
           complete:(void (^)(NSString *groupId, RCDGroupAddMemberStatus status))complete {
    if (!groupName || !memberIds) {
        SealTalkLog(@"groupName or memberIds is nil");
        if (complete) {
            complete(nil, 0);
        }
        return;
    }
    NSDictionary *params = @{ @"name" : groupName, @"memberIds" : memberIds };
    if (portraitUri.length > 0) {
        params = @{ @"name" : groupName, @"memberIds" : memberIds, @"portraitUri" : portraitUri };
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/create"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (complete) {
                                             complete(result.content[@"id"],
                                                      [self getGroupAddMemberStatus:result.content[@"userStatus"]]);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil, 0);
                                         }
                                     }
                                 }];
}

+ (void)copyGroup:(NSString *)groupId
        groupName:(NSString *)groupName
      portraitUri:(NSString *)portraitUri
         complete:(void (^)(NSString *, RCDGroupAddMemberStatus))complete
            error:(void (^)(RCDGroupErrorCode))error {
    if (!groupName || !groupId) {
        SealTalkLog(@"groupName or groupId is nil");
        if (error) {
            complete(nil, 0);
        }
        return;
    }
    NSDictionary *params = @{ @"name" : groupName, @"groupId" : groupId };
    if (portraitUri.length > 0) {
        params = @{ @"name" : groupName, @"groupId" : groupId, @"portraitUri" : portraitUri };
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/copy_group"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (complete) {
                                             complete(result.content[@"id"],
                                                      [self getGroupAddMemberStatus:result.content[@"userStatus"]]);
                                         }
                                     } else {
                                         if (error) {
                                             error(result.errorCode);
                                         }
                                     }
                                 }];
}

+ (void)setGroupPortrait:(NSString *)portraitUri groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId || !portraitUri) {
        SealTalkLog(@"groupId or portraitUri is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"portraitUri" : portraitUri };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_portrait_uri"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

//修改群组名称
+ (void)resetGroupName:(NSString *)groupName groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId || !groupName) {
        SealTalkLog(@"groupId or groupName is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"name" : groupName };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/rename"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

//获取群信息
+ (void)getGroupInfo:(NSString *)groupId complete:(void (^)(RCDGroupInfo *groupInfo))complete {
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
                                         RCDGroupInfo *group = [[RCDGroupInfo alloc] initWithJson:content];
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

//退出群组
+ (void)quitGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
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
+ (void)dismissGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/dismiss"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

//发布群公告
+ (void)publishGroupAnnouncement:(NSString *)content
                         groupId:(NSString *)groupId
                        complete:(void (^)(BOOL success))complete {
    if (!groupId || !content) {
        SealTalkLog(@"groupId or content is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"bulletin" : content };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_bulletin"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)getGroupAnnouncement:(NSString *)groupId complete:(void (^)(RCDGroupAnnouncement *announcement))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"group/get_bulletin"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *json = result.content;
                                         RCDGroupAnnouncement *announe =
                                             [[RCDGroupAnnouncement alloc] initWithJson:json];
                                         if (complete) {
                                             complete(announe);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}

+ (void)setGroupAllMute:(BOOL)mute groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"muteStatus" : @(mute ? 1 : 0) };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/mute_all"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)setGroupCertification:(BOOL)open groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"certiStatus" : @(open ? 0 : 1) };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_certification"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)getGroupNoticeList:(void (^)(NSArray<RCDGroupNotice *> *))complete {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"group/notice_info"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *array = result.content;
                                         NSMutableArray *list = [NSMutableArray array];
                                         for (NSDictionary *dic in array) {
                                             RCDGroupNotice *notice = [[RCDGroupNotice alloc] initWithJson:dic];
                                             [list addObject:notice];
                                         }
                                         if (complete) {
                                             complete(list.copy);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}

+ (void)clearGroupNoticeList:(void (^)(BOOL))complete {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/clear_notice"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)setGroupApproveAction:(RCDGroupInviteActionType)type
                     targetId:(NSString *)targetId
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"status" : @(type), @"receiverId" : targetId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/agree"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)setGroupMemberProtection:(BOOL)open groupId:(NSString *)groupId complete:(void (^)(BOOL))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"memberProtection" : @(open ? 1 : 0) };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_member_protection"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)getGroupLeftMemberList:(NSString *)groupId complete:(void (^)(NSArray<RCDGroupLeftMember *> *))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/exited_list"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *list = result.content;
                                         NSMutableArray *array = [[NSMutableArray alloc] init];
                                         for (NSDictionary *dic in list) {
                                             RCDGroupLeftMember *member = [[RCDGroupLeftMember alloc] initWithJson:dic];
                                             [array addObject:member];
                                         }
                                         if (complete) {
                                             complete(array.copy);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}

#pragma mark - Group member
//获取群组成员列表
+ (void)getGroupMembers:(NSString *)groupId
               complete:(void (^)(NSArray<RCDGroupMember *> *_Nonnull))complete
                  error:(void (^)(RCDGroupErrorCode))errorBlock {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (errorBlock) {
            errorBlock(RCDGroupErrorCodeUnknown);
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
                                             RCDGroupMember *member = [[RCDGroupMember alloc] initWithJson:dic];
                                             member.groupId = groupId;
                                             [array addObject:member];
                                         }
                                         if (complete) {
                                             complete(array.copy);
                                         }
                                     } else {
                                         if (errorBlock) {
                                             errorBlock(result.httpCode);
                                         }
                                     }
                                 }];
}

//获取我的群组
+ (void)getMyGroupList:(void (^)(NSArray<RCDGroupInfo *> *groupList))complete {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/favgroups"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSMutableArray *groupList = [NSMutableArray new];
                                         NSArray *list = result.content[@"list"];
                                         for (NSDictionary *dic in list) {
                                             RCDGroupInfo *group = [[RCDGroupInfo alloc] initWithJson:dic];
                                             [groupList addObject:group];
                                         }
                                         if (complete) {
                                             complete(groupList.copy);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }

                                 }];
}

//加入群组
+ (void)joinGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
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
        complete:(void (^)(BOOL success, RCDGroupAddMemberStatus status))complete {
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO, 0);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"memberIds" : userIds };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/add"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success, [self getGroupAddMemberStatus:result.content]);
                                     }
                                 }];
}

//将用户踢出群组
+ (void)kickUsers:(NSArray *)userIds groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"memberIds" : userIds };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/kick"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

//群主转让
+ (void)transferGroupOwner:(NSString *)targetId groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId || !targetId) {
        SealTalkLog(@"groupId or targetId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"userId" : targetId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/transfer"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)addGroupManagers:(NSArray<NSString *> *)userIds
                 groupId:(NSString *)groupId
                complete:(void (^)(BOOL success))complete {
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"memberIds" : userIds };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_manager"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)removeGroupManagers:(NSArray<NSString *> *)userIds
                    groupId:(NSString *)groupId
                   complete:(void (^)(BOOL success))complete {
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"memberIds" : userIds };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/remove_manager"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)setGroupMemberDetailInfo:(RCDGroupMemberDetailInfo *)memberInfo
                         groupId:(NSString *)groupId
                        complete:(void (^)(BOOL))complete {
    if (!groupId || !memberInfo.userId) {
        SealTalkLog(@"groupId or userId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSMutableDictionary *params = [memberInfo decode].mutableCopy;
    [params setObject:groupId forKey:@"groupId"];
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_member_info"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)getGroupMemberDetailInfo:(NSString *)userId
                         groupId:(NSString *)groupId
                        complete:(void (^)(RCDGroupMemberDetailInfo *))complete {
    if (!groupId || !userId) {
        SealTalkLog(@"groupId or userId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"memberId" : userId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/get_member_info"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         RCDGroupMemberDetailInfo *member =
                                             [[RCDGroupMemberDetailInfo alloc] initWithJson:result.content];
                                         member.userId = userId;
                                         if (complete) {
                                             complete(member);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}
#pragma mark - My Group
// 添加到我的群组
+ (void)addToMyGroups:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/fav"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)removeFromMyGroups:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodDelete
                                URLString:@"group/fav"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

#pragma mark - helper
+ (RCDGroupAddMemberStatus)getGroupAddMemberStatus:(NSArray *)array {
    RCDGroupAddMemberStatus addMemberStatus = 0;
    if (array.count > 0) {
        NSMutableArray *joinedArr = [NSMutableArray array];
        NSMutableArray *inviteeApprovingArr = [NSMutableArray array];
        NSMutableArray *managerApprovingArr = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            NSString *userId = dic[@"id"];
            // 1 为已加入, 2 为等待管理员同意, 3 为等待被邀请者同意
            int status = [dic[@"status"] intValue];
            if (status == 1) {
                [joinedArr addObject:userId];
            } else if (status == 2) {
                [managerApprovingArr addObject:userId];
            } else if (status == 3) {
                [inviteeApprovingArr addObject:userId];
            }
        }
        if (inviteeApprovingArr.count > 0) {
            addMemberStatus = RCDGroupAddMemberStatusInviteeApproving;
        } else if (managerApprovingArr.count > 0) {
            addMemberStatus = RCDGroupAddMemberStatusOnlyManagerApproving;
        } else {
            addMemberStatus = RCDGroupAddMembersStatusAllJoined;
        }
    }
    return addMemberStatus;
}
@end
