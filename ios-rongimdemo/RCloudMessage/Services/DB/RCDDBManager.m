//
//  RCDDBManager.m
//  SealTalk
//
//  Created by LiFei on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDDBManager.h"
#import "RCDDBHelper.h"

static NSString *const USER_TABLE = @"t_user";
static NSString *const GROUP_TABLE = @"t_group";
static NSString *const MY_GROUP_TABLE = @"t_my_group";
static NSString *const GROUP_MEMBER_TABLE = @"t_group_member";
static NSString *const FRIEND_TABLE = @"t_friend";
static NSString *const BLACKLIST_TABLE = @"t_blacklist";
static NSString *const CHATCONFIG_TABLE = @"t_chat_config";
static NSString *const GROUP_NOTICE_TABLE = @"t_group_notice";
static NSString *const USER_SETTING_TABLE = @"t_user_setting";
static NSString *const FRIEND_DESCRIPTION_TABLE = @"t_friend_description";
static NSString *const GROUP_LEFT_MEMBER_TABLE = @"t_group_left_member";
static NSString *const GROUP_MEMBER_DETAIL_TABLE = @"t_group_member_detail";
static int USER_TABLE_VERSION = 2;
static int GROUP_TABLE_VERSION = 3;
static int MY_GROUP_TABLE_VERSION = 1;
static int GROUP_MEMBER_TABLE_VERSION = 2;
static int FRIEND_TABLE_VERSION = 1;
static int BLACKLIST_TABLE_VERSION = 1;
static int CHATCONFIG_TABLE_VERSION = 1;
static int GROUP_NOTICE_TABLE_VERSION = 1;
static int USER_SETTING_TABLE_VERSION = 1;
static int FRIEND_DESCRIPTION_TABLE_VERSION = 1;
static int GROUP_LEFT_MEMBER_TABLE_VERSION = 1;
static int GROUP_MEMBER_DETAIL_TABLE_VERSION = 1;
@interface RCDGroupMemberDetailInfo ()
@property (nonatomic, strong) NSString *describeStr;
@end
@implementation RCDDBManager
+ (BOOL)openDB:(NSString *)path {
    BOOL result = [RCDDBHelper openDB:path];
    if (result) {
        [self upgradeTableIfNeed];
        [self createTableIfNeed];
    }
    return result;
}

+ (void)closeDB {
    [RCDDBHelper closeDB];
}

+ (void)saveUsers:(NSArray<RCDUserInfo *> *)userList {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"saveUsers, db is not open");
        return;
    }
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        NSString *sql = @"REPLACE INTO t_user (user_id, name, portrait_uri, st_account, gender) VALUES (?, ?, ?, ?, ?)";
        for (RCDUserInfo *user in userList) {
            if (user.userId.length > 0) {
                NSString *name = user.name ?: @"";
                NSString *portrait = user.portraitUri ?: @"";
                NSString *stAccount = user.stAccount ?: @"";
                NSString *gender = user.gender ?: @"";
                NSArray *arr = @[ user.userId, name, portrait, stAccount, gender ];
                [db executeUpdate:sql withArgumentsInArray:arr];
            }
        }
    }];
}

+ (RCDUserInfo *)getUser:(NSString *)userId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getUser, db is not open");
        return nil;
    }
    if (userId.length == 0) {
        NSLog(@"getUser, userId length is zero");
        return nil;
    }
    __block RCDUserInfo *userInfo = nil;
    NSString *sql = @"SELECT * FROM t_user WHERE user_id = ?";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ userId ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       if ([resultSet next]) {
                           userInfo = [self generateUserInfoFromFMResultSet:resultSet];
                       }
                   }];
    return userInfo;
}

+ (void)saveFriends:(NSArray<RCDFriendInfo *> *)friendList {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"saveFriends, db is not open");
        return;
    }
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        NSString *userSql =
            @"REPLACE INTO t_user (user_id, name, portrait_uri, st_account, gender) VALUES (?, ?, ?, ?, ?)";
        NSString *friendSql =
            @"REPLACE INTO t_friend (user_id, status, display_name, phone_number, update_dt) VALUES (?, ?, ?, ?, ?)";
        for (RCDFriendInfo *friend in friendList) {
            if (friend.userId.length > 0) {
                NSString *name = friend.name ?: @"";
                NSString *portrait = friend.portraitUri ?: @"";
                NSString *stAccount = friend.stAccount ?: @"";
                NSString *gender = friend.gender ?: @"";
                NSArray *userArr = @[ friend.userId, name, portrait, stAccount, gender ];
                [db executeUpdate:userSql withArgumentsInArray:userArr];

                NSString *displayName = friend.displayName ?: @"";
                NSString *phoneNumber = friend.phoneNumber ?: @"";
                NSArray *friendArr = @[ friend.userId, @(friend.status), displayName, phoneNumber, @(friend.updateDt) ];
                [db executeUpdate:friendSql withArgumentsInArray:friendArr];
            }
        }
    }];
}

+ (void)deleteFriends:(NSArray<NSString *> *)userIdList {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"deleteFriends, db is not open");
        return;
    }
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        NSString *friendSql = @"DELETE FROM t_friend WHERE user_id = ?";
        for (NSString *userId in userIdList) {
            if (userId.length > 0) {
                [db executeUpdate:friendSql withArgumentsInArray:@[ userId ]];
            }
        }
    }];
}

