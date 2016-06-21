//
//  SelectAppKeyViewController.h
//  RCloudMessage
//
//  Created by litao on 15/5/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

//本文件为了切换appkey测试用的，请应用开发者忽略关于本文件的信息。
#import <UIKit/UIKit.h>
#import "AppkeyModel.h"

@interface SelectAppKeyViewController : UITableViewController
@property (nonatomic, strong)void (^result)(AppkeyModel *selectedModel);
@end
