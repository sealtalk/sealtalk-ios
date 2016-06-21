/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCUnknownMessage.h
//  Created by xugang on 15/1/24.

#import "RCMessageContent.h"

/*!
 未知消息的类型名
 */
#define RCUnknownMessageTypeIdentifier @"RC:UnknownMsg"

/*!
 未知消息类
 
 @discussion 所有未注册的消息类型，在IMKit中都会作为此类消息处理和显示。
 */
@interface RCUnknownMessage : RCMessageContent

@end
