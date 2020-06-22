//
//  RCDPokeMessage.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPokeMessage.h"

@implementation RCDPokeMessage
///消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

///将消息内容编码成json
- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.content forKey:@"content"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

///将json解码生成消息内容
- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (dictionary) {
            self.content = dictionary[@"content"];
        }
    }
}

/// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return [NSString stringWithFormat:@"[%@]", RCDLocalizedString(@"Poke")];
}

///消息的类型名
+ (NSString *)getObjectName {
    return RCDPokeMessageTypeIdentifier;
}
@end
