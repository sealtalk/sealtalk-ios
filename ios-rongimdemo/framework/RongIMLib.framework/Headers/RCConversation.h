/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCConversation.h
//  Created by Heq.Shinoda on 14-6-13.

#import "RCMessageContent.h"
#import <Foundation/Foundation.h>

/*!
 会话类

 @discussion 会话类，包含会话的所有属性。
 */
@interface RCConversation : NSObject <NSCoding>

/*!
 会话类型
 */
@property(nonatomic, assign) RCConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 会话的标题
 */
@property(nonatomic, strong) NSString *conversationTitle;

/*!
 会话中的未读消息数量
 */
@property(nonatomic, assign) int unreadMessageCount;

/*!
 是否置顶，默认值为NO

 @discussion
 如果设置了置顶，在IMKit的RCConversationListViewController中会将此会话置顶显示。
 */
@property(nonatomic, assign) BOOL isTop;

/*!
 会话中最后一条消息的接收状态
 */
@property(nonatomic, assign) RCReceivedStatus receivedStatus;

/*!
 会话中最后一条消息的发送状态
 */
@property(nonatomic, assign) RCSentStatus sentStatus;

/*!
 会话中最后一条消息的接收时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long receivedTime;

/*!
 会话中最后一条消息的发送时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long sentTime;

/*!
 会话中存在的草稿
 */
@property(nonatomic, strong) NSString *draft;

/*!
 会话中最后一条消息的类型名
 */
@property(nonatomic, strong) NSString *objectName;

/*!
 会话中最后一条消息的发送者用户ID
 */
@property(nonatomic, strong) NSString *senderUserId;

/*!
 会话中最后一条消息的发送者的用户名（已废弃，请勿使用）

 @warning **已废弃，请勿使用。**
 */
@property(nonatomic, strong) NSString *senderUserName
__deprecated_msg("已废弃，请勿使用。");

/*!
 会话中最后一条消息的消息ID
 */
@property(nonatomic, assign) long lastestMessageId;

/*!
 会话中最后一条消息的内容
 */
@property(nonatomic, strong) RCMessageContent *lastestMessage;

/*!
 会话中最后一条消息的json Dictionary
 
 @discussion 此字段存放最后一条消息内容中未编码的json数据。
 SDK内置的消息，如果消息解码失败，默认会将消息的内容存放到此字段；如果编码和解码正常，此字段会置为nil。
 */
@property(nonatomic, strong) NSDictionary *jsonDict;

/*!
 最后一条消息的全局唯一ID

 @discussion 服务器消息唯一ID（在同一个Appkey下全局唯一）
 */
@property(nonatomic, strong) NSString *lastestMessageUId;

/*!
 会话中是否存在被@的消息
 
 @discussion 在清除会话未读数（clearMessagesUnreadStatus:targetId:）的时候，会将此状态置成 NO。
 */
@property(nonatomic, assign) BOOL hasUnreadMentioned;

/*!
 RCConversation初始化方法（已废弃，请勿使用）

 @param json    会话的json Dictionary
 @return        会话对象

 @warning **已废弃，请勿使用。**
 */
+ (instancetype)conversationWithProperties:(NSDictionary *)json
    __deprecated_msg("已废弃，请勿使用。");

@end
