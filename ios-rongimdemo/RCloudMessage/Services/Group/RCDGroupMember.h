//
//  RCDGroupMember.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCUserInfo.h>
typedef enum : NSUInteger {
    RCDGroupMemberRoleOwner,
    RCDGroupMemberRoleMember,
    RCDGroupMemberRoleManager,
} RCDGroupMemberRole;
NS_ASSUME_NONNULL_BEGIN

@interface RCDGroupMember : RCUserInfo
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) RCDGroupMemberRole role;
@property(nonatomic, assign) long long createDt;
@property(nonatomic, assign) long long updateDt;
@end

NS_ASSUME_NONNULL_END
