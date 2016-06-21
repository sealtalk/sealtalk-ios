//
//  RCDPrivateSettingsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/5/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>

@interface RCDPrivateSettingsTableViewController : UITableViewController<UIActionSheetDelegate>

@property (nonatomic, strong) RCUserInfo *userInfo;

@property (nonatomic, strong) NSString *userId;

@end
