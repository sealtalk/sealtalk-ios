//
//  RCDFriendInfo.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCUserInfo.h>
#import "RCDUserInfo.h"

typedef NS_ENUM(NSInteger, RCDFriendStatus) {
    RCDFriendStatusRequest = 10,
    RCDFriendStatusRequested = 11,
    RCDFriendStatusAgree = 20,
    RCDFriendStatusIgnore = 21,
    RCDFriendStatusDelete = 30,
    RCDFriendStatusBlock = 31,
};

@interface RCDFriendInfo : RCDUserInfo

/**
 status: 与好友的关系。下面是好友关系的对照表，上面数据得到的status 值是20，表示和这个用户已经是好友了。
        | 对自己的状态    |自己  | 好友 | 对好友的状态
        | 发出了好友邀请  | 10   | 11  | 收到了好友邀请
        | 发出了好友邀请  | 10   | 21  | 忽略了好友邀请
        | 已是好友       | 20   | 20  | 已是好友
        | 已是好友       | 20   | 30  | 删除了好友关系
        | 删除了好友关系  | 30   | 30  | 删除了好友关系
        | 拉黑          | 31   | 31  | 拉黑
 */
@property (nonatomic, assign) RCDFriendStatus status;

@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, strong) NSString *phoneNumber;

@property (nonatomic, assign) long long updateDt;

@end
