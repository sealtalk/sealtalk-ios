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
    RCDLoginErrorCodeVerificationCodeExpired = 2000,
    RCDLoginErrorCodeParameterError = 3102,
    RCDLoginErrorCodeVerificationCodeError = 1000,
    RCDLoginErrorCodeVerificationCodeFrequencyTransfinite = 5000,
    RCDLoginErrorCodeUnknown
};

typedef NS_ENUM(NSInteger, RCDUserErrorCode) {
    RCDUserErrorCodeStAccountIsExist = 1000,
    RCDUserErrorCodeInvalidFormat,
    RCDUserErrorCodeUnknown
};

typedef NS_ENUM(NSInteger, RCDGroupErrorCode) {
    RCDGroupErrorCodeNotInGroup = 403,
    RCDGroupErrorCodeProtection = 20004,//群处于保护期
    RCDGroupErrorCodeCopyOnceIn7D = 20005,//7 天内已被复制一次
    RCDGroupErrorCodeNotExist = 20006,//群不存在或被解散
    RCDGroupErrorCodeMemberOnlyOne = 20007,//群成员仅有一人，无法复制
    RCDGroupErrorCodeUnknown
};

#endif /* RCDEnum_h */
