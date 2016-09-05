//
//  RCRecallNotificationMessage.h
//  RongIMLib
//
//  Created by litao on 16/7/15.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 撤回通知消息的类型名
 */
#define RCRecallNotificationMessageIdentifier @"RC:RcNtf"

/*!
 撤回通知消息类
 */
@interface RCRecallNotificationMessage : RCMessageContent

/*!
 发起撤回操作的用户ID
 */
@property(nonatomic, strong) NSString *operatorId;

/*!
 撤回的时间（毫秒）
 */
@property(nonatomic, assign) long long recallTime;

/*!
 原消息的消息类型名
 */
@property(nonatomic, strong) NSString *originalObjectName;

@end
