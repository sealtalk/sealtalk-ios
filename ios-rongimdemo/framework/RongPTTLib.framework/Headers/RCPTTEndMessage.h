//
//  RCPTTEndMessage.h
//  RongPTTLib
//
//  Created by LiFei on 2017/1/12.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 对讲结束消息的类型名
 */
#define RCPTTEndMessageTypeIdentifier @"RCE:PttEnd"

/*!
 标识对讲结束的消息，该消息只会由app server发送
 */
@interface RCPTTEndMessage : RCMessageContent

@end