+ (RCDFriendInfo *)getFriend:(NSString *)userId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getFriend, db is not open");
        return nil;
    }
    if (userId.length == 0) {
        NSLog(@"getFriend, userId length is zero");
        return nil;
    }
    __block RCDFriendInfo *friendInfo = nil;
    NSString *sql = @"SELECT u.user_id AS user_id, u.name AS name, u.portrait_uri AS portrait_uri, u.st_account AS "
                    @"st_account, u.gender AS gender, f.status AS status, f.display_name AS display_name, "
                    @"f.phone_number AS phone_number, f.update_dt AS update_dt FROM (t_friend AS f LEFT JOIN t_user "
                    @"AS u ON f.user_id = u.user_id) WHERE f.user_id = ?";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ userId ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       if ([resultSet next]) {
                           friendInfo = [self generateFriendInfoFromFMResultSet:resultSet];
                       }
                   }];
    return friendInfo;
}

+ (void)clearFriends {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"clearFriends, db is not open");
        return;
    }
    NSString *sql = @"DELETE FROM t_friend";
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:nil];
}

+ (int)getFriendRequesteds {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getAllFriends, db is not open");
        return 0;
    }
    __block int requestCount = 0;
    NSString *sql = @"SELECT u.user_id AS user_id, u.name AS name, u.portrait_uri AS portrait_uri, u.st_account AS "
                    @"st_account, u.gender AS gender, f.status AS status, f.display_name AS display_name, "
                    @"f.phone_number AS phone_number, f.update_dt AS update_dt FROM (t_friend AS f LEFT JOIN t_user "
                    @"AS u ON f.user_id = u.user_id) WHERE f.status = 11";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:nil
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           requestCount++;
                       }
                   }];
    return requestCount;
}

+ (NSArray<RCDFriendInfo *> *)getAllFriends {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getAllFriends, db is not open");
        return nil;
    }
    __block NSMutableArray *friendList = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT u.user_id AS user_id, u.name AS name, u.portrait_uri AS portrait_uri, u.st_account AS "
                    @"st_account, u.gender AS gender, f.status AS status, f.display_name AS display_name, "
                    @"f.phone_number AS phone_number, f.update_dt AS update_dt FROM (t_friend AS f LEFT JOIN t_user "
                    @"AS u ON f.user_id = u.user_id) WHERE f.status = 20 ORDER BY f.update_dt";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:nil
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           RCDFriendInfo *userInfo = [self generateFriendInfoFromFMResultSet:resultSet];
                           [friendList addObject:userInfo];
                       }
                   }];
    return friendList;
}

+ (NSArray<RCDFriendInfo *> *)getAllFriendRequests {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getAllFriendRequests, db is not open");
        return nil;
    }
    __block NSMutableArray *friendList = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT u.user_id AS user_id, u.name AS name, u.portrait_uri AS portrait_uri, u.st_account AS "
                    @"st_account, u.gender AS gender, f.status AS status, f.display_name AS display_name, "
                    @"f.phone_number AS phone_number, f.update_dt AS update_dt FROM (t_friend AS f LEFT JOIN t_user "
                    @"AS u ON f.user_id = u.user_id) ORDER BY f.update_dt DESC";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:nil
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           RCDFriendInfo *userInfo = [self generateFriendInfoFromFMResultSet:resultSet];
                           [friendList addObject:userInfo];
                       }
                   }];
    return friendList;
}

+ (void)addBlacklist:(NSArray<NSString *> *)userIdList {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"saveBlacklist, db is not open");
        return;
    }
    if (userIdList.count == 0) {
        NSLog(@"saveBlacklist, userIdList count is zero");
        return;
    }
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        NSString *sql = @"REPLACE INTO t_blacklist (user_id) VALUES (?)";
        for (NSString *userId in userIdList) {
            if (userId.length > 0) {
                [db executeUpdate:sql withArgumentsInArray:@[ userId ]];
            }
        }
    }];
}

+ (NSArray<NSString *> *)getBlacklist {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getBlacklist, db is not open");
        return nil;
    }
    __block NSMutableArray *blacklistArray = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM t_blacklist";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:nil
                   syncResult:^(FMResultSet *resultSet) {
                       while ([resultSet next]) {
                           NSString *userId = [resultSet stringForColumn:@"user_id"];
                           [blacklistArray addObject:userId];
                       }
                   }];
    return blacklistArray;
}

+ (void)removeBlacklist:(NSArray<NSString *> *)userIdList {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"clearBlacklist, db is not open");
        return;
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM t_blacklist WHERE user_id IN ('%@')",
                                               [userIdList componentsJoinedByString:@"','"]];
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:nil];
}

+ (void)clearBlacklist {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"clearBlacklist, db is not open");
        return;
    }
    NSString *sql = @"DELETE FROM t_blacklist";
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:nil];
}

+ (void)saveGroups:(NSArray<RCDGroupInfo *> *)groupList {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"saveGroups, db is not open");
        return;
    }
    if (groupList.count == 0) {
        NSLog(@"saveGroups, userIdList count is zero");
        return;
    }
    NSString *sql = @"REPLACE INTO t_group (group_id, name, portrait_uri, member_count, max_count, introduce, "
                    @"creator_id, is_dismiss, mute, need_certification, member_protection) VALUES (?, ?, ?, ?, ?, ?, "
                    @"?, ?, ?, ?, ?)";
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (RCDGroupInfo *groupInfo in groupList) {
            [db executeUpdate:sql
                withArgumentsInArray:@[
                    groupInfo.groupId ?: @"",
                    groupInfo.groupName ?: @"",
                    groupInfo.portraitUri ?: @"",
                    @([groupInfo.number intValue]),
                    @([groupInfo.maxNumber intValue]),
                    groupInfo.introduce ?: @"",
                    groupInfo.creatorId ?: @"",
                    @(groupInfo.isDismiss),
                    @(groupInfo.mute),
                    @(groupInfo.needCertification),
                    @(groupInfo.memberProtection)
                ]];
        }
    }];
}

