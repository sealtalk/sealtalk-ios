//
//  SortForTime.m
//  RCloudMessage
//
//  Created by Jue on 16/7/15.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "SortForTime.h"
#import "RCDUserInfo.h"

@implementation SortForTime
- (NSMutableArray *)sortForUpdateAt:(NSMutableArray *)UserInfoList order:(NSComparisonResult)order {
    //  NSMutableArray *sortedList = [NSMutableArray new];
    //  NSMutableDictionary *tempDic = [NSMutableDictionary new];
    //  for (NSString *updateAt in updatedAtList) {
    //    NSString *str1 =
    //    [updateAt stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    //    NSString *str2 =
    //    [str1 stringByReplacingOccurrencesOfString:@"T" withString:@"/"];
    //    NSString *str3 =
    //    [str2 stringByReplacingOccurrencesOfString:@":" withString:@"/"];
    //    NSMutableString *str = [[NSMutableString alloc] initWithString:str3];
    //    NSString *point = @".";
    //    if ([str rangeOfString:point].location != NSNotFound) {
    //      NSRange rang = [updateAt rangeOfString:point];
    //      [str deleteCharactersInRange:NSMakeRange(rang.location,
    //                                               str.length - rang.location)];
    //      [sortedList addObject:str];
    //      [tempDic setObject:updateAt forKey:str];
    //    }
    //  }
    UserInfoList = (NSMutableArray *)[UserInfoList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        RCDUserInfo *user1 = (RCDUserInfo *)obj1;
        RCDUserInfo *user2 = (RCDUserInfo *)obj2;

        user1.updatedAt = [self formatTime:user1.updatedAt];
        user2.updatedAt = [self formatTime:user2.updatedAt];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd/hh/mm/ss"];
        if (obj1 == [NSNull null]) {
            obj1 = @"0000/00/00/00/00/00";
        }
        if (obj2 == [NSNull null]) {
            obj2 = @"0000/00/00/00/00/00";
        }
        NSDate *date1 = [formatter dateFromString:user1.updatedAt];
        NSDate *date2 = [formatter dateFromString:user2.updatedAt];
        NSComparisonResult result = [date1 compare:date2];
        return result == order;
    }];
    return UserInfoList;
}

- (NSString *)formatTime:(NSString *)updateAt {
    NSString *str1 = [updateAt stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"T" withString:@"/"];
    NSString *str3 = [str2 stringByReplacingOccurrencesOfString:@":" withString:@"/"];
    NSMutableString *str = [[NSMutableString alloc] initWithString:str3];
    NSString *point = @".";
    if ([str rangeOfString:point].location != NSNotFound) {
        NSRange rang = [updateAt rangeOfString:point];
        [str deleteCharactersInRange:NSMakeRange(rang.location, str.length - rang.location)];
    }
    return str;
}

@end
