//
//  RCDChatManager.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import "RCDGroupInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCDChatManager : NSObject

//设置会话截屏通知
+ (void)setScreenCaptureNotification:(BOOL)open
                    conversationType:(RCConversationType)type
                            targetId:(NSString *)targetId
                            complete:(void (^)(BOOL success))complete;

//获取会话截屏通知状态
+ (void)getScreenCaptureNotification:(RCConversationType)type
                            targetId:(NSString *)targetId
                            complete:(void (^)(BOOL open))complete
                               error:(void (^)())error;

+ (void)sendScreenCaptureNotification:(RCConversationType)conversationType
                             targetId:(NSString *)targetId
                             complete:(void (^)(BOOL success))complete;

+ (void)setGroupMessageClearStatus:(RCDGroupMessageClearStatus)status
                           groupId:(NSString *)groupId
                          complete:(void (^)(BOOL success))complete;

+ (void)getGroupMessageClearStatus:(NSString *)groupId complete:(void (^)(RCDGroupMessageClearStatus status))complete;

+ (BOOL)isHoldChatNotificationMessage:(RCMessage *)message;
@end

NS_ASSUME_NONNULL_END
