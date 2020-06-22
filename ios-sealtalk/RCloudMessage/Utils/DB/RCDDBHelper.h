//
//  RCDDBHelper.h
//  SealTalk
//
//  Created by LiFei on 2019/5/29.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDDBHelper : NSObject

+ (BOOL)isDBOpened;

+ (BOOL)openDB:(NSString *)path;

+ (void)closeDB;

+ (BOOL)executeUpdate:(NSString *)sql withArgumentsInArray:(nullable NSArray *)arguments;

+ (void)executeQuery:(NSString *)sql
withArgumentsInArray:(nullable NSArray *)arguments
          syncResult:(void (^)(FMResultSet *resultSet))syncResultBlock;

+ (void)executeTransaction:(void (^)(FMDatabase *db, BOOL *rollback))transactionBlock;

+ (int)versionOfTable:(NSString *)table;

+ (BOOL)updateTable:(NSString *)table version:(int)version transaction:(BOOL (^)(FMDatabase *db))updateTransaction;

+ (BOOL)dropTable:(NSString *)table;

+ (BOOL)isColumnExist:(NSString *)columnName inTable:(NSString *)tableName;

+ (BOOL)existsTableWithName:(NSString *)tableName;

NS_ASSUME_NONNULL_END

@end
