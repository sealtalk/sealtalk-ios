//
//  RCDGroupManager.m
//  SealTalk
//
//  Created by LiFei on 2019/6/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupManager.h"
#import "RCDGroupAPI.h"
#import "RCDDBManager.h"
#import "RCDUtilities.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDIMService.h"
#import "RCDCommonString.h"
#import "RCDGroupNotificationMessage.h"
#import "RCDGroupNoticeUpdateMessage.h"
#import "RCDUserInfoManager.h"
#import "RCDEnum.h"

@implementation RCDGroupManager

#pragma mark - Group

+ (void)createGroup:(NSString *)groupName
        portraitUri:(NSString *)portraitUri
          memberIds:(NSArray *)memberIds
           complete:(void (^)(NSString *, RCDGroupAddMemberStatus status))complete {
    [RCDGroupAPI
        createGroup:groupName
        portraitUri:portraitUri
          memberIds:memberIds
           complete:^(NSString *_Nonnull groupId, RCDGroupAddMemberStatus status) {
               if (groupId) {
                   RCDGroupInfo *group =
                       [[RCDGroupInfo alloc] initWithGroupId:groupId groupName:groupName portraitUri:portraitUri];
                   [RCDDBManager saveGroups:@[ group ]];
                   group = [self generateDefaultPortraitIfNeed:group];
                   [[RCIM sharedRCIM] refreshGroupInfoCache:group withGroupId:groupId];
               }
               if (complete) {
                   complete(groupId, status);
               }
           }];
}

+ (void)copyGroup:(NSString *)groupId
        groupName:(NSString *)groupName
      portraitUri:(NSString *)portraitUri
         complete:(void (^)(NSString *, RCDGroupAddMemberStatus))complete
            error:(void (^)(RCDGroupErrorCode))error {
    [RCDGroupAPI
          copyGroup:groupId
          groupName:groupName
        portraitUri:portraitUri
           complete:^(NSString *_Nonnull groupId, RCDGroupAddMemberStatus status) {
               if (groupId) {
                   RCDGroupInfo *group =
                       [[RCDGroupInfo alloc] initWithGroupId:groupId groupName:groupName portraitUri:portraitUri];
                   [RCDDBManager saveGroups:@[ group ]];
                   group = [self generateDefaultPortraitIfNeed:group];
                   [[RCIM sharedRCIM] refreshGroupInfoCache:group withGroupId:groupId];
               }
               if (complete) {
                   complete(groupId, status);
               }
           }
              error:error];
}

+ (void)setGroupPortrait:(NSString *)portraitUri groupId:(NSString *)groupId complete:(void (^)(BOOL))complete {
    [RCDGroupAPI setGroupPortrait:portraitUri
                          groupId:groupId
                         complete:^(BOOL success) {
                             if (success) {
                                 RCDGroupInfo *groupInfo = [RCDDBManager getGroup:groupId];
                                 groupInfo.portraitUri = portraitUri;
                                 [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo withGroupId:groupId];
                                 [RCDDBManager saveGroups:@[ groupInfo ]];
                             }
                             if (complete) {
                                 complete(success);
                             }
                         }];
}

+ (void)setGroupName:(NSString *)groupName groupId:(NSString *)groupId complete:(void (^)(BOOL))complete {
    [RCDGroupAPI resetGroupName:groupName
                        groupId:groupId
                       complete:^(BOOL success) {
                           if (success) {
                               RCDGroupInfo *groupInfo = [RCDDBManager getGroup:groupId];
                               groupInfo.groupName = groupName;
                               [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo withGroupId:groupId];
                               [RCDDBManager saveGroups:@[ groupInfo ]];
                           }
                           if (complete) {
                               complete(success);
                           }
                       }];
}

+ (RCDGroupInfo *)getGroupInfo:(NSString *)groupId {
    RCDGroupInfo *group = [RCDDBManager getGroup:groupId];
    group = [self generateDefaultPortraitIfNeed:group];
    return group;
}

+ (void)getGroupInfoFromServer:(NSString *)groupId complete:(void (^)(RCDGroupInfo *_Nonnull))complete {
    [RCDGroupAPI getGroupInfo:groupId
                     complete:^(RCDGroupInfo *_Nonnull groupInfo) {
                         if (groupInfo) {
                             [RCDDBManager saveGroups:@[ groupInfo ]];
                             groupInfo = [self generateDefaultPortraitIfNeed:groupInfo];
                             [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo withGroupId:groupId];
                         }
                         if (complete) {
                             complete(groupInfo);
                         }
                     }];
}

