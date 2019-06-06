//
//  RongRTCAVOutputStream.h
//  RongRTCLib
//
//  Created by zhaobingdong on 2019/1/8.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@class RongRTCLocalVideoView;
@class RongRTCStreamParams;

/**
 要发送出去的音视频流
 */
@interface RongRTCAVOutputStream :NSObject

/**
 请勿调用 init 创建对象，发布音视频流的时候会返回给您 RongRTCAVOutputStream 对象
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 请勿调用 new 方法创建对象
*/
- (instancetype)new NS_UNAVAILABLE;


/**
 初始化流数据的参数

 @param pars 参数
 @param tag 用户自定标签，注：用户不能传特殊字符，只支持 ascii
 @return 流对象
 */
-(instancetype)initWithParameters:(nullable RongRTCStreamParams*)pars
                              tag:(NSString*)tag;

/**
 写入媒体流，该方法会直接将视频数据进行音视频编码并发送只远端

 @param sample 媒体数据
 @param error 失败时返回的相关描述
 */
- (void)write:(CMSampleBufferRef)sample error:(NSError**)error;

/**
 设置视频媒体数据的渲染界面

 @param render 渲染界面，传空则将原视图删除
 */
-(void)setVideoRender:(nullable RongRTCLocalVideoView *)render;

@end

NS_ASSUME_NONNULL_END
