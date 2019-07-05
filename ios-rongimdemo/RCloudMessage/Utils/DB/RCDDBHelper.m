//
//  RCDDBHelper.m
//  SealTalk
//
//  Created by LiFei on 2019/5/29.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDDBHelper.h"

static FMDatabaseQueue *dbQueue;

@implementation RCDDBHelper

+ (BOOL)openDB:(NSString *)path {
    [self closeDB];
    if (path.length > 0) {
        dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    if (dbQueue) {
        [self configVersion];
    }
    return (dbQueue != nil);
}

+ (void)closeDB {
    if (dbQueue) {
        [dbQueue close];
    }
    dbQueue = nil;
}

+ (BOOL)isDBOpened {
    return dbQueue != nil;
}

+ (BOOL)executeUpdate:(NSString *)sql withArgumentsInArray:(NSArray *)arguments {
    __block BOOL result = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql withArgumentsInArray:arguments];
    }];
    return result;
}

+ (void)executeQuery:(NSString *)sql
withArgumentsInArray:(NSArray *)arguments
          syncResult:(void (^)(FMResultSet *resultSet))syncResultBlock {
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql withArgumentsInArray:arguments];
        syncResultBlock(resultSet);
        [resultSet close];
    }];
}

+ (void)executeTransaction:(void (^)(FMDatabase *db, BOOL *rollback))transactionBlock {
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (transactionBlock) {
            transactionBlock(db, rollback);
        }
    }];
}

+ (int)versionOfTable:(NSString *)table {
    __block int version = 0;
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT version FROM table_version WHERE table_name = ?", table];
        if ([rs next]) {
            version = [rs intForColumn:@"version"];
        }
        [rs close];
    }];
    return version;
}

+ (BOOL)updateTable:(NSString *)table
            version:(int)version
        transaction:(BOOL (^)(FMDatabase *db))updateTransaction {
    __block BOOL result = NO;
    [self executeTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = updateTransaction(db);
        if (result) {
            result = [db executeUpdate:@"REPLACE INTO table_version (table_name, version) VALUES (?, ?)", table, @(version)];
        }
        *rollback = !result;
    }];
    return result;
}

+ (BOOL)configVersion {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS table_version ("
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "table_name TEXT NOT NULL UNIQUE,"   //表名
    "version INTEGER CHECK(version > 0)" //版本，必须大于0
    ")";
    return [self executeUpdate:sql withArgumentsInArray:nil];
}

+ (BOOL)dropTable:(NSString *)table {
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", table];
    return [self executeUpdate:sql withArgumentsInArray:nil];
}

+ (BOOL)existsTableWithName:(NSString *)tableName{
    __block BOOL exists = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type = 'table' and name = %@",tableName];
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            NSInteger count = [result intForColumn:@"count"];
            if (count == 0 ) {
                exists = NO;
            } else {
                exists = YES;
            }
            [result close];
            break;
        }
    }];
    return exists;
}
+ (BOOL)isColumnExist:(NSString *)columnName inTable:(NSString *)tableName {
    __block BOOL isExist = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *columnQurerySql = [NSString stringWithFormat:@"SELECT %@ from %@", columnName, tableName];
        FMResultSet *rs = [db executeQuery:columnQurerySql];
        if ([rs next]) {
            isExist = YES;
        } else {
            isExist = NO;
        }
        [rs close];
    }];
    return isExist;
}

@end
