//
//  RongRTCNetworkMonitorDelegate.h
//  RongRTCLib
//
//  Created by birney on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RongRTCAVInputStream;
@class RongRTCAVOutputStream;

/**
 网路质量反馈
 */
@protocol RongRTCNetworkMonitorDelegate <NSObject>

@optional

/**
 上行 和 下性 的总比特率

 @param sRate 上行比特率 kbps
 @param rRate 下行比特率 kbps
 */
- (void)totalSendBitRate:(float)sRate recvBitRate:(float)rRate;
/**
 下行 RongRTCAVInputStream 实例的比特率 和 丢包率

 @param stream stream 实例
 @param rate 比特率 kbps
 @param loss 丢包率
 */
- (void)inputStream:(RongRTCAVInputStream *)stream
            bitRate:(float)rate
           packLoss:(float)loss;

/**
 上行 RongRTCAVOutputStream 实例的比特率 和 丢包率
 
 @param stream stream 实例
 @param type 媒体类型
 @param rate 比特率 kbps
 @param loss 丢包率
 */
- (void)outputStream:(RongRTCAVOutputStream *)stream
           mediaType:(RTCMediaType)type
             bitRate:(float)rate
            packLoss:(float)loss;

/**
 音视频流传输数据信息
 
 @param memberArray 远端用户数据
 @param localArray 本地数据
 */
- (void)onAudioVideoTransfer:(NSArray *)memberArray
                    transfer:(NSArray *)localArray;

/**
 音频流音量数据信息
 
 @param levelArray 本地+远端用户音量数据
 */
- (void)onUserAudioLevel:(NSArray *)levelArray;

@end

NS_ASSUME_NONNULL_END
