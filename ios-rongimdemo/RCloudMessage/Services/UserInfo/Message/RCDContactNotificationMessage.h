//
//  RCDContactNotificationMessage.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 好友请求消息的类型名
 */
#define RCDContactNotificationMessageIdentifier @"ST:ContactNtf"

/*!
 请求添加好友
 */
#define RCDContactNotificationMessage_ContactOperationRequest @"Request"
/*!
 同意添加好友的请求
 */
#define RCDContactNotificationMessage_ContactOperationAcceptResponse @"AcceptResponse"
/*!
 拒绝添加好友的请求
 */
#define RCDContactNotificationMessage_ContactOperationRejectResponse @"RejectResponse"

/*!
 好友请求消息类

 @discussion 好友请求消息类，此消息会进行存储，但不计入未读消息数。
 */
@interface RCDContactNotificationMessage : RCMessageContent <NSCoding>

/*!
 好友请求的当前操作名

 @discussion
 好友请求当前的操作名称，您可以使用预定义好的操作名，也可以是您自己定义的任何操作名。
 预定义的操作名：RCDContactNotificationMessage_ContactOperationRequest、RCDContactNotificationMessage_ContactOperationAcceptResponse、RCDContactNotificationMessage_ContactOperationRejectResponse。
 */
@property (nonatomic, copy) NSString *operation;

/*!
 当前操作发起用户的用户ID
 */
@property (nonatomic, copy) NSString *sourceUserId;

/*!
 当前操作目标用户的用户ID
 */
@property (nonatomic, copy) NSString *targetUserId;

/*!
 当前操作的消息内容

 @discussion 当前操作的消息内容，如同意、拒绝的理由等。
 */
@property (nonatomic, copy) NSString *message;

/*!
 当前操作的附加信息
 */
@property (nonatomic, copy) NSString *extra;

/*!
 初始化好友请求消息

 @param operation       好友请求当前的操作名
 @param sourceUserId    当前操作发起用户的用户ID
 @param targetUserId    当前操作目标用户的用户ID
 @param message         当前操作的消息内容
 @param extra           当前操作的附加信息
 @return                好友请求消息对象

 @discussion 融云不介入您的好友关系，所有的好友关系都由您的服务器自己维护。
 所以好友请求的操作名和消息内容、扩展信息您均可以自己定制，只要您发送方和接收方针对具体字段内容做好UI显示即可。
 */
+ (instancetype)notificationWithOperation:(NSString *)operation
                             sourceUserId:(NSString *)sourceUserId
                             targetUserId:(NSString *)targetUserId
                                  message:(NSString *)message
                                    extra:(NSString *)extra;

@end

NS_ASSUME_NONNULL_END