+ (RCDGroupInfo *)getGroup:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getGroup, db is not open");
        return nil;
    }
    if (groupId.length == 0) {
        NSLog(@"getGroup, groupId length is zero");
        return nil;
    }
    NSString *sql = @"SELECT * FROM t_group WHERE group_id = ?";
    __block RCDGroupInfo *group = nil;
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ groupId ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       if ([resultSet next]) {
                           group = [self generateGroupInfoFromFMResultSet:resultSet];
                       }
                   }];
    return group;
}

+ (void)deleteGroup:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"deleteGroup, db is not open");
        return;
    }
    if (groupId.length == 0) {
        NSLog(@"deleteGroup, groupId length is zero");
        return;
    }
    NSString *sql = @"DELETE FROM t_group WHERE group_id = ?";
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:@[ groupId ]];
}

+ (NSArray<RCDGroupInfo *> *)getAllGroupList {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getAllGroupList, db is not open");
        return nil;
    }
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM t_group";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:nil
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           RCDGroupInfo *group = [self generateGroupInfoFromFMResultSet:resultSet];
                           [groups addObject:group];
                       }
                   }];
    return groups;
}

+ (void)saveMyGroups:(NSArray<NSString *> *)groupIdList {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"saveMyGroups, db is not open");
        return;
    }
    NSString *sql = @"REPLACE INTO t_my_group (group_id) VALUES (?)";
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (NSString *groupId in groupIdList) {
            if (groupId.length > 0) {
                [db executeUpdate:sql withArgumentsInArray:@[ groupId ]];
            }
        }
    }];
}

+ (NSArray<RCDGroupInfo *> *)getMyGroups {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getMyGroups, db is not open");
        return nil;
    }
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT g.* FROM (t_my_group AS m LEFT JOIN t_group AS g ON m.group_id = g.group_id)";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:nil
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           RCDGroupInfo *group = [self generateGroupInfoFromFMResultSet:resultSet];
                           [groups addObject:group];
                       }
                   }];
    return groups;
}

+ (void)clearMyGroups {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"clearMyGroups, db is not open");
        return;
    }
    NSString *sql = @"DELETE FROM t_my_group";
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:nil];
}

+ (void)saveGroupMembers:(NSArray<RCDGroupMember *> *)memberList inGroup:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"saveGroupMembers, db is not open");
        return;
    }
    if (groupId.length == 0) {
        NSLog(@"saveGroupMembers, groupId length is zero");
        return;
    }
    [RCDDBManager saveUsers:memberList];
    NSString *sql = @"REPLACE INTO t_group_member (group_id, user_id, group_nickname, role, create_dt, update_dt) "
                    @"VALUES (?, ?, ?, ?, ?, ?)";
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (RCDGroupMember *member in memberList) {
            [db executeUpdate:sql
                withArgumentsInArray:@[
                    groupId,
                    member.userId ?: @"",
                    member.groupNickname ? member.groupNickname : @"",
                    @(member.role),
                    @(member.createDt),
                    @(member.updateDt)
                ]];
        }
    }];
}

+ (void)clearGroupMembers:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"clearGroupMembers, db is not open");
        return;
    }
    if (groupId.length == 0) {
        NSLog(@"clearGroupMembers, groupId length is zero");
        return;
    }
    NSString *sql = @"DELETE FROM t_group_member WHERE group_id = ?";
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:@[ groupId ]];
}

+ (NSArray<NSString *> *)getGroupMembers:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getGroupMembers, db is not open");
        return nil;
    }
    if (groupId.length == 0) {
        NSLog(@"getGroupMembers, groupId length is zero");
        return nil;
    }
    NSString *sql = @"SELECT * FROM t_group_member WHERE group_id = ? ORDER BY create_dt";
    NSMutableArray *members = [[NSMutableArray alloc] init];
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ groupId ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           NSString *userId = [resultSet stringForColumn:@"user_id"];
                           [members addObject:userId];
                       }
                   }];
    return members;
}

+ (RCDGroupMember *)getGroupMember:(NSString *)userId inGroup:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getGroupMember:inGroup: , db is not open");
        return nil;
    }
    if (groupId.length == 0 || userId.length == 0) {
        NSLog(@"getGroupMember:inGroup:, groupId or userId length is zero");
        return nil;
    }
    NSString *sql = @"SELECT gm.user_id, gm.group_id, gm.group_nickname, gm.role, gm.create_dt, gm.update_dt, u.name, "
                    @"u.portrait_uri, u.st_account, u.gender FROM t_group_member gm LEFT JOIN t_user u On gm.user_id "
                    @"= u.user_id WHERE gm.user_id = ? AND gm.group_id = ?";
    __block RCDGroupMember *member = nil;
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ userId, groupId ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           member = [self generateGroupMemberFromFMResultSet:resultSet];
                       }
                   }];
    return member;
}

