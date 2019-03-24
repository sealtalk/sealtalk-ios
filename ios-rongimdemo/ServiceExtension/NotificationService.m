//
//  NotificationService.m
//  ServiceExtension
//
//  Created by rongcloud on 2018/11/26.
//  Copyright © 2018 RongCloud. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    UNNotificationContent *content1 = request.content;
    NSDictionary *userInfo = content1.userInfo;
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *category = [aps objectForKey:@"category"];
    if (aps && category && [category isEqualToString:@"RC:RcCmd"]) {
        NSString *appData = [userInfo objectForKey:@"appData"];
        NSDictionary *appDataDic = [NSJSONSerialization JSONObjectWithData:[appData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *idString = [appDataDic objectForKey:@"rc-dlt-identifier"];
        if (idString) {
            [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
                if (notifications.count == 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.contentHandler = contentHandler;
                        self.bestAttemptContent = [request.content mutableCopy];
                        self.contentHandler(self.bestAttemptContent);
                    });
                    return;
                }
                
                for (UNNotification *notice in notifications) {
                    UNNotificationRequest *request = notice.request;
                    UNNotificationContent *content = request.content;
                    NSDictionary *userInfo1 = content.userInfo;
                    NSString *identifier = userInfo1[@"rc"][@"id"];
                    if ([idString isEqualToString:identifier]) {
                        [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[request.identifier]];
                    }
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.contentHandler = contentHandler;
                    self.bestAttemptContent = [request.content mutableCopy];
                    self.contentHandler(self.bestAttemptContent);
                    
                });
                
            }];
        }
    } else {
        self.contentHandler = contentHandler;
        self.bestAttemptContent = [request.content mutableCopy];
        self.contentHandler(self.bestAttemptContent);
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
