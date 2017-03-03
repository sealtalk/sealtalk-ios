//
//  RedpacketWebControllerManager.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/4/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RedpacketWebController : NSObject

/**
 *  零钱明细的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)changeMoneyListWebControllerWithTitleColor:(UIColor *)color;

/**
 *  常见问题的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)myRechangeQaWebControllerWithTitleColor:(UIColor *)color;

/**
 *  用户服务务协议的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)bindCardProtocolControllerWithTitleColor:(UIColor *)color;

/**
 *  个人账户资金损失保险的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)guaranteeTaipingyangProtocolWithTitleColor:(UIColor *)color;




@end
