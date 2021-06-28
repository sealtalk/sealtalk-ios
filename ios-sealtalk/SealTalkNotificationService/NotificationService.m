//
//  NotificationService.m
//  SealTalkNotificationService
//
//  Created by 张改红 on 2021/5/25.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "NotificationService.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCDCommonDefine.h"
@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSDictionary *userInfo = self.bestAttemptContent.userInfo;
    [[RCCoreClient sharedCoreClient] initWithAppKey:RONGCLOUD_IM_APPKEY];
    if (RONGCLOUD_STATS_SERVER.length > 0) {
        [[RCCoreClient sharedCoreClient] setStatisticServer:RONGCLOUD_STATS_SERVER];
    }
    [[RCCoreClient sharedCoreClient] recordReceivedRemoteNotificationEvent:userInfo];
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
