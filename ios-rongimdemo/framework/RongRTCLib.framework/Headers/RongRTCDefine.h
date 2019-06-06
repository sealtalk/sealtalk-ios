//
//  RongRTCDefine.h
//  RongRTCEngine
//
//  Created by jfdreamyang on 2019/1/3.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#ifndef RongRTCDefine_h
#define RongRTCDefine_h

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "RongRTCCodeDefine.h"

#if defined(__cplusplus)
#define RC_EXPORT extern "C"
#else
#define RC_EXPORT extern
#endif

@class RongRTCMember;
@class RongRTCRoom;
@class RongRTCStream;

/**
 加入房间成功之后的回调，其中包含房间中的所有用户信息，包含自己的信息
 
 @param isSuccess 加入成功与否
 @param room 房间中的所有用户信息，包含自己的信息
 */
typedef void(^RTCJoinRoomCallback)(BOOL isSuccess,RongRTCRoom * _Nullable room);

/**
 创建流的回调
 
 @param stream 流通道属性，通过该属性可以直接操作对应的音视频流或者数据
 */
typedef void(^RongRTCCreateStreamCallback)(RongRTCStream * _Nullable stream);


/**
 某些操作的回调

 @param isSuccess 操作是否成功
 @param desc 成功或者失败描述的错误码
 */
typedef void(^RongRTCOperationCallback)(BOOL isSuccess,RongRTCCode desc);

/**
 获取用户属性操作回调
 
 @param isSuccess 操作是否成功
 @param desc 成功或者失败的描述 错误码
 @param attr 获取结果
 */
typedef void(^RongRTCAttributeOperationCallback)(BOOL isSuccess,RongRTCCode desc,NSDictionary * _Nullable attr);

typedef enum : NSUInteger {
    /**
     输入流处于禁用状态，不应该订阅，即使订阅该流也不会收到音视频数据
     */
    RongRTCInputStreamStateForbidden = 0,
    /**
     输入流处于正常状态，可以正常订阅
     */
    RongRTCInputStreamStateNormal
} RongRTCInputStreamState;

/**
 资源类型
 */
typedef enum : NSUInteger {
    /**
     只有声音
     */
    RTCMediaTypeAudio,
    /**
     声音视频
     */
    RTCMediaTypeVideo,
    /**
     数据（暂不支持）
     */
    RTCMediaTypeData,
    /**
     空数据
     */
    RTCMediaTypeNothing
} RTCMediaType;

typedef NS_ENUM(NSUInteger, RongRTCVideoSizePreset) {
    /**
     分辨率 256X144
     */
    RongRTCVideoSizePreset256x144        = 1,
    /**
     分辨率 320X240
     */
    RongRTCVideoSizePreset320x240,
    /**
     分辨率 480X360
     */
    RongRTCVideoSizePreset480x360,
    /**
     分辨率 640X360
     */
    RongRTCVideoSizePreset640x360,
    /**
     分辨率 640X480
     */
    RongRTCVideoSizePreset640x480,
    /**
     分辨率 720X480
     */
    RongRTCVideoSizePreset720x480,
    /**
     分辨率 1280X720
     */
    RongRTCVideoSizePreset1280x720,
};

/**
 视频方向
 */
typedef NS_ENUM(NSUInteger, RongRTCVideoOrientation) {
    /**
     竖立，home 键在下部
     */
    RonngRTCVideoOrientationPortrait            = 1,
    /**
     竖立，home 键在上部
     */
    RonngRTCVideoOrientationPortraitUpsideDown,
    /**
     横屏，home 键在左侧
     */
    RonngRTCVideoOrientationLandscapeRight,
    /**
     竖立，home 键在右侧
     */
    RonngRTCVideoOrientationLandscapeLeft,
};

/**
 帧率
 */
typedef NS_ENUM(NSUInteger, RongRTCVideoFPS) {
    /**
     每秒 15 帧
     */
    RongRTCVideoFPS15,
    /**
     每秒 24 帧
     */
    RongRTCVideoFPS24,
    /**
     每秒 30 帧
     */
    RongRTCVideoFPS30
};

/**
 视频编码
 */
typedef NS_ENUM(NSUInteger, RongRTCCodecType) {
    /**
     H264 编码
     */
    RongRTCCodecH264,
    /**
     VP8(目前不支持)
     */
    RongRTCCodecVP8,
    /**
     VP9(目前不支持)
     */
    RongRTCCodecVP9
};

/**
 摄像头
 */
typedef enum : NSUInteger {
    /**
     未指明
     */
    RongRTCCaptureDeviceUnspecified = AVCaptureDevicePositionUnspecified,
    /**
     后置摄像头
     */
    RongRTCCaptureDeviceBack = AVCaptureDevicePositionBack,
    /**
     前置摄像头
     */
    RongRTCCaptureDeviceFront = AVCaptureDevicePositionFront,
} RongRTCDeviceCamera;

/**
 设置加入房间时音视频使用模式
 */
typedef enum : NSUInteger {
    /**
     普通试试音视频模式加入
     */
    RongRTCJoinRoomModeNormal,
    /**
     类直播场景模式加入，观察者模式加入之后会减少信令服务器的消息转发压力，提高直播场景体验
     */
    RongRTCJoinRoomModeLive,
} RongRTCJoinRoomMode;

/**
 * Error passing block.
 */
typedef void (^RongRTCVideoCapturerErrorBlock)(NSError * _Nullable error);

/**
 视频帧回调 block
 
 @param valid 该视频帧是否有效
 @param sampleBuffer 视频帧内容
 @return 用户自定义视频帧
 */
typedef CMSampleBufferRef _Nullable (^RongRTCVideoCMSampleBufferCallback)(BOOL valid,CMSampleBufferRef _Nullable sampleBuffer);

/**
 接收到音频输入输出的回调
 
 @param isOutput 1 证明是从本端发到远端的数据，0 是接收到的音频数据
 @param audioSamples 音频 PCM 数据
 @param length PCM 数据长度
 @param channels 通道数
 @param sampleRate 采样率
 */
typedef void(^RongRTCAudioPCMBufferCallback)(BOOL isOutput,const short * _Nullable audioSamples,const int length,const int channels,const int sampleRate);

#endif /* RongRTCDefine_h */
