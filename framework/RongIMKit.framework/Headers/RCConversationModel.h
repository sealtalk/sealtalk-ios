//
//  RongConversationModel.h
//  RongIMKit
//
//  Created by xugang on 15/1/22.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef __RongConversationModel
#define __RongConversationModel

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

/*!
 会话Cell数据模型的显示类型
 */
typedef NS_ENUM(NSUInteger, RCConversationModelType) {
    /*!
     默认显示
     */
    RC_CONVERSATION_MODEL_TYPE_NORMAL = 1,
    /*!
     聚合显示
     */
    RC_CONVERSATION_MODEL_TYPE_COLLECTION = 2,
    /*!
     用户自定义的会话显示
     */
    RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION = 3,
    /*!
     公众服务的会话显示
     */
    RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE = 4
};

/*!
 会话Cell的数据模型类
 */
@interface RCConversationModel : NSObject

/*!
 会话Cell数据模型的显示类型
 */
@property(nonatomic) RCConversationModelType conversationModelType;

/*!
 用户自定义的扩展数据
 */
@property(nonatomic, strong) id extend;

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
 会话中的未读消息数
 */
@property(nonatomic, assign) NSInteger unreadMessageCount;

/*!
 当前会话是否置顶
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
@property(nonatomic, strong) __deprecated_msg("已废弃，请勿使用。") NSString *senderUserName;

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
 */
@property(nonatomic, strong) NSDictionary *jsonDict;

/*!
 初始化会话Cell的数据模型（已废弃，请勿使用）
 
 @param conversationModelType 会话Cell数据模型的显示类型
 @param extend                用户自定义的扩展数据
 
 @return 会话Cell的数据模型对象
 
 @warning **已废弃，请勿使用。**
 */
- (id)init:(RCConversationModelType)conversationModelType exntend:(id)extend
__deprecated_msg("已废弃，请勿使用。");

/*!
 初始化会话显示数据模型
 
 @param conversationModelType 会话Cell数据模型的显示类型
 @param conversation          会话
 @param extend                用户自定义的扩展数据
 
 @return 会话Cell的数据模型对象
 */
- (id)init:(RCConversationModelType)conversationModelType conversation:(RCConversation *)conversation extend:(id)extend;

@end

#endif