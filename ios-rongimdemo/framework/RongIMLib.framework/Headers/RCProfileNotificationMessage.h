/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCProfileNotificationMessage.h
//  Created by xugang on 14/11/28.

#import "RCMessageContent.h"

/*!
 公众服务账号信息变更消息的类型名
 */
#define RCProfileNotificationMessageIdentifier @"RC:ProfileNtf"

/*!
 公众服务账号信息变更消息类

 @discussion 公众服务账号信息变更消息类，此消息会进行存储，但不计入未读消息数。
 */
@interface RCProfileNotificationMessage : RCMessageContent<NSCoding>

/*!
公众服务账号信息变更的操作名
*/
@property(nonatomic, strong) NSString *operation;

/*!
 信息变更的数据，可以为任意格式，如json数据。
 */
@property(nonatomic, strong) NSString *data;

/*!
 信息变更的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化公众服务账号信息变更消息

 @param operation   信息变更的操作名
 @param data        信息变更的数据
 @param extra       信息变更的附加信息
 @return            公众服务账号信息变更消息的对象
 */
+ (instancetype)notificationWithOperation:(NSString *)operation
                                     data:(NSString *)data
                                    extra:(NSString *)extra;

@end
