//
//  RCDClearMessage.m
//  SealTalk
//
//  Created by 张改红 on 2019/9/5.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDClearMessage.h"

@implementation RCDClearMessage
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

- (void)decodeWithData:(NSData *)data {
    __autoreleasing NSError *__error = nil;
    if (!data) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&__error];
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (!__error && dict) {
        self.clearTime = [[dict objectForKey:@"clearTime"] longLongValue];
    }
}

+ (NSString *)getObjectName {
    return RCDClearMessageIdentifier;
}
@end
