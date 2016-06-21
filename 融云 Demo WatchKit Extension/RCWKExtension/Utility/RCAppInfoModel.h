//
//  RCAppInfoModel.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/16.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@interface RCAppInfoModel : NSObject
+ (instancetype)sharedModel;
+ (RCUserInfo *)getUserInfoById:(NSString *)userId;
+ (RCGroup *)getGroupInfoById:(NSString *)groupId;
+ (BOOL)isHeadIconCached:(NSString *)targetId;
@property(strong, nonatomic) NSString *appName;
@property(strong, nonatomic) NSString *appGroups;
@property(strong, nonatomic) NSArray *contacts; // of RCUserInfo
@property(strong, nonatomic) NSArray *groups; // of RCUserInfo
@end