//退出群组
+ (void)quitGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI quitGroup:groupId
                  complete:^(BOOL success) {
                      if (success) {
                          [RCDDBManager deleteGroup:groupId];
                          [self getMyGroupListFromServer:nil];
                      }
                      if (complete) {
                          complete(success);
                      }
                  }];
}

//解散群组
+ (void)dismissGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI dismissGroup:groupId
                     complete:^(BOOL success) {
                         if (success) {
                             [RCDDBManager deleteGroup:groupId];
                             [self getMyGroupListFromServer:nil];
                         }
                         if (complete) {
                             complete(success);
                         }
                     }];
}

//发布群公告
+ (void)publishGroupAnnouncement:(NSString *)content
                         groupId:(NSString *)groupId
                        complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI publishGroupAnnouncement:content
                                  groupId:groupId
                                 complete:^(BOOL success) {
                                     if (success) {
                                         [self getGroupInfoFromServer:groupId complete:nil];
                                     }
                                     if (complete) {
                                         complete(success);
                                     }
                                 }];
}

+ (void)getGroupAnnouncement:(NSString *)groupId complete:(void (^)(RCDGroupAnnouncement *))complete {
    [RCDGroupAPI getGroupAnnouncement:groupId complete:complete];
}

+ (void)setGroupAllMute:(BOOL)mute groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI setGroupAllMute:mute
                         groupId:groupId
                        complete:^(BOOL success) {
                            if (success) {
                                RCDGroupInfo *group = [self getGroupInfo:groupId];
                                if (group) {
                                    group.mute = mute;
                                    [RCDDBManager saveGroups:@[ group ]];
                                } else {
                                    [self getGroupInfoFromServer:groupId complete:nil];
                                }
                            }
                            if (complete) {
                                complete(success);
                            }
                        }];
}

+ (void)setGroupCertification:(BOOL)open groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI setGroupCertification:open
                               groupId:groupId
                              complete:^(BOOL success) {
                                  if (success) {
                                      RCDGroupInfo *group = [self getGroupInfo:groupId];
                                      if (group) {
                                          group.needCertification = open;
                                          [RCDDBManager saveGroups:@[ group ]];
                                      } else {
                                          [self getGroupInfoFromServer:groupId complete:nil];
                                      }
                                  }
                                  if (complete) {
                                      complete(success);
                                  }
                              }];
}

+ (NSInteger)getGroupNoticeUnreadCount {
    return [RCDDBManager getGroupNoticeUnreadCount];
}

+ (NSArray<RCDGroupNotice *> *)getGroupNoticeList {
    return [RCDDBManager getGroupNoticeList];
}

+ (void)getGroupNoticeListFromServer:(void (^)(NSArray<RCDGroupNotice *> *))complete {
    [RCDGroupAPI getGroupNoticeList:^(NSArray<RCDGroupNotice *> *_Nonnull noticeList) {
        if (noticeList) {
            [RCDDBManager clearGroupNoticeList];
            [RCDDBManager saveGroupNoticeList:noticeList];
        }
        if (complete) {
            complete(noticeList);
        }
    }];
}

+ (void)clearGroupNoticeList:(void (^)(BOOL success))complete {
    [RCDGroupAPI clearGroupNoticeList:^(BOOL success) {
        if (success) {
            [RCDDBManager clearGroupNoticeList];
        }
        if (complete) {
            complete(success);
        }
    }];
}

+ (void)setGroupApproveAction:(RCDGroupInviteActionType)type
                     targetId:(NSString *)targetId
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL))complete {
    [RCDGroupAPI setGroupApproveAction:type
                              targetId:targetId
                               groupId:groupId
                              complete:^(BOOL success) {
                                  if (success) {
                                      [self getGroupNoticeListFromServer:nil];
                                  }
                                  if (complete) {
                                      complete(success);
                                  }
                              }];
}

