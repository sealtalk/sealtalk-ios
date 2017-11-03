//
//  RCDEditGroupNameViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupInfo.h"
#import <UIKit/UIKit.h>

@interface RCDEditGroupNameViewController : UIViewController <UITextFieldDelegate>

/**
 *  修改群名称页面的初始化方法
 *
 *  @return 实例对象
 */
+ (instancetype)editGroupNameViewController;

/**
 *  修改群名称的textFiled
 */
@property(nonatomic, strong) UITextField *groupNameTextField;

/**
 *  用户信息
 */
@property(nonatomic, strong) RCDGroupInfo *groupInfo;

@end
