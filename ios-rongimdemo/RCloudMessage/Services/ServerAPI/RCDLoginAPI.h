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
              password:(NSString *)password
                region:(NSString *)region
               success:(void (^)(NSString *token, NSString *userId))successBlock
                 error:(void (^)(RCDLoginErrorCode errorCode))errorBlock;

+ (void)logout:(void (^)(BOOL success))completeBlock;

+ (void)getVersionInfo:(void (^)(NSDictionary *versionInfo))completeBlock;

+ (void)checkPhoneNumberAvailable:(NSString *)phoneCode
                      phoneNumber:(NSString *)phoneNumber
                         complete:(void (^)(BOOL success, BOOL numberAvailable))completeBlock;

+ (void)getVerificationCode:(NSString *)phoneCode
                phoneNumber:(NSString *)phoneNumber
                    success:(void (^)(BOOL success))successBlock
                      error:(void (^)(RCDLoginErrorCode errorCode, NSString *errorMsg))errorBlock;

+ (void)verifyVerificationCode:(NSString *)phoneCode
                   phoneNumber:(NSString *)phoneNumber
              verificationCode:(NSString *)verificationCode
                       success:(void (^)(BOOL success, NSString *codeToken))successBlock
                         error:(void (^)(RCDLoginErrorCode errorCode))errorBlock;

+ (void)registerWithNickname:(NSString *)nickname
                    password:(NSString *)password
            verficationToken:(NSString *)verficationToken
                    complete:(void (^)(BOOL success))completeBlock;

+ (void)changePassword:(NSString *)oldPwd newPwd:(NSString *)newPwd complete:(void (^)(BOOL success))completeBlock;

+ (void)resetPassword:(NSString *)password
               vToken:(NSString *)verificationToken
             complete:(void (^)(BOOL success))completeBlock;

+ (void)getRegionlist:(void (^)(NSArray *regionArray))completeBlock;

+ (void)getToken:(void (^)(BOOL success, NSString *token, NSString *userId))completeBlock;

@end
