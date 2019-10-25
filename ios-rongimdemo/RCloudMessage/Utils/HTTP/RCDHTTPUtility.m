//
//  RCDHTTPUtility.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDHTTPUtility.h"
#import "RCDCommonString.h"
#import <AFNetworking/AFNetworking.h>

#define HTTP_SUCCESS 200

NSString *const BASE_URL = @"http://api.sealtalk.im/";

static AFHTTPSessionManager *manager;

@implementation RCDHTTPUtility

+ (AFHTTPSessionManager *)sharedHTTPManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [AFHTTPSessionManager manager];
        manager.completionQueue = dispatch_queue_create("cn.rongcloud.sealtalk.httpqueue", DISPATCH_QUEUE_SERIAL);
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.validatesDomainName = NO;
        securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy = securityPolicy;
        manager.requestSerializer.HTTPShouldHandleCookies = YES;
        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        ((AFJSONResponseSerializer *)manager.responseSerializer).removesKeysWithNullValues = YES;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    });
    return manager;
}

+ (void)requestWithHTTPMethod:(HTTPMethod)method
                    URLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                     response:(void (^)(RCDHTTPResult *))responseBlock {
    AFHTTPSessionManager *manager = [RCDHTTPUtility sharedHTTPManager];
    NSString *url = [BASE_URL stringByAppendingPathComponent:URLString];

    switch (method) {
    case HTTPMethodGet: {
        [manager GET:url
            parameters:parameters
            progress:nil
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"GET url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task]);
                }
            }];
        break;
    }

    case HTTPMethodHead: {
        [manager HEAD:url
            parameters:parameters
            success:^(NSURLSessionDataTask *_Nonnull task) {
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:nil]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"HEAD url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task]);
                }
            }];
        break;
    }

    case HTTPMethodPost: {
        [manager POST:url
            parameters:parameters
            progress:nil
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                [self saveCookieIfHave:task];
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"POST url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task]);
                }
            }];
        break;
    }

    case HTTPMethodPut: {
        [manager PUT:url
            parameters:parameters
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"PUT url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task]);
                }
            }];
        break;
    }

    case HTTPMethodDelete: {
        [manager DELETE:url
            parameters:parameters
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                if (responseBlock) {
                    responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                }
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                NSLog(@"DELETE url is %@, error is %@", URLString, error.localizedDescription);
                if (responseBlock) {
                    responseBlock([[self class] httpFailureResult:task]);
                }
            }];
        break;
    }

    default:
        break;
    }
}

+ (RCDHTTPResult *)httpSuccessResult:(NSURLSessionDataTask *)task response:(id)responseObject {
    RCDHTTPResult *result = [[RCDHTTPResult alloc] init];
    result.httpCode = ((NSHTTPURLResponse *)task.response).statusCode;

    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        result.errorCode = [responseObject[@"code"] integerValue];
        result.content = responseObject[@"result"];
        result.success = (result.errorCode == HTTP_SUCCESS);
        if (!result.success) {
            NSLog(@"%@, {%@}", task.currentRequest.URL, result);
        }
    } else {
        result.success = NO;
    }

    return result;
}

+ (RCDHTTPResult *)httpFailureResult:(NSURLSessionDataTask *)task {
    RCDHTTPResult *result = [[RCDHTTPResult alloc] init];
    result.success = NO;
    result.httpCode = ((NSHTTPURLResponse *)task.response).statusCode;
    NSLog(@"%@, {%@}", task.currentRequest.URL, result);
    return result;
}

+ (void)saveCookieIfHave:(NSURLSessionDataTask *)task {
    NSString *cookieString = [[(NSHTTPURLResponse *)task.response allHeaderFields] valueForKey:@"Set-Cookie"];
    NSMutableString *finalCookie = [NSMutableString new];
    NSArray *cookieStrings = [cookieString componentsSeparatedByString:@","];
    for (NSString *temp in cookieStrings) {
        NSArray *tempArr = [temp componentsSeparatedByString:@";"];
        [finalCookie appendString:[NSString stringWithFormat:@"%@;", tempArr[0]]];
    }
    [DEFAULTS setObject:finalCookie forKey:RCDUserCookiesKey];
    [DEFAULTS synchronize];
}

@end
