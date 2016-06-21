//
//  RCDataBaseManager.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/6/3.
//  Copyright (c) 2015年 dlz. All rights reserved.
//

#import "RCDataBaseManager.h"
#import "RCDLoginInfo.h"
#import "RCDUserInfo.h"
#import "RCDHttpTool.h"
#import "DBHelper.h"

@implementation RCDataBaseManager

static NSString * const userTableName = @"USERTABLE";
static NSString * const groupTableName = @"GROUPTABLEV2";
static NSString * const friendTableName = @"FRIENDTABLE";
static NSString * const blackTableName = @"BLACKTABLE";
static NSString * const groupMemberTableName = @"GROUPMEMBERTABLE";

+ (RCDataBaseManager*)shareInstance
{
    static RCDataBaseManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        [instance CreateUserTable];
    });
    return instance;
}

//创建用户存储表
-(void)CreateUserTable
{
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    if (queue==nil) {
        return;
    }
    [queue inDatabase:^(FMDatabase *db) {
        if (![DBHelper isTableOK: userTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE USERTABLE (id integer PRIMARY KEY autoincrement, userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_userid ON USERTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![DBHelper isTableOK: groupTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE GROUPTABLEV2 (id integer PRIMARY KEY autoincrement, groupId text,name text, portraitUri text,inNumber text,maxNumber text ,introduce text ,creatorId text,creatorTime text, isJoin text, isDismiss text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_groupid ON GROUPTABLEV2(groupId);";
            [db executeUpdate:createIndexSQL];
        }
        if (![DBHelper isTableOK: friendTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE FRIENDTABLE (id integer PRIMARY KEY autoincrement, userid text,name text, portraitUri text, status text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_friendId ON FRIENDTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![DBHelper isTableOK: blackTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE BLACKTABLE (id integer PRIMARY KEY autoincrement, userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_blackId ON BLACKTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        if (![DBHelper isTableOK: groupMemberTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE GROUPMEMBERTABLE (id integer PRIMARY KEY autoincrement, groupid text, userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_groupmemberId ON GROUPMEMBERTABLE(groupid,userid);";
            [db executeUpdate:createIndexSQL];
        }
    }];
    
}

//存储用户信息
-(void)insertUserToDB:(RCUserInfo*)user
{
    NSString *insertSql = @"REPLACE INTO USERTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];

    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,user.userId,user.name,user.portraitUri];
    }];
}

//插入黑名单列表
-(void)insertBlackListToDB:(RCUserInfo*)user{
    NSString *insertSql = @"REPLACE INTO BLACKTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,user.userId,user.name,user.portraitUri];
    }];
}

//获取黑名单列表
- (NSArray *)getBlackList{
    NSMutableArray *allBlackList = [NSMutableArray new];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BLACKTABLE"];
        while ([rs next]) {
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allBlackList addObject:model];
        }
        [rs close];
    }];
    return allBlackList;
}

//移除黑名单
- (void)removeBlackList:(NSString *)userId{
    NSString *deleteSql =[NSString stringWithFormat: @"DELETE FROM BLACKTABLE WHERE userid=%@",userId];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    if (queue==nil) {
        return ;
    }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

//清空黑名单缓存数据
-(void)clearBlackListData
{
    NSString *deleteSql = @"DELETE FROM BLACKTABLE";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    if (queue==nil) {
        return ;
    }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

//从表中获取用户信息
-(RCUserInfo*) getUserByUserId:(NSString*)userId
{
    __block RCUserInfo *model = nil;
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    if (queue==nil) {
        return nil;
    }
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE where userid = ?",userId];
        while ([rs next]) {
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
        }
        [rs close];
    }];
    return model;
}

//从表中获取所有用户信息
-(NSArray *) getAllUserInfo
{
    NSMutableArray *allUsers = [NSMutableArray new];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE"];
        while ([rs next]) {
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}
//存储群组信息
-(void)insertGroupToDB:(RCDGroupInfo *)group
{
    if(group == nil || [group.groupId length]<1)
        return;
    
    NSString *insertSql = @"REPLACE INTO GROUPTABLEV2 (groupId, name,portraitUri,inNumber,maxNumber,introduce,creatorId,creatorTime,isJoin,isDismiss) VALUES (?,?,?,?,?,?,?,?,?,?)";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
        if (queue==nil) {
            return;
        }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,group.groupId, group.groupName,group.portraitUri,group.number,group.maxNumber,group.introduce,group.creatorId,group.creatorTime,[NSString stringWithFormat:@"%d",group.isJoin],group.isDismiss];
    }];
    
}

//从表中获取群组信息
-(RCDGroupInfo*) getGroupByGroupId:(NSString*)groupId
{
    __block RCDGroupInfo *model = nil;
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM GROUPTABLEV2 where groupId = ?",groupId];
        while ([rs next]) {
            model = [[RCDGroupInfo alloc] init];
            model.groupId = [rs stringForColumn:@"groupId"];
            model.groupName = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            model.number=[rs stringForColumn:@"inNumber"];
            model.maxNumber=[rs stringForColumn:@"maxNumber"];
            model.introduce=[rs stringForColumn:@"introduce"];
            model.creatorId=[rs stringForColumn:@"creatorId"];
            model.creatorTime=[rs stringForColumn:@"creatorTime"];
            model.isJoin=[rs boolForColumn:@"isJoin"];
            model.isDismiss = [rs stringForColumn:@"isDismiss"];
            
        }
        [rs close];
    }];
    return model;
}

