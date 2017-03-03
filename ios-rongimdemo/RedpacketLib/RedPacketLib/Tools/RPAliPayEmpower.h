//
//  RPAliPayEmpower.h
//  RedpacketLib
//
//  Created by 都基鹏 on 2017/2/17.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RedpacketMessageModel.h"

typedef void(^RPAliPayEmpowerSuccessBlock)();
typedef void(^RPAliPayEmpowerFailureBlock)(NSString *errorString);

@interface RPAliPayEmpower : NSObject

//  支付宝授权弹窗
+ (void)aliEmpowerSuccess:(RPAliPayEmpowerSuccessBlock)success failure:(RPAliPayEmpowerFailureBlock)failure;

@end
