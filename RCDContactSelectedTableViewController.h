//
//  RCDContactSelectedTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDContactSelectedTableViewController : UITableViewController

@property(nonatomic, strong) NSArray *keys;

@property(nonatomic, strong) NSMutableDictionary *allFriends;

@property(nonatomic, strong) NSArray *allKeys;

@property(nonatomic, strong) NSArray *seletedUsers;

@property(nonatomic, strong) NSString *titleStr;

@property(nonatomic, strong) NSMutableArray *addGroupMembers;

@property(nonatomic, strong) NSMutableArray *delGroupMembers;

@property(nonatomic, strong) NSString *groupId;

@property BOOL forCreatingGroup;

@property BOOL forCreatingDiscussionGroup;

@property(nonatomic, strong) NSMutableArray *addDiscussionGroupMembers;

@property(nonatomic, strong) NSString *discussiongroupId;

@property BOOL isAllowsMultipleSelection;

@end
