//
//  RCDPrivateSettingsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/5/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"
#import <RongIMKit/RongIMKit.h>
#import <UIKit/UIKit.h>

@interface RCDPrivateSettingsTableViewController : RCDTableViewController <UIActionSheetDelegate>

@property(nonatomic, strong) NSString *userId;

+ (instancetype)privateSettingsTableViewController;

@end
