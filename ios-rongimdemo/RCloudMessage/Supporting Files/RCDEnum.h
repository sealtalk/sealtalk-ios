//
//  RCDEnum.h
//  RCloudMessage
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#ifndef RCDEnum_h
#define RCDEnum_h

typedef NS_ENUM(NSInteger, RCDLoginErrorCode) {
    RCDLoginErrorCodeWrongPassword,
    RCDLoginErrorCodeUserNotRegistered,
    RCDLoginErrorCodeVerificationCodeExpired = 2000,
    RCDLoginErrorCodeParameterError = 3102,
    RCDLoginErrorCodeUnknown
};

#endif /* RCDEnum_h */
