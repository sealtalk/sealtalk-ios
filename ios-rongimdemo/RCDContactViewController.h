//
//  RCDContactViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableView.h"
#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>

@interface RCDContactViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate>
@property(nonatomic, strong) UISearchBar *searchFriendsBar;
@property(nonatomic, strong) RCDTableView *friendsTabelView;

@property(nonatomic, strong) NSDictionary *allFriendSectionDic;

@property(nonatomic, strong) NSArray *seletedUsers;

@property(nonatomic, strong) NSString *titleStr;

@property(nonatomic, strong) void (^selectUserList)(NSArray<RCUserInfo *> *selectedUserList);

@end
