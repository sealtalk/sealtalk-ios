//
//  RCDChatNotificationMessage.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/16.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
extern NSString *_Nullable const RCDChatNotificationOpenScreenNtf;
extern NSString *_Nullable const RCDChatNotificationCloseScreenNtf;
extern NSString *_Nullable const RCDChatNotificationSendScreenNtf;
extern NSString *_Nullable const RCDChatNotificationOpenRegularClearNtf;
extern NSString *_Nullable const RCDChatNotificationCloseRegularClearNtf;
NS_ASSUME_NONNULL_BEGIN
#define RCDChatNotificationMessageIdentifier @"ST:ConNtf"
@interface RCDChatNotificationMessage : RCMessageContent
@property (nonatomic, copy) NSString *operation;

@property (nonatomic, copy) NSString *operatorUserId;
- (NSString *)getDigest:(NSString *)groupId;
@end

NS_ASSUME_NONNULL_END
