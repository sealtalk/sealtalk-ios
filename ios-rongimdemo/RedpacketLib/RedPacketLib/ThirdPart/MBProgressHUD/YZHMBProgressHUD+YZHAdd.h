//
//  MBProgressHUD+Add.h
//  视频客户端
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "YZHMBProgressHUD.h"

@interface YZHMBProgressHUD (YZHAdd)
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (YZHMBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view;
@end
