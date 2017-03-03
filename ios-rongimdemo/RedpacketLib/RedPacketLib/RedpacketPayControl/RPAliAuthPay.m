//
//  RPAliAuthPay.m
//  RedpacketLib
//
//  Created by Mr.Yang on 2016/12/19.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPAliAuthPay.h"
#import "RedpacketErrorCode.h"
#import "AlipaySDK.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketDataRequester.h"
#import "UIView+YZHPrompting.h"
#import "RPAlipayAuth.h"
#import "RPRedpacketTool.h"
#import "UIAlertView+YZHAlert.h"

/*
 返回码	含义
 9000	订单支付成功
 8000	正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
 4000	订单支付失败
 5000	重复请求
 6001	用户中途取消
 6002	网络连接出错
 6004	支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
 其它	其它支付错误
 */


#define AlipayPaySuccess    9000
#define AlipayPayUserCancel 6001
#define AlipayPayResultUnKnow 8000

@interface RPAliAuthPay ()
{
    //支付的父控制器
    __weak UIViewController *_payController;
}

/**
 *  账单流水号
 */
@property (nonatomic, copy) NSString *billRef;
@property (nonatomic, copy) PaySuccessBlock paySuccessBlock;
@property (nonatomic, copy) NSString *payMoney;

@end


@implementation RPAliAuthPay

- (void)payMoney:(NSString *)payMoney
    inController:(UIViewController *)currentController
  andFinishBlock:(PaySuccessBlock)paySuccessBlock
{
    _payController = currentController;
    self.payMoney = payMoney;
    self.paySuccessBlock = paySuccessBlock;
    
    [self requestAlipayBillRef:payMoney
                  inController:currentController];
}

//  下单
- (void)requestAlipayBillRef:(NSString *)money
                inController:(UIViewController *)viewController
{
    [viewController.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        
        [viewController.view rp_removeHudInManaual];
        [weakSelf requestAlipayView:data];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        [viewController.view rp_removeHudInManaual];
        if (code == RedpacketUnAliAuthed) {
            //  没有授权
            [weakSelf showAuthAlert];
            
        }else {
            
            [weakSelf alertCancelPayMessage:@"付款失败，该红包不会被发出" withTitle:@"付款失败"];
            
        }
        
    }];
    
    [request requestAliAuthPayInfo:money];
}

- (void)requestAlipayView:(NSDictionary *)info
{
    self.billRef = [NSString stringWithFormat:@"%@", [info objectForKey:@"BillRef"]];
    RPDebug(@"BillRef:%@", self.billRef)
    NSString *orderString = [info rp_stringForKey:@"OrderInfo"];
    NSString *urlScheme = [YZHRedpacketBridge sharedBridge].redacketURLScheme;
    
    if (urlScheme.length == 0) {
        [self alertWithMessage:@"urlScheme为空，无法调用支付宝"];
        return;
    }
    
    rpWeakSelf;
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:urlScheme callback:^(NSDictionary *resultDic) {
        
        RPDebug(@"支付宝支付回调BillRef:%@ Param:%@", weakSelf.billRef, resultDic);
        NSInteger code = [[resultDic rp_stringIntForKey:@"resultStatus"] integerValue];
        
        if (code == AlipayPaySuccess) {
            if (weakSelf.paySuccessBlock) {
                weakSelf.paySuccessBlock(weakSelf.billRef);
            }
            
        }else if (code == AlipayPayResultUnKnow) {
            
            [weakSelf validatePayBillRef:weakSelf.billRef];
        
        } else if (code == AlipayPayUserCancel) {
            [weakSelf alertCancelPayMessage:@"你已取消支付，该红包不会被发出"
                              withTitle:@"取消支付"];
        }else {
            [weakSelf alertCancelPayMessage:@"付款失败, 该红包不会被发出"
                              withTitle:@"付款失败"];
        }
        
        RPDebug(@"reslut = %@",resultDic);
    }];
}

- (void)validatePayBillRef:(NSString *)billRef
{
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        
        NSInteger status = [[data valueForKey:@"Status"] integerValue];
        if (status == 1) {
            if (weakSelf.paySuccessBlock) {
                weakSelf.paySuccessBlock(billRef);
            }
        }else {
            [weakSelf alertCancelPayMessage:@"付款失败, 该红包不会被发出"
                                  withTitle:@"付款失败"];
        }
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        [weakSelf alertCancelPayMessage:@"付款失败, 该红包不会被发出"
                          withTitle:@"付款失败"];
        
    }];
    
    [request validateBillRefPayMentInfo:billRef];
}

// 支付宝App支付的回调
- (void)alipayCallBack:(NSNotification *)notifaction
{
    RPDebug(@"红包SDK通知：\n收到支付宝支付回调：%@\n 当前的控制器：%@", notifaction, self);
    
    if (self.billRef) {
        if ([notifaction.object isKindOfClass:[NSDictionary class]]) {
            NSInteger code = [[notifaction.object valueForKey:@"resultStatus"] integerValue];
            if (code == 9000) {
                //  支付成功
                if (self.paySuccessBlock) {
                    self.paySuccessBlock(self.billRef);
                }
                
            }else if (code == AlipayPayUserCancel) {
                [self alertCancelPayMessage:@"你已取消支付，该红包不会被发出"
                                  withTitle:@"取消支付"];
            }else {
                [self alertCancelPayMessage:@"付款失败, 该红包不会被发出"
                                  withTitle:@"付款失败"];
            }
            
        }else {
            self.billRef = nil;
            [_payController.view rp_removeHudInManaual];
        }
        
    }else {

        //  收到无效Alipay通知
        
    }
}

- (void)showAuthAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"需授权绑定支付宝账户"
                                                    message:@"发红包使用绑定的支付宝账号支付。"
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确认授权", nil];
    
    rpWeakSelf;
    [alert setRp_completionBlock:^(UIAlertView * alertView, NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            [weakSelf doAlipayAuth];
        }
    
    }];
    
    [alert show];
}

//  没有授权， 去授权
- (void)doAlipayAuth
{
    static RPAlipayAuth *staticAuth = nil;
    staticAuth = [RPAlipayAuth new];
    
    rpWeakSelf;
    
    [_payController.view rp_showHudWaitingView:YZHPromptTypeWating];
    [staticAuth doAlipayAuth:^(BOOL isSuccess, NSString *error) {
        staticAuth = nil;
        [_payController.view rp_removeHudInManaual];
        
        if (isSuccess) {
            //[weakSelf requestAlipayBillRef:weakSelf.payMoney
            //                  inController:_payController];
            [weakSelf alertWithMessage:@"已成功绑定支付宝账号，以后红包收到的钱会自动入账到此支付宝账号。"];
        
        }else {
            [_payController.view rp_showHudErrorView:error];
            
        }
        
    }];
    
}

- (void)alertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    
    [alert show];
}

- (void)alertCancelPayMessage:(NSString *)message
                    withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"取消支付"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"我知道了"
                                          otherButtonTitles:nil];
    
    [alert show];
}


@end
