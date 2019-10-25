//
//  RCDGroupNoticeUpdateMessage.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "RCDGroupNotice.h"
extern NSString *_Nullable const RCDGroupMemberInvite;

NS_ASSUME_NONNULL_BEGIN
#define RCDGroupNoticeUpdateMessageIdentifier @"ST:GrpApply"
@interface RCDGroupNoticeUpdateMessage : RCMessageContent
@property (nonatomic, copy) NSString *operation;

@property (nonatomic, copy) NSString *operatorUserId;

@property (nonatomic, copy) NSString *targetGroupId;

@property (nonatomic, assign) RCDGroupNoticeType noticeType;

@property (nonatomic, assign) RCDGroupInviteStatus status;
@end

NS_ASSUME_NONNULL_END