+ (NSArray<NSString *> *)getGroupManagers:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getGroupManagers, db is not open");
        return nil;
    }
    if (groupId.length == 0) {
        NSLog(@"getGroupManagers, groupId length is zero");
        return nil;
    }
    NSString *sql = @"SELECT * FROM t_group_member WHERE group_id = ? AND role = ? ORDER BY create_dt";
    NSMutableArray *members = [[NSMutableArray alloc] init];
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ groupId, @(RCDGroupMemberRoleManager) ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           NSString *userId = [resultSet stringForColumn:@"user_id"];
                           [members addObject:userId];
                       }
                   }];
    return members;
}

+ (NSString *)getGroupOwner:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getGroupOwner, db is not open");
        return nil;
    }
    if (groupId.length == 0) {
        NSLog(@"getGroupOwner, groupId length is zero");
        return nil;
    }
    NSString *sql = @"SELECT * FROM t_group_member WHERE group_id = ? AND role = ?";
    __block NSString *owner = [NSString string];
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ groupId, @(RCDGroupMemberRoleOwner) ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           owner = [resultSet stringForColumn:@"user_id"];
                       }
                   }];
    return owner;
}

+ (void)saveChatConfig:(RCDChatConfig *)chatConfig {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"saveChatConfig, db is not open");
        return;
    }
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        NSString *sql = @"REPLACE INTO t_chat_config (conversation_type, target_id, is_screen_capture_notification, "
                        @"message_clear_status) VALUES (?, ?, ?, ?)";
        [db executeUpdate:sql
            withArgumentsInArray:@[
                @(chatConfig.conversationType),
                chatConfig.targetId,
                @(chatConfig.screenCaptureNotification),
                @(chatConfig.messageClearStatus)
            ]];
    }];
}

+ (RCDChatConfig *)getChatConfigWithConversationType:(RCConversationType)conversationType
                                            targetId:(NSString *)targetId {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"getChatConfig, db is not open");
        return nil;
    }
    if (targetId.length == 0) {
        NSLog(@"getChatConfig, target length is zero");
        return nil;
    }
    NSString *sql = @"SELECT * FROM t_chat_config WHERE target_id = ? AND conversation_type = ?";
    __block RCDChatConfig *chatConfig = nil;
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ targetId, @(conversationType) ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       if ([resultSet next]) {
                           chatConfig = [self generateChatConfigFromFMResultSet:resultSet];
                       }
                   }];
    return chatConfig;
}

+ (BOOL)getScreenCaptureNotification:(RCConversationType)type targetId:(NSString *)targetId {
    return [[self class] getChatConfigWithConversationType:type targetId:targetId].screenCaptureNotification;
}

+ (RCDGroupMessageClearStatus)getMessageClearStatus:(RCConversationType)type targetId:(NSString *)targetId {
    return [[self class] getChatConfigWithConversationType:type targetId:targetId].messageClearStatus;
}

+ (void)saveGroupNoticeList:(NSArray<RCDGroupNotice *> *)noticeList {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return;
    }
    NSString *sql = @"REPLACE INTO t_group_notice (group_id, operator_id, target_id, notice_type, invite_status, "
                    @"update_dt) VALUES (?, ?, ?, ?, ?, ?)";
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (RCDGroupNotice *notice in noticeList) {
            [db executeUpdate:sql
                withArgumentsInArray:@[
                    notice.groupId ?: @"",
                    notice.operatorId ?: @"",
                    notice.targetId ?: @"",
                    @(notice.noticeType),
                    @(notice.status),
                    @(notice.createTime)
                ]];
        }
    }];
}

+ (NSArray<RCDGroupNotice *> *)getGroupNoticeList {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return nil;
    }
    __block NSMutableArray *noticeList = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM t_group_notice ORDER BY update_dt DESC";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:nil
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           RCDGroupNotice *userInfo = [self generateGroupNoticeFromFMResultSet:resultSet];
                           [noticeList addObject:userInfo];
                       }
                   }];
    return noticeList;
}

+ (NSInteger)getGroupNoticeUnreadCount {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return 0;
    }
    __block NSInteger count;
    NSString *sql = @"SELECT COUNT(*) AS count FROM t_group_notice WHERE invite_status = ?";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ @(RCDGroupInviteStatusApproving) ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           count = [resultSet intForColumn:@"count"];
                       }
                   }];
    return count;
}

+ (void)clearGroupNoticeList {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return;
    }
    NSString *sql = @"DELETE FROM t_group_notice";
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:nil];
}

+ (void)saveGroupLeftMemberList:(NSArray<RCDGroupLeftMember *> *)list groupId:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return;
    }
    NSString *sql =
        @"REPLACE INTO t_group_left_member (group_id, user_id, reason, operator_id, time) VALUES (?, ?, ?, ?, ?)";
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (RCDGroupLeftMember *member in list) {
            [db executeUpdate:sql
                withArgumentsInArray:@[
                    groupId ?: @"",
                    member.userId ?: @"",
                    @(member.reason),
                    member.operatorId ?: @"",
                    @(member.time)
                ]];
        }
    }];
}

+ (void)clearGroupLeftMemberList:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return;
    }
    NSString *sql = @"DELETE FROM t_group_left_member WHERE group_id = ?";
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:@[ groupId ?: @"" ]];
}

+ (NSArray<RCDGroupLeftMember *> *)getGroupLeftMemberList:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return nil;
    }
    __block NSMutableArray *list = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM t_group_left_member WHERE group_id = ?";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ groupId ?: @"" ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           RCDGroupLeftMember *member = [self generateGroupLeftMemberFromFMResultSet:resultSet];
                           [list addObject:member];
                       }
                   }];
    return list;
}

