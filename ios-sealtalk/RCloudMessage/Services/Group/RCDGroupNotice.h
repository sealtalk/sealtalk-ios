//
//  RCDGroupNotice.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, RCDGroupInviteStatus) {
    RCDGroupInviteStatusIgnored,
    RCDGroupInviteStatusAgreed,
    RCDGroupInviteStatusApproving,
    RCDGroupInviteStatusExpired,
};

typedef NS_ENUM(NSInteger, RCDGroupInviteActionType) {
    RCDGroupInviteActionTypeIgnore = 0,
    RCDGroupInviteActionTypeAgree = 1,
};

typedef NS_ENUM(NSInteger, RCDGroupNoticeType) {
    RCDGroupNoticeTypeInviteeApproving = 1,
    RCDGroupNoticeTypeManagerApproving = 2,
};

@interface RCDGroupNotice : NSObject
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *operatorId;
@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, assign) RCDGroupNoticeType noticeType;
@property (nonatomic, assign) RCDGroupInviteStatus status;
@property (nonatomic, assign) long long createTime;

- (instancetype)initWithJson:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END
