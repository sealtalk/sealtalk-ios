//
//  RCCSLeaveMessage.h
//  RongIMLib
//
//  Created by 张改红 on 2016/12/7.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#define RCCSLeaveMessageTypeIdentifier @"RC:CsLM"
@interface RCCSLeaveMessage : RCMessageContent
@property (nonatomic, strong)NSDictionary *leaveMessageDic;
@end
