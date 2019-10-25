//
//  RCDGroupNotice.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupNotice.h"

@implementation RCDGroupNotice
- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        self.groupId = json[@"group"][@"id"];
        self.operatorId = json[@"requester"][@"id"];
        self.targetId = json[@"receiver"][@"id"];
        self.noticeType = [json[@"type"] integerValue];
        self.status = [json[@"status"] integerValue];
        self.createTime = [json[@"timestamp"] longLongValue];
    }
    return self;
}
@end
