//
//  RCDGroupAnnouncement.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupAnnouncement.h"

@implementation RCDGroupAnnouncement
- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        self.publishId = json[@"id"];
        self.groupId = json[@"groupId"];
        self.content = json[@"content"];
        self.publishTime = [json[@"timestamp"] longLongValue];
    }
    return self;
}
@end
