//
//  UIView+Prompting.h
//  zhibo
//
//  Created by Mr.Yang on 14-3-19.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHMBProgressHUD.h"


#define YZHPromptTypeWating    @"请稍候..."
#define YZHPromptTypeError     @"网络连接异常，请稍后再试"


@interface UIView (YZHPrompting)

//  等待提示
- (YZHMBProgressHUD *)rp_showHudWaitingView:(NSString *)prompt;

//  文字提示
- (YZHMBProgressHUD *)rp_showHudAuto:(NSString *)text;
- (YZHMBProgressHUD *)rp_showHudManaual:(NSString *)text;

//  成功失败提示
- (YZHMBProgressHUD *)rp_showHudSuccessView:(NSString *)text;
- (YZHMBProgressHUD *)rp_showHudErrorView:(NSString *)text;

//  消除视图
- (void)rp_removeHudInManaual;

@end
