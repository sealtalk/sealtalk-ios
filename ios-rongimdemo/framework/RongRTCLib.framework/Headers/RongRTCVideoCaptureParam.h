//
//  RongRTCVideoCaptureParam.h
//  RongRTCLib
//
//  Created by zhaobingdong on 2019/1/10.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "RongRTCDefine.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 视频采集器参数
 */
@interface RongRTCVideoCaptureParam : NSObject

/**
 获取默认音视频采集参数

 @return 默认音视频采集参数（注意该返回值不是单列）
 */
+(RongRTCVideoCaptureParam *)defaultParameters;

/**
 摄像头输出的视频分辨率
 */
@property(nonatomic,assign) RongRTCVideoSizePreset videoSizePreset;

/**
 使用后置摄像头, 默认是前置摄像头
 */
@property (nonatomic, assign) RongRTCDeviceCamera camera;

/**
 初始化时打开摄像头
 */
@property (nonatomic, assign) BOOL turnOnCamera;

/**
 视频发送帧率. 默认是 15 FPS
 */
@property (nonatomic, assign) RongRTCVideoFPS videoFrameRate;

/**
 是否启用视频小流，默认是开启的
 */
@property (nonatomic,assign) BOOL tinyStreamEnable;

/**
 码率
 */
@property (nonatomic, assign) NSInteger maxBitrate;

/**
 设置摄像头采集方向，默认以 AVCaptureVideoOrientationPortrait 角度进行采集
 */
@property(nonatomic,assign) AVCaptureVideoOrientation videoOrientation;

@end


/**
 stream 参数
 */
@interface RongRTCStreamParams : NSObject

/**
 视频分辨率参数
 */
@property(nonatomic,assign) RongRTCVideoSizePreset videoSizePreset;

/**
 视频发送帧率. 默认是 15 FPS
 */
@property (nonatomic,assign) RongRTCVideoFPS videoFrameRate;

/**
 码率
 */
@property (nonatomic, assign) NSInteger maxBitrate;

/**
 编码方式
 */
@property (nonatomic, assign) RongRTCCodecType codecType;

/**
 分辨率
 */
- (CGSize)resolution;

/**
帧率
 */
- (NSInteger)fpsValue;

@end

NS_ASSUME_NONNULL_END