+ (void)saveGroupMemberDetailInfo:(RCDGroupMemberDetailInfo *)memberDetail groupId:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return;
    }
    RCDGroupMember *member = [self getGroupMember:memberDetail.userId inGroup:groupId];
    if (!member) {
        member = [[RCDGroupMember alloc] init];
    }
    member.groupNickname = memberDetail.groupNickname;
    [self saveGroupMembers:@[ member ] inGroup:groupId];
    NSString *sql = @"REPLACE INTO t_group_member_detail (user_id, group_id, region, phone, wechat_account, "
                    @"alipay_account, description) VALUES (? ,? ,? ,? ,? ,? ,? )";
    [RCDDBHelper executeUpdate:sql
          withArgumentsInArray:@[
              memberDetail.userId ?: @"",
              groupId ?: @"",
              memberDetail.region ?: @"",
              memberDetail.phone ?: @"",
              memberDetail.weChatAccount ?: @"",
              memberDetail.alipayAccount ?: @"",
              memberDetail.describeStr ?: @""
          ]];
}

+ (void)clearGroupMemberDetailInfo:(NSString *)userId groupId:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return;
    }
    NSString *sql = @"DELETE FROM t_group_member_detail WHERE group_id = ? AND user_id = ?";
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:@[ groupId ?: @"", userId ?: @"" ]];
}

+ (void)clearGroupMemberDetailInfo:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return;
    }
    NSString *sql = @"DELETE FROM t_group_member_detail WHERE group_id = ?";
    [RCDDBHelper executeUpdate:sql withArgumentsInArray:@[ groupId ?: @"" ]];
}

+ (RCDGroupMemberDetailInfo *)getGroupMemberDetailInfo:(NSString *)userId groupId:(NSString *)groupId {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return nil;
    }
    __block RCDGroupMemberDetailInfo *memberDetail;
    NSString *sql = @"SELECT gmd.user_id, gm.group_nickname, gmd.region, gmd.phone, gmd.wechat_account, "
                    @"gmd.alipay_account,gmd.description FROM t_group_member_detail gmd LEFT JOIN t_group_member gm "
                    @"On (gm.user_id = gmd.user_id AND gm.group_id = gmd.group_id) WHERE gmd.user_id = ? AND "
                    @"gmd.group_id = ?";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ userId ?: @"", groupId ?: @"" ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           memberDetail = [self generateGroupMemberDetailFromFMResultSet:resultSet];
                       }
                   }];
    return memberDetail;
}

+ (void)saveUserSetting:(RCDUserSetting *)setting {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return;
    }
    NSString *sql = @"REPLACE INTO t_user_setting (user_id, allow_mobile_search, allow_st_search, "
                    @"need_add_friend_verify, need_join_group_verify) VALUES ( ?, ?, ?, ?, ?)";
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        [db executeUpdate:sql
            withArgumentsInArray:@[
                setting.userId ?: @"",
                @(setting.allowMobileSearch),
                @(setting.allowSTAccountSearch),
                @(setting.needAddFriendVerify),
                @(setting.needJoinGroupVerify)
            ]];
    }];
}

+ (RCDUserSetting *)getUserSetting {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return nil;
    }
    __block RCDUserSetting *userSetting;
    NSString *sql = @"SELECT * FROM t_user_setting WHERE user_id = ?";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ [RCIMClient sharedRCIMClient].currentUserInfo.userId ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           userSetting = [self generateUserSettingFromFMResultSet:resultSet];
                       }
                   }];
    return userSetting;
}

+ (void)saveFriendDescription:(RCDFriendDescription *)description {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return;
    }
    NSString *sql = @"REPLACE INTO t_friend_description (user_id, display_name, region, phone, desc, imageUrl) VALUES "
                    @"( ?, ?, ?, ?, ?, ?)";
    [RCDDBHelper executeTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        [db executeUpdate:sql
            withArgumentsInArray:@[
                description.userId ?: @"",
                description.displayName ?: @"",
                description.region ?: @"",
                description.phone ?: @"",
                description.desc ?: @"",
                description.imageUrl ?: @""
            ]];
    }];
}

+ (RCDFriendDescription *)getFriendDescription:(NSString *)userId {
    if (![RCDDBHelper isDBOpened]) {
        SealTalkLog(@"db is not open");
        return nil;
    }
    if (userId.length == 0) {
        NSLog(@"getUser, userId length is zero");
        return nil;
    }

    __block RCDFriendDescription *friendDescription;
    NSString *sql = @"SELECT * FROM t_friend_description WHERE user_id = ?";
    [RCDDBHelper executeQuery:sql
         withArgumentsInArray:@[ userId ]
                   syncResult:^(FMResultSet *_Nonnull resultSet) {
                       while ([resultSet next]) {
                           friendDescription = [self generateFriendDescriptionFromFMResultSet:resultSet];
                       }
                   }];
    return friendDescription;
}

+ (RCDFriendDescription *)generateFriendDescriptionFromFMResultSet:(FMResultSet *)resultSet {
    RCDFriendDescription *friendDescription = [[RCDFriendDescription alloc] init];
    friendDescription.userId = [resultSet stringForColumn:@"user_id"];
    friendDescription.displayName = [resultSet stringForColumn:@"display_name"];
    friendDescription.region = [resultSet stringForColumn:@"region"];
    friendDescription.phone = [resultSet stringForColumn:@"phone"];
    friendDescription.desc = [resultSet stringForColumn:@"desc"];
    friendDescription.imageUrl = [resultSet stringForColumn:@"imageUrl"];
    return friendDescription;
}

