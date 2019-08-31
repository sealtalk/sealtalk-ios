//
//  RCDIMService.m
//  SealTalk
//
//  Created by 张改红 on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDIMService.h"
#import "RCDHTTPUtility.h"

#define timeout 5

typedef enum : NSUInteger {
    RCDConnectStatusSuccess,
    RCDConnectStatusFailed,
    RCDConnectStatusTokenIncorrect,
} RCDConnectStatus;

@implementation RCDIMService
+ (instancetype)sharedService {
    static RCDIMService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[RCDIMService alloc] init];
        service.userInputStatus = [NSMutableDictionary new];
    });
    return service;
}

- (void)connectWithToken:(NSString *)token
                dbOpened:(void (^)(RCDBErrorCode))dbOpenedBlock
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode status))errorBlock
          tokenIncorrect:(void (^)(void))tokenIncorrectBlock{
    __block NSTimeInterval requestTime = [[NSDate date] timeIntervalSince1970] * 1000;
    [[RCIM sharedRCIM] connectWithToken:token dbOpened:dbOpenedBlock success:^(NSString *userId) {
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
        [self sendHTTP:RCDConnectStatusSuccess errorCode:0 requestTime:requestTime nowTime:nowTime];
        if (successBlock) {
            successBlock(userId);
        }
    } error:^(RCConnectErrorCode status) {
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
        [self sendHTTP:RCDConnectStatusFailed errorCode:status requestTime:requestTime nowTime:nowTime];
        if (errorBlock) {
            errorBlock(status);
        }
    } tokenIncorrect:^{
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
        [self sendHTTP:RCDConnectStatusTokenIncorrect errorCode:-1 requestTime:requestTime nowTime:nowTime];
        if (tokenIncorrectBlock) {
            tokenIncorrectBlock();
        }
    }];
}

- (void)sendHTTP:(RCDConnectStatus)connectStatus errorCode:(NSInteger)errorCode requestTime:(NSTimeInterval)requestTime nowTime:(NSTimeInterval)nowTime{
    NSString *connectStr;
    switch (connectStatus) {
        case RCDConnectStatusSuccess:
            connectStr = @"success";
            break;
        case RCDConnectStatusFailed:
            connectStr = @"Failed";
            break;
        case RCDConnectStatusTokenIncorrect:
            connectStr = @"tokenIncorrect";
            break;
        default:
            break;
    }
    NSDictionary *headers = @{@"Content-Type" : @"application/json"};
    NSDictionary *data = @{@"connectStatus" : connectStr, @"errorCode" : @(errorCode), @"consumTime" : @(nowTime-requestTime)};
    NSDictionary *params = @{@"app":@"sealTalk",
                             @"platform":@"iOS",
                             @"data":data,
                             @"version":@"new"
                             };
    [self postWithURLString:@"http://172.29.11.240:8081/dataReport/addDataReport" headers:headers  parameters:params completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"");
    }];
}

- (void)postWithURLString:(NSString *)URLString
                  headers:(NSDictionary *)headers
               parameters:(NSDictionary *)parameters
        completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    
    if (parameters.allKeys.count > 0) {
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:bodyData];
    }
    
    for (NSString *headerKey in headers.allKeys) {
        [request setValue:headers[headerKey] forHTTPHeaderField:headerKey];
    }
    request.timeoutInterval = timeout;
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(data, response, error);
        }
    }];
    [task resume];
}

- (NSString *)dealWithParam:(NSDictionary *)param {
    NSArray *allkeys = [param allKeys];
    NSMutableString *result = [NSMutableString string];
    
    for (NSString *key in allkeys) {
        NSString *string = [NSString stringWithFormat:@"%@=%@&", key, param[key]];
        [result appendString:string];
    }
    return result;
}

- (void)clearHistoryMessage:(RCConversationType)conversationType targetId:(NSString *)targetId successBlock:(void (^)(void))successBlock errorBlock:(void (^)(RCErrorCode))errorBlock{
    NSArray *latestMessages = [[RCIMClient sharedRCIMClient] getLatestMessages:conversationType targetId:targetId count:1];
    if (latestMessages.count > 0) {
        RCMessage *message = (RCMessage *)[latestMessages firstObject];
        [[RCIMClient sharedRCIMClient]clearRemoteHistoryMessages:conversationType targetId:targetId recordTime:message.sentTime success:^{
            [[RCIMClient sharedRCIMClient] deleteMessages:conversationType
                                                 targetId:targetId
                                                  success:^{
                                                      rcd_dispatch_main_async_safe(^{
                                                          if (successBlock) {
                                                              successBlock();
                                                          }
                                                      });
                                                  } error:^(RCErrorCode status) {
                                                      rcd_dispatch_main_async_safe(^{
                                                          if (errorBlock) {
                                                              errorBlock(status);
                                                          }
                                                      });
                                                  }];
        }error:^(RCErrorCode status) {
            rcd_dispatch_main_async_safe(^{
                if (errorBlock) {
                    errorBlock(status);
                }
            });
        }];
    }else{
        rcd_dispatch_main_async_safe(^{
            if (successBlock) {
                successBlock();
            }
        });
    }
}
@end
