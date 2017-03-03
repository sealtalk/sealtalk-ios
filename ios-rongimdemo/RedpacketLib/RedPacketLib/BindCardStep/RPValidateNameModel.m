//
//  RPValidateNameModel.m
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPValidateNameModel.h"

@implementation RPValidateNameModel

- (void)setBindingCardType:(BindingCardType )bindingCardType
{
    _bindingCardType = bindingCardType;
    
    switch (bindingCardType) {
        case BindingCardTypeSend:
        {
            self.title = @"添加银行卡";
            self.detaile = @"添加用于支付的银行借记卡";
            self.cancelNotice = @"放弃添加银行卡吗？";
        }
            break;
        case BindingCardTypeChangeQuota:
        case BindingCardTypeSetPassword:
        case BindingCardTypeWithDrawNoPass:
        {
            self.title = @"设置支付密码";
            self.detaile = @"通过银行借记卡验证身份";
            self.cancelNotice = @"放弃支付密码设置吗？";
        }
            break;
        case BindingCardTypeWithDrawNoCard:
        {
            self.title = @"添加银行卡";
            self.detaile = @"添加一张银行借记卡";
            self.cancelNotice = @"放弃添加银行卡吗？";
        }
            break;
        case BindingCardTypeAddBankCard:
        {
            self.title = @"添加银行卡";
            self.detaile = @"添加用于支付的银行借记卡";
            self.cancelNotice = @"放弃添加银行卡吗？";
        }
            break;
        case BindingCardTypeForgetPass:
        {
            self.title = @"忘记支付密码";
            self.detaile = @"请重新验证银行卡以找回密码";
            self.cancelNotice = @"放弃找回密码？";
        }
            break;
        case BindingCardTypeWithDrawNoPassAdnNoCard:
        {
            self.title = @"设置支付密码";
            self.detaile = @"添加一张银行借记卡以验证身份";
            self.cancelNotice = @"放弃支付密码设置吗？";
        }
            break;
        case BindingCardTypeChangeDeveice:
        {
            self.title = @"验证身份";
            self.detaile = @"通过银行借记卡验证身份";
            self.cancelNotice = @"放弃验证身份吗？";
        }
            break;
        default:
            break;
    }
}

@end
