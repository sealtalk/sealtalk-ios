//
//  RCDAddressBookViewController.h
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RCSelectPersonViewController.h"

@interface RCDAddressBookViewController : UITableViewController

+ (instancetype)addressBookViewController;

@property(nonatomic, strong) NSArray *keys;

@property(nonatomic, strong) NSMutableDictionary *allFriends;

@property(nonatomic, strong) NSArray *allKeys;

@property(nonatomic, strong) NSArray *seletedUsers;

@property(nonatomic, assign) BOOL hideSectionHeader;

@property(nonatomic, assign) BOOL needSyncFriendList;
@end
