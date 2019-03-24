//
//  RCDSearchDataManager.m
//  RCloudMessage
//
//  Created by 张改红 on 16/9/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchDataManager.h"
#import "RCDSearchResultModel.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"

@implementation RCDSearchDataManager
+ (instancetype)shareInstance {
    static RCDSearchDataManager *searchDataManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        searchDataManager = [[[self class] alloc] init];
    });
    return searchDataManager;
}

- (void)searchDataWithSearchText:(NSString *)searchText
                    bySearchType:(NSInteger)searchType
                        complete:(void (^)(NSDictionary *dic, NSArray *array))result {
    NSString *searchStr = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!searchText.length || searchStr.length == 0) {
        return result(nil, nil);
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    if (searchType == RCDSearchFriend || searchType == RCDSearchAll) {
        NSArray *friendArray = [self searchFriendBysearchText:searchText];
        if (friendArray.count > 0) {
            [dic setObject:friendArray forKey:RCDLocalizedString(@"all_contacts")];
            [array addObject:RCDLocalizedString(@"all_contacts")];
        }
    }
    if (searchType == RCDSearchGroup || searchType == RCDSearchAll) {
        NSArray *groupArray = [self searchGroupBysearchText:searchText];
        if (groupArray.count > 0) {
            [dic setObject:groupArray forKey:RCDLocalizedString(@"group")
];
            [array addObject:RCDLocalizedString(@"group")
];
        }
    }
    if (searchType == RCDSearchChatHistory || searchType == RCDSearchAll) {
        NSArray *messsageResult = [self searchMessageBysearchText:searchText];
        if (messsageResult.count > 0) {
            [dic setObject:messsageResult forKey:RCDLocalizedString(@"chat_history")];
            [array addObject:RCDLocalizedString(@"chat_history")];
        }
    }
    result(dic.copy, array.copy);
}

- (NSArray *)searchFriendBysearchText:(NSString *)searchText {
    NSMutableArray *friendResults = [NSMutableArray array];
    NSArray *friendArray = [[RCDataBaseManager shareInstance] getAllFriends];
    for (RCDUserInfo *user in friendArray) {
        if ([user.status isEqualToString:@"20"]) {
            if (user.displayName && [RCDUtilities isContains:user.displayName withString:searchText]) {
                RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
                model.conversationType = ConversationType_PRIVATE;
                model.targetId = user.userId;
                model.otherInformation = user.displayName;
                model.portraitUri = user.portraitUri;
                model.searchType = RCDSearchFriend;
                [friendResults addObject:model];
            } else if ([RCDUtilities isContains:user.name withString:searchText]) {
                RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
                model.conversationType = ConversationType_PRIVATE;
                model.targetId = user.userId;
                model.name = user.name;
                model.portraitUri = user.portraitUri;
                if (user.displayName) {
                    model.otherInformation = user.displayName;
                }
                model.searchType = RCDSearchFriend;

                [friendResults addObject:model];
            }
        }
    }
    return friendResults;
}

