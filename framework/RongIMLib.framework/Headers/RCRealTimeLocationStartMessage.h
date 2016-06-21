//
//  RCRealTimeLocationStartMessage.h
//  RongIMLib
//
//  Created by litao on 15/7/14.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"

/*!
 实时位置共享的发起消息的类型名
 */
#define RCRealTimeLocationStartMessageTypeIdentifier @"RC:RLStart"

/*!
 实时位置共享的发起消息类
 
 @discussion 实时位置共享的发起消息类，此消息会进行存储并计入未读消息数。
 */
@interface RCRealTimeLocationStartMessage : RCMessageContent

/*!
 发起消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化实时位置共享的发起消息
 
 @param extra   附加信息
 @return        初始化实时位置共享的发起消息对象
 */
+ (instancetype)messageWithExtra:(NSString *)extra;

@end
