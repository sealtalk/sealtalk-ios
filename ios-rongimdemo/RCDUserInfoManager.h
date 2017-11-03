//
//  RCDUserInfoManager.h
//  RCloudMessage
//
//  Created by Jue on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDUserInfo.h"
#import <Foundation/Foundation.h>

@interface RCDUserInfoManager : NSObject

+ (RCDUserInfoManager *)shareInstance;

//通过自己Id获取自己的用户信息
- (void)getUserInfo:(NSString *)userId completion:(void (^)(RCUserInfo *))completion;

//通过好友Id获取好友的用户信息
- (void)getFriendInfo:(NSString *)friendId completion:(void (^)(RCUserInfo *))completion;

//通过好友Id从数据库中获取好友的用户信息
- (RCUserInfo *)getFriendInfoFromDB:(NSString *)friendId;

//如有好友备注，则显示备注
- (NSArray *)getFriendInfoList:(NSArray *)friendList;

//通过userId设置默认的用户信息
- (RCUserInfo *)generateDefaultUserInfo:(NSString *)userId;

@end
