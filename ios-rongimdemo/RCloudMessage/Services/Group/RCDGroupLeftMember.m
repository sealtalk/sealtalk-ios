//
//  RCDGroupLeftMember.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupLeftMember.h"

@implementation RCDGroupLeftMember
- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        self.operatorId = json[@"operatorId"];
        self.userId = json[@"quitUserId"];
        self.reason = [json[@"quitReason"] intValue];
        self.time = [json[@"quitTime"] longLongValue];
    }
    return self;
}
@end
