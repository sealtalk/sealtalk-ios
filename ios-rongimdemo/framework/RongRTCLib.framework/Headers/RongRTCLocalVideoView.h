//
//  RCLocalPreviewView.h
//  RongRTCLib
//
//  Created by zhaobingdong on 2018/12/17.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RongRTCVideoPreviewView.h"
#import <AVFoundation/AVFoundation.h>

// 请不要直接在 localView 上添加视图，内部会有翻转的逻辑

NS_ASSUME_NONNULL_BEGIN

/**
视频渲染的 view
*/
@interface RongRTCLocalVideoView : RongRTCVideoPreviewView


/**
 渲染视图
 
 @param sample 视频 sampleBuffer
 */
- (void)renderSampleBuffer:(CMSampleBufferRef)sample;


/**
 刷新渲染视图 View.
 */
- (void)flushVideoView;

@end

NS_ASSUME_NONNULL_END
