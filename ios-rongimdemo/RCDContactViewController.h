//
//  RCDContactViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

@interface RCDContactViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate,
                        UISearchBarDelegate, UISearchControllerDelegate>

@property(nonatomic, strong) UISearchBar *searchFriendsBar;
@property(nonatomic, strong) UITableView *friendsTabelView;

@property(nonatomic, strong) NSDictionary *allFriendSectionDic;


@property(nonatomic, strong) NSArray *seletedUsers;

@property(nonatomic, strong) NSString *titleStr;

@property(nonatomic, strong) void (^selectUserList)(NSArray<RCUserInfo *> *selectedUserList);

@end
