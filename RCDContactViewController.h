//
//  RCDContactViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDContactViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate,
                        UISearchBarDelegate, UISearchControllerDelegate>

@property(weak, nonatomic) IBOutlet UISearchBar *searchFriendsBar;

@property(weak, nonatomic) IBOutlet UITableView *friendsTabelView;

@property(nonatomic, strong) NSArray *seletedUsers;

@end
