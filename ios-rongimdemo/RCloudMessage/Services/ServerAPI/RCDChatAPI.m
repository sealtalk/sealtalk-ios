//
//  RCDChatAPI.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatAPI.h"
#import "RCDHTTPUtility.h"
@implementation RCDChatAPI

+ (void)setChatConfigWithConversationType:(RCConversationType)conversationType
                                 targetId:(NSString *)targetId
                screenCaptureNotification:(BOOL)open
                                 complete:(void (^)(BOOL))complete {
    if (!targetId) {
        SealTalkLog(@"targetId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    if (conversationType != ConversationType_PRIVATE && conversationType != ConversationType_GROUP) {
        complete(NO);
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"misc/set_screen_capture"
                               parameters:@{
                                   @"conversationType" : @(conversationType),
                                   @"targetId" : targetId,
                                   @"noticeStatus" : @(open ? 1 : 0)
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)getChatConfigWithConversationType:(RCConversationType)type
                                 targetId:(NSString *)targetId
                                  success:(void (^)(BOOL open))success
                                    error:(void (^)())error {
    if (!targetId) {
        SealTalkLog(@"targetId is nil");
        if (error) {
            error();
        }
        return;
    }
    NSDictionary *params = @{ @"conversationType" : @(type), @"targetId" : targetId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"misc/get_screen_capture"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *dic = result.content;
                                         BOOL open = [dic[@"status"] boolValue];
                                         if (success) {
                                             success(open);
                                         }
                                     } else {
                                         if (error) {
                                             error();
                                         }
                                     }
                                 }];
}

+ (void)sendScreenCaptureNotification:(RCConversationType)conversationType
                             targetId:(NSString *)targetId
                             complete:(void (^)(BOOL))complete {
    if (!targetId) {
        SealTalkLog(@"targetId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"misc/send_sc_msg"
                               parameters:@{
                                   @"conversationType" : @(conversationType),
                                   @"targetId" : targetId
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)setGroupMessageClearStatus:(RCDGroupMessageClearStatus)status
                           groupId:(NSString *)groupId
                          complete:(void (^)(BOOL))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"clearStatus" : @(status) };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_regular_clear"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)getGroupMessageClearStatus:(NSString *)groupId complete:(void (^)(RCDGroupMessageClearStatus))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/get_regular_clear"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if ([result.content isKindOfClass:NSNumber.class]) {
                                             if (complete) {
                                                 complete([result.content integerValue]);
                                             }
                                         } else {
                                             if (complete) {
                                                 complete([result.content[@"clearStatus"] integerValue]);
                                             }
                                         }
                                     } else {
                                         if (complete) {
                                             complete(RCDGroupMessageClearStatusUnknown);
                                         }
                                     }
                                 }];
}
@end