+ (RCDGroupMember *)generateGroupMemberFromFMResultSet:(FMResultSet *)resultSet {
    RCDGroupMember *member = [[RCDGroupMember alloc] init];
    member.userId = [resultSet stringForColumn:@"user_id"];
    member.name = [resultSet stringForColumn:@"name"];
    member.portraitUri = [resultSet stringForColumn:@"portrait_uri"];
    member.groupId = [resultSet stringForColumn:@"group_id"];
    member.role = [resultSet intForColumn:@"role"];
    member.stAccount = [resultSet stringForColumn:@"st_account"];
    member.gender = [resultSet stringForColumn:@"gender"];
    member.groupNickname = [resultSet stringForColumn:@"group_nickname"];
    member.createDt = [resultSet longLongIntForColumn:@"create_dt"];
    member.updateDt = [resultSet longLongIntForColumn:@"update_dt"];
    return member;
}

+ (RCDGroupLeftMember *)generateGroupLeftMemberFromFMResultSet:(FMResultSet *)resultSet {
    RCDGroupLeftMember *member = [[RCDGroupLeftMember alloc] init];
    member.userId = [resultSet stringForColumn:@"user_id"];
    member.operatorId = [resultSet stringForColumn:@"operator_id"];
    member.reason = [resultSet intForColumn:@"reason"];
    member.time = [resultSet longLongIntForColumn:@"time"];
    return member;
}

+ (RCDGroupMemberDetailInfo *)generateGroupMemberDetailFromFMResultSet:(FMResultSet *)resultSet {
    RCDGroupMemberDetailInfo *member = [[RCDGroupMemberDetailInfo alloc] init];
    member.userId = [resultSet stringForColumn:@"user_id"];
    member.groupNickname = [resultSet stringForColumn:@"group_nickname"];
    member.region = [resultSet stringForColumn:@"region"];
    member.phone = [resultSet stringForColumn:@"phone"];
    member.weChatAccount = [resultSet stringForColumn:@"wechat_account"];
    member.alipayAccount = [resultSet stringForColumn:@"alipay_account"];
    NSString *string = [resultSet stringForColumn:@"description"];
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        if (array && array.count) {
            member.describeArray = array;
        }
    }
    return member;
}

+ (RCDUserSetting *)generateUserSettingFromFMResultSet:(FMResultSet *)resultSet {
    RCDUserSetting *userSetting = [[RCDUserSetting alloc] init];
    userSetting.userId = [resultSet stringForColumn:@"user_id"];
    userSetting.allowMobileSearch = [resultSet boolForColumn:@"allow_mobile_search"];
    userSetting.allowSTAccountSearch = [resultSet boolForColumn:@"allow_st_search"];
    userSetting.needAddFriendVerify = [resultSet boolForColumn:@"need_add_friend_verify"];
    userSetting.needJoinGroupVerify = [resultSet boolForColumn:@"need_join_group_verify"];
    return userSetting;
}

+ (RCDUserInfo *)generateUserInfoFromFMResultSet:(FMResultSet *)resultSet {
    RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
    userInfo.userId = [resultSet stringForColumn:@"user_id"];
    userInfo.name = [resultSet stringForColumn:@"name"];
    userInfo.portraitUri = [resultSet stringForColumn:@"portrait_uri"];
    userInfo.stAccount = [resultSet stringForColumn:@"st_account"];
    userInfo.gender = [resultSet stringForColumn:@"gender"];
    return userInfo;
}

+ (RCDFriendInfo *)generateFriendInfoFromFMResultSet:(FMResultSet *)resultSet {
    RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
    friendInfo.userId = [resultSet stringForColumn:@"user_id"];
    friendInfo.name = [resultSet stringForColumn:@"name"];
    friendInfo.portraitUri = [resultSet stringForColumn:@"portrait_uri"];
    friendInfo.status = [resultSet intForColumn:@"status"];
    friendInfo.displayName = [resultSet stringForColumn:@"display_name"];
    friendInfo.phoneNumber = [resultSet stringForColumn:@"phone_number"];
    friendInfo.updateDt = [resultSet longLongIntForColumn:@"update_dt"];
    friendInfo.stAccount = [resultSet stringForColumn:@"st_account"];
    friendInfo.gender = [resultSet stringForColumn:@"gender"];
    return friendInfo;
}

+ (RCDGroupInfo *)generateGroupInfoFromFMResultSet:(FMResultSet *)resultSet {
    RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
    group.groupId = [resultSet stringForColumn:@"group_id"];
    group.groupName = [resultSet stringForColumn:@"name"];
    group.portraitUri = [resultSet stringForColumn:@"portrait_uri"];
    group.number = [resultSet stringForColumn:@"member_count"];
    group.maxNumber = [resultSet stringForColumn:@"max_count"];
    group.introduce = [resultSet stringForColumn:@"introduce"];
    group.creatorId = [resultSet stringForColumn:@"creator_id"];
    group.isDismiss = [resultSet boolForColumn:@"is_dismiss"];
    group.mute = [resultSet boolForColumn:@"mute"];
    group.needCertification = [resultSet boolForColumn:@"need_certification"];
    group.memberProtection = [resultSet boolForColumn:@"member_protection"];
    return group;
}

