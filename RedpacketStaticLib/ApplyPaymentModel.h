//
//  BankCardInfo.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/5/3.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BindCardInfo : NSObject

/**
 *  银行卡号，(数据库已经存在的CardID)
 */
@property (nonatomic, copy) NSString *cardId;

/**
 *  银行卡号
 */
@property (nonatomic, copy) NSString *cardNo;

/**
 *  银行英文缩写
 */
@property (nonatomic, copy) NSString *bankId;

/**
 *  银行名称
 */
@property (nonatomic, copy) NSString *bankName;

/**
 *  身份证号
 */
@property (nonatomic, copy) NSString *IDCard;

/**
 *  真实姓名
 */
@property (nonatomic, copy) NSString *realName;

/**
 *  电话号码
 */
@property (nonatomic, copy) NSString *telephone;

/**
 *  省份
 */
@property (nonatomic, copy) NSString *province;

/**
 *  城市
 */
@property (nonatomic, copy) NSString *city;

/**
 *  联行名称
 */
@property (nonatomic, copy) NSString *bankBranchName;

/**
 *  联行号
 */
@property (nonatomic, copy) NSString *bankBranchCode;

+ (BindCardInfo *)modelWithDic:(NSDictionary *)dic;

- (void)parseDic:(NSDictionary *)dic;

- (NSDictionary *)toDic;

@end


@interface ApplyPaymentModel : NSObject

/**
 *  账单流水号
 */
@property (nonatomic, copy) NSString *billRef;
/**
 *  支付金额
 */
@property (nonatomic, copy) NSString *amount;
/**
 *  验证码
 */
@property (nonatomic, copy) NSString *captcha;

/**
 *  银行信息
 */
@property (nonatomic, strong) BindCardInfo *cardInfo;

/**
 *  提现时的支付密码
 */
@property (nonatomic, copy) NSString *passWord;

+ (ApplyPaymentModel *)modelWithDic:(NSDictionary *)dic;

- (NSDictionary *)toDic;

@end
