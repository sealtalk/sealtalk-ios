//
//  RCDiscussGroupSettingViewController.h
//  RongIMToolkit
//  讨论组设置
//  Created by Liv on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDSettingBaseViewController.h"
#import <RongIMKit/RongIMKit.h>

typedef void (^setDiscussTitle)(NSString *discussTitle);

@interface RCDDiscussGroupSettingViewController : RCDSettingBaseViewController

//设置讨论组名称后，回传值
@property(nonatomic, copy) setDiscussTitle setDiscussTitleCompletion;

@property(nonatomic, copy) NSString *conversationTitle;

@end