+ (RCDGroupNotice *)generateGroupNoticeFromFMResultSet:(FMResultSet *)resultSet {
    RCDGroupNotice *notice = [[RCDGroupNotice alloc] init];
    notice.groupId = [resultSet stringForColumn:@"group_id"];
    notice.operatorId = [resultSet stringForColumn:@"operator_id"];
    notice.targetId = [resultSet stringForColumn:@"target_id"];
    notice.noticeType = [resultSet intForColumn:@"notice_type"];
    notice.status = [resultSet intForColumn:@"invite_status"];
    notice.createTime = [resultSet longLongIntForColumn:@"update_dt"];
    return notice;
}

+ (RCDChatConfig *)generateChatConfigFromFMResultSet:(FMResultSet *)resultSet {
    RCDChatConfig *chatConfig = [[RCDChatConfig alloc] init];
    chatConfig.screenCaptureNotification = [resultSet boolForColumn:@"is_screen_capture_notification"];
    chatConfig.messageClearStatus = [resultSet intForColumn:@"message_clear_status"];
    chatConfig.conversationType = [resultSet intForColumn:@"conversation_type"];
    chatConfig.targetId = [resultSet stringForColumn:@"target_id"];
    return chatConfig;
}

+ (void)createTableIfNeed {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"createTableIfNeed, db is not open");
        return;
    }

    [RCDDBHelper updateTable:USER_TABLE
                     version:USER_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_user ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "user_id TEXT NOT NULL UNIQUE,"
                                      "name TEXT,"
                                      "portrait_uri TEXT,"
                                      "st_account TEXT,"
                                      "gender TEXT"
                                      ")";
                     BOOL result = [db executeUpdate:sql];
                     if (result) {
                         result = [db executeUpdate:@"CREATE INDEX IF NOT EXISTS idx_user_id ON t_user(user_id)"];
                     }
                     return result;
                 }];

    [RCDDBHelper updateTable:FRIEND_TABLE
                     version:FRIEND_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_friend ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "user_id TEXT NOT NULL UNIQUE,"
                                      "status INTEGER,"
                                      "display_name TEXT,"
                                      "phone_number TEXT,"
                                      "update_dt INTEGER"
                                      ")";
                     BOOL result = [db executeUpdate:sql];
                     if (result) {
                         result =
                             [db executeUpdate:@"CREATE INDEX IF NOT EXISTS idx_friend_user_id ON t_friend(user_id) "];
                     }
                     return result;
                 }];

    [RCDDBHelper updateTable:GROUP_TABLE
                     version:GROUP_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_group ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "group_id TEXT NOT NULL UNIQUE,"
                                      "name TEXT,"
                                      "portrait_uri TEXT,"
                                      "member_count INTEGER,"
                                      "max_count INTEGER,"
                                      "introduce TEXT,"
                                      "creator_id TEXT,"
                                      "is_dismiss INTEGER,"
                                      "mute INTEGER,"
                                      "need_certification INTEGER,"
                                      "member_protection INTEGER"
                                      ")";
                     BOOL result = [db executeUpdate:sql];
                     if (result) {
                         result = [db executeUpdate:@"CREATE INDEX IF NOT EXISTS idx_group_id ON t_group(group_id)"];
                     }
                     return result;
                 }];

    [RCDDBHelper updateTable:MY_GROUP_TABLE
                     version:MY_GROUP_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_my_group ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "group_id TEXT NOT NULL UNIQUE"
                                      ")";
                     return [db executeUpdate:sql];
                 }];

    [RCDDBHelper updateTable:BLACKLIST_TABLE
                     version:BLACKLIST_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_blacklist ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "user_id TEXT NOT NULL UNIQUE"
                                      ")";
                     return [db executeUpdate:sql];
                 }];

    [RCDDBHelper
        updateTable:GROUP_MEMBER_TABLE
            version:GROUP_MEMBER_TABLE_VERSION
        transaction:^BOOL(FMDatabase *_Nonnull db) {
            NSString *sql = @"CREATE TABLE IF NOT EXISTS t_group_member ("
                             "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                             "group_id TEXT,"
                             "user_id TEXT,"
                             "group_nickname TEXT,"
                             "role INTEGER,"
                             "create_dt INTEGER,"
                             "update_dt INTEGER"
                             ")";
            BOOL result = [db executeUpdate:sql];
            if (result) {
                result = [db
                    executeUpdate:
                        @"CREATE UNIQUE INDEX IF NOT EXISTS idx_group_member ON t_group_member (group_id, user_id)"];
            }
            return result;
        }];

    [RCDDBHelper updateTable:CHATCONFIG_TABLE
                     version:CHATCONFIG_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_chat_config ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "target_id TEXT NOT NULL UNIQUE,"
                                      "conversation_type INTEGER,"
                                      "is_screen_capture_notification INTEGER,"
                                      "message_clear_status"
                                      ")";
                     return [db executeUpdate:sql];
                 }];
    [RCDDBHelper updateTable:GROUP_NOTICE_TABLE
                     version:GROUP_NOTICE_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_group_notice ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "group_id TEXT,"
                                      "operator_id TEXT,"
                                      "target_id TEXT,"
                                      "notice_type INTEGER,"
                                      "invite_status INTEGER,"
                                      "update_dt INTEGER"
                                      ")";
                     BOOL result = [db executeUpdate:sql];
                     return result;
                 }];
    [RCDDBHelper updateTable:USER_SETTING_TABLE
                     version:USER_SETTING_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_user_setting ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "user_id TEXT NOT NULL UNIQUE,"
                                      "allow_mobile_search INTEGER,"
                                      "allow_st_search INTEGER,"
                                      "need_add_friend_verify INTEGER,"
                                      "need_join_group_verify INTEGER"
                                      ")";
                     BOOL result = [db executeUpdate:sql];
                     return result;
                 }];
    [RCDDBHelper updateTable:FRIEND_DESCRIPTION_TABLE
                     version:FRIEND_DESCRIPTION_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_friend_description ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "user_id TEXT NOT NULL UNIQUE,"
                                      "display_name TEXT,"
                                      "region TEXT,"
                                      "phone TEXT,"
                                      "desc TEXT,"
                                      "imageUrl TEXT"
                                      ")";
                     BOOL result = [db executeUpdate:sql];
                     return result;
                 }];
    [RCDDBHelper updateTable:GROUP_LEFT_MEMBER_TABLE
                     version:GROUP_LEFT_MEMBER_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_group_left_member ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "user_id TEXT NOT NULL,"
                                      "group_id TEXT NOT NULL,"
                                      "operator_id TEXT,"
                                      "reason INTEGER,"
                                      "time INTEGER"
                                      ")";
                     BOOL result = [db executeUpdate:sql];
                     if (result) {
                         result = [db executeUpdate:@"CREATE UNIQUE INDEX IF NOT EXISTS idx_group_left_member ON "
                                                    @"t_group_left_member (group_id, user_id)"];
                     }
                     return result;
                 }];
    [RCDDBHelper updateTable:GROUP_LEFT_MEMBER_TABLE
                     version:GROUP_LEFT_MEMBER_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_group_left_member ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "user_id TEXT NOT NULL,"
                                      "group_id TEXT NOT NULL,"
                                      "operator_id TEXT,"
                                      "reason INTEGER,"
                                      "time INTEGER"
                                      ")";
                     BOOL result = [db executeUpdate:sql];
                     if (result) {
                         result = [db executeUpdate:@"CREATE UNIQUE INDEX IF NOT EXISTS idx_group_left_member ON "
                                                    @"t_group_left_member (group_id, user_id)"];
                     }
                     return result;
                 }];
    [RCDDBHelper updateTable:GROUP_MEMBER_DETAIL_TABLE
                     version:GROUP_MEMBER_DETAIL_TABLE_VERSION
                 transaction:^BOOL(FMDatabase *_Nonnull db) {
                     NSString *sql = @"CREATE TABLE IF NOT EXISTS t_group_member_detail ("
                                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                      "user_id TEXT NOT NULL,"
                                      "group_id TEXT NOT NULL,"
                                      "region TEXT,"
                                      "phone TEXT,"
                                      "wechat_account TEXT,"
                                      "alipay_account TEXT,"
                                      "description  TEXT)";
                     BOOL result = [db executeUpdate:sql];
                     if (result) {
                         result = [db executeUpdate:@"CREATE UNIQUE INDEX IF NOT EXISTS idx_group_member_detail ON "
                                                    @"t_group_member_detail (group_id, user_id)"];
                     }
                     return result;
                 }];
}

