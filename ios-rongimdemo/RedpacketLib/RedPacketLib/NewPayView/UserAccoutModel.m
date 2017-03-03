//
//  UserAccoutModel.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/29.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "UserAccoutModel.h"
#import "NSDictionary+YZHExtern.h"
#import "RPRedpacketSetting.h"

#ifdef WeChatAvaliable

#import "WXApi.h"

#endif


static NSString *addCardIcon            = @"paypassView_addIcon";

static NSString *changeMoneyIcon        = @"paypassView_changeMoney";
static NSString *changeMoneyDisableIcon = @"paypassView_changeMoneyDisable";

static NSString *jdpayIcon              = @"paypassView_jdPay";
static NSString *jdpayDisableIcon       = @"payPassView_jdPay_Disable";

static NSString *wechatIcon             = @"paypassView_wechat";
static NSString *wechatDisableIcon      = @"paypassView_wechat_disable";

static NSString *aliPayIcon           = @"paypassView_alipay";
static NSString *aliPayDisableIcon    = @"payPassVIew_Alipay_disable";

@implementation QuotaModel

- (void)configWithDic:(NSDictionary *)dict
{
    self.total = [[dict rp_stringForKey:@"Total"] floatValue];
    self.remainString = [dict valueForKey:@"Remain"];
    self.remain = [[dict rp_stringForKey:@"Remain"] floatValue];
    
    self.message = [dict rp_stringForKey:@"Message"];
}

@end

@implementation YZHPayInfo

+ (instancetype)payInfoWithType:(YZHPayInfoType)payType
{
    YZHPayInfo *payInfo = [[self class] new];
    [payInfo configWithType:payType];
    
    return payInfo;
}

- (void)configWithType:(YZHPayInfoType)payType
{
    self.payType = payType;
    self.isAValiable = YES;
    switch (payType) {
        case YZHPayInfoTypeJDPay:
            self.payImage = jdpayIcon;
            break;
            
        case YZHPayInfoTypeWechat:
            self.payImage = wechatIcon;
            self.payName = @"微信支付";
            self.describe = @"无单笔限额";
            break;
            
        case YZHPayInfoTypeBindCard:
            self.payImage = addCardIcon;
            self.payName = @"添加银行卡付款";
            break;
            
        case YZHPayInfoTypeAlipay:
            self.payImage = aliPayIcon;
            self.payName = @"支付宝支付";
            break;
            
        case YZHPayInfoTypeChangeMoney:
            self.payImage = changeMoneyIcon;
            self.payName = @"我的零钱";
            self.describe = @"无单笔限额";
            break;
            
        default:
            break;
    }
}

@end

@implementation YZHBankPayInfo

- (void)configWithDic:(NSDictionary *)dict
{
    self.bankName = [dict rp_stringForKey:@"BankName"];
    self.cardSuffix = [dict rp_stringIntForKey:@"CardSuffix"];
    self.telephone = [dict rp_stringForKey:@"Telephone"];
    self.cardIndex = [[dict rp_stringIntForKey:@"CardIndex"] integerValue];
    self.cardID = [dict rp_stringIntForKey:@"CardId"];
    self.balance = [[dict rp_stringFloatForKey:@"JdQuotaBalance"] floatValue];
    self.balanceString = [dict valueForKey:@"JdQuotaBalance"];
    self.onceLimit = [[dict rp_stringFloatForKey:@"JdQuotaSingleItem"] floatValue];

    self.payName = [NSString stringWithFormat:@"%@(尾号%@)",
                    self.bankName,
                    self.cardSuffix];
    self.describe = [NSString stringWithFormat:@"单笔限额%d元，当日剩余额度%@元",
                     (int)self.onceLimit,
                     self.balanceString];
}

@end

@implementation UserAccoutModel

+ (UserAccoutModel *)userAccountModelWithPayMoney:(NSString *)payMoney
                                     andWalletDic:(NSDictionary *)dict
{
    UserAccoutModel *model = [UserAccoutModel new];
    model.payMoney = payMoney;
    [model configPayWithDic:dict];
    
    return model;
}

+ (UserAccoutModel *)userAccountModelWithRechangeMoney:(NSString *)changeMoney andWalletDic:(NSDictionary *)dict
{
    UserAccoutModel *model = [UserAccoutModel new];
    model.payMoney = changeMoney;
    [model configRechargeWithDic:dict];
    
    return model;
}

