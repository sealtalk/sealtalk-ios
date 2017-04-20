//
//  RCContactCardMessage.h
//  RCloudMessage
//
//  Created by Sin on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 文件消息的类型名
 */
#define RCContactCardMessageTypeIdentifier @"RC:CardMsg"

/**
 *  个人名片消息
 */
@interface RCContactCardMessage : RCMessageContent

/**
 *  个人名片消息的id
 */
@property (nonatomic,copy) NSString *userId;

/**
 *  个人名片的昵称
 */
@property (nonatomic,copy) NSString *name;

/**
 *  个人名片的头像
 */
@property (nonatomic,copy) NSString *portraitUri;

/**
 *  个人名片的附加信息
 */
@property (nonatomic,copy) NSString *extra;

/**
 *  名片消息的初始化方法
 *
 *  @param userInfo 名片的用户信息
 *
 *  @return 名片消息对象
 */
+ (instancetype)messageWithUserInfo:(RCUserInfo *)userInfo;

@end