- (NSArray *)searchGroupBysearchText:(NSString *)searchText {
    NSMutableArray *groupResults = [NSMutableArray array];
    NSArray *groupArray = [[RCDataBaseManager shareInstance] getAllGroup];
    for (RCDGroupInfo *group in groupArray) {
        if ([RCDUtilities isContains:group.groupName withString:searchText]) {
            RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
            model.conversationType = ConversationType_GROUP;
            model.targetId = group.groupId;
            model.name = group.groupName;
            model.portraitUri = group.portraitUri;
            model.searchType = RCDSearchGroup;

            [groupResults addObject:model];
            continue;
        } else {
            NSArray *groupMember = [[RCDataBaseManager shareInstance] getGroupMember:group.groupId];
            NSString *str = nil;
            for (RCUserInfo *user in groupMember) {
                RCDUserInfo *friendUser = [[RCDataBaseManager shareInstance] getFriendInfo:user.userId];
                if (friendUser && friendUser.displayName.length > 0) {
                    if ([RCDUtilities isContains:friendUser.displayName withString:searchText]) {
                        str = [self changeString:str appendStr:friendUser.displayName];
                    } else if ([RCDUtilities isContains:user.name withString:searchText]) {
                        str = [self
                            changeString:str
                               appendStr:[NSString stringWithFormat:@"%@(%@)", friendUser.displayName, user.name]];
                    }
                } else {
                    if ([RCDUtilities isContains:user.name withString:searchText]) {
                        str = [self changeString:str appendStr:user.name];
                    }
                }
            }
            if (str.length > 0) {
                RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
                model.conversationType = ConversationType_GROUP;
                model.targetId = group.groupId;
                model.name = group.groupName;
                model.portraitUri = group.portraitUri;
                model.otherInformation = str;
                model.searchType = RCDSearchGroup;
                [groupResults addObject:model];
            }
        }
    }
    return groupResults;
}

- (NSArray *)searchMessageBysearchText:(NSString *)searchText {
    if (!searchText.length) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    NSArray *messsageResult = [[RCIMClient sharedRCIMClient]
        searchConversations:@[ @(ConversationType_GROUP), @(ConversationType_PRIVATE) ]
                messageType:@[
                    [RCTextMessage getObjectName], [RCRichContentMessage getObjectName], [RCFileMessage getObjectName]
                ]
                    keyword:searchText];

    for (RCSearchConversationResult *result in messsageResult) {
        RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
        model.conversationType = result.conversation.conversationType;
        model.targetId = result.conversation.targetId;
        if (result.matchCount > 1) {
            model.otherInformation = [NSString stringWithFormat:RCDLocalizedString(@"total_related_message"), result.matchCount];
        } else {
            NSString *string = nil;
            model.objectName = result.conversation.objectName;
            if ([result.conversation.lastestMessage isKindOfClass:[RCRichContentMessage class]]) {
                RCRichContentMessage *rich = (RCRichContentMessage *)result.conversation.lastestMessage;
                string = rich.title;
            } else if ([result.conversation.lastestMessage isKindOfClass:[RCFileMessage class]]) {
                RCFileMessage *file = (RCFileMessage *)result.conversation.lastestMessage;
                string = file.name;
            } else {
                string = [self formatMessage:result.conversation.lastestMessage
                               withMessageId:result.conversation.lastestMessageId];
            }
            model.otherInformation = [self relaceEnterBySpace:string];
        }
        if (result.conversation.conversationType == ConversationType_PRIVATE) {
            RCUserInfo *user = [[RCDataBaseManager shareInstance] getUserByUserId:result.conversation.targetId];
            model.name = user.name;
            model.portraitUri = user.portraitUri;
        } else if (result.conversation.conversationType == ConversationType_GROUP) {
            RCDGroupInfo *group = [[RCDataBaseManager shareInstance] getGroupByGroupId:result.conversation.targetId];
            model.name = group.groupName;
            model.portraitUri = group.portraitUri;
        }
        model.searchType = RCDSearchChatHistory;
        model.count = result.matchCount;
        [array addObject:model];
    }
    return array;
}

- (NSString *)relaceEnterBySpace:(NSString *)originalString {
    NSString *string = [originalString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    return string;
}

- (NSString *)formatMessage:(RCMessageContent *)messageContent withMessageId:(long)messageId {
    if ([RCIM sharedRCIM].showUnkownMessage && messageId > 0 && !messageContent) {
        return NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
    } else {
        return [RCKitUtility formatMessage:messageContent];
    }
}

- (NSString *)changeString:(NSString *)str appendStr:(NSString *)appendStr {
    if (str.length > 0) {
        str = [NSString stringWithFormat:@"%@,%@", str, appendStr];
    } else {
        str = appendStr;
    }
    return str;
}
@end
