//
//  LoginServer.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDLoginAPI.h"
#import "RCDHTTPUtility.h"

@implementation RCDLoginAPI

+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
                region:(NSString *)region
               success:(void (^)(NSString *_Nonnull, NSString *_Nonnull))successBlock
                 error:(void (^)(RCDLoginErrorCode))errorBlock {
    NSDictionary *params = @{ @"region" : region, @"phone" : phone, @"password" : password };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/login"
                               parameters:params
                                 response:^(RCDHTTPResult *_Nonnull result) {
                                     if (result.success) {
                                         if (successBlock) {
                                             NSString *token = result.content[@"token"];
                                             NSString *userId = result.content[@"id"];
                                             successBlock(token, userId);
                                         }
                                     } else {
                                         if (errorBlock) {
                                             if (result.httpCode == 400 || result.errorCode == 1000) {
                                                 errorBlock(RCDLoginErrorCodeUserNotRegistered);
                                             } else if (result.errorCode == 1001) {
                                                 errorBlock(RCDLoginErrorCodeWrongPassword);
                                             } else {
                                                 errorBlock(RCDLoginErrorCodeUnknown);
                                             }
                                         }
                                     }
                                 }];
}

+ (void)logout:(void (^)(BOOL))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"/user/logout"
                               parameters:nil
                                 response:^(RCDHTTPResult *_Nonnull result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)getVersionInfo:(void (^)(NSDictionary *))completeBlock {
    [RCDHTTPUtility
        requestWithHTTPMethod:HTTPMethodGet
                    URLString:@"misc/mobile_version"
                   parameters:nil
                     response:^(RCDHTTPResult *_Nonnull result) {
                         if (result.success) {
                             NSDictionary *iOSResult = result.content[@"iOS"];
                             NSString *sealtalkBuild = iOSResult[@"build"];
                             NSString *applistURL = iOSResult[@"url"];

                             NSDictionary *info;
                             NSString *currentBuild =
                                 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

                             NSDate *currentBuildDate = [RCDLoginAPI stringToDate:currentBuild];
                             NSDate *buildDate = [RCDLoginAPI stringToDate:sealtalkBuild];
                             NSTimeInterval secondsInterval = [currentBuildDate timeIntervalSinceDate:buildDate];
                             if (secondsInterval < 0) {
                                 info = [NSDictionary
                                     dictionaryWithObjectsAndKeys:@(YES), @"isNeedUpdate", applistURL, @"applist", nil];
                             } else {
                                 info = [NSDictionary dictionaryWithObjectsAndKeys:@(NO), @"isNeedUpdate", nil];
                             }
                             if (completeBlock) {
                                 completeBlock(info);
                             }
                         } else {
                             if (completeBlock) {
                                 completeBlock(nil);
                             }
                         }
                     }];
}

+ (void)checkPhoneNumberAvailable:(NSString *)phoneCode
                      phoneNumber:(NSString *)phoneNumber
                         complete:(void (^)(BOOL, BOOL))completeBlock {
    NSDictionary *params = @{ @"region" : phoneCode, @"phone" : phoneNumber };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/check_phone_available"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     BOOL numberAvailable = [(NSNumber *)result.content boolValue];
                                     if (completeBlock) {
                                         completeBlock(result.success, numberAvailable);
                                     }
                                 }];
}

+ (void)getVerificationCode:(NSString *)phoneCode
                phoneNumber:(NSString *)phoneNumber
                    success:(void (^)(BOOL))successBlock
                      error:(void (^)(RCDLoginErrorCode, NSString *))errorBlock {
    NSDictionary *params = @{ @"region" : phoneCode, @"phone" : phoneNumber };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/send_code_yp"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {

                                     if (result.success) {
                                         if (successBlock) {
                                             successBlock(YES);
                                         }
                                     } else {
                                         NSString *errorMsg = result.content[@"msg"];
                                         if (result.errorCode == 3102) {
                                             errorBlock(RCDLoginErrorCodeParameterError, errorMsg);
                                         } else {
                                             errorBlock(RCDLoginErrorCodeUnknown, errorMsg);
                                         }
                                     }
                                 }];
}

+ (void)verifyVerificationCode:(NSString *)phoneCode
                   phoneNumber:(NSString *)phoneNumber
              verificationCode:(NSString *)verificationCode
                       success:(void (^)(BOOL, NSString *))successBlock
                         error:(void (^)(RCDLoginErrorCode))errorBlock {
    NSDictionary *params = @{ @"region" : phoneCode, @"phone" : phoneNumber, @"code" : verificationCode };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/verify_code_yp"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (successBlock) {
                                             NSString *token = result.content[@"verification_token"];
                                             successBlock(YES, token);
                                         }
                                     } else {
                                         if (errorBlock) {
                                             if (result.errorCode == 1000) { // verification_code_error
                                                 errorBlock(RCDLoginErrorCodeWrongPassword);
                                             } else if (result.errorCode == 2000) {
                                                 errorBlock(RCDLoginErrorCodeVerificationCodeExpired);
                                             } else {
                                                 errorBlock(RCDLoginErrorCodeUnknown);
                                             }
                                         }
                                     }
                                 }];
}

+ (void)registerWithNickname:(NSString *)nickname
                    password:(NSString *)password
            verficationToken:(NSString *)verficationToken
                    complete:(void (^)(BOOL success))completeBlock {
    NSDictionary *params =
        @{ @"nickname" : nickname,
           @"password" : password,
           @"verification_token" : verficationToken };

    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/register"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)changePassword:(NSString *)oldPwd newPwd:(NSString *)newPwd complete:(void (^)(BOOL))completeBlock {
    NSDictionary *params = @{ @"oldPassword" : oldPwd, @"newPassword" : newPwd };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/change_password"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)resetPassword:(NSString *)password vToken:(NSString *)verificationToken complete:(void (^)(BOOL))completeBlock {
    NSDictionary *params = @{ @"password" : password, @"verification_token" : verificationToken };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/reset_password"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)getRegionlist:(void (^)(NSArray *))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/regionlist"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *regionArray = (NSArray *)result.content;
                                         if (completeBlock) {
                                             completeBlock(regionArray);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

+ (void)getToken:(void (^)(BOOL, NSString *, NSString *))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/get_token"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSString *token = result.content[@"token"];
                                         NSString *userId = result.content[@"id"];
                                         if (completeBlock) {
                                             completeBlock(YES, token, userId);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(NO, nil, nil);
                                         }
                                     }
                                 }];
}

#pragma mark - private
+ (NSDate *)stringToDate:(NSString *)build {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
    NSDate *date = [dateFormatter dateFromString:build];
    return date;
}
@end
