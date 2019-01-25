//
//  RCPTTBeginMessage.h
//  RongPTTLib
//
//  Created by LiFei on 2017/1/11.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 对讲开始消息的类型名
 */
#define RCPTTBeginMessageTypeIdentifier @"RCE:PttBegin"

/*!
 标识对讲开始的消息，该消息只会由app server发送
 */
@interface RCPTTBeginMessage : RCMessageContent <NSCoding>

/*!
 对讲发起者
 */
@property(nonatomic, strong) NSString *initiator;

@end
