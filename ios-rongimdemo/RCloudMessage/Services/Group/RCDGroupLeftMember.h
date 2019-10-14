//
//  RCDGroupLeftMember.h
//  SealTalk
//
//  Created by 张改红 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, RCDGroupMemberLeftReason) {
    RCDGroupMemberLeftReasonOwner = 0,
    RCDGroupMemberLeftReasonManager,
    RCDGroupMemberLeftReasonSelf,
};
NS_ASSUME_NONNULL_BEGIN

@interface RCDGroupLeftMember : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *operatorId;
@property (nonatomic, assign) RCDGroupMemberLeftReason reason;
@property (nonatomic, assign) long long time;
- (instancetype)initWithJson:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END
