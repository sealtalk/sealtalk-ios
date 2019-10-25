//
//  RCDSearchResultModel.m
//  RCloudMessage
//
//  Created by 张改红 on 16/9/12.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchResultModel.h"
#import "RCDUserInfoManager.h"

@implementation RCDSearchResultModel

+ (instancetype)modelForMessage:(RCMessage *)message {
    RCDSearchResultModel *messegeModel = [[RCDSearchResultModel alloc] init];
    messegeModel.conversationType = message.conversationType;
    messegeModel.targetId = message.targetId;
    messegeModel.time = message.sentTime;
    messegeModel.objectName = message.objectName;

    if (message.conversationType == ConversationType_GROUP) {
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:message.senderUserId];
        messegeModel.name = user.name;
        messegeModel.portraitUri = user.portraitUri;
    } else if (message.conversationType == ConversationType_PRIVATE) {
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:message.targetId];
        messegeModel.name = user.name;
        messegeModel.portraitUri = user.portraitUri;
    }

    NSString *string = nil;
    if ([message.content isKindOfClass:[RCRichContentMessage class]]) {
        RCRichContentMessage *rich = (RCRichContentMessage *)message.content;
        string = rich.title;
    } else if ([message.content isKindOfClass:[RCFileMessage class]]) {
        RCFileMessage *file = (RCFileMessage *)message.content;
        string = file.name;
    } else {
        string = [RCKitUtility formatMessage:message.content];
    }

    messegeModel.otherInformation = string;
    return messegeModel;
}
@end
