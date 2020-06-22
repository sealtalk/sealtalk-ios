//
//  RCDUserSetting.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDUserSetting.h"
#import <RongIMKit/RongIMKit.h>
@implementation RCDUserSetting
- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        self.userId = json[@"id"];
        self.allowMobileSearch = [json[@"phoneVerify"] boolValue];
        self.allowSTAccountSearch = [json[@"stSearchVerify"] boolValue];
        self.needAddFriendVerify = [json[@"friVerify"] boolValue];
        self.needJoinGroupVerify = [json[@"groupVerify"] boolValue];
    }
    return self;
}
@end
