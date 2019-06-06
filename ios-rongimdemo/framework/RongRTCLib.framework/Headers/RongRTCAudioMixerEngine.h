//
//  RongRTCAudioMixerEngine.h
//  IMRTCService
//
//  Created by jfdreamyang on 2019/5/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <RongIMLib/RongIMLib.h>

/**
 混音模式
 */
typedef enum : NSUInteger {
    /**
     只进行音频混合，不播放音频数据
     */
    RTCAudioActionOnlyMix,
    /**
     只进行声音文件的播放，不混合声音数据，不发送声音文件数据（发送 Mic 数据）
     */
    RTCAudioActionOnlyPlay,
    /**
     混合音频的同时播放音频
     */
    RTCAudioActionMixAndPlay,
    /**
     使用提供的音频源进行发送，不采集 mic 数据
     */
    RTCAudioActionReplace,
    /**
     直接使用 Mic 采集的音频数据进行发送（包含录制的人声和从扬声器出来的声音）
     */
    RTCAudioActionLoopback
} RTCAudioAction;

/**
 混音引擎所处状态
 */
typedef enum : NSUInteger {
    /**
     混音功能未开启
     */
    RTCMixEngineStatusNormal,
    /**
     混音功能准备中
     */
    RTCMixEngineStatusPrepare,
    /**
     正在进行中
     */
    RTCMixEngineStatusPlaying,
    /**
     暂停状态
     */
    RTCMixEngineStatusPause,
} RTCMixEngineStatus;


NS_ASSUME_NONNULL_BEGIN

/**
 混音引擎
 */
@interface RongRTCAudioMixerEngine : NSObject

/**
 混音引擎单里

 @return 引擎实例
 */
+(RongRTCAudioMixerEngine *)sharedEngine;

/**
 当前混音状态
 */
@property (nonatomic,assign,readonly)RTCMixEngineStatus status;

/**
 当前音频操作类型
 */
@property (nonatomic,assign,readonly)RTCAudioAction action;

/**
 当前音视频所使用的格式
 */
@property (nonatomic,strong,readonly)AVAudioFormat *renderFormat;

/**
 设置混音声音的音量
 */
@property (nonatomic,assign)double volume;

/**
 混音功能（目前只支持混合本地音频数据），开始新混音之前需要先调用 stop，结束混音

 @param audioSource 要混合的音频数据
 @param action 混音音频的类型
 @param loop 视频循环混合音频数据，YES 时 音频数据播放结束时会循环播放，大文件不建议使用 loop 的模式进行播放
 @return 成功与否
 */
-(BOOL)mix:(NSString *)audioSource action:(RTCAudioAction)action loop:(BOOL)loop;

/**
 开始混音

 @return 开始混音是否成功
 */
-(BOOL)start;

/**
 暂停混音

 @return 暂停是否成功
 */
-(BOOL)pause;

/**
 结束混音

 @return 结束混音是否成功
 */
-(BOOL)stop;


@end

NS_ASSUME_NONNULL_END
