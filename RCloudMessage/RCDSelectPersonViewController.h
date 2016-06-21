//
//  RCDSelectPersonViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/3/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAddressBookViewController.h"
@class RCDUserInfo;


@interface RCDSelectPersonViewController : RCDAddressBookViewController<UIActionSheetDelegate>

typedef void(^clickDone)(RCDSelectPersonViewController *selectPersonViewController, NSArray *seletedUsers);

@property (nonatomic,copy) clickDone clickDoneCompletion;


@end
