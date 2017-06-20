//
//  RCCallCommonDefine.h
//  RongCallLib
//
//  Created by 岑裕 on 16/2/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#ifndef RCCallCommonDefine_h
#define RCCallCommonDefine_h

/*!
 媒体类型
 */
typedef NS_ENUM(NSInteger, RCCallMediaType) {
  /*!
   音频
   */
  RCCallMediaAudio = 1,
  /*!
   视频
   */
  RCCallMediaVideo = 2,
};

/*!
 通话质量
 */
typedef NS_ENUM(NSUInteger, RCCallQuality) {
  RCCall_Quality_Unknown = 0,
  RCCall_Quality_Excellent = 1,
  RCCall_Quality_Good = 2,
  RCCall_Quality_Poor = 3,
  RCCall_Quality_Bad = 4,
  RCCall_Quality_VBad = 5,
  RCCall_Quality_Down = 6,
};

#pragma mark - Call

/*!
 错误码
 */
typedef NS_ENUM(NSInteger, RCCallErrorCode) {
  /*!
   成功
   */
  RCCallSuccess = 0,
  /*!
   网络不可用
   */
  RCCallNetworkUnavailable = 1,
  /*!
   已经处于通话中了
   */
  RCCallOneCallExisted = 2,
  /*!
   无效操作
   */
  RCCallOperationUnavailable = 3,
  /*!
   参数错误
   */
  RCCallInvalidParam = 4,
  /*!
   网络不稳定
   */
  RCCallNetworkUnstable = 5,
  /*!
   媒体服务请求失败
   */
  RCCallMediaRequestFailed = 6,
  /*!
   媒体服务初始化失败
   */
  RCCallMediaServerNotReady = 7,
  /*!
   媒体服务未初始化
   */
  RCCallMediaServerNotInitialized = 8,
  /*!
   媒体服务请求超时
   */
  RCCallMediaRequestTimeout = 9,
  /*!
   未知的媒体服务错误
   */
  RCCallMediaUnkownError = 10,
};

/*!
 通话结束原因
 */
typedef NS_ENUM(NSInteger, RCCallDisconnectReason) {
  /*!
   己方取消已发出的通话请求
   */
  RCCallDisconnectReasonCancel = 1,
  /*!
   己方拒绝收到的通话请求
   */
  RCCallDisconnectReasonReject = 2,
  /*!
   己方挂断
   */
  RCCallDisconnectReasonHangup = 3,
  /*!
   己方忙碌
   */
  RCCallDisconnectReasonBusyLine = 4,
  /*!
   己方未接听
   */
  RCCallDisconnectReasonNoResponse = 5,
  /*!
   己方不支持当前引擎
   */
  RCCallDisconnectReasonEngineUnsupported = 6,
  /*!
   己方网络出错
   */
  RCCallDisconnectReasonNetworkError = 7,

  /*!
   对方取消已发出的通话请求
   */
  RCCallDisconnectReasonRemoteCancel = 11,
  /*!
   对方拒绝收到的通话请求
   */
  RCCallDisconnectReasonRemoteReject = 12,
  /*!
   通话过程对方挂断
   */
  RCCallDisconnectReasonRemoteHangup = 13,
  /*!
   对方忙碌
   */
  RCCallDisconnectReasonRemoteBusyLine = 14,
  /*!
   对方未接听
   */
  RCCallDisconnectReasonRemoteNoResponse = 15,
  /*!
   对方网络错误
   */
  RCCallDisconnectReasonRemoteEngineUnsupported = 16,
  /*!
   对方网络错误
   */
  RCCallDisconnectReasonRemoteNetworkError = 17,
  /*!
   己方其他端已接听
  */
  RCCallDisconnectReasonAcceptByOtherClient = 18,
};

/*!
 通话视频参数
 */
typedef NS_ENUM(NSInteger, RCVideoProfile) {
  /*!
   320x240, 15fps, 200kbps
   */
  RC_VIDEO_PROFILE_240P = 20,
  /*!
   640x360, 15fps, 400kbps
   */
  RC_VIDEO_PROFILE_360P = 30,
  /*!
   640x480, 15fps, 500kbps
   */
  RC_VIDEO_PROFILE_480P = 40,
  /*!
   1280x720, 15fps, 1000kbps
   */
  RC_VIDEO_PROFILE_720P = 50,
  /*!
   默认的视频参数
   */
  RC_VIDEO_PROFILE_DEFAULT = RC_VIDEO_PROFILE_360P,
};

/*!
 通话状态
 */
typedef NS_ENUM(NSInteger, RCCallStatus) {
  /*!
   初始状态
   */
//  RCCallIdle   = 0,
  /*!
   正在呼出
   */
  RCCallDialing = 1,
  /*!
   正在呼入
   */
  RCCallIncoming = 2,
  /*!
   收到一个通话呼入后，正在振铃
   */
  RCCallRinging = 3,
  /*!
   正在通话
   */
  RCCallActive = 4,
  /*!
   已经挂断
   */
  RCCallHangup = 5,
};

#endif /* RCCallCommonDefine_h */
