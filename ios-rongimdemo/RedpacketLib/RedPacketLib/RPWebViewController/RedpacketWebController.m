//
//  RedpacketWebControllerManager.m
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/4/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketWebController.h"
#import "YZHWebViewController.h"
#import "RPWebRequestURLString.h"
#import "RPRedpacketTool.h"
#import "RPRedpacketSetting.h"


@implementation RedpacketWebController

+ (YZHWebViewController *)webViewController
{    
    return [YZHWebViewController new];
}

+ (UIViewController *)changeMoneyListWebControllerWithTitleColor:(UIColor *)color
{
    YZHWebViewController *changeController = [[YZHWebViewController alloc] init];
    changeController.url = [NSURL URLWithString:[RPWebRequestURLString rechangeMoneyListWebUrl]];
    changeController.titleLable.text = @"零钱明细";
    changeController.titleLable.textColor = color;
    changeController.subLable.textColor = color;
    return changeController;
}

+ (UIViewController *)myRechangeQaWebControllerWithTitleColor:(UIColor *)color
{
    YZHWebViewController *changeController = [[YZHWebViewController alloc] init];
    changeController.url = [NSURL URLWithString:[RPWebRequestURLString myRechangeQaWebUrl]];
    changeController.titleLable.text = @"常见问题";
    changeController.titleLable.textColor = color;
    changeController.subLable.textColor = color;
    return changeController;
}

+ (UIViewController *)bindCardProtocolControllerWithTitleColor:(UIColor *)color
{
    YZHWebViewController *changeController = [[YZHWebViewController alloc] init];
    changeController.url = [NSURL URLWithString:[RPWebRequestURLString bindCardProtocolWebUrl]];
    NSString *orgName = [RPRedpacketSetting shareInstance].redpacketOrgName;
    changeController.titleLable.text = [NSString stringWithFormat:@"%@用户服务协议", orgName];
    changeController.titleLable.textColor = color;
    changeController.subLable.textColor = color;
    return changeController;
}

+ (UIViewController *)guaranteeTaipingyangProtocolWithTitleColor:(UIColor *)color
{
    YZHWebViewController *changeController = [[YZHWebViewController alloc] init];
    changeController.url = [NSURL URLWithString:[RPWebRequestURLString guaranteeTaipingyangWeburl]];
    changeController.titleLable.text = [NSString stringWithFormat:@"%@", @"个人资金账户损失保险"];
    changeController.titleLable.textColor = color;
    changeController.subLable.textColor = color;
    return changeController;
}

@end

