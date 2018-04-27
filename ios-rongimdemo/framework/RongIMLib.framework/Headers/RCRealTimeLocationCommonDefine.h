//
//  RCRealTimeLocationCommonDefine.h
//  RongIMLib
//
//  Created by LiFei on 2018/3/8.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#ifndef RCRealTimeLocationCommonDefine_h
#define RCRealTimeLocationCommonDefine_h

/**
 坐标体系类型
 
 - RCRealTimeLocationTypeWGS84: WGS-84
 - RCRealTimeLocationTypeGCJ02: GCJ-02
 - RCRealTimeLocationTypeBD09: BD-09
 */
typedef NS_ENUM(NSUInteger, RCRealTimeLocationType) {
    RCRealTimeLocationTypeWGS84 = 1,
    RCRealTimeLocationTypeGCJ02 = 2,
    RCRealTimeLocationTypeBD09 = 3
};

/*!
 实时位置共享状态
 */
typedef NS_ENUM(NSInteger, RCRealTimeLocationStatus) {
    /*!
     实时位置共享，初始状态
     */
    RC_REAL_TIME_LOCATION_STATUS_IDLE,
    /*!
     实时位置共享，接收状态
     */
    RC_REAL_TIME_LOCATION_STATUS_INCOMING,
    /*!
     实时位置共享，发起状态
     */
    RC_REAL_TIME_LOCATION_STATUS_OUTGOING,
    /*!
     实时位置共享，共享状态
     */
    RC_REAL_TIME_LOCATION_STATUS_CONNECTED
};

/*!
 实时位置共享错误码
 */
typedef NS_ENUM(NSInteger, RCRealTimeLocationErrorCode) {
    /*!
     当前设备不支持实时位置共享
     */
    RC_REAL_TIME_LOCATION_NOT_SUPPORT,
    /*!
     当前会话不支持实时位置共享
     */
    RC_REAL_TIME_LOCATION_CONVERSATION_NOT_SUPPORT,
    /*!
     当前会话超出了参与者人数限制
     */
    RC_REAL_TIME_LOCATION_EXCEED_MAX_PARTICIPANT,
    /*!
     获取当前会话信息失败
     */
    RC_REAL_TIME_LOCATION_GET_CONVERSATION_FAILURE
};

#endif /* RCRealTimeLocationCommonDefine_h */