+ (void)setGroupMemberProtection:(BOOL)open groupId:(NSString *)groupId complete:(void (^)(BOOL))complete {
    [RCDGroupAPI setGroupMemberProtection:open
                                  groupId:groupId
                                 complete:^(BOOL success) {
                                     if (success) {
                                         RCDGroupInfo *group = [RCDDBManager getGroup:groupId];
                                         if (open != group.memberProtection) {
                                             group.memberProtection = open;
                                             [RCDDBManager saveGroups:@[ group ]];
                                         }
                                     }
                                     if (complete) {
                                         complete(success);
                                     }
                                 }];
}
#pragma mark - Group Member
+ (NSArray<NSString *> *)getGroupMembers:(NSString *)groupId {
    return [RCDDBManager getGroupMembers:groupId];
}

+ (void)getGroupMembersFromServer:(NSString *)groupId complete:(void (^)(NSArray<NSString *> *))complete {
    [RCDGroupAPI getGroupMembers:groupId
        complete:^(NSArray<RCDGroupMember *> *_Nonnull memberList) {
            if (memberList) {
                NSMutableArray *memberIdList = [NSMutableArray array];
                for (RCDGroupMember *user in memberList) {
                    [memberIdList addObject:user.userId];
                    [self refreshGroupMemberInfo:user.userId groupId:groupId];
                }
                [RCDDBManager clearGroupMembers:groupId];
                if (memberList) {
                    [RCDDBManager saveGroupMembers:memberList inGroup:groupId];
                }
                if (complete) {
                    complete([RCDDBManager getGroupMembers:groupId]);
                }
            }
        }
        error:^(RCDGroupErrorCode errorCode) {
            if (errorCode == RCDGroupErrorCodeNotInGroup) {
                [RCDDBManager clearGroupMembers:groupId];
            }
            if (complete) {
                complete(nil);
            }
        }];
}

+ (RCDGroupMember *)getGroupMember:(NSString *)userId groupId:(NSString *)groupId {
    RCDGroupMember *member = [RCDDBManager getGroupMember:userId inGroup:groupId];
    return member;
}

+ (NSString *)getGroupOwner:(NSString *)groupId {
    return [RCDDBManager getGroupOwner:groupId];
}

+ (NSArray<NSString *> *)getGroupManagers:(NSString *)groupId {
    return [RCDDBManager getGroupManagers:groupId];
}

+ (BOOL)currentUserIsGroupCreatorOrManager:(NSString *)groupId {
    RCDGroupMember *member = [self getGroupMember:[RCIM sharedRCIM].currentUserInfo.userId groupId:groupId];
    if (member.role != RCDGroupMemberRoleMember) {
        return YES;
    }
    return NO;
}

+ (void)joinGroup:(NSString *)groupId complete:(void (^)(BOOL))complete {
    [RCDGroupAPI joinGroup:groupId
                  complete:^(BOOL success) {
                      if (success) {
                          [self syncGroup:groupId];
                      }
                      if (complete) {
                          complete(success);
                      }
                  }];
}

//添加群组成员
+ (void)addUsers:(NSArray *)userIds
         groupId:(NSString *)groupId
        complete:(void (^)(BOOL success, RCDGroupAddMemberStatus status))complete {
    [RCDGroupAPI addUsers:userIds
                  groupId:groupId
                 complete:^(BOOL success, RCDGroupAddMemberStatus status) {
                     if (success) {
                         [self syncGroup:groupId];
                     }
                     if (complete) {
                         complete(success, status);
                     }
                 }];
}

//将用户踢出群组
+ (void)kickUsers:(NSArray *)userIds groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI kickUsers:userIds
                   groupId:groupId
                  complete:^(BOOL success) {
                      if (success) {
                          [self syncGroup:groupId];
                      }
                      if (complete) {
                          complete(success);
                      }
                  }];
}

//群主转让
+ (void)transferGroupOwner:(NSString *)targetId groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI transferGroupOwner:targetId
                            groupId:groupId
                           complete:^(BOOL success) {
                               if (complete) {
                                   complete(success);
                               }
                           }];
}

+ (void)addGroupManagers:(NSArray<NSString *> *)userIds
                 groupId:(NSString *)groupId
                complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI addGroupManagers:userIds
                          groupId:groupId
                         complete:^(BOOL success) {
                             if (complete) {
                                 complete(success);
                             }
                         }];
}

+ (void)removeGroupManagers:(NSArray<NSString *> *)userIds
                    groupId:(NSString *)groupId
                   complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI removeGroupManagers:userIds
                             groupId:groupId
                            complete:^(BOOL success) {
                                if (complete) {
                                    complete(success);
                                }
                            }];
}

