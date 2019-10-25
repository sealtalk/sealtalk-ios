//
//  RCDGroupSettingsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"
#import <UIKit/UIKit.h>
@class RCDGroupInfo;
@interface RCDGroupSettingsTableViewController : RCDTableViewController
@property (nonatomic, strong) RCDGroupInfo *group;
@property (nonatomic, copy) void (^clearMessageHistory)();
@end
