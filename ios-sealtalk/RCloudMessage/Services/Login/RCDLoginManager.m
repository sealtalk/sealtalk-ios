//
//  RCDLoginManager.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDLoginManager.h"
#import "RCDDBManager.h"
#import "RCDCommonString.h"
#import "RCDCountry.h"

static NSString *const RongCloud = @"RongCloud";
static NSString *const DBName = @"SealTalkDB";

@implementation RCDLoginManager
+ (void)loginWithPhone:(NSString *)phone
      verificationCode:(NSString *)verificationCode
                region:(NSString *)region
               success:(void (^)(NSString *token, NSString *userId, NSString *nickName))successBlock
                 error:(void (^)(RCDLoginErrorCode errorCode))errorBlock{
    [RCDLoginAPI loginWithPhone:phone verificationCode:verificationCode region:region success:^(NSString *token, NSString *userId, NSString *nickName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openDB:userId];
        });
        if (successBlock) {
            successBlock(token, userId, nickName);
        }
    } error:errorBlock];
}

+ (void)logout:(void (^)(BOOL))completeBlock {
    [RCDLoginAPI logout:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RCDDBManager closeDB];
            });
        }
        if (completeBlock) {
            completeBlock(success);
        }
    }];
}

+ (BOOL)openDB:(NSString *)currentUserId {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:RongCloud]
        stringByAppendingPathComponent:currentUserId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dbPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }

    dbPath = [dbPath stringByAppendingPathComponent:DBName];
    return [RCDDBManager openDB:dbPath];
}

+ (void)getVersionInfo:(void (^)(BOOL, NSString *))completeBlock {
    [RCDLoginAPI getVersionInfo:^(NSDictionary *versionInfo) {
        if (versionInfo) {
            BOOL isNeedUpdate = [[versionInfo objectForKey:@"isNeedUpdate"] boolValue];
            NSString *finalURL = nil;
            if (isNeedUpdate) {
                //获取系统当前的时间戳
                NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval now = [dat timeIntervalSince1970] * 1000;
                NSString *timeString = [NSString stringWithFormat:@"%f", now];
                //为html增加随机数，避免缓存。
                NSString *applist = [versionInfo objectForKey:@"applist"];
                applist = [NSString stringWithFormat:@"%@?%@", applist, timeString];
                finalURL = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", applist];
            }
            if (completeBlock) {
                completeBlock(isNeedUpdate, finalURL);
            }
        }
    }];
}

+ (void)getVerificationCode:(NSString *)phoneCode
                phoneNumber:(NSString *)phoneNumber
                    success:(void (^)(BOOL))successBlock
                      error:(void (^)(RCDLoginErrorCode, NSString *))errorBlock {
    [RCDLoginAPI getVerificationCode:phoneCode phoneNumber:phoneNumber success:successBlock error:errorBlock];
}

+ (void)verifyVerificationCode:(NSString *)phoneCode
                   phoneNumber:(NSString *)phoneNumber
              verificationCode:(NSString *)verificationCode
                       success:(void (^)(BOOL, NSString *_Nonnull))successBlock
                         error:(void (^)(RCDLoginErrorCode))errorBlock {

    [RCDLoginAPI verifyVerificationCode:phoneCode
                            phoneNumber:phoneNumber
                       verificationCode:verificationCode
                                success:successBlock
                                  error:errorBlock];
}

+ (void)getRegionlist:(void (^)(NSArray *_Nonnull))completeBlock {
    [RCDLoginAPI getRegionlist:^(NSArray *regionArray) {
        if (completeBlock) {
            NSMutableArray *countryArray = [NSMutableArray arrayWithCapacity:regionArray.count];
            for (NSDictionary *dict in regionArray) {
                RCDCountry *country = [[RCDCountry alloc] initWithDict:dict];
                [countryArray addObject:country];
            }
            completeBlock(countryArray);
        }
    }];
}

+ (void)getToken:(void (^)(BOOL, NSString *_Nonnull, NSString *_Nonnull))completeBlock {
    [RCDLoginAPI getToken:completeBlock];
}

@end
