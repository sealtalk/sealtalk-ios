//
//  RongRTCRoomDelegate.h
//  RongRTCLib
//
//  Created by 杜立召 on 2019/1/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#ifndef RongRTCRoomDelegate_h
#define RongRTCRoomDelegate_h

#import <RongIMLib/RongIMLib.h>

@class RongRTCRemoteUser;
@class RongRTCAVInputStream;
@class RongRTCDataInputStream;
@class RongRTCRoom;
NS_ASSUME_NONNULL_BEGIN

/**
 音视频通话的房间代理，实现这个代理之后房间成员变化以及资源的变化都会通过代理通知给您
 */
@protocol RongRTCRoomDelegate <NSObject>

@optional

/**
 有用户加入的回调,此时 user 不包含任何资源，只是标记有人加入,此时无法订阅这个人的流
 
 @param user 加入的用户信息
 */
-(void)didJoinUser:(RongRTCRemoteUser*)user;

/**
 有用户离开时的回调,当有用户离开的时候，SDK 会取消订阅这个 user ， APP 无需再次调用取消订阅的接口。
 
 @param user 离开的用户
 */
-(void)didLeaveUser:(RongRTCRemoteUser*)user;

/**
 流连接成功
 
 @param stream 连接成功的流
 */
- (void)didConnectToStream:(RongRTCAVInputStream *)stream;

/**
 数据流第一个关键帧到达
 
 @param stream 开始接收数据的 stream
 */
- (void)didReportFirstKeyframe:(RongRTCAVInputStream *)stream;

/**
 当有用户发布资源的时候，通过此方法回调用户发布的流，其中流中有 userID（用户 ID）， tag（标识符）， type（流类型）， state（是否禁用） 等关键信息，可调用订阅接口，订阅其中的流
 
 @param streams 用户发布的资源信息
 */
- (void)didPublishStreams:(NSArray <RongRTCAVInputStream *>*)streams;
/**
 当有用户取消发布资源的时候，通过此方法回调，SDK 默认会取消订阅这些流，其中流中有 userID（用户 ID）， tag（标识符）， type（流类型）， state（是否禁用） 等关键信息，APP 可根据这些关键信息自定义化，无需再次调用取消订阅接口。
 
 @param streams 取消发布资源
 */
- (void)didUnpublishStreams:(NSArray<RongRTCAVInputStream *>*)streams;

/**
 *  接收到其他人发送到 room 里的消息
 
 @param message 消息体，参考 IMLib 中x RCMessage
 */
- (void)didReceiveMessage:(RCMessage *)message;

/**
 被踢出房间的回调,主动调用 `leaveRoom` 方法，不会走此回调，只有当前用户被踢出房间的时候，该回调会出发，并且 SDK 会关闭音视频连接。

 @param room 离开的房间
 */
- (void)didKickedOutOfTheRoom:(RongRTCRoom *)room;
/**
 音频状态改变
 
 @param stream 流信息
 @param mute 当前流是否可用
 */
- (void)stream:(RongRTCAVInputStream*)stream didAudioMute:(BOOL)mute;

/**
 视频状态改变
 
 @param stream 流信息
 @param enable 当前流是否可用
 */
- (void)stream:(RongRTCAVInputStream*)stream didVideoEnable:(BOOL)enable;


@end
NS_ASSUME_NONNULL_END
#endif /* RongRTCRoomDelegate_h */