+ (NSArray<RCDGroupInfo *> *)getAllGroupList {
    return [RCDDBManager getAllGroupList];
}

+ (void)setGroupMemberDetailInfo:(RCDGroupMemberDetailInfo *)memberInfo
                         groupId:groupId
                        complete:(void (^)(BOOL))complete {
    [RCDGroupAPI setGroupMemberDetailInfo:memberInfo
                                  groupId:groupId
                                 complete:^(BOOL success) {
                                     if (success) {
                                         [RCDDBManager saveGroupMemberDetailInfo:memberInfo groupId:groupId];
                                         [self refreshGroupMemberInfo:memberInfo.userId groupId:groupId];
                                     }
                                     if (complete) {
                                         complete(success);
                                     }
                                 }];
}

+ (RCDGroupMemberDetailInfo *)getGroupMemberDetailInfo:(NSString *)userId groupId:(NSString *)groupId {
    return [RCDDBManager getGroupMemberDetailInfo:userId groupId:groupId];
}

+ (void)getGroupMemberDetailInfoFromServer:(NSString *)userId
                                   groupId:(NSString *)groupId
                                  complete:(void (^)(RCDGroupMemberDetailInfo *))complete {
    [RCDGroupAPI getGroupMemberDetailInfo:userId
                                  groupId:groupId
                                 complete:^(RCDGroupMemberDetailInfo *member) {
                                     if (member) {
                                         [RCDDBManager saveGroupMemberDetailInfo:member groupId:groupId];
                                         [self refreshGroupMemberInfo:userId groupId:groupId];
                                     }
                                     if (complete) {
                                         complete(member);
                                     }
                                 }];
}

+ (NSArray<RCDGroupLeftMember *> *)getGroupLeftMemberList:(NSString *)groupId {
    return [RCDDBManager getGroupLeftMemberList:groupId];
}

+ (void)getGroupLeftMemberListFromServer:(NSString *)groupId
                                complete:(void (^)(NSArray<RCDGroupLeftMember *> *))complete {
    [RCDGroupAPI getGroupLeftMemberList:groupId
                               complete:^(NSArray<RCDGroupLeftMember *> *list) {
                                   if (list) {
                                       [RCDDBManager clearGroupLeftMemberList:groupId];
                                       [RCDDBManager saveGroupLeftMemberList:list groupId:groupId];
                                   }
                                   if (complete) {
                                       complete(list);
                                   }
                               }];
}
#pragma mark - My Group
+ (NSArray<RCDGroupInfo *> *)getMyGroupList {
    return [RCDDBManager getMyGroups];
}

+ (void)getMyGroupListFromServer:(void (^)(NSArray<RCDGroupInfo *> *))complete {
    [RCDGroupAPI getMyGroupList:^(NSArray<RCDGroupInfo *> *_Nonnull groupList) {
        if (groupList) {
            [RCDDBManager saveGroups:groupList];
            NSMutableArray *tempArr = [NSMutableArray array];
            for (RCDGroupInfo *group in groupList) {
                [tempArr addObject:group.groupId];
            }
            [RCDDBManager clearMyGroups];
            [RCDDBManager saveMyGroups:tempArr];
        }
        if (complete) {
            complete(groupList);
        }
    }];
}

// 添加到我的群组
+ (void)addToMyGroups:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    [RCDGroupAPI addToMyGroups:groupId
                      complete:^(BOOL success) {
                          if (success) {
                              [RCDDBManager saveMyGroups:@[ groupId ]];
                          }
                          if (complete) {
                              complete(success);
                          }
                      }];
}

+ (void)removeFromMyGroups:(NSString *)groupId complete:(void (^)(BOOL))complete {
    [RCDGroupAPI removeFromMyGroups:groupId
                           complete:^(BOOL success) {
                               if (success) {
                                   [self getMyGroupListFromServer:nil];
                               }
                               if (complete) {
                                   complete(success);
                               }
                           }];
}

