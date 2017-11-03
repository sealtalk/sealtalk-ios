//
//  RCFileMessage.h
//  RongIMLib
//
//  Created by 珏王 on 16/5/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 文件消息的类型名
 */
#define RCFileMessageTypeIdentifier @"RC:FileMsg"

@interface RCFileMessage : RCMessageContent <NSCoding>

/*!
 文件名
 */
@property(nonatomic, strong) NSString *name;

/*!
 文件大小，单位为Byte
 */
@property(nonatomic, assign) long long size;

/*!
 文件类型
 */
@property(nonatomic, strong) NSString *type;

/*!
 文件的网络地址
 */
@property(nonatomic, strong) NSString *fileUrl;

/*!
 文件的本地路径
 */
@property(nonatomic, strong) NSString *localPath;

/*!
 附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化文件消息

 @param localPath 文件的本地路径
 @return          文件消息对象
 */
+ (instancetype)messageWithFile:(NSString *)localPath;

@end
