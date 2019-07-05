//
//  RCDFrienfRemarksViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/8/11.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDFriendInfo.h"
#import <UIKit/UIKit.h>

@interface RCDFriendRemarksViewController : UIViewController

@property (nonatomic, copy) void (^setRemarksSuccess)();
@property (nonatomic, strong) RCDFriendInfo *friendInfo;

@end
