//
//  DBHelper.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/5/22.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface DBHelper : NSObject

+(FMDatabaseQueue *) getDatabaseQueue;

+(void)closeDataBase;

+(BOOL) isTableOK:(NSString *)tableName withDB:(FMDatabase *)db;
@end

