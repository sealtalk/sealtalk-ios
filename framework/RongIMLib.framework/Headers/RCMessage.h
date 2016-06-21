/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCMessage.h
//  Created by Heq.Shinoda on 14-6-13.

#ifndef __RCMessage
#define __RCMessage
#import <Foundation/Foundation.h>
#import "RCStatusDefine.h"
#import "RCMessageContent.h"

/*!
 消息实体类
 
 @discussion 消息实体类，包含消息的所有属性。
 */
@interface RCMessage : NSObject <NSCopying, NSCoding>

/*!
 会话类型
 */
@property(nonatomic, assign) RCConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 消息的ID
 
 @discussion 本地存储的消息的唯一值（数据库索引唯一值）
 */
@property(nonatomic, assign) long messageId;

/*!
 消息的方向
 */
@property(nonatomic, assign) RCMessageDirection messageDirection;

/*!
 消息的发送者ID
 */
@property(nonatomic, strong) NSString *senderUserId;

/*!
 消息的接收状态
 */
@property(nonatomic, assign) RCReceivedStatus receivedStatus;

/*!
 消息的发送状态
 */
@property(nonatomic, assign) RCSentStatus sentStatus;

/*!
 消息的接收时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long receivedTime;

/*!
 消息的发送时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long sentTime;

/*!
 消息的类型名
 */
@property(nonatomic, strong) NSString *objectName;

/*!
 消息的内容
 */
@property(nonatomic, strong) RCMessageContent *content;

/*!
 消息的附加字段
 */
@property(nonatomic, strong) NSString *extra;

/*!
 全局唯一ID
 
 @discussion 服务器消息唯一ID（在同一个Appkey下全局唯一）
 */
@property(nonatomic, strong) NSString *messageUId;

/*!
 RCMessage初始化方法
 
 @param  conversationType    会话类型
 @param  targetId            目标会话ID
 @param  messageDirection    消息的方向
 @param  messageId           消息的ID
 @param  content             消息的内容
 */
- (instancetype)initWithType:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                   direction:(RCMessageDirection)messageDirection
                   messageId:(long)messageId
                     content:(RCMessageContent *)content;

/*!
 RCMessage初始化方法（已废弃，请勿使用）
 
 @param jsonData    消息的JSON Dictionary
 @return            消息实体对象
 
 @warning **已废弃，请勿使用。**
 */
+ (instancetype)messageWithJSON:(NSDictionary *)jsonData
__deprecated_msg("已废弃，请勿使用。");

@end
#endif
