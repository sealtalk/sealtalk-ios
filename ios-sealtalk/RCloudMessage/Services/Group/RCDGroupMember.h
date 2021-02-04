//
//  RCDGroupMember.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCUserInfo.h>
#import "RCDUserInfo.h"
typedef enum : NSUInteger {
    RCDGroupMemberRoleOwner,
    RCDGroupMemberRoleMember,
    RCDGroupMemberRoleManager,
} RCDGroupMemberRole;

typedef enum : NSUInteger {
    RCDGroupAddMembersStatusAllJoined = 1,       //所有成员已加入
    RCDGroupAddMemberStatusInviteeApproving,     //部分需要被邀请者审批
    RCDGroupAddMemberStatusOnlyManagerApproving, //仅包含需要管理者审批
} RCDGroupAddMemberStatus;
NS_ASSUME_NONNULL_BEGIN

@interface RCDGroupMember : RCDUserInfo
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *groupNickname;
@property (nonatomic, assign) RCDGroupMemberRole role;
@property (nonatomic, assign) long long createDt;
@property (nonatomic, assign) long long updateDt;
- (instancetype)initWithJson:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END
