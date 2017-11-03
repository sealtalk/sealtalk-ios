//
//  RCDGroupSettingsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDBaseSettingTableViewCell.h"
#import "RCDGroupInfo.h"
#import "RCDTableViewController.h"
#import <RongIMKit/RongIMKit.h>
#import <UIKit/UIKit.h>

@interface RCDGroupSettingsTableViewController
    : RCDTableViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate,
                              UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                              RCDBaseSettingTableViewCellDelegate>

+ (instancetype)groupSettingsTableViewController;

@property(nonatomic, strong) RCDGroupInfo *Group;

@end
