//
//  RCCSLeaveMessage.h
//  RongIMLib
//
//  Created by 张改红 on 2016/12/6.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#define RCCSPullLeaveMessageTypeIdentifier @"RC:CsPLM"
@interface RCCSPullLeaveMessage : RCMessageContent
@property(nonatomic, copy) NSString *content;
@end
