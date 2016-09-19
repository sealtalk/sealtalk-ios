//
//  RPRedpacketGlobalSetting.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/7/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^RedpacketSuccessBlock)(void);

@interface RPRedpacketSetting : NSObject

+ (RPRedpacketSetting *)shareInstance;

/**
 *  刷新配置数据，如果距离上次请求不足2小时，则不请求，并且也不回调。
 *
 *  @param success 成功之后的回调
 */
+ (void)asyncRequestRedpacketSettings:(RedpacketSuccessBlock)success;

/**
 *  立即刷新配置数据
 *
 *  @param success 成功后的回调
 */
+ (void)asyncRequestRedpacketsettingsIfNeed:(RedpacketSuccessBlock)success;

/**
 *  红包SDK客户名称
 */
@property (nonatomic, copy) NSString *redpacketOrgName;

/**
 *  用户是否设置了加密密码
 */
@property (nonatomic, assign)   BOOL isSetPassWordSha256;

/**
 *  单个红包最大金额
 */
@property (nonatomic, assign)   CGFloat singlePayLimit;

/**
 *  单个红包最小金额
 */
@property (nonatomic, assign)   CGFloat redpacketMinMoney;

/**
 *  单笔提现最大金额
 */
@property (nonatomic, assign)   CGFloat withDrawMaxMoney;

/**
 *  单笔提现最小金额
 */
@property (nonatomic, assign)   CGFloat withDrawMinMoney;

/**
 *  单笔提现日限额
 */
@property (nonatomic, assign)   CGFloat withDrawDayMoney;

/**
 *  京东单笔最大上限
 */
@property (nonatomic, assign)   CGFloat jdpayMaxMoney;

/**
 *  京东支付单日最大上限
 */
@property (nonatomic, assign)   CGFloat jdpayDayMoney;

/**
 *  支付宝单笔最大上限
 */
@property (nonatomic, assign)   CGFloat alipayMaxMoney;

/**
 *  支付宝单日最大上限
 */
@property (nonatomic, assign)   CGFloat alipayDayMoney;

/**
 *  红包最大个数
 */
@property (nonatomic, assign)   NSInteger maxRedpacketCount;

/**
 *  是否可提现
 */
@property (nonatomic, assign)   BOOL isWithDraw;

/**
 *  红包背景图
 */
@property (nonatomic, copy) NSString *redpacketBackImageURL;

/**
 *  红包祝福语
 */
@property (nonatomic, strong)   NSArray *redpacketGreetings;

/**
 *  红包保险服务协议用语
 */
@property (nonatomic, copy) NSString *insuranceDes;

/**
 *  切换用户的时候需要reset一次
 */
- (void)resetSettings;

@end
