//
//  RCDClearMessage.h
//  SealTalk
//
//  Created by 张改红 on 2019/9/5.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN
#define RCDClearMessageIdentifier @"ST:MsgClear"
@interface RCDClearMessage : RCMessageContent
@property (nonatomic, assign) long long clearTime;
@end

NS_ASSUME_NONNULL_END
