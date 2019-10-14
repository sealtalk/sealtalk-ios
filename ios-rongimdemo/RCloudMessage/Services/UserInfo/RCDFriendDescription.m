//
//  RCDFriendDescription.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDFriendDescription.h"

@implementation RCDFriendDescription

- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        self.displayName = json[@"displayName"];
        self.region = json[@"region"];
        self.phone = json[@"phone"];
        self.desc = json[@"description"];
        self.imageUrl = json[@"imageUri"];
    }
    return self;
}
@end
