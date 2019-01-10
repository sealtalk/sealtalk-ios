/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCUserInfo.h
//  Created by Heq.Shinoda on 14-6-16.

#import <Foundation/Foundation.h>

/*!
 用户信息类
 */
@interface RCUserInfo : NSObject <NSCoding>

/*!
 用户ID
 */
@property(nonatomic, copy) NSString *userId;

/*!
 用户名称
 */
@property(nonatomic, copy) NSString *name;

/*!
 用户头像的URL
 */
@property(nonatomic, copy) NSString *portraitUri;

/**
 用户信息附加字段
 */
@property(nonatomic, copy) NSString *extra;

/*!
 用户信息的初始化方法

 @param userId      用户ID
 @param username    用户名称
 @param portrait    用户头像的URL
 @return            用户信息对象
 */
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait;

@end
