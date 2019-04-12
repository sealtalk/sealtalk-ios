//
//  RongRTCRemoteUser.h
//  RongRTCLib
//
//  Created by 杜立召 on 2019/1/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RongRTCUser.h"
#import "RongRTCAVInputStream.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RongRTCRemoteUserDelegate;

/**
 音视频远端用户
 */
@interface RongRTCRemoteUser : RongRTCUser

/**
 *  用户发布的音视频流
 */
@property (nonatomic, copy, readonly) NSArray<RongRTCAVInputStream *> *remoteAVStreams;

/**
 订阅流
 
 @param avStreams 普通流
 @param tinyStreams 需要携带小流的流数组
 @param completion 完成的回调
 */
- (void)subscribeAVStream:(nullable NSArray<RongRTCAVInputStream *> *)avStreams
              tinyStreams:(nullable NSArray<RongRTCAVInputStream *> *)tinyStreams
               completion:(nullable RongRTCOperationCallback)completion;

/**
 将一个视频流切换成小码率视频流

 @param streams 要切换的流
 @param completion 切换是否成功
 */
-(void)exchangeStreamToTinyStream:(nonnull NSArray<RongRTCAVInputStream *> *)streams
                       completion:(nullable RongRTCOperationCallback)completion;

/**
 将一个视频流切换成正常码率视频流

 @param streams 要切换的视频流
 @param completion 切换是否成功
 */
-(void)exchangeStreamToNormalStream:(nonnull NSArray<RongRTCAVInputStream *> *)streams
                       completion:(nullable RongRTCOperationCallback)completion;

/**
 接收数据流.
 
 @param streams 要接收的数据流
 @param completion 结果
 */
- (void)subscribeDataStream:(NSArray<RongRTCAVInputStream *> *)streams
                 completion:(RongRTCOperationCallback)completion;

/**
 取消接收音视频流.
 
 @param streams 发布的音视频流
 @param completion 发布的音视频流结果
 */
- (void)unsubscribeAVStream:(NSArray <RongRTCAVInputStream *> *)streams completion:(nonnull RongRTCOperationCallback)completion;

/**
 取消接收数据流.
 
 @param streams 要接收的数据流
 @param completion 结果
 */
- (void)unsubscribeDataStream:(NSArray<RongRTCAVInputStream *> *)streams
                   completion:(RongRTCOperationCallback)completion;
@end

NS_ASSUME_NONNULL_END
