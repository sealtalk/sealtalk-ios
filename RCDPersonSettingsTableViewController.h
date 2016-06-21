//
//  RCDPersonSettingsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

@interface RCDPersonSettingsTableViewController : UITableViewController<UIActionSheetDelegate>

@property (nonatomic, strong) NSString *targetId;

@property (nonatomic, strong) RCUserInfo *user;

@end
