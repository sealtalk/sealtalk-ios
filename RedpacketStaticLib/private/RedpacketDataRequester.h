//
//  RedpacketDataRequest.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/16.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RedpacketMessageModel.h"
#import "ApplyPaymentModel.h"


typedef void(^RedpacketDataRequestSuccessBlock)(NSDictionary *data);
typedef void(^RedpacketDataRequestFailureBlock)(NSString *error, NSInteger code);


@interface RedpacketDataRequester : NSObject

/**
 *  FIXME: 待修改为：先设置请求的接口， 然后设置回调，并发送请求
 
- (void)startWithSuccessBlock:(RedpacketDataRequestSuccessBlock)successBlock
              andFaliureBlock:(RedpacketDataRequestFailureBlock)failureBlock;
 
*/


/**
 *  请求成功后的回调通知
 *
 *  @param successBlock 成功回调
 *  @param failureBlock 失败回调
 *
 *  @return 请求对象
 */
+ (RedpacketDataRequester *)requestSuccessBlock:(RedpacketDataRequestSuccessBlock)successBlock
                                  andFaliureBlock:(RedpacketDataRequestFailureBlock)failureBlock;


/**
 *  通过环信Token的方式请求红包Token
 *
 *  @param userId  用户ID
 *  @param appKey  商户在环信处注册的APPKey
 *  @param imToken 商户在环信注册的Token
 */
- (void)requestTokenByImTokenWithUserId:(NSString *)userId
                                 appKey:(NSString *)appKey
                             andImToken:(NSString *)imToken;


/**
 *  通过容联云Token的方式请求红包Token
 *
 *  @param appId     容联云商户ID
 *  @param imUserId  容联云用户ID
 *  @param imToken   容联云Token
 *  @param timestamp 时间戳
 */
- (void)requestTokenByRongLianTokenWithAppId:(NSString *)appId
                                    imUserId:(NSString *)imUserId
                                     imToken:(NSString *)imToken
                                andTimestamp:(NSString *)timestamp;

/**
 *  通过签名的方式请求红包Token
 *
 *  @param sign      签名
 *  @param partner   商户名称
 *  @param userId    用户ID
 *  @param timeStamp 时间戳
 */
- (void)requestTokenBySignWithSign:(NSString *)sign
                           partner:(NSString *)partner
                            userId:(NSString *)userId
                      andTimestamp:(NSString *)timestamp;

/**
 *  我的红包收入历史
 *
 *  @param offset 红包页面的偏移量（假设每页10条，第一页10条， 第二就传10， 第三页就传20）
 */
- (void)requestInComeMoneyDetailOffset:(NSInteger)offset;

/**
 *  我的红包发送历史
 *
 *  @param offset 红包页面的偏移量（假设每页10条，第一页10条， 第二就传10， 第三页就传20）
 */
- (void)requestInComeMoneySenderDetailOffset:(NSInteger)offset;

/**
 *  红包的相关设置
 */
- (void)requestRedpacketSetting;

/**
 *  红包相关详情
 *
 *  @param redpacketId 红包详情ID
 */
- (void)requestRedpacketDetail:(NSString *)redpacketId;
/**
 *  广告红包相关详情
 *
 *  @param redpacketId 红包详情ID
 */
- (void)requestADRedpacketDetail:(NSString *)redpacketId;

/**
 *  抢红包结果
 *
 *  @param model 红包数据模型
 */
- (void)requestGrabRedpacketResult:(RedpacketMessageModel *)model;

/**
 *  请求红包ID
 */
- (void)requestRedpacketID;

/**
 *  请求零钱详情
 */
- (void)requestLQDetail;

/**
 *  发送红包
 *
 *  @param model 红包Model，支付密码
 */
- (void)sendRedpacketByModel:(RedpacketMessageModel *)model
                  andPayPass:(NSString *)payPass
                  orTradeNum:(NSString *)tradeNum;

#pragma mark -
#pragma mark BindCardRelegative

/**
 *  申请支付流程 -- 银行信息校验并发送验证码
 *
 *  @param model 支付相关数据
 */
- (void)applyForRedpacketPaymentWithApplyPayment:(ApplyPaymentModel *)model;

/**
 *  申请支付流程 --  验证码校验
 *
 *  @param model 支付相关数据
 */
- (void)confirmPaymentWithApplyPayment:(ApplyPaymentModel *)model;

/**
 *   提现绑卡或者设置交易密码流程 -- 银行信息校验并发送验证码
 *
 *  @param model 银行信息
 */
- (void)bindCardInTradeOrWithDraw:(ApplyPaymentModel *)model;

/**
 *  提现绑卡或者设置交易密码流程 -- 验证码校验
 *
 *  @param model 银行信息和验证码
 */
- (void)bindCardVerifyInTradeOrWithDraw:(ApplyPaymentModel *)model;

/**
 *  我的银行卡列表
 */
- (void)getHongbaoPaymentCardsList;

/**
 *  解绑某张银行卡
 */
- (void)removeBankCardWith:(NSString *)cardId;

/**
 * 重置支付密码
 */
- (void)resetPayPasswordWith:(NSString *)passWord with:(NSString *)captcha;

/**
 * 查看银行卡BIN信息
 */
- (void)getCardBInInfoWith:(NSString *)cardNo;


#pragma mark -

/**
 *  设备变更请求短信验证码
 */
- (void)deviceChangedSMSRequest;

/**
 *  设备变更验证短信验证码
 */
- (void)deviceChangedSMSVerify:(NSString *)smsCode
                      andBillRef:(NSString *)billRef;

/**
 * 查看用户余额
 */
- (void)getPaymentMoney;

/**
 * 查看用户余额
 */
- (void)getPaymentCardInfo;

/**
 * 获取银行卡省份信息
 */
- (void)getBankCardProv;

/**
 * 根据省份查看城市信息
 */
- (void)getBankCardCityWith:(NSString *)pno;

/**
 * 根据城市信息 和 银行信息确定支行
 */
- (void)getBranchBancWith:(NSString *)cNo with:(NSString *)bankNo with:(NSString *)bankName;

/**
 * 完善卡信息
 */
- (void)updateCardInfoWith:(ApplyPaymentModel *)model;

/**
 * 提现到银行卡
 */
- (void)withDrawPaymentWith:(ApplyPaymentModel *)model;

/**
 *  上传身份证
 */
- (void)uploadUserIDPhoto:(UIImage *)image1 andImageOtherSide:(UIImage *)image2;

/**
 *  查询用户实名状态
 */
- (void)fetchUserValidateState;

/**
 *  数据统计
 */
- (void)analysisUserDataWithViewUrl:(NSString *)viewUrl;

#pragma mark -

- (void)requestAlipayInfo:(NSString *)money;


@end
