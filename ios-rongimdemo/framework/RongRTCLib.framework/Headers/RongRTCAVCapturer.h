//
//  RongRTCAVCaptureOutputStream.h
//  RongRTCLib
//
//  Created by zhaobingdong on 2019/1/8.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RongRTCAVOutputStream.h"
#import <CoreMedia/CoreMedia.h>
#import <UIkit/UIkit.h>
#import "RongRTCVideoCaptureParam.h"
#import "RongRTCDefine.h"
#import "RongRTCAudioMixerEngine.h"

NS_ASSUME_NONNULL_BEGIN

@class RongRTCLocalVideoView;
@class RTCPeerConnectionFactory;
@class RongRTCVideoCaptureParam;

/**
 音视频采集管理实例
 */
@interface RongRTCAVCapturer : RongRTCAVOutputStream

/**
 不可用

 @return 失败
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 不可用

 @return 失败
 */
- (instancetype)new NS_UNAVAILABLE;

/**
 不可用

 @param pars 采集参数
 @param tag 标识
 @return 失败
 */
-(instancetype)initWithParameters:(nullable RongRTCStreamParams*)pars
                              tag:(NSString*)tag NS_UNAVAILABLE;

/**
 单例对象获取

 @return 采集器对象
 */
+ (instancetype)sharedInstance;

/**
 通话前设置音视频采集参数，通过过程中设置无效

 @param params 参数
 */
- (void)setCaptureParam:(RongRTCVideoCaptureParam*)params;

/**
 关闭/打开麦克风
 
 @param disable YES 关闭，NO 打开
 */
- (void)setMicrophoneDisable:(BOOL)disable;

/**
 切换前后摄像头
 */
- (void)switchCamera;


/**
 切换使用外放/听筒

 @param useSpeaker yes 使用扬声器 no 不使用
 @return 接入外设时，如蓝牙音箱等 返回 NO
 */
- (BOOL)useSpeaker:(BOOL)useSpeaker;

/**
 开启音视频采集
 */
- (void)startCapture;

/**
 关闭音视频采集
 */
- (void)stopCapture;


/**
 采集运行中关闭或打开摄像头

 @param disable YES 关闭，否则打开
 */
- (void)setCameraDisable:(BOOL)disable;

/**
 设置通话过程中的视频分辨率
 */
@property(nonatomic,assign) RongRTCVideoSizePreset videoSizePreset;

/**
 设置通话过程中视频帧率
 */
@property(nonatomic,assign) RongRTCVideoFPS videoFrameRate;


/**
 运行通话过程中最大码率设置，单位 bps
 */
@property(nonatomic,assign) NSUInteger maxBitrate;

/**
 设置摄像头采集方向，默认以 AVCaptureVideoOrientationPortrait 角度进行采集
 */
@property(nonatomic,assign) AVCaptureVideoOrientation videoOrientation;

/**
 接收到音频或者发送音频时的音频数据，用户可以直接处理该音频数据
 */
@property (nonatomic,copy,nullable) RongRTCAudioPCMBufferCallback audioBufferCallback;

/**
 引擎底部开始视频编码并发送之前会往上层抛一个回调，用户可以修改和调整 CMSampleBufferRef 数据，然后返回一个 CMSampleBufferRef 数据，如果返回空或者没有实现该回调，则会使用默认视频数据传输
 
 注：如果用户传正常数据，则内部会自行 CFRelease CMSampleBufferRef 对象，上层不需要再考虑释放问题
 */
@property (nonatomic,copy,nullable) RongRTCVideoCMSampleBufferCallback videoSendBufferCallback;

/**
 本地摄像头采集的视频在即将预览前会往上层抛一个视频帧回调，用户可以处理视频帧数据之后然后回传给 RTC，RTC 使用用户处理的视频帧进行预览
 
  注：如果用户传正常数据，则内部会自行 CFRelease CMSampleBufferRef 对象，上层不需要再考虑释放问题
 */
@property (nonatomic,copy,nullable) RongRTCVideoCMSampleBufferCallback videoDisplayBufferCallback;

/**
 设置视频媒体数据的渲染界面
 
 @param render 渲染界面
 */
-(void)setVideoRender:(nullable RongRTCLocalVideoView *)render;

/**
 混合 PCM 数据，单声道，16 bit signed, 48000 采样率，外置 mic 和网络音频流场景可以
 通过该方法实现外置 mic 的混合以及替换的逻辑，目前只支持下面两种使用方式。
 action: RTCAudioActionOnlyMix, RTCAudioActionReplace
 
 内部会保证时间同步，上层请注意往里面写的频率（写入速度太快容易导致内部缓冲区满而导致丢失数据）
 另外如果仅仅是文件声音混合，请直接使用 RongRTCAudioMixerEngine，使用更加简单方便

 @param pcmBuffer 声音 buffer
 @param action 混音使用的模式
 @return 是否混合成功
 */
-(BOOL)writePCMBuffer:(NSData *)pcmBuffer action:(RTCAudioAction)action;

@end

NS_ASSUME_NONNULL_END
