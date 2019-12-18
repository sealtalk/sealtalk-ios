//
//  RCDPrivateSettingsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/5/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"
#import <UIKit/UIKit.h>

@interface RCDPrivateSettingsTableViewController : RCDTableViewController
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, copy) void (^clearMessageHistory)();
@end
