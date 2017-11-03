/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCTextMessage.h
//  Created by Heq.Shinoda on 14-6-13.

#import "RCMessageContent.h"

/*!
 文本消息的类型名
 */
#define RCTextMessageTypeIdentifier @"RC:TxtMsg"

/*!
 文本消息类

 @discussion 文本消息类，此消息会进行存储并计入未读消息数。
 */
@interface RCTextMessage : RCMessageContent <NSCoding>

/*!
 文本消息的内容
 */
@property(nonatomic, strong) NSString *content;

/*!
 文本消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化文本消息

 @param content 文本消息的内容
 @return        文本消息对象
 */
+ (instancetype)messageWithContent:(NSString *)content;

@end
