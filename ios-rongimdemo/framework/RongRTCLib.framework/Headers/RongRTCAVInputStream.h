//
//  RongRTCInputStream.h
//  RongRTCLib
//
//  Created by 杜立召 on 2019/1/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCDefine.h"
#import <CoreVideo/CoreVideo.h>
NS_ASSUME_NONNULL_BEGIN

@class RongRTCRemoteVideoView;
@class RongRTCAVInputStream;

/**
 音视频流的delegate
 */
@protocol RongRTCAVInputStreamDelegate <NSObject>
/**
  视图即将渲染某个视频帧，如果如果需要自定义视频显示的话需要修改该视频帧

 @param ref 即将渲染的视频帧数据
 @param stream 用户需要渲染的视频帧数据
 */
-(void)willRenderCVPixelBufferRef:(CVPixelBufferRef)ref stream:(RongRTCAVInputStream *)stream;

@end

/**
 接收到的的音视频流
 */
@interface RongRTCAVInputStream : NSObject

/**
 请勿调用，有人发布流之后会返回给您 RongRTCAVInputStream 对象
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 请勿调用，有人发布流之后会返回给您 RongRTCAVInputStream 对象
 */
- (instancetype)new NS_UNAVAILABLE;

/**
 流ID，或者媒体ID
 */
@property (nonatomic,copy,readonly) NSString *streamId;

/**
 发布人
 */
@property (nonatomic,copy,readonly) NSString *userId;

/**
 唯一流扩展标识符
 */
@property(nonatomic , copy , readonly)NSString *tag;

/**
 当前的流类型
 */
@property(nonatomic , assign , readonly)RTCMediaType streamType;

/**
 该资源是否被禁用
 */
@property(nonatomic , assign , readonly)RongRTCInputStreamState state;

/**
 视频即将渲染的代理
 */
@property(nonatomic , weak)id<RongRTCAVInputStreamDelegate>delegate;

/**
 将该流禁用（注：只是不播放视频与音频，但是音视频数据是正常接收的，如果不想接收数据可以走取消订阅逻辑）
 */
@property(nonatomic , assign)BOOL disable;

/**
 设置远端用户视频流的渲染界面

 @param render 渲染界面
 */
- (void)setVideoRender:(nullable RongRTCRemoteVideoView*)render;

@end

NS_ASSUME_NONNULL_END
