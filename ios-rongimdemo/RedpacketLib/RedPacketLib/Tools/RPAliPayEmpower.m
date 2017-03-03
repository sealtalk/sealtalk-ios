//
//  RPAliPayEmpower.m
//  RedpacketLib
//
//  Created by 都基鹏 on 2017/2/17.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import "RPAliPayEmpower.h"
#import "UIAlertView+YZHAlert.h"
#import "RPAlipayAuth.h"
@implementation RPAliPayEmpower

+ (void)aliEmpowerSuccess:(RPAliPayEmpowerSuccessBlock)success failure:(RPAliPayEmpowerFailureBlock)failure {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"需授权绑定支付宝账户"
                                                    message:@"收到的红包会直接入账至绑定的支付宝账号。"
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确认授权", nil];
    
    [alert setRp_completionBlock:^(UIAlertView * alertView, NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            [self doAlipayAuthsuccess:success failure:failure];
        }
    }];
    
    [alert show];
}

+ (void)doAlipayAuthsuccess:(RPAliPayEmpowerSuccessBlock)success failure:(RPAliPayEmpowerFailureBlock)failure {
    static RPAlipayAuth *staticAuth = nil;
    staticAuth = [RPAlipayAuth new];
    
    [staticAuth doAlipayAuth:^(BOOL isSuccess, NSString *error) {
        staticAuth = nil;
        if (isSuccess) {
            if (success) success();
            [[[UIAlertView alloc] initWithTitle:@"提示"
                                       message:@"已成功绑定支付宝账号，以后红包收到的钱会自动入账到此支付宝账号。"
                                      delegate:nil
                             cancelButtonTitle:@"我知道了"
                             otherButtonTitles:nil] show];
            
        }else {
            if (failure) failure(error);
        }
    }];
    
}

@end
