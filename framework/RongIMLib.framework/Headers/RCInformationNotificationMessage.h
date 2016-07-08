/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCInformationNotificationMessage.h
//  Created by xugang on 14/12/4.

#import "RCMessageContent.h"

/*!
 通知消息的类型名
 */
#define RCInformationNotificationMessageIdentifier @"RC:InfoNtf"

/*!
 通知消息类

 @discussion 通知消息类，此消息会进行存储，但不计入未读消息数。
 */
@interface RCInformationNotificationMessage : RCMessageContent

/*!
 通知的内容
 */
@property(nonatomic, strong) NSString *message;

/*!
 通知的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化通知消息

 @param message 通知的内容
 @param extra   通知的附加信息
 @return        通知消息对象
 */
+ (instancetype)notificationWithMessage:(NSString *)message
                                  extra:(NSString *)extra;

@end
