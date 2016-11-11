//
//  RCDAddFriendViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/4/16.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <RongIMLib/RCUserInfo.h>
#import <UIKit/UIKit.h>

@interface RCDAddFriendViewController : UITableViewController

@property(nonatomic, strong) RCUserInfo *targetUserInfo;
@property(nonatomic, strong) UILabel *lblName;
@property(nonatomic, strong) UIImageView *ivAva;
@property(nonatomic, strong) UIButton *addFriendBtn;
@property(nonatomic, strong) UIButton *startChat;

@end
