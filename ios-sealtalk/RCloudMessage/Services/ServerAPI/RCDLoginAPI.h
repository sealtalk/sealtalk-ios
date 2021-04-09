//
//  LoginServer.h
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDEnum.h"

@interface RCDLoginAPI : NSObject

+ (void)loginWithPhone:(NSString *)phone
      verificationCode:(NSString *)verificationCode
                region:(NSString *)region
               success:(void (^)(NSString *token, NSString *userId, NSString *nickName))successBlock
                 error:(void (^)(RCDLoginErrorCode errorCode))errorBlock;

+ (void)logout:(void (^)(BOOL success))completeBlock;

+ (void)getVersionInfo:(void (^)(NSDictionary *versionInfo))completeBlock;

+ (void)getVerificationCode:(NSString *)phoneCode
                phoneNumber:(NSString *)phoneNumber
                    success:(void (^)(BOOL success))successBlock
                      error:(void (^)(RCDLoginErrorCode errorCode, NSString *errorMsg))errorBlock;

+ (void)verifyVerificationCode:(NSString *)phoneCode
                   phoneNumber:(NSString *)phoneNumber
              verificationCode:(NSString *)verificationCode
                       success:(void (^)(BOOL success, NSString *codeToken))successBlock
                         error:(void (^)(RCDLoginErrorCode errorCode))errorBlock;

+ (void)getRegionlist:(void (^)(NSArray *regionArray))completeBlock;

+ (void)getToken:(void (^)(BOOL success, NSString *token, NSString *userId))completeBlock;

@end