+ (void)upgradeTableIfNeed {
    if (![RCDDBHelper isDBOpened]) {
        NSLog(@"createTableIfNeed, db is not open");
        return;
    }
    int oldVersion = [RCDDBHelper versionOfTable:USER_TABLE];
    if (oldVersion < USER_TABLE_VERSION) {
        [RCDDBHelper dropTable:USER_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:GROUP_TABLE];
    if (oldVersion < GROUP_TABLE_VERSION) {
        [RCDDBHelper dropTable:GROUP_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:MY_GROUP_TABLE];
    if (oldVersion < MY_GROUP_TABLE_VERSION) {
        [RCDDBHelper dropTable:MY_GROUP_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:GROUP_MEMBER_TABLE];
    if (oldVersion < GROUP_MEMBER_TABLE_VERSION) {
        [RCDDBHelper dropTable:GROUP_MEMBER_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:FRIEND_TABLE];
    if (oldVersion < FRIEND_TABLE_VERSION) {
        [RCDDBHelper dropTable:FRIEND_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:BLACKLIST_TABLE];
    if (oldVersion < BLACKLIST_TABLE_VERSION) {
        [RCDDBHelper dropTable:BLACKLIST_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:CHATCONFIG_TABLE];
    if (oldVersion < CHATCONFIG_TABLE_VERSION) {
        [RCDDBHelper dropTable:CHATCONFIG_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:GROUP_NOTICE_TABLE];
    if (oldVersion < GROUP_NOTICE_TABLE_VERSION) {
        [RCDDBHelper dropTable:GROUP_NOTICE_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:USER_SETTING_TABLE];
    if (oldVersion < USER_SETTING_TABLE_VERSION) {
        [RCDDBHelper dropTable:USER_SETTING_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:FRIEND_DESCRIPTION_TABLE];
    if (oldVersion < FRIEND_DESCRIPTION_TABLE_VERSION) {
        [RCDDBHelper dropTable:FRIEND_DESCRIPTION_TABLE];
    }
    oldVersion = [RCDDBHelper versionOfTable:GROUP_LEFT_MEMBER_TABLE];
    if (oldVersion < GROUP_LEFT_MEMBER_TABLE_VERSION) {
        [RCDDBHelper dropTable:GROUP_LEFT_MEMBER_TABLE];
    }
}
@end
