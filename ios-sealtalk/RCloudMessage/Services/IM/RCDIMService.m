//
//  RCDIMService.m
//  SealTalk
//
//  Created by 张改红 on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDIMService.h"

#define RCD_USERINPUTSTATUS @"RCD_userInputStatus"

@implementation RCDIMService
+ (instancetype)sharedService {
    static RCDIMService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[RCDIMService alloc] init];
        service.userInputStatus = [[NSUserDefaults standardUserDefaults] objectForKey:RCD_USERINPUTSTATUS];
    });
    return service;
}

- (void)connectWithToken:(NSString *)token
                dbOpened:(void (^)(RCDBErrorCode))dbOpenedBlock
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode status))errorBlock {
    [[RCIM sharedRCIM] connectWithToken:token dbOpened:dbOpenedBlock success:^(NSString *userId) {
            if (successBlock) {
                successBlock(userId);
            }
        } error:^(RCConnectErrorCode errorCode) {
            if (errorBlock) {
                errorBlock(errorCode);
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

- (RCChatSessionInputBarInputType)getInputStatus:(RCConversationType)conversationType targetId:(NSString *)targetId {
    if (targetId.length <= 0) {
        return 0;
    }
    NSString *userInputStatusKey = [NSString stringWithFormat:@"%lu--%@", (unsigned long)conversationType, targetId];
    NSMutableDictionary *userInputStatus = self.userInputStatus;
    if (userInputStatus && [userInputStatus.allKeys containsObject:userInputStatusKey]) {
        KBottomBarStatus inputType = (KBottomBarStatus)[userInputStatus[userInputStatusKey] integerValue];
        //输入框记忆功能，如果退出时是语音输入，再次进入默认语音输入
        if (inputType == KBottomBarRecordStatus) {
            return RCChatSessionInputBarInputVoice;
        } else if (inputType == KBottomBarPluginStatus) {
            //      self.defaultInputType = RCChatSessionInputBarInputExtention;
        } else if (inputType == KBottomBarDestructStatus) {
            return RCChatSessionInputBarInputDestructMode;
        }
    }
    return 0;
}

- (void)saveInputStatus:(RCConversationType)conversationType
               targetId:(NSString *)targetId
              inputType:(KBottomBarStatus)inputType {
    if (targetId.length <= 0) {
        return;
    }
    NSMutableDictionary *userInputStatus = [self.userInputStatus mutableCopy];
    if (!userInputStatus) {
        userInputStatus = [NSMutableDictionary new];
    }
    NSString *userInputStatusKey = [NSString stringWithFormat:@"%lu--%@", (unsigned long)conversationType, targetId];
    [userInputStatus setObject:[NSString stringWithFormat:@"%ld", (long)inputType] forKey:userInputStatusKey];
    [[NSUserDefaults standardUserDefaults] setObject:userInputStatus forKey:RCD_USERINPUTSTATUS];
    self.userInputStatus = userInputStatus;
}

@end
