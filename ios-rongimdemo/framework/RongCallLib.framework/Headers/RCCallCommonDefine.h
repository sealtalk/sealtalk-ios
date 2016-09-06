//
//  RCCallCommonDefine.h
//  RongCallLib
//
//  Created by 岑裕 on 16/2/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#ifndef RCCallCommonDefine_h
#define RCCallCommonDefine_h

typedef NS_ENUM(NSInteger, RCCallMediaType) {
  RCCallMediaAudio = 1,
  RCCallMediaVideo = 2,
};

#pragma mark - Call

typedef NS_ENUM(NSInteger, RCCallErrorCode) {
  RCCallSuccess = 0,
  RCCallNetworkUnavailable = 1,
  RCCallOneCallExisted = 2,
  RCCallOperationUnavailable = 3,
  RCCallInvalidParam = 4,
  RCCallNetworkUnstable = 5,
  RCCallMediaRequestFailed = 6,
  RCCallMediaServerNotReady = 7,
  RCCallMediaServerNotInitialized = 8,
  RCCallMediaRequestTimeout = 9,
  RCCallMediaUnkownError = 10,
};

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
};

typedef NS_ENUM(NSInteger, RCVideoProfile) {
                                           // res       fps  kbps
  RC_VIDEO_PROFILE_240P = 20,              // 320x240   15   200
  RC_VIDEO_PROFILE_360P = 30,              // 640x360   15   400
  RC_VIDEO_PROFILE_480P = 40,              // 640x480   15   500
  RC_VIDEO_PROFILE_720P = 50,              // 1280x720  15   1000
  RC_VIDEO_PROFILE_DEFAULT = RC_VIDEO_PROFILE_360P,
};

typedef NS_ENUM(NSInteger, RCCallStatus) {
  //    RCCallIdle   = 0,
  RCCallDialing = 1,
  RCCallIncoming = 2,
  RCCallRinging = 3,
  RCCallActive = 4,
  RCCallHangup = 5,
};

#endif /* RCCallCommonDefine_h */
