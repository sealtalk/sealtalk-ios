//
//  RCDUserInfo.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCUserInfo.h>

@interface RCDUserInfo : RCUserInfo

/** 全拼*/
@property(nonatomic, strong) NSString *quanPin;
/** email*/
@property(nonatomic, strong) NSString *email;
/**
 status: 与好友的关系。下面是好友关系的对照表，上面数据得到的status 值是20，表示和这个用户已经是好友了。
        | 对自己的状态    |自己  | 好友 | 对好友的状态
        | 发出了好友邀请  | 10   | 11  | 收到了好友邀请
        | 发出了好友邀请  | 10   | 21  | 忽略了好友邀请
        | 已是好友       | 20   | 20  | 已是好友
        | 已是好友       | 20   | 30  | 删除了好友关系
        | 删除了好友关系  | 30   | 30  | 删除了好友关系
 */
@property(nonatomic, strong) NSString *status;

@property(nonatomic, strong) NSString *updatedAt;

@property(nonatomic, strong) NSString *displayName;

@end
