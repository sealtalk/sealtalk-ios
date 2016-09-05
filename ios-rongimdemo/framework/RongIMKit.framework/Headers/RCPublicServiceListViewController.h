//
//  RCPublicServiceListViewController.h
//  RongIMKit
//
//  Created by litao on 15/4/20.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 已关注公众服务账号列表的展示ViewController
 */
@interface RCPublicServiceListViewController : UITableViewController

@property(nonatomic, strong) NSMutableDictionary *allFriends;

@property(nonatomic, strong) NSArray *allKeys;

@end