+ (BOOL)isInMyGroups:(NSString *)groupId {
    NSArray *groups = [RCDGroupManager getMyGroupList];
    for (RCDGroupInfo *group in groups) {
        if ([groupId isEqualToString:group.groupId]) {
            return YES;
        }
    }
    return NO;
}
#pragma mark - Group Notification
+ (BOOL)isHoldGroupNotificationMessage:(RCMessage *)message {
    if ([message.content isMemberOfClass:[RCDGroupNotificationMessage class]] ||
        [message.content isMemberOfClass:[RCGroupNotificationMessage class]]) {
        return [self isReceiveGroupNotificationMessage:message];
    } else if ([message.content isMemberOfClass:[RCDGroupNoticeUpdateMessage class]]) {
        return [self isReceiveGroupNoticeUpdateMessage:message];
    }
    return NO;
}

#pragma mark - private
+ (void)syncGroup:(NSString *)groupId {
    [self getGroupInfoFromServer:groupId complete:nil];
    [self getGroupMembersFromServer:groupId complete:nil];
}

+ (void)refreshGroupMemberInfo:(NSString *)userId groupId:(NSString *)groupId {
    RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
    if (user) {
        RCDGroupMember *memberDetail = [self getGroupMember:userId groupId:groupId];
        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
        if (friend.displayName.length > 0) {
            user.name = friend.displayName;
        } else if (memberDetail.groupNickname.length > 0) {
            user.name = memberDetail.groupNickname;
        }
        [[RCIM sharedRCIM] refreshGroupUserInfoCache:user withUserId:userId withGroupId:groupId];
    }
}

+ (RCDGroupInfo *)generateDefaultPortraitIfNeed:(RCDGroupInfo *)group {
    if (group) {
        if (group.portraitUri.length == 0) {
            group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
        }
    }
    return group;
}

+ (BOOL)isReceiveGroupNotificationMessage:(RCMessage *)message {
    RCDGroupNotificationMessage *msg = (RCDGroupNotificationMessage *)message.content;
    if ([msg.operation isEqualToString:RCDGroupDismiss] &&
        [msg.operatorUserId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        //自己操作解散的群组清理消息和会话
        [[RCDIMService sharedService] clearHistoryMessage:ConversationType_GROUP
            targetId:message.targetId
            successBlock:^{

            }
            errorBlock:^(RCErrorCode status){

            }];
        [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP targetId:message.targetId];
    } else if ([msg.operation isEqualToString:RCDGroupMemberManagerRemove]) {
        [[RCIMClient sharedRCIMClient] deleteMessages:@[ @(message.messageId) ]];
    }

    if ([msg.operation isEqualToString:RCDGroupDismiss] || [msg.operation isEqualToString:RCDGroupMemberQuit] ||
        [msg.operation isEqualToString:RCDGroupMemberKicked]) {
        [RCDDBManager clearGroupMembers:message.targetId];
        [RCDDBManager clearGroupMemberDetailInfo:message.targetId];
    }

    if (msg.operation && ![msg.operation isEqualToString:RCDGroupRename] &&
        ![msg.operation isEqualToString:RCDGroupBulletin]) {
        [RCDGroupManager getGroupMembersFromServer:message.targetId
                                          complete:^(NSArray<NSString *> *_Nonnull memberIdList) {
                                              rcd_dispatch_main_async_safe((^{
                                                  [[NSNotificationCenter defaultCenter]
                                                      postNotificationName:RCDGroupMemberUpdateKey
                                                                    object:@{
                                                                        @"targetId" : message.targetId,
                                                                        @"operation" : msg.operation
                                                                    }];
                                              }));
                                          }];
    }
    //同步群信息
    [RCDGroupManager getGroupInfoFromServer:message.targetId
                                   complete:^(RCDGroupInfo *_Nonnull groupInfo) {
                                       rcd_dispatch_main_async_safe(^{
                                           [[NSNotificationCenter defaultCenter]
                                               postNotificationName:RCDGroupInfoUpdateKey
                                                             object:message.targetId];
                                       });
                                   }];
    return YES;
}

+ (BOOL)isReceiveGroupNoticeUpdateMessage:(RCMessage *)message {
    RCDGroupNoticeUpdateMessage *msg = (RCDGroupNoticeUpdateMessage *)message.content;
    if ([msg.operation isEqualToString:RCDGroupMemberInvite]) {
        [RCDGroupManager getGroupNoticeListFromServer:^(NSArray<RCDGroupNotice *> *noticeList) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:RCDGroupNoticeUpdateKey object:nil];
            });
        }];
    }
    return YES;
}
@end
