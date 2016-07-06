//
//  RCRealTimeLocationEndMessage.h
//  RongIMLib
//
//  Created by 杜立召 on 15/8/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageContent.h"

/*!
 实时位置共享的结束消息的类型名
 */
#define RCRealTimeLocationEndMessageTypeIdentifier @"RC:RLEnd"

/*!
 实时位置共享的结束消息类

 @discussion 实时位置共享的结束消息类，此消息会进行存储并计入未读消息数。
 */
@interface RCRealTimeLocationEndMessage : RCMessageContent

/*!
 结束消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化实时位置共享的结束消息

 @param extra   附加信息
 @return        初始化实时位置共享的结束消息对象
 */
+ (instancetype)messageWithExtra:(NSString *)extra;

@end