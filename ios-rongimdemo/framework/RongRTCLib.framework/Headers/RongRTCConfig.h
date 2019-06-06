//
//  RongRTCConfig.h
//  RongRTCLib
//
//  Created by jfdreamyang on 2019/5/21.
//  Copyright © 2019 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RongRTCConfig : NSObject

/**
  设置媒体服务服务地址（私有部署用户使用），公有云请不要设置
 */
@property (nonatomic,copy)NSString *mediaServerUrl;

/**
 加入房间场景
 1、默认模式 RongRTCJoinRoomModeNormal，普通的音视频会议功能
    单个房间内最多允许 9 人同时进行视频通话
    单个房间内最多允许 20 人同时进行音频通话
    注：同一房间中可发起音视频通话总用户上限为 20 人。
 
 2、设置该模式为 RongRTCJoinRoomModeLive 时只支持发布最多两路音频，可以支持同时上万人数的音频订阅，满足上万人的音频直播场景等特殊功能需求
 
 */
@property (nonatomic)RongRTCJoinRoomMode mode;

@end

NS_ASSUME_NONNULL_END
