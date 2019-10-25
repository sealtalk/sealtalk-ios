//
//  RCDPokeMessage.h
//  SealTalk
//
//  Created by 张改红 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN
#define RCDPokeMessageTypeIdentifier @"ST:PokeMsg"
@interface RCDPokeMessage : RCMessageContent
@property (nonatomic, strong) NSString *content;
@end

NS_ASSUME_NONNULL_END
