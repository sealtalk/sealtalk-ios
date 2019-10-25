//
//  RCDGroupMembersTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/4/10.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"

@interface RCDGroupMemberListController : RCDTableViewController
- (instancetype)initWithGroupId:(NSString *)groupId;
@property (nonatomic, strong) NSArray *groupMembers;

@end