//删除表中的群组信息
-(void)deleteGroupToDB:(NSString *)groupId
{
    if([groupId length]<1)
        return;
     NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",@"GROUPTABLEV2", @"groupid", groupId];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    if (queue==nil) {
        return;
    }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}


//从表中获取所有群组信息
-(NSMutableArray *) getAllGroup
{
    NSMutableArray *allGroups = [NSMutableArray new];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM GROUPTABLEV2 ORDER BY groupId"];
        while ([rs next]) {
            RCDGroupInfo *model;
            model = [[RCDGroupInfo alloc] init];
            model.groupId = [rs stringForColumn:@"groupId"];
            model.groupName = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            model.number=[rs stringForColumn:@"inNumber"];
            model.maxNumber=[rs stringForColumn:@"maxNumber"];
            model.introduce=[rs stringForColumn:@"introduce"];
            model.creatorId=[rs stringForColumn:@"creatorId"];
            model.creatorTime=[rs stringForColumn:@"creatorTime"];
            model.isJoin=[rs boolForColumn:@"isJoin"];
            [allGroups addObject:model];
        }
        [rs close];
    }];
    return allGroups;
}

//存储群组成员信息
-(void)insertGroupMemberToDB:(NSMutableArray *)groupMemberList groupId:(NSString *)groupId
{
    if(groupMemberList == nil || [groupMemberList count]<1)
        return;
    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",@"GROUPMEMBERTABLE", @"groupid", groupId];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    if (queue==nil) {
        return;
    }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
        for (RCUserInfo *user in groupMemberList) {
            NSString *insertSql = @"REPLACE INTO GROUPMEMBERTABLE (groupid, userid, name, portraitUri) VALUES (?, ?, ?, ?)";
//            [queue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:insertSql,groupId, user.userId, user.name, user.portraitUri];
//            }];
        }
    }];
    
}

//从表中获取群组成员信息
-(NSMutableArray *)getGroupMember:(NSString *)groupId
{
    NSMutableArray *allUsers = [NSMutableArray new];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM GROUPMEMBERTABLE where groupid=? order by id", groupId];
        while ([rs next]) {
            //            RCUserInfo *model;
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

//存储好友信息
//-(void)insertFriendToDB:(RCUserInfo *)friend
-(void)insertFriendToDB:(RCDUserInfo *)friendInfo
{
    NSString *insertSql = @"REPLACE INTO FRIENDTABLE (userid, name, portraitUri, status) VALUES (?, ?, ?, ?)";
        FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:insertSql,friendInfo.userId, friendInfo.name, friendInfo.portraitUri, friendInfo.status];
        }];
}

//从表中获取所有好友信息 //RCUserInfo
-(NSArray *) getAllFriends
{
    NSMutableArray *allUsers = [NSMutableArray new];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM FRIENDTABLE"];
        while ([rs next]) {
//            RCUserInfo *model;
            RCDUserInfo *model;
            model = [[RCDUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            model.status = [rs stringForColumn:@"status"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

//清空群组缓存数据
-(void)clearGroupsData
{
    NSString *deleteSql = @"DELETE FROM GROUPTABLEV2";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    if (queue==nil) {
        return ;
    }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

//清空好友缓存数据
-(void)clearFriendsData
{
    NSString *deleteSql = @"DELETE FROM FRIENDTABLE";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    if (queue==nil) {
        return ;
    }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}


-(void)deleteFriendFromDB:(NSString *)userId;
{
    NSString *deleteSql =[NSString stringWithFormat: @"DELETE FROM FRIENDTABLE WHERE userid=%@",userId];
        FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
        if (queue==nil) {
            return ;
        }
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:deleteSql];
        }];
}

@end
