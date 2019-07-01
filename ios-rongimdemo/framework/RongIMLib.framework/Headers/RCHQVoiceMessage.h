//
//  RCHQVoiceMessage.h
//  RongIMLib
//
//  Created by Zhaoqianyu on 2019/5/16.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 高清语音消息类型名
 */
#define RCHQVoiceMessageTypeIdentifier @"RC:HQVCMsg"

NS_ASSUME_NONNULL_BEGIN

@interface RCHQVoiceMessage : RCMediaMessageContent <NSCoding>

/*!
 语音消息的时长
 */
@property(nonatomic, assign) long duration;

/*!
 语音消息的附加信息
 */
@property(nonatomic, copy) NSString *extra;

/*!
 初始化高清语音消息
 
 @param localPath 语音的本地路径
 @return          语音消息对象
 */
+ (instancetype)messageWithPath:(NSString *)localPath duration:(long)duration;

@end

NS_ASSUME_NONNULL_END
