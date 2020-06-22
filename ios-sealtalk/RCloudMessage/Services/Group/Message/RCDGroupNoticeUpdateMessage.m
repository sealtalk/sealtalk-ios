//
//  RCDGroupNoticeUpdateMessage.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupNoticeUpdateMessage.h"
NSString *const RCDGroupMemberInvite = @"Invite";
@interface RCDGroupNoticeUpdateMessage ()
@property (nonatomic, copy) NSString *targetGroupName;
@property (nonatomic, copy) NSString *operationName;
@end
@implementation RCDGroupNoticeUpdateMessage
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISPERSISTED;
}

- (void)decodeWithData:(NSData *)data {
    __autoreleasing NSError *__error = nil;
    if (!data) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&__error];
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (!__error && dict) {
        self.operation = [dict objectForKey:@"operation"];
        self.operatorUserId = [dict objectForKey:@"operatorUserId"];
        self.operationName = dict[@"data"][@"operatorNickname"];
        self.targetGroupName = dict[@"data"][@"targetGroupName"];
        self.noticeType = [dict[@"data"][@"type"] integerValue];
        self.status = [dict[@"data"][@"status"] integerValue];
    } else {
        self.rawJSONData = data;
    }
}

- (NSString *)conversationDigest {
    return @"";
}

+ (NSString *)getObjectName {
    return RCDGroupNoticeUpdateMessageIdentifier;
}

@end
