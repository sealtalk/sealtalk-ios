//
//  RCDChatAPI.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import "RCDGroupInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCDChatAPI : NSObject

//设置会话截屏通知
+ (void)setChatConfigWithConversationType:(RCConversationType)conversationType
                                 targetId:(NSString *)targetId
                screenCaptureNotification:(BOOL)open
                                 complete:(void (^)(BOOL))complete;

//获取会话截屏通知状态
+ (void)getChatConfigWithConversationType:(RCConversationType)type
                                 targetId:(NSString *)targetId
                                  success:(void (^)(BOOL open))success
                                    error:(void (^)())error;

+ (void)sendScreenCaptureNotification:(RCConversationType)conversationType
                             targetId:(NSString *)targetId
                             complete:(void (^)(BOOL success))complete;

+ (void)setGroupMessageClearStatus:(RCDGroupMessageClearStatus)status
                           groupId:(NSString *)groupId
                          complete:(void (^)(BOOL success))complete;

+ (void)getGroupMessageClearStatus:(NSString *)groupId complete:(void (^)(RCDGroupMessageClearStatus status))complete;
@end

NS_ASSUME_NONNULL_END
