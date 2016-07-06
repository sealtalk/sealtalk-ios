//
//  RCUserTypingStatus.h
//  RongIMLib
//
//  Created by 岑裕 on 16/1/8.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 用户输入状态类
 */
@interface RCUserTypingStatus : NSObject

/*!
 当前正在输入的用户ID
 */
@property(nonatomic, strong) NSString *userId;

/*!
 当前正在输入的消息类型名

 @discussion
 contentType为用户当前正在编辑的消息类型名，即RCMessageContent中getObjectName的返回值。
 如文本消息，应该传类型名"RC:TxtMsg"。
 */
@property(nonatomic, strong) NSString *contentType;

/*!
 初始化用户输入状态对象

 @param userId     当前正在输入的用户ID
 @param objectName 当前正在输入的消息类型名

 @return 用户输入状态对象
 */
- (instancetype)initWithUserId:(NSString *)userId
                   contentType:(NSString *)objectName;

@end
