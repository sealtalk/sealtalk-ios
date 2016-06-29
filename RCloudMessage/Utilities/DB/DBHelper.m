//
//  DBHelper.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/5/22.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "DBHelper.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import <RongIMKit/RongIMKit.h>
@implementation DBHelper

static FMDatabaseQueue *databaseQueue = nil;
//
//+(FMDatabase *) getDataBase:(NSString *)dbname
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:dbname];
//    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
//    if (![db open]) {
//        NSLog(@"Could not open %@",dbname);
//    }
//    
//    return db;
//}
+(void)closeDataBase
{
    databaseQueue = nil;
}


+(FMDatabaseQueue *) getDatabaseQueue
{
    if ([RCIMClient sharedRCIMClient].currentUserInfo==nil) {
        return nil;
    }

    if (!databaseQueue) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            NSString *dbPath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"RongIMDemoDB%@",[RCIMClient sharedRCIMClient].currentUserInfo.userId]];
            databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
            
//        });
    }
    
    return databaseQueue;
    
}

+ (BOOL) isTableOK:(NSString *)tableName withDB:(FMDatabase *)db
{
    BOOL isOK = NO;
    
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count)
        {
            isOK =  NO;
        }
        else
        {
            isOK = YES;
        }
    }
    [rs close];
    
    return isOK;
}

@end
