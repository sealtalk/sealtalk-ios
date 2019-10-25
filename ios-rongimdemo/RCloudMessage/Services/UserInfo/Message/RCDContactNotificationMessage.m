//
//  RCDContactNotificationMessage.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDContactNotificationMessage.h"
#import "RCDUserInfoManager.h"

@implementation RCDContactNotificationMessage

+ (instancetype)notificationWithOperation:(NSString *)operation
                             sourceUserId:(NSString *)sourceUserId
                             targetUserId:(NSString *)targetUserId
                                  message:(NSString *)message
                                    extra:(NSString *)extra {

    RCDContactNotificationMessage *notif = [[RCDContactNotificationMessage alloc] init];
    if (notif) {
        notif.operation = operation;
        notif.sourceUserId = sourceUserId;
        notif.targetUserId = targetUserId;
        notif.message = message;
        notif.extra = extra;
    }
    return notif;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISPERSISTED;
}

- (NSString *)conversationDigest {
    return [self formatContent];
}

- (NSString *)formatContent {
    RCUserInfo *friendInfo = [RCDUserInfoManager getUserInfo:self.sourceUserId];
    NSDictionary *dict = (NSDictionary *)self.extra;
    NSString *operationContent;
    NSString *name = friendInfo.name ? friendInfo.name : dict[@"sourceUserNickname"];
    if ([self.operation isEqualToString:RCDContactNotificationMessage_ContactOperationRequest]) {
        operationContent = [NSString stringWithFormat:RCDLocalizedString(@"from_someone_friend_request"), name];
    } else if ([self.operation isEqualToString:RCDContactNotificationMessage_ContactOperationAcceptResponse]) {
        operationContent = [NSString stringWithFormat:RCDLocalizedString(@"someone_accept_you_friend_request"), @""];
    } else if ([self.operation isEqualToString:RCDContactNotificationMessage_ContactOperationRejectResponse]) {
        operationContent = [NSString stringWithFormat:RCDLocalizedString(@"RejectFriendRequest"), name];
    } else {
        operationContent = NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
    }
    return operationContent;
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
        self.sourceUserId = [dict objectForKey:@"sourceUserId"];
        self.targetUserId = [dict objectForKey:@"targetUserId"];
        self.message = [dict objectForKey:@"message"];
        self.extra = [dict objectForKey:@"extra"];

        NSDictionary *userinfoDict = [dict objectForKey:@"user"];
        [super decodeUserInfo:userinfoDict];

    } else {
        self.rawJSONData = data;
    }
}

- (NSData *)encode {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.operation) {
        [dict setObject:self.operation forKey:@"operation"];
    }
    if (self.sourceUserId) {
        [dict setObject:self.sourceUserId forKey:@"sourceUserId"];
    }
    if (self.targetUserId) {
        [dict setObject:self.targetUserId forKey:@"targetUserId"];
    }
    if (self.message) {
        [dict setObject:self.message forKey:@"message"];
    }
    if (self.extra) {
        [dict setObject:self.extra forKey:@"extra"];
    }
    if (self.senderUserInfo) {
        [dict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    }

    // serialized to utf-8 encoded data
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return jsonData;
}

+ (NSString *)getObjectName {
    return RCDContactNotificationMessageIdentifier;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    [super dealloc];
}
#endif //__has_feature(objc_arc)

#pragma mark - NSCoding protocol methods
/*
 @property(nonatomic, copy) NSString *operation;
 @property(nonatomic, copy) NSString *sourceUserId;
 @property(nonatomic, copy) NSString *targetUserId;
 @property(nonatomic, copy) NSString *message;
 @property(nonatomic, copy) NSString *extra;
 */
#define KEY_CONTACT_NOTIFICATION_OPERATION @"operation"
#define KEY_CONTACT_NOTIFICATION_SOURCEUSERID @"sourceUserId"
#define KEY_CONTACT_NOTIFICATION_TARGETUSERID @"targetUserId"
#define KEY_CONTACT_NOTIFICATION_MESSAGE @"message"
#define KEY_CONTACT_NOTIFICATION_EXTRA @"extra"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.operation = [aDecoder decodeObjectForKey:KEY_CONTACT_NOTIFICATION_OPERATION];
        self.sourceUserId = [aDecoder decodeObjectForKey:KEY_CONTACT_NOTIFICATION_SOURCEUSERID];
        self.targetUserId = [aDecoder decodeObjectForKey:KEY_CONTACT_NOTIFICATION_TARGETUSERID];
        self.message = [aDecoder decodeObjectForKey:KEY_CONTACT_NOTIFICATION_MESSAGE];
        self.extra = [aDecoder decodeObjectForKey:KEY_CONTACT_NOTIFICATION_EXTRA];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.operation forKey:KEY_CONTACT_NOTIFICATION_OPERATION];
    [aCoder encodeObject:self.sourceUserId forKey:KEY_CONTACT_NOTIFICATION_SOURCEUSERID];
    [aCoder encodeObject:self.targetUserId forKey:KEY_CONTACT_NOTIFICATION_TARGETUSERID];
    [aCoder encodeObject:self.message forKey:KEY_CONTACT_NOTIFICATION_MESSAGE];
    [aCoder encodeObject:self.extra forKey:KEY_CONTACT_NOTIFICATION_EXTRA];
}
@end
