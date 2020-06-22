//
//  RCDGroupMember.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupMember.h"

@implementation RCDGroupMember
- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        NSDictionary *userDic = json[@"user"];
        self.userId = userDic[@"id"];
        self.name = userDic[@"nickname"];
        self.portraitUri = userDic[@"portraitUri"];
        self.stAccount = userDic[@"stAccount"];
        self.gender = userDic[@"gender"];
        self.groupNickname = json[@"groupNickname"];
        self.role = [json[@"role"] integerValue];
        self.createDt = [json[@"timestamp"] longLongValue];
        self.updateDt = [json[@"updatedTime"] longLongValue];
    }
    return self;
}
@end
