//
//  UserAccoutModel.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/29.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface QuotaModel : NSObject
/**
 *  剩余限额
 */
@property (nonatomic, assign) CGFloat remain;

//  剩余额度字符串
@property (nonatomic, copy) NSString *remainString;
/**
 *  总限额
 */
@property (nonatomic, assign) CGFloat total;
/**
 *  提示信息 (如果限额不够了，则提示用户此信息)
 */
@property (nonatomic, copy) NSString *message;

- (void)configWithDic:(NSDictionary *)dict;

@end

typedef NS_ENUM(NSInteger, YZHPayInfoType) {
    YZHPayInfoTypeChangeMoney,
    YZHPayInfoTypeWechat,
    YZHPayInfoTypeAlipay,
    YZHPayInfoTypeJDPay,
    YZHPayInfoTypeBindCard
};

@interface YZHPayInfo : NSObject

@property (nonatomic, assign) YZHPayInfoType payType;
@property (nonatomic, copy) NSString *payName;
@property (nonatomic, copy) NSString *payImage;
@property (nonatomic, copy) NSString *describe;
@property (nonatomic, assign) BOOL isAValiable;

+ (instancetype)payInfoWithType:(YZHPayInfoType)payType;

@end

@interface YZHBankPayInfo : YZHPayInfo

@property (nonatomic, copy) NSString *bankName;
@property (nonatomic, copy) NSString *cardSuffix;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, assign) NSInteger cardIndex;
@property (nonatomic, copy) NSString *cardID;
@property (nonatomic, assign) CGFloat onceLimit;
@property (nonatomic, assign) CGFloat balance;
@property (nonatomic, copy) NSString *balanceString;

- (void)configWithDic:(NSDictionary *)dict;

@end


@interface UserAccoutModel : NSObject

@property (nonatomic, copy) NSString *payMoney;
@property (nonatomic, assign) BOOL isHasPayPass;
@property (nonatomic, assign) BOOL isAlipayAvaliable;
@property (nonatomic, assign) BOOL isWechatAvaliable;
@property (nonatomic, assign) CGFloat balance;
@property (nonatomic, strong) NSArray <YZHPayInfo *> *payInfos;

/**
 *  当日限额
 */
@property (nonatomic, strong) QuotaModel *dayQuota;

/** 零钱限额 */
@property (nonatomic, strong) QuotaModel *changeMoneyQuota;

/** 零钱无密码限额 */
@property (nonatomic, strong) QuotaModel *WithOutPassQuota;

/**
 *  当日转账限额
 */
@property (nonatomic, strong) QuotaModel *dayTransferQuota;

/**
 *  京东支付限额
 */
@property (nonatomic, strong) QuotaModel *jdQuota;
/**
 *  支付宝支付限额
 */
@property (nonatomic, strong) QuotaModel *aliQuota;
/**
 *  微信支付限额
 */
@property (nonatomic, strong) QuotaModel *weChatQuota;


/**
 *  发红包页面
 *
 *  @param payMoney 支付的金额
 *  @param dict wallet
 *
 *  @return 返回支付列表数据
 */
+ (UserAccoutModel *)userAccountModelWithPayMoney:(NSString *)payMoney
                                     andWalletDic:(NSDictionary *)dict;

/**
 *  发红包页面
 *
 *  @param payMoney 支付的金额
 *  @param dict wallet
 *
 *  @return 返回支付列表数据
 */
+ (UserAccoutModel *)userAccountModelWithRechangeMoney:(NSString *)changeMoney
                                          andWalletDic:(NSDictionary *)dict;

/**
 *  首页上的配置选项
 *
 *  @return 支付方式数组
 */
- (NSArray *)getIndexPayInfos;

- (YZHPayInfo *)getPayInfo:(YZHPayInfoType)type;

- (NSArray *)getBanks;

@end
