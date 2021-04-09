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
      verificationCode:(NSString *)verificationCode
                region:(NSString *)region
               success:(void (^)(NSString *token, NSString *userId, NSString *nickName))successBlock
                 error:(void (^)(RCDLoginErrorCode errorCode))errorBlock{
    NSDictionary *params = @{ @"region" : region, @"phone" : phone, @"code" : verificationCode };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/verify_code_register"
                               parameters:params
                                 response:^(RCDHTTPResult *_Nonnull result) {
        if (result.success) {
            if (successBlock) {
                NSString *token = result.content[@"token"];
                NSString *userId = result.content[@"id"];
                NSString *nickName = result.content[@"nickName"];
                successBlock(token, userId, nickName);
            }
        } else {
            if (errorBlock) {
                errorBlock(result.errorCode);
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
                                         if (errorBlock) {
                                             errorBlock(result.errorCode, errorMsg);
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
                                             errorBlock(result.errorCode);
                                         }
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
