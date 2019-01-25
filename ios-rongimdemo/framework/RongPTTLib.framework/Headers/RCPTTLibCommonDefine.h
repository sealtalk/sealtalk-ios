//
//  RCPTTLibCommonDefine.h
//  RongPTTLib
//
//  Created by LiFei on 2017/1/15.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#ifndef RCPTTLibCommonDefine_h
#define RCPTTLibCommonDefine_h

#import "RCPTTSession.h"

typedef NS_ENUM(NSInteger, RCPTTErrorCode) {
    /*!
     成功
     */
    RCPTTSuccess = 0,

    /*!
     不在对讲session中
     */
    RCPTTNotInSession = 1,

    /*!
     正在对讲
     */
    RCPTTIsSpeaking = 2,

    /*!
     错误的会话
     */
    RCPTTIncorrectConversation = 3,

    /*!
     已经在对讲session中
     */
    RCPTTAlreadyInSession = 4,

    RCPTTHTTPError = 5,

    /*!
     未知的错误
     */
    RCPTTUnkownError = 100,
};

#endif /* RCPTTLibCommonDefine_h */
