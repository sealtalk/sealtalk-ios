//
//  RCCommandMessage.h
//  RongIMLib
//
//  Created by 张改红 on 15/12/2.
//  Copyright © 2015年 RongCloud. All rights reserved.
//
#import "RCMessageContent.h"

/*!
 命令消息的类型名
 */
#define RCCommandMessageIdentifier @"RC:CmdMsg"

/*!
 命令消息类

 @discussion 命令消息类，此消息不存储不计入未读消息数。
 与RCCommandNotificationMessage的区别是，此消息不存储，也不会在界面上显示。
 */
@interface RCCommandMessage : RCMessageContent<NSCoding>

/*!
命令的名称
*/
@property(nonatomic, strong) NSString *name;

/*!
 命令的扩展数据

 @discussion 命令的扩展数据，可以为任意字符串，如存放您定义的json数据。
 */
@property(nonatomic, strong) NSString *data;

/*!
 初始化命令消息

 @param name    命令的名称
 @param data    命令的扩展数据
 @return        命令消息对象
 */
+ (instancetype)messageWithName:(NSString *)name data:(NSString *)data;

@end
