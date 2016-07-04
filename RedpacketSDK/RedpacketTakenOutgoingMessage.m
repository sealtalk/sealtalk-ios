//
//  RedpacketTakenOutgoingMessage.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-5-30.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketTakenOutgoingMessage.h"

@implementation RedpacketTakenOutgoingMessage

+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_NONE);
}

+ (NSString *)getObjectName
{
    return YZHRedpacketTakenOutgoingMessageTypeIdentifier;
}
@end
