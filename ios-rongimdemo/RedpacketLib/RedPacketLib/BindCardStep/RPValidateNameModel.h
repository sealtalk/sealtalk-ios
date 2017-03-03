//
//  RPValidateNameModel.h
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,  BindingCardType)
{
    BindingCardTypeSend           = 9001,   //发送红包绑定银行卡           - 绑卡支付→四要素页面_确定
    BindingCardTypeChangeQuota    = 9002,   //零钱超限额，未绑定银行卡      - 验证绑卡→设置支付密码页面
    BindingCardTypeWithDrawNoCard = 9003,   //提现未绑定银行卡但是有密码    - 验证绑卡→短信验证码页面
    BindingCardTypeWithDrawNoPass = 9004,   //提现未设置支付密码           - 验证绑卡→设置支付密码页面
    BindingCardTypeAddBankCard    = 9005,   //绑卡验证                   - 验证绑卡→短信验证码页面
    BindingCardTypeSetPassword    = 9006,    //设置支付密码                - 验证绑卡→设置支付密码页面
    BindingCardTypeWithDrawNoPassAdnNoCard,  //提现时无卡无密码             - 验证绑卡→设置支付密码页面
    BindingCardTypeChangeDeveice,            //切换设备并且有密码无卡        -验证绑卡→四要素页面_确定
    BindingCardTypeForgetPass                //发送红包 忘记支付密码         - 验证绑卡→设置支付密码页面
};

@interface RPValidateNameModel : NSObject

@property(nonatomic, assign) BindingCardType bindingCardType;

@property(nonatomic, copy) NSString *title;

@property(nonatomic, copy) NSString *detaile;

@property(nonatomic, copy) NSString *cancelNotice;

@end
