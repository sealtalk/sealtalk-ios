//
//  RongRTCEngine.h
//  RongRTCEngine
//
//  Created by jfdreamyang on 2019/1/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCDefine.h"
#import "RongRTCConfig.h"
#import "RongRTCCodeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class RongRTCRoom;
@class RongRTCVideoPreviewView;
@class RongRTCVideoCaptureParam;
@class RongRTCAVOutputStream;
@protocol RongRTCNetworkMonitorDelegate;

/**
 音视频 SDK 对应版本
 
 RongRTCLib version: 3.0.6
 RongRTCLib commit: 248b2a62
 RongRTCLib time: 2019-05-30
 
 */


/**
 音视频引擎入口
 */
@interface RongRTCEngine : NSObject

/**
 音视频引擎单例
 */
+(RongRTCEngine *)sharedEngine;

/**
 数据上报
 */
@property (nonatomic, weak) id<RongRTCNetworkMonitorDelegate> netMonitor;

/**
 当然已加入的房间
 */
@property (nonatomic,strong,readonly)RongRTCRoom *currentRoom;


/**
 设置媒体服务服务地址（私有部署用户使用）
 
 @param url url
 */
- (BOOL)setMediaServerUrl:(NSString *)url;

/**
 加入房间

 @param roomId 房间 Id(支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式 最长 64 个字符)
 @param completion 加入房间回调,其中，room 对象中的 remoteUsers ，只存储当前房间中发布过资源的人，如果某用户加入房间但是没有发布资源，remoteUsers 不会包含此人。
 */
-(void)joinRoom:(NSString *)roomId
     completion:(nullable void (^)( RongRTCRoom  * _Nullable room,RongRTCCode code))completion;

/**
 离开房间(注：离开房间时不需要调用取消资源发布和关闭摄像头，SDK 内部会做好取消发布和关闭摄像头资源释放逻辑)
 
 @param roomId 房间 Id
 @param completion 加入房间回调
 */
-(void)leaveRoom:(NSString*)roomId
      completion:(void (^) (BOOL isSuccess , RongRTCCode code))completion;

@end

NS_ASSUME_NONNULL_END
