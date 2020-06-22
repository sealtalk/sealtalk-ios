//
//  RCDGroupInfo.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDGroupInfo.h"

@implementation RCDGroupInfo
#define KEY_RCDGROUP_INFO_NUMBER @"number"

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        if (decoder == nil) {
            return self;
        }
        self.number = [decoder decodeObjectForKey:KEY_RCDGROUP_INFO_NUMBER];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.number forKey:KEY_RCDGROUP_INFO_NUMBER];
}

- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        self.groupId = [json objectForKey:@"id"];
        self.groupName = [json objectForKey:@"name"];
        self.portraitUri = [json objectForKey:@"portraitUri"];
        self.creatorId = [json objectForKey:@"creatorId"];
        self.introduce = [json objectForKey:@"introduce"];
        if (!self.introduce) {
            self.introduce = @"";
        }
        self.number = [[json objectForKey:@"memberCount"] stringValue];
        self.maxNumber = [json objectForKey:@"max_number"];
        NSString *deletedAt = [json objectForKey:@"deletedAt"];
        if (deletedAt.length > 0) {
            self.isDismiss = YES;
        } else {
            self.isDismiss = NO;
        }
        self.mute = [[json objectForKey:@"isMute"] boolValue];
        self.needCertification = ![[json objectForKey:@"certiStatus"] boolValue];
        self.memberProtection = [[json objectForKey:@"memberProtection"] boolValue];
    }
    return self;
}
@end
