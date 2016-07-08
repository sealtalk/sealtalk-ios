/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCGroupNotification.h
//  Created by xugang on 14/11/24.

#import "RCMessageContent.h"

/*!
 群组通知消息的类型名
 */
#define RCGroupNotificationMessageIdentifier @"RC:GrpNtf"

/*!
 有成员加入群组的通知
 */
#define GroupNotificationMessage_GroupOperationAdd @"Add"
/*!
 有成员退出群组的通知
 */
#define GroupNotificationMessage_GroupOperationQuit @"Quit"
/*!
 有成员被踢出群组的通知
 */
#define GroupNotificationMessage_GroupOperationKicked @"Kicked"
/*!
 群组名称发生变更的通知
 */
#define GroupNotificationMessage_GroupOperationRename @"Rename"
/*!
 群组公告发生变更的通知
 */
#define GroupNotificationMessage_GroupOperationBulletin @"Bulletin"

/*!
 群组通知消息类

 @discussion 群组通知消息类，此消息会进行存储，但不计入未读消息数。
 */
@interface RCGroupNotificationMessage : RCMessageContent

/*!
 群组通知的当前操作名

 @discussion
 群组通知的当前操作名称，您可以使用预定义好的操作名，也可以是您自己定义的任何操作名。
 预定义的操作名：GroupNotificationMessage_GroupOperationAdd、GroupNotificationMessage_GroupOperationQuit、GroupNotificationMessage_GroupOperationKicked、GroupNotificationMessage_GroupOperationRename、GroupNotificationMessage_GroupOperationBulletin。
 */
@property(nonatomic, strong) NSString *operation;

/*!
 当前操作发起用户的用户ID
 */
@property(nonatomic, strong) NSString *operatorUserId;

/*!
 当前操作的目标对象

 @discussion
 当前操作的目标对象，如被当前操作目标用户的用户ID或变更后的群主名称等。
 */
@property(nonatomic, strong) NSString *data;

/*!
 当前操作的消息内容
 */
@property(nonatomic, strong) NSString *message;

/*!
 当前操作的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化群组通知消息

 @param operation       群组通知的当前操作名
 @param operatorUserId  当前操作发起用户的用户ID
 @param data            当前操作的目标对象
 @param message         当前操作的消息内容
 @param extra           当前操作的附加信息
 @return                群组通知消息对象

 @discussion 群组关系有开发者文虎，所有的群组操作都由您的服务器自己管理和维护。
 所以群组通知的操作名和目标对象、消息内容、扩展信息您均可以自己定制，只要您发送方和接收方针对具体字段内容做好UI显示即可。
 */
+ (instancetype)notificationWithOperation:(NSString *)operation
                           operatorUserId:(NSString *)operatorUserId
                                     data:(NSString *)data
                                  message:(NSString *)message
                                    extra:(NSString *)extra;

@end