- (void)configPayWithDic:(NSDictionary *)dict
{
    [self configPayInfoQuota:dict];
    
    NSDictionary *payModels = dict[@"PayModels"];
    self.isAlipayAvaliable = [[payModels rp_stringIntForKey:@"AliPay"] boolValue];
    BOOL isJdPayAvaliable = [[payModels rp_stringForKey:@"JdPay"] boolValue];
    
#ifdef WeChatAvaliable
    
    self.isWechatAvaliable = [[payModels rp_stringForKey:@"WxPay"] boolValue];
    if (_isWechatAvaliable) {
        BOOL isInstallWechat = [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
        _isWechatAvaliable = isInstallWechat;
    }
    
#endif
    NSArray *payModeList = [dict valueForKey:@"PayModeList"];
    
    NSMutableArray *mutBanks = [NSMutableArray array];
    for (NSString *mode in [payModeList reverseObjectEnumerator]) {
        if ([mode isEqualToString:@"JdPay"]) {
            /**
             *  京东支付
             */
            if (isJdPayAvaliable) {
                NSArray *banks = [self getBankCards:dict];
                [mutBanks addObjectsFromArray:banks];
            }
            
        }else if ([mode isEqualToString:@"AliPay"]) {
            /**
             *  支付宝
             */
            CGFloat alipayMaxMoney = [RPRedpacketSetting shareInstance].alipayMaxMoney * 100;
            CGFloat payMoney = [self.payMoney floatValue] * 100;
            if (_isAlipayAvaliable) {
                YZHPayInfo *aliInfo = [YZHPayInfo payInfoWithType:YZHPayInfoTypeAlipay];
                //  支付金额小于阿里剩余额度且支付金额小于阿里单笔支付额度
                if (self.aliQuota.remain * 100 >= payMoney && alipayMaxMoney >= payMoney) {
                    aliInfo.isAValiable = YES;
                    aliInfo.payImage = aliPayIcon;
                }else {
                    aliInfo.isAValiable = NO;
                    aliInfo.payImage = aliPayDisableIcon;
                }
                
                NSInteger onceLimit = [RPRedpacketSetting shareInstance].alipayMaxMoney;
                aliInfo.describe = [NSString stringWithFormat:@"单笔限额%d元，当日剩余额度%@元",
                                                            (int)onceLimit,
                                                            self.aliQuota.remainString];
                
                [mutBanks insertObject:aliInfo atIndex:0];
            }
        }
#ifdef WeChatAvaliable
        else if ([mode isEqualToString:@"WxPay"]) {
            /**
             *  微信支付
             */
            CGFloat weChatMaxMoney = self.weChatQuota.total * 100;
            CGFloat payMoney = [self.payMoney floatValue] * 100;
            if (_isWechatAvaliable) {
                YZHPayInfo *wxInfo = [YZHPayInfo payInfoWithType:YZHPayInfoTypeWechat];
                
                if (self.weChatQuota.remain * 100 >= payMoney && weChatMaxMoney >= payMoney) {
                    
                    wxInfo.isAValiable = YES;
                    wxInfo.payImage = wechatIcon;
                    
                }else {
                    
                    wxInfo.isAValiable = NO;
                    wxInfo.payImage = wechatDisableIcon;
                }
                
                NSInteger onceLimit = self.weChatQuota.total;
                wxInfo.describe = [NSString stringWithFormat:@"单笔限额%d元，当日剩余额度%@元",
                                   (int)onceLimit,
                                   self.weChatQuota.remainString];
                
                [mutBanks insertObject:wxInfo atIndex:0];
            }
        }
#endif
    }
    
    /**
     *  零钱
     */
    YZHPayInfo *changeMoney = [YZHPayInfo payInfoWithType:YZHPayInfoTypeChangeMoney];
    self.balance = [[dict rp_stringForKey:@"Balance"] floatValue];
    changeMoney.payName = [NSString stringWithFormat:@"我的零钱 (余额¥%.2f)", self.balance];
    if (self.balance < 0.01 && self.balance != 0) {
        //self.balance 有等于0.009999999的情况
        self.balance = .01;
    }
    //  支付金额是否小于零钱限额
    //BOOL isPayMoneyUnderChangeMoneyQuota = ceil(self.changeMoneyQuota.remain * 100) >= ceil([self.payMoney floatValue] * 100);
    //isPayMoneyUnderChangeMoneyQuota &&
    //  支付金额是否小于零钱余额
    BOOL isPayMoneyUnderChangeMoneyBalance = ceil(self.balance * 100) >= ceil([self.payMoney floatValue] * 100);
    if (isPayMoneyUnderChangeMoneyBalance) {
        changeMoney.isAValiable = YES;
        changeMoney.payImage = changeMoneyIcon;
    }else {
        changeMoney.isAValiable = NO;
        changeMoney.payImage = changeMoneyDisableIcon;
    }
    
    [mutBanks insertObject:changeMoney atIndex:0];
    
    /**
     *  绑卡
     */
    YZHPayInfo *bindbank = [YZHPayInfo payInfoWithType:YZHPayInfoTypeBindCard];
    [mutBanks  addObject:bindbank];

    self.payInfos = [mutBanks copy];
}

- (void)configRechargeWithDic:(NSDictionary *)dict
{
    [self configPayInfoQuota:dict];
    NSArray *payInfos = [self getBankCards:dict];
    NSMutableArray *mutPays = [payInfos mutableCopy];
    [mutPays addObject:[YZHPayInfo payInfoWithType:YZHPayInfoTypeBindCard]];
    self.payInfos = [mutPays copy];
}

- (NSArray *)getBankCards:(NSDictionary *)dict
{
    NSMutableArray *payInfosMut = [NSMutableArray array];
    
    NSArray *banks = [dict rp_arrayForKey:@"BankCards"];
    
    for (NSDictionary *bank in banks) {
        YZHBankPayInfo *info = [YZHBankPayInfo payInfoWithType:YZHPayInfoTypeJDPay];
        [info configWithDic:bank];
        
        //  首先判断有没有超出当日限额，然后判断有没有超出单笔限额// jdpayMaxSingle??
        CGFloat jdpayMaxMoney = [RPRedpacketSetting shareInstance].jdpayMaxMoney * 100;
        CGFloat payMoney = [self.payMoney floatValue] * 100;
    
        if (info.balance < 0.01 && self.balance != 0) {
            //balance 有等于0.009999999的情况
            info.balance = .01;
        }
        
        if ((info.balance * 100 >= payMoney) && (jdpayMaxMoney >= payMoney)) {
            info.isAValiable = YES;
            info.payImage = jdpayIcon;
        }else {
            info.isAValiable = NO;
            info.payImage = jdpayDisableIcon;
        }

        [payInfosMut addObject:info];
    }
    
    return payInfosMut;
}

- (void)configPayInfoQuota:(NSDictionary *)dict
{
    self.isHasPayPass = [[dict rp_stringIntForKey:@"HasPayPwd"] boolValue];
    /**
     *  转账
     */
    NSDictionary *dayTransferDic;
    /**
     *  当日限额
     */
    NSDictionary *dayQuota;
    
    NSDictionary *withOutPassQuotaDic;
    
    /*
    if (self.isHasPayPass) {
    
        dayQuota = [dict rp_dictionaryForKey:@"SingleDayQuota"];
        dayTransferDic = [dict rp_dictionaryForKey:@"singleTransDayQuota"];
        
    }else {
        //如果没有密码，转账额度也要先用无密码的额度
        dayQuota = [dict rp_dictionaryForKey:@"NoPwdQuota"];
        dayTransferDic = dayQuota;
        
    }
     */
    
    //  不管有无密码，日限额都只有当日限额，不用无密限额
    dayTransferDic = [dict rp_dictionaryForKey:@"singleTransDayQuota"];
    dayQuota = [dict rp_dictionaryForKey:@"SingleDayQuota"];
    withOutPassQuotaDic = [dict rp_dictionaryForKey:@"NoPwdQuota"];
    
    if (withOutPassQuotaDic) {
        self.WithOutPassQuota = [QuotaModel new];
        [self.WithOutPassQuota configWithDic:withOutPassQuotaDic];
    }
    
    if (dayTransferDic) {
        self.dayTransferQuota = [QuotaModel new];
        [self.dayTransferQuota configWithDic:dayTransferDic];
    }
    
    if (dayQuota) {
        self.dayQuota = [QuotaModel new];
        [self.dayQuota configWithDic:dayQuota];
    }
    
    NSDictionary *changeMoneyDic = [dict rp_dictionaryForKey:@"Quota"];
    if (changeMoneyDic) {
        self.changeMoneyQuota = [QuotaModel new];
        [self.changeMoneyQuota configWithDic:changeMoneyDic];
    }
    
    NSDictionary *jdQuota = [dict rp_dictionaryForKey:@"JdQuota"];
    if (jdQuota) {
        self.jdQuota = [QuotaModel new];
        [self.jdQuota configWithDic:jdQuota];
    }
    
    NSDictionary *aliQuotaDic = [dict rp_dictionaryForKey:@"AlipayQuota"];
    if (aliQuotaDic) {
        self.aliQuota = [QuotaModel new];
        [self.aliQuota configWithDic:aliQuotaDic];
//        self.aliQuota.remain = 100.0;
    }
    
    NSDictionary *wechatQutotaDic = [dict rp_dictionaryForKey:@"WxPayQuota"];
    if (wechatQutotaDic) {
        self.weChatQuota = [QuotaModel new];
        [self.weChatQuota configWithDic:wechatQutotaDic];
    }
    
}

- (YZHPayInfo *)getPayInfo:(YZHPayInfoType)type
{   
    for (YZHPayInfo *payInfo in self.payInfos) {
        if (payInfo.payType == type) {
            /**
             *  如果是京东支付，返回第一张可用的银行卡
             */
            if (payInfo.payType == YZHPayInfoTypeJDPay) {
                if (payInfo.isAValiable) {
                    return payInfo;
                }
            }else {
                return payInfo;
            }
        }
    }
    
    return nil;
}

- (NSArray *)getIndexPayInfos
{
    return nil;
}

- (NSArray *)getBanks
{
    NSMutableArray *array = [NSMutableArray array];
    for (YZHBankPayInfo *info in self.payInfos) {
        if ([info isKindOfClass:[YZHBankPayInfo class]]) {
            [array addObject:info];
        }
    }
    
    return array;
}

@end
