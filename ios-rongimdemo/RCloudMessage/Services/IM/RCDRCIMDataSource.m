//
//  RCDRCIMDelegateImplementation.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDRCIMDataSource.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import "RCDGroupManager.h"
#import "RCDCommonString.h"

@interface RCDRCIMDataSource ()

@end

@implementation RCDRCIMDataSource

+ (RCDRCIMDataSource *)sharedInstance {
    static RCDRCIMDataSource *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];

    });
    return instance;
}

- (void)syncAllData{
    [RCDDataSource syncGroups];
    [RCDDataSource syncGroupNoticeList];
    [RCDDataSource syncFriendList];
}

- (void)syncGroups {
    //开发者调用自己的服务器接口获取所属群组信息
    [RCDGroupManager getMyGroupListFromServer:^(NSArray<RCDGroupInfo *> * _Nonnull groupList) {
        for (RCDGroupInfo *group in groupList) {
            [RCDGroupManager getGroupMembersFromServer:group.groupId complete:^(NSArray<NSString *> * _Nonnull memberIdList) {}];
        }
    }];
}

- (void)syncGroupNoticeList{
    [RCDGroupManager getGroupNoticeListFromServer:^(NSArray<RCDGroupNotice *> *noticeList) {
        
    }];
}

- (void)syncFriendList{
    [RCDUserInfoManager getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
        rcd_dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:RCDContactsRequestKey object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:RCDContactsUpdateUIKey object:nil];
        });
    }];
}

#pragma mark - GroupInfoFetcherDelegate
- (void)getGroupInfoWithGroupId:(NSString *)groupId completion:(void (^)(RCGroup *))completion {
    if ([groupId length] == 0)
        return;

    //开发者调自己的服务器接口根据userID异步请求数据
    [RCDGroupManager getGroupInfoFromServer:groupId complete:^(RCDGroupInfo * _Nonnull groupInfo) {
        completion(groupInfo);
    }];
}
#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    NSLog(@"getUserInfoWithUserId ----- %@", userId);
    if ([userId isEqualToString:RCDGroupNoticeTargetId]) {//群通知的用户信息直接在自定义的 RCDGroupConversationCell 里面处理了
        return;
    }
    //开发者调自己的服务器接口根据userID异步请求数据
    [RCDUserInfoManager getUserInfoFromServer:userId complete:^(RCUserInfo *userInfo) {
        if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            completion(userInfo);
        }else{
            [RCDUserInfoManager getFriendInfoFromServer:userId complete:^(RCDFriendInfo *friendInfo) {
                if (friendInfo && friendInfo.displayName.length > 0) {
                    userInfo.name = friendInfo.displayName;
                }
                completion(userInfo);
            }];
        }
    }];
    return;
}

#pragma mark - RCIMGroupUserInfoDataSource
/**
 *  获取群组内的用户信息。
 *  如果群组内没有设置用户信息，请注意：1，不要调用别的接口返回全局用户信息，直接回调给我们nil就行，SDK会自己巧用用户信息提供者；2一定要调用completion(nil)，这样SDK才能继续往下操作。
 *
 *  @param groupId  群组ID.
 *  @param completion 获取完成调用的BLOCK.
 */
- (void)getUserInfoWithUserId:(NSString *)userId
                      inGroup:(NSString *)groupId
                   completion:(void (^)(RCUserInfo *userInfo))completion {
    //在这里查询该group内的群名片信息，如果能查到，调用completion返回。如果查询不到也一定要调用completion(nil)
    if ([groupId isEqualToString:@"22"] && [userId isEqualToString:@"30806"]) {
        completion([[RCUserInfo alloc] initWithUserId:@"30806" name:@"我在22群中的名片" portrait:nil]);
    } else {
        completion(nil); //融云demo中暂时没有实现，以后会添加上该功能。app也可以自己实现该功能。
    }
}

#pragma mark - RCIMGroupMemberDataSource
- (void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray<NSString *> *))resultBlock {
    [RCDGroupManager getGroupMembersFromServer:groupId complete:^(NSArray<NSString *> * _Nonnull memberIdList) {
        if (resultBlock) {
            resultBlock(memberIdList);
        }
    }];
}

#pragma mark - 名片消息
- (void)getAllContacts:(void (^)(NSArray<RCCCUserInfo *> *contactsInfoList))resultBlock {
    NSMutableArray *contacts = [NSMutableArray new];
    NSArray *allFriends = [RCDUserInfoManager getAllFriends];
    for (RCDFriendInfo *friend in allFriends) {
        RCCCUserInfo *contact = [RCCCUserInfo new];
        contact.userId = friend.userId;
        contact.name = friend.name;
        contact.portraitUri = friend.portraitUri;
        RCUserInfo *tempContact = [RCDUserInfoManager getFriendInfo:friend.userId];
        contact.displayName = tempContact.name;
        [contacts addObject:contact];
    }
    resultBlock(contacts);
}

- (void)getGroupInfoByGroupId:(NSString *)groupId result:(void (^)(RCCCGroupInfo *groupInfo))resultBlock {
    RCDGroupInfo *group = [RCDGroupManager getGroupInfo:groupId];
    RCCCGroupInfo *groupInfo = [RCCCGroupInfo new];
    groupInfo.groupId = groupId;
    groupInfo.groupName = group.groupName;
    groupInfo.portraitUri = group.portraitUri;
    groupInfo.number = group.number;
    resultBlock(groupInfo);
}

@end
