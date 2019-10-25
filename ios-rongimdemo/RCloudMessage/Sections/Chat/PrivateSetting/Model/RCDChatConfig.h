//
//  RCDChatConfig.h
//  SealTalk
//
//  Created by hrx on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "RCDGroupInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDChatConfig : RCConversation <NSCoding>

@property (nonatomic, assign) BOOL screenCaptureNotification;
@property (nonatomic, assign) RCDGroupMessageClearStatus messageClearStatus;

+ (instancetype)chatConfigWithConversationType:(RCConversationType)conversationType
                                      targetId:(NSString *)targetId
                     screenCaptureNotification:(BOOL)screenCaptureNotification;
+ (instancetype)chatConfigWithConversationType:(RCConversationType)conversationType
                                      targetId:(NSString *)targetId
                     screenCaptureNotification:(BOOL)screenCaptureNotification
                            messageClearStatus:(RCDGroupMessageClearStatus)clearStatus;

@end

NS_ASSUME_NONNULL_END
