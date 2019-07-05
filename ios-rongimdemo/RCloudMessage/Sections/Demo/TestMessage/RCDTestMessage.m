//
//  RCDTestMessage.m
//  RCloudMessage
//
//  Created by 岑裕 on 15/12/17.
//  Copyright © 2015年 RongCloud. All rights reserved.
//

#import "RCDTestMessage.h"

@implementation RCDTestMessage

///初始化
+ (instancetype)messageWithContent:(NSString *)content {
    RCDTestMessage *text = [[RCDTestMessage alloc] init];
    if (text) {
        text.content = content;
    }
    return text;
}

///消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

/// NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.extra = [aDecoder decodeObjectForKey:@"extra"];
    }
    return self;
}

/// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.extra forKey:@"extra"];
}

///将消息内容编码成json
- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.content forKey:@"content"];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }

    if (self.senderUserInfo) {
        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    }

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
            self.extra = dictionary[@"extra"];

            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
    }
}

/// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return self.content;
}

///消息的类型名
+ (NSString *)getObjectName {
    return RCDTestMessageTypeIdentifier;
}

@end
