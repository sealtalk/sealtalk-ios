//
//  RCDGroupSettingsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDGroupInfo.h"

@interface RCDGroupSettingsTableViewController : UITableViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) RCDGroupInfo *Group;

@property (nonatomic, strong) NSMutableArray *GroupMemberList;

@end
