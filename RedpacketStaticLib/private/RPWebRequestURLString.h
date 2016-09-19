//
//  RPWebRequestURLString.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/8/15.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPWebRequestURLString : NSObject

// 零钱明细
+ (NSString *)rechangeMoneyListWebUrl;

// 零钱页 常见问题
+ (NSString *)myRechangeQaWebUrl;

// 绑卡页面 环信用户服务协议
+ (NSString *)bindCardProtocolWebUrl;

//绑卡页面 支付时才出现的页面
+ (NSString *)guaranteeTaipingyangWeburl;

@end
