//
//  RCDUserInfoManager.m
//  RCloudMessage
//
//  Created by Jue on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDUserInfoManager.h"
#import "AFHttpTool.h"
#import "RCDGroupInfo.h"
#import "RCDHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"

@implementation RCDUserInfoManager

+ (RCDUserInfoManager *)shareInstance {
    static RCDUserInfoManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

//通过自己的userId获取自己的用户信息
- (void)getUserInfo:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    [RCDHTTPTOOL getUserInfoByUserID:userId
                          completion:^(RCUserInfo *user) {
                              if (user) {
                                  completion(user);
                                  return;
                              } else {
                                  user = [[RCDataBaseManager shareInstance] getUserByUserId:userId];
                                  if (user == nil) {
                                      user = [self generateDefaultUserInfo:userId];
                                      completion(user);
                                      return;
                                  }
                              }
                          }];
}
//通过好友详细信息或好友Id获取好友信息
- (void)getFriendInfo:(NSString *)friendId completion:(void (^)(RCUserInfo *))completion {
    __block RCUserInfo *resultInfo;
    [RCDHTTPTOOL getFriendDetailsWithFriendId:friendId
        success:^(RCDUserInfo *user) {
            resultInfo = [self getRCUserInfoByRCDUserInfo:user];
            completion(resultInfo);
            return;
        }
        failure:^(NSError *err) {
            RCDUserInfo *friendInfo = [[RCDataBaseManager shareInstance] getFriendInfo:friendId];
            if (friendInfo != nil) {
                resultInfo = [self getRCUserInfoByRCDUserInfo:friendInfo];
                completion(resultInfo);
                return;
            } else {
                [self getUserInfo:friendId
                       completion:^(RCUserInfo *user) {
                           resultInfo = user;
                           completion(resultInfo);
                           return;
                       }];
            }
        }];
}

- (RCUserInfo *)getFriendInfoFromDB:(NSString *)friendId {
    RCUserInfo *resultInfo;
    RCDUserInfo *friend = [[RCDataBaseManager shareInstance] getFriendInfo:friendId];
    if (friend != nil) {
        resultInfo = [self getRCUserInfoByRCDUserInfo:friend];
        return resultInfo;
    }
    return nil;
}

//如有好友备注，则显示备注
- (NSArray *)getFriendInfoList:(NSArray *)friendList {
    NSMutableArray *resultList = [NSMutableArray new];
    for (RCUserInfo *user in friendList) {
        RCUserInfo *friend = [self getFriendInfoFromDB:user.userId];
        if (friend != nil) {
            [resultList addObject:friend];
        } else {
            [resultList addObject:user];
        }
    }
    NSArray *result = [[NSArray alloc] initWithArray:resultList];
    return result;
}

//设置默认的用户信息
- (RCUserInfo *)generateDefaultUserInfo:(NSString *)userId {
    RCUserInfo *defaultUserInfo = [RCUserInfo new];
    defaultUserInfo.userId = userId;
    defaultUserInfo.name = [NSString stringWithFormat:@"name%@", userId];
    defaultUserInfo.portraitUri = [RCDUtilities defaultUserPortrait:defaultUserInfo];
    return defaultUserInfo;
}

//通过RCDUserInfo对象获取RCUserInfo对象
- (RCUserInfo *)getRCUserInfoByRCDUserInfo:(RCDUserInfo *)friendDetails {
    RCUserInfo *friend = [RCUserInfo new];
    friend.userId = friendDetails.userId;
    friend.name = friendDetails.name;
    if (friendDetails.displayName.length > 0 && ![friendDetails.displayName isEqualToString:@""]) {
        friend.name = friendDetails.displayName;
    }
    friend.portraitUri = friendDetails.portraitUri;
    if (!friendDetails.portraitUri || friendDetails.portraitUri.length <= 0) {
        friend.portraitUri = [RCDUtilities defaultUserPortrait:friendDetails];
    }
    return friend;
}
@end
