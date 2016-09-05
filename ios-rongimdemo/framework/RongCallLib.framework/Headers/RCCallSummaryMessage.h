//
//  RCCallSummaryMessage.h
//  RongCallLib
//
//  Created by 岑裕 on 16/3/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCCallCommonDefine.h"
#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

/*!
 通话摘要消息的类型名
 */
#define RCCallSummaryMessageTypeIdentifier @"RC:VCSummary"

/*!
 通话摘要消息类

 @discussion 通话摘要消息类，此消息会进行存储并计入未读消息数。
 */
@interface RCCallSummaryMessage : RCMessageContent

/*!
 通话的最初发起人
 */
@property(nonatomic, strong) NSString *caller;

/*!
 邀请当前用户加入通话的邀请者
 */
@property(nonatomic, strong) NSString *inviter;

/*!
 当前用户最后使用的媒体类型
 */
@property(nonatomic, assign) RCCallMediaType mediaType;

/*!
 通话挂断时包含的用户ID列表
 */
@property(nonatomic, strong) NSArray *memberIdList;

/*!
 通话开始时间

 @discussion
 如果是用户呼出的通话，则startTime为通话呼出时间；如果是呼入的通话，则startTime为通话呼入时间。
 */
@property(nonatomic, assign) long long startTime;

/*!
 通话接通时间
 */
@property(nonatomic, assign) long long connectedTime;

/*!
 通话总时长
 */
@property(nonatomic, assign) long long duration;

/*!
 通话结束的原因
 */
@property(nonatomic, assign) RCCallDisconnectReason hangupReason;

/*!
 初始化通话摘要消息

 @param caller        通话的最初发起人
 @param inviter       邀请当前用户加入通话的邀请者
 @param mediaType     当前用户最后使用的媒体类型
 @param memberIdList  通话挂断时包含的用户ID列表
 @param startTime     通话开始时间
 @param connectedTime 通话接通时间
 @param duration      通话总时长
 @param hangupReason  通话结束的原因

 @return 通话摘要消息的对象
 */
- (instancetype)initWithCaller:(NSString *)caller
                       inviter:(NSString *)inviter
                     mediaType:(RCCallMediaType)mediaType
                  memberIdList:(NSArray *)memberIdList
                     startTime:(long long)startTime
                 connectedTime:(long long)connectedTime
                      duration:(long long)duration
                  hangupReason:(RCCallDisconnectReason)hangupReason;

@end
