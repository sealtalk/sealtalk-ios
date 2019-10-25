//
//  RCDIMService.m
//  SealTalk
//
//  Created by 张改红 on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDIMService.h"

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
          tokenIncorrect:(void (^)(void))tokenIncorrectBlock {
    [[RCIM sharedRCIM] connectWithToken:token
        dbOpened:dbOpenedBlock
        success:^(NSString *userId) {
            if (successBlock) {
                successBlock(userId);
            }
        }
        error:^(RCConnectErrorCode status) {
            if (errorBlock) {
                errorBlock(status);
            }
        }
        tokenIncorrect:^{
            if (tokenIncorrectBlock) {
                tokenIncorrectBlock();
            }
        }];
}

- (void)clearHistoryMessage:(RCConversationType)conversationType
                   targetId:(NSString *)targetId
               successBlock:(void (^)(void))successBlock
                 errorBlock:(void (^)(RCErrorCode))errorBlock {
    NSArray *latestMessages =
        [[RCIMClient sharedRCIMClient] getLatestMessages:conversationType targetId:targetId count:1];
    if (latestMessages.count > 0) {
        RCMessage *message = (RCMessage *)[latestMessages firstObject];
        [[RCIMClient sharedRCIMClient] clearRemoteHistoryMessages:conversationType
            targetId:targetId
            recordTime:message.sentTime
            success:^{
                [[RCIMClient sharedRCIMClient] deleteMessages:conversationType
                    targetId:targetId
                    success:^{
                        rcd_dispatch_main_async_safe(^{
                            if (successBlock) {
                                successBlock();
                            }
                        });
                    }
                    error:^(RCErrorCode status) {
                        rcd_dispatch_main_async_safe(^{
                            if (errorBlock) {
                                errorBlock(status);
                            }
                        });
                    }];
            }
            error:^(RCErrorCode status) {
                rcd_dispatch_main_async_safe(^{
                    if (errorBlock) {
                        errorBlock(status);
                    }
                });
            }];
    } else {
        rcd_dispatch_main_async_safe(^{
            if (successBlock) {
                successBlock();
            }
        });
    }
}
@end
