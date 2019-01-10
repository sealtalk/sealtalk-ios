//
//  RCPublicServiceCommandMessage.h
//  RongIMLib
//
//  Created by litao on 15/6/23.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"
#import "RCPublicServiceMenuItem.h"

/*!
 公众服务请求消息的类型名
 */
#define RCPublicServiceCommandMessageTypeIdentifier @"RC:PSCmd"

/*!
 公众服务请求消息类

 @discussion 公众服务请求消息类，此消息不存储，也不计入未读消息数。
 此消息仅用于客户端公共服务账号中的菜单，向服务器发送请求。
 */
@interface RCPublicServiceCommandMessage : RCMessageContent <NSCoding>

/*!
 请求的名称
 */
@property(nonatomic, copy) NSString *command;

/*!
 请求的内容
 */
@property(nonatomic, copy) NSString *data;

/*!
 请求的扩展数据
 */
@property(nonatomic, copy) NSString *extra;

/*!
 初始化公众服务请求消息

 @param item    公众服务菜单项
 @return        公众服务请求消息对象
 */
+ (instancetype)messageFromMenuItem:(RCPublicServiceMenuItem *)item;

/*!
 初始化公众服务请求消息

 @param command     请求的名称
 @param data        请求的内容
 @return            公众服务请求消息对象
 */
+ (instancetype)messageWithCommand:(NSString *)command data:(NSString *)data;

@end
