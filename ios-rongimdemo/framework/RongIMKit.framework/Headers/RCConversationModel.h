//
//  RCConversationModel.h
//  RongIMKit
//
//  Created by xugang on 15/1/22.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

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
@property(nonatomic, assign) RCConversationModelType conversationModelType;

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
@property(nonatomic, copy) NSString *targetId;

/*!
 会话的标题
 */
@property(nonatomic, copy) NSString *conversationTitle;

/*!
 会话中的未读消息数
 */
@property(nonatomic, assign) NSInteger unreadMessageCount;

/*!
 当前会话是否置顶
 */
@property(nonatomic, assign) BOOL isTop;

/*!
 置顶Cell的背景颜色
 */
@property(nonatomic, strong) UIColor *topCellBackgroundColor;

/*!
 非置顶的Cell的背景颜色
 */
@property(nonatomic, strong) UIColor *cellBackgroundColor;

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
@property(nonatomic, copy) NSString *draft;

/*!
 会话中最后一条消息的类型名
 */
@property(nonatomic, copy) NSString *objectName;

/*!
 会话中最后一条消息的发送者用户ID
 */
@property(nonatomic, copy) NSString *senderUserId;

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
 会话中最后一条消息的方向
 */
@property(nonatomic, assign) RCMessageDirection lastestMessageDirection;

/*!
 会话中最后一条消息的json Dictionary
 */
@property(nonatomic, strong) NSDictionary *jsonDict;

/*!
 会话中有被提及的消息（有@你的消息）
 */
@property(nonatomic, assign) BOOL hasUnreadMentioned;

/*!
 初始化会话Cell的数据模型（已废弃，请勿使用）

 @param conversationModelType 会话Cell数据模型的显示类型
 @param extend                用户自定义的扩展数据
 @return 会话Cell的数据模型对象

 @warning **已废弃，请勿使用。**
 */
- (instancetype)init:(RCConversationModelType)conversationModelType
             exntend:(id)extend __deprecated_msg("已废弃，请勿使用。");

/*!
 初始化会话显示数据模型

 @param conversationModelType 会话Cell数据模型的显示类型
 @param conversation          会话
 @param extend                用户自定义的扩展数据
 @return 会话Cell的数据模型对象

 @warning **已废弃，请勿使用。**
 */
- (instancetype)init:(RCConversationModelType)conversationModelType
        conversation:(RCConversation *)conversation
              extend:(id)extend __deprecated_msg("已废弃，请勿使用。");

/*!
 初始化会话显示数据模型

 @param conversation          会话
 @param extend                用户自定义的扩展数据
 @return 会话Cell的数据模型对象
 */
- (instancetype)initWithConversation:(RCConversation *)conversation extend:(id)extend;

/*!
 更新数据模型中的消息

 @param message 此会话中最新的消息
 */
- (void)updateWithMessage:(RCMessage *)message;

/*!
 会话和数据模型是否匹配

 @param conversationType 会话类型
 @param targetId         目标会话ID
 @return 会话和数据模型是否匹配
 */
- (BOOL)isMatching:(RCConversationType)conversationType targetId:(NSString *)targetId;

@end
