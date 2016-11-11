//
//  RCDRCIMDelegateImplementation.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "AFHttpTool.h"
#import "DefaultPortraitView.h"
#import "RCDCommonDefine.h"
#import "RCDGroupInfo.h"
#import "RCDHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDUserInfo.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDUserInfoManager.h"

@interface RCDRCIMDataSource ()

@end

@implementation RCDRCIMDataSource

+ (RCDRCIMDataSource *)shareInstance {
  static RCDRCIMDataSource *instance = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    instance = [[[self class] alloc] init];

  });
  return instance;
}

- (void)syncGroups {
  //开发者调用自己的服务器接口获取所属群组信息
  [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result) {
    for (RCDGroupInfo *group in result) {
      [RCDHTTPTOOL getGroupMembersWithGroupId:group.groupId Block:^(NSMutableArray *result) {
        [[RCDataBaseManager shareInstance]
         insertGroupMemberToDB:result
         groupId:group.groupId
         complete:^(BOOL result) {
           
         }];
      }];
    }
  }];
}

- (void)syncFriendList:(NSString *)userId
              complete:(void (^)(NSMutableArray *friends))completion {
  [RCDHTTPTOOL getFriendscomplete:^(NSMutableArray *result) {
                   completion(result);
                 }];
}

#pragma mark - GroupInfoFetcherDelegate
- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *))completion {
  if ([groupId length] == 0)
    return;

  //开发者调自己的服务器接口根据userID异步请求数据
  [RCDHTTPTOOL getGroupByID:groupId
          successCompletion:^(RCDGroupInfo *group) {
            completion(group);
          }];
}
#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *))completion {
  NSLog(@"getUserInfoWithUserId ----- %@", userId);
  RCUserInfo *user = [RCUserInfo new];
  if (userId == nil || [userId length] == 0) {
    user.userId = userId;
    user.portraitUri = @"";
    user.name = @"";
    completion(user);
    return;
  }
  //开发者调自己的服务器接口根据userID异步请求数据
  if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
    [[RCDUserInfoManager shareInstance] getFriendInfo:userId
                                                  completion:^(RCUserInfo *user) {
                                                    completion(user);
                                                  }];
  } else {
    [[RCDUserInfoManager shareInstance] getUserInfo:userId
                                         completion:^(RCUserInfo *user) {
                                           [[RCIM sharedRCIM]
                                            refreshUserInfoCache:user
                                            withUserId:user.userId];
                                           
                                            completion(user);
    }];
  }
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
    completion([[RCUserInfo alloc] initWithUserId:@"30806"
                                             name:@"我在22群中的名片"
                                         portrait:nil]);
  } else {
    completion(
        nil); //融云demo中暂时没有实现，以后会添加上该功能。app也可以自己实现该功能。
  }
}

- (void)getAllMembersOfGroup:(NSString *)groupId
                      result:(void (^)(NSArray *userIdList))resultBlock {
  [[RCDHttpTool shareInstance]
      getGroupMembersWithGroupId:groupId
                           Block:^(NSMutableArray *result) {
                             NSMutableArray *ret =
                                 [[NSMutableArray alloc] init];
                             for (RCUserInfo *user in result) {
                               [ret addObject:user.userId];
                             }
                             resultBlock(ret);
                           }];
}

- (NSArray *)getAllUserInfo:(void (^)())completion {
  return [[RCDataBaseManager shareInstance] getAllUserInfo];
}

- (NSArray *)getAllGroupInfo:(void (^)())completion {
  return [[RCDataBaseManager shareInstance] getAllGroup];
}

- (NSArray *)getAllFriends:(void (^)())completion {
  return [[RCDataBaseManager shareInstance] getAllFriends];
}
@end
