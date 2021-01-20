//
//  RCDEditGroupNameViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
@class RCDGroupInfo;
@interface RCDEditGroupNameViewController : RCDViewController <UITextFieldDelegate>
/**
 *  用户信息
 */
@property (nonatomic, strong) RCDGroupInfo *groupInfo;

@end
