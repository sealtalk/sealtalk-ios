//
//  AddAppKeyViewController.h
//  RCloudMessage
//
//  Created by litao on 15/5/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

//本文件为了切换appkey测试用的，请应用开发者忽略关于本文件的信息。
#import "AppkeyModel.h"
#import <UIKit/UIKit.h>
@interface AddAppKeyViewController : UIViewController
@property(nonatomic, strong) void (^result)(AppkeyModel *addedKey);
@end
