//
//  RCDContactSelectedTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
#import <RongIMLib/RongIMLib.h>

typedef NS_ENUM(NSUInteger, RCDContactSelectedGroupOptionType) {
    RCDContactSelectedGroupOptionTypeCreate = 0,
    RCDContactSelectedGroupOptionTypeAdd,
    RCDContactSelectedGroupOptionTypeDelete,
};
@class RCDFriendInfo;
@interface RCDContactSelectedTableViewController : RCDViewController

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) NSMutableArray *orignalGroupMembers;

@property (nonatomic, assign) RCDContactSelectedGroupOptionType groupOptionType;

- (instancetype)initWithTitle:(NSString *)title isAllowsMultipleSelection:(BOOL)isAllowsMultipleSelection;

@end
