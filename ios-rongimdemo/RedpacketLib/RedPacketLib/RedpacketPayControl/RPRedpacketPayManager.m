
//
//  RPRedpacketPayControl.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/8/4.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketPayManager.h"
#import "UserAccoutModel.h"
#import "RedpacketOpenConst.h"
#import "RPTelphoneValidateView.h"
#import "ApplyPaymentModel.h"
#import "RPValidateNameViewController.h"
#import "ValidateUserIDController.h"
#import "YZTransparent.h"
#import "UIView+YZHAnimation.h"
#import "UIView+YZHPrompting.h"
#import "UIAlertView+YZHAlert.h"
#import "NSBundle+RedpacketBundle.h"
#import "RedpacketMessageModel.h"
#import "RPRedpacketSetting.h"
#import "RPRedpacketTool.h"
#import "AlipaySDK.h"
#import "RPRedpacketDeviceChangeControl.h"
#import "RedpacketErrorCode.h"

#ifdef WeChatAvaliable

#import "WXApi.h"

#endif


#define IsAlipayLastpayKey      @"IsAlipayLastpayKey"
#define IsWechatpayLastPayKey   @"IsWechatpayLastPayKey"


#define RPPayController _payController
#define RPPayView   _payController.view
#define RPWeakPayView __weak UIView* weakPayView = _payController.view


static RPRedpacketPayManager *__manager = nil;

/**
 *  !!!!: 尽量不要用全局变量！
 */
@interface RPRedpacketPayManager () <RPValidatedeDelegate>
{
    @public
    NSString *_payMoney;
    
    //支付的父控制器
    __weak UIViewController *_payController;
    
    // 付款类型
    RedpacketPayUseType _payType;

}

@property (nonatomic, strong) UserAccoutModel          *accountModel;
@property (nonatomic, copy  ) RedpacketPaySuccessBlock paySuccessBlock;

/**
 *  解决支付宝支付菊花无法消失的问题
 */
@property (nonatomic, weak) UIView *promptView;

/**
 *  上次支付是否是支付宝
 */
@property (nonatomic, assign) BOOL isAlipayLastpay;

/**
 *  上次支付是否是微信支付
 */
@property (nonatomic, assign) BOOL isWechatpayLastpay;

/**
 *  流水号
 */
@property (nonatomic, copy) NSString *billRef;

/**
 *  支付相关信息
 */
@property (nonatomic, strong) ApplyPaymentModel *paymentModel;


@property (nonatomic, copy) NSString *payMoney;


@end


@implementation RPRedpacketPayManager

- (void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    RPDebug(@"~~dealloc:%@", NSStringFromClass([self class]));
    
    [self removeAllViews];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (RPRedpacketPayManager *)currentManager
{
    if (!__manager) {
        __manager = [RPRedpacketPayManager new];
    }

    return __manager;
}

+ (void)releasePayManager
{
    if (__manager) {
        [__manager removeAllViews];
    }
    
    __manager = nil;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _isAlipayLastpay = [[[NSUserDefaults standardUserDefaults] valueForKey:IsAlipayLastpayKey] boolValue];
        _isWechatpayLastpay = [[[NSUserDefaults standardUserDefaults] valueForKey:IsWechatpayLastPayKey] boolValue];
        
        [self addRedpacketNotifaction];
    }
    
    return self;
}

- (void)payMoney:(NSString *)money inController:(UIViewController *__weak)controller
                           withRedpacketPayType:(RedpacketPayUseType)payType
                                    andPayBlock:(RedpacketPaySuccessBlock)payBlock
{
    _payMoney = money;
    _payController = controller;
    _payType = payType;
    
    if (_payType == RedpacketPayUseTypeChange) {
        [self addKeyboardNotifaction];
    }
    
    self.paySuccessBlock = payBlock;
    
    [self requestUserWallet];
}

- (void)reRequestUserWallet
{
    [self requestUserWallet];
}

- (void)requestUserWallet
{
    [RPPayView rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RPWeakPayView;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        [weakPayView rp_removeHudInManaual];
        [weakSelf showNewPayViewWithDic:dict];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        if (code == NSIntegerMax) {
            [weakPayView rp_removeHudInManaual];
            [weakPayView rp_showHudErrorView:error];
            
        }else if (code == 4004){//需要将数字改成type类型
            [weakPayView rp_removeHudInManaual];
            [weakSelf alertBindCardAndSetPayPass];
            
        }else {
            [weakPayView rp_removeHudInManaual];
            [weakSelf alertWithMessage:error];
        }
        
    }];
    
    [request requestLQDetail];
}

- (NewPayView *)getNewPayView
{
    if (_payType == RedpacketPayUseTypeChange) {
        
        //  充值
       return [[NewPayView alloc] initWithRecharge];
        
    }else if (_payType == RedpacketPayUseTypeTransfer) {
        
        return [[NewPayView alloc] initWithTransfer];
        
    }else {
        
        return [NewPayView new];
        
    }
}

- (NewPaySelectionView *)getNewPaySelectionView
{
    if (_payType == RedpacketPayUseTypeChange) {
        
        return [[NewPaySelectionView alloc] initWithRecharge];
        
    }else if (_payType == RedpacketPayUseTypeTransfer) {
    
        return [[NewPaySelectionView alloc] initWithTransfer];
        
    }else {
        
        return [NewPaySelectionView new];
        
    }
}

- (UserAccoutModel *)getUserAccountModel:(NSDictionary *)dict
{
    if (_payType == RedpacketPayUseTypeChange) {
    
        return [UserAccoutModel userAccountModelWithRechangeMoney:_payMoney andWalletDic:dict];
        
    }else {
    
        return [UserAccoutModel userAccountModelWithPayMoney:_payMoney andWalletDic:dict];
        
    }
}

- (YZHBankPayInfo *)payInfoWithPaymentModel:(ApplyPaymentModel *)model
{
    YZHBankPayInfo *info = [YZHBankPayInfo payInfoWithType:YZHPayInfoTypeJDPay];
    info.bankName = _paymentModel.cardInfo.bankName;
    NSString *cardNo = _paymentModel.cardInfo.cardNo;
    cardNo = [cardNo substringWithRange:NSMakeRange(cardNo.length - 4, 4)];
    info.cardSuffix = cardNo;
    
    NSString *tel = _paymentModel.cardInfo.telephone;
    NSString *replace = [tel substringWithRange:NSMakeRange(3, 4)];
    tel = [tel stringByReplacingOccurrencesOfString:replace withString:@"****"];
    
    info.telephone = tel;
    
    RPRedpacketSetting *setting = [RPRedpacketSetting shareInstance];
    info.onceLimit = setting.jdpayMaxMoney;
    info.balance = setting.jdpayDayMoney;
    
    info.isAValiable = YES;
    
    if (info.bankName.length == 0) {
        info.bankName = @"";
    }
    info.payName = [NSString stringWithFormat:@"%@(尾号%@)",
                    info.bankName,
                    info.cardSuffix];
    info.describe = [NSString stringWithFormat:@"单笔限额%d元，当日剩余额度%.2f元",
                     (int)info.onceLimit,
                     info.balance];
    
    return info;
}

- (QuotaModel *)currentPayQuotaModel
{
    if (_payType == RedpacketPayUseTypeTransfer) {
        return self.accountModel.dayTransferQuota;
    }
    
    return _accountModel.dayQuota;
}

#pragma mark -  payView
- (void)showNewPayViewWithDic:(NSDictionary *)dict
{
    [RPPayView endEditing:YES];
    
    if (_payTypeView) {
        //  绑卡回来之后重新弹出支付对话框
        [self removeAllViews];
    }
    
    NewPayView *payview = [self getNewPayView];
    
    CGFloat affordMoney = [_payMoney floatValue];
    
    UserAccoutModel *model = [self getUserAccountModel:dict];
    _accountModel = model;
    
    //  是从绑卡支付过来的
    if (_paymentModel && _paymentModel.cardInfo.cardNo.length > 0) {
        //  如果有绑卡信息, 要把相关的绑卡信息放到 BankInfo里边
        NSMutableArray *payInfos = [NSMutableArray arrayWithArray:model.payInfos];
        YZHBankPayInfo *info = [self payInfoWithPaymentModel:_paymentModel];
        
        for (YZHBankPayInfo * bankInfo in [model getBanks]) {
            if ([bankInfo.cardSuffix isEqualToString:info.cardSuffix]) {
                [payInfos removeObject:bankInfo];
                info = bankInfo;
                break;
            }
        }
        
        for (YZHPayInfo *payInfo in payInfos) {
            if (payInfo.payType == YZHPayInfoTypeJDPay) {
                NSInteger index = [payInfos indexOfObject:payInfo];
                [payInfos insertObject:info atIndex:index];
                break;
            }
        }
        
        model.payInfos = [payInfos copy];
        
        //  直接通过
        payview.payType = RDPayTypeWithValidateCode;
        payview.payInfo = info;
        [payview timerRun];
        
    }else {
        
        BOOL isAlipayAvaliable = [self.accountModel getPayInfo:YZHPayInfoTypeAlipay].isAValiable;
        BOOL isWechatPayAvaliable = [self.accountModel getPayInfo:YZHPayInfoTypeWechat].isAValiable;
        
        /**
         *  如果是转账的话，得用转账的日限额
         */
        QuotaModel *currentPayQuotaModel = [self currentPayQuotaModel];
        
        if (currentPayQuotaModel.remain >= affordMoney) {
            // 没有超日限额
            
            if (model.balance >= affordMoney) {
                // 零钱足够
                if (model.isHasPayPass) {
                    payview.payType = RDPayTypeWithPass;
                    
                }else {
                    
                    //  判断支付额度有没有超过无密限额
                    if (affordMoney > model.WithOutPassQuota.remain) {
                        
                        payview.payType = RDPayTypeExceedNoPass;
                        
                    }else {
                        payview.payType = RDPayTypeWithNoPass;
                    }
                }

            }else {
                // 零钱不够, 上次付款是支付宝支付
                if (_isAlipayLastpay && model.isAlipayAvaliable && isAlipayAvaliable){
                    /**
                     *  上次支付是阿里支付且阿里支付可用，且阿里支付限额足够
                     */
                    payview.payType = RDPayTypeAlipay;
                    
                }else if (_isWechatpayLastpay && model.isWechatAvaliable && isWechatPayAvaliable) {
                    
                    payview.payType = RDPayTypeWeChatPay;
                
                } else {
                    
                    if ([model getBanks].count) {
                        BOOL isAvaliable = NO;
                        YZHBankPayInfo *bankInfo;
                        for (YZHPayInfo *info in model.payInfos) {
                            if ([info isKindOfClass:[YZHBankPayInfo class]] && info.isAValiable) {
                                bankInfo = (YZHBankPayInfo *)info;
                                isAvaliable = YES;
                                break;
                            }
                        }
                        
                        if (isAvaliable) {
                            //  京东限额足够
                            payview.payType = RDPayTypeWithValidateCode;
                            payview.payInfo = bankInfo;
                            [self requestJDPaySMSAtCard:bankInfo];
                            
                        }else {
                            //  支付宝可用
                            if (model.isAlipayAvaliable && isAlipayAvaliable) {
                                payview.payType = RDPayTypeAlipay;
                                
                            }else if (model.isWechatAvaliable && isWechatPayAvaliable) {
                                payview.payType = RDPayTypeWeChatPay;
                                
                            }else {
                                //  最大可发金额
                                [self alertOverPayMoneyInPayInfos];
                                return;
                            }
                        }
                    }else {
                        if (model.isAlipayAvaliable && isAlipayAvaliable) {
                            payview.payType = RDPayTypeAlipay;
                        }else if (model.isWechatAvaliable && isWechatPayAvaliable) {
                            payview.payType = RDPayTypeWeChatPay;
                            
                        } else {
                            //  未绑卡
                            [RPPayView endEditing:YES];
                            
                            if (model.balance == 0.0f) {
                                payview.payType = RDPayTypeWithNoMoneyAndNoCard;
                                
                            }else {
                                payview.payType = RDPayTypeMoneNotEnoughAndNoCard;
                                
                            }
                        }
                    }
                }
            }
            
        }else {
            //  超过限额
            if (model.isHasPayPass) {
                //  单日最大可发金额
                [self alertMaxPayMoneyInDay];
                return;
                
            }else {
                if (model.isAlipayAvaliable && isAlipayAvaliable) {
                    
                    payview.payType = RDPayTypeAlipay;
                    
                }else if (model.isWechatAvaliable && isWechatPayAvaliable) {
                    
                    payview.payType = RDPayTypeWeChatPay;
                    
                }else {
                    //  提示绑卡
                    [self alertBindCardAndSetPayPass];
                    return;
                }
            }
        }
    }
    
    [payview configWithModel:model];
    
    rpWeakSelf;
    [payview setSelectionBlock:^(YZHPayInfo *payInfo) {
        YZHPayInfoType type = payInfo.payType;
        if (type == YZHPayInfoTypeBindCard){
            // 绑卡并支付
            [weakSelf removeAllViews];
            [weakSelf showValidateNameViewController:BindingCardTypeSend
                                         andPayMoney:weakSelf.payMoney];
            
        }else{
            [weakSelf showPaySelectionView];
        }
        
    }];
    
    /**
     *  界面上的用户行为回调
     */
    //__weak NewPayView *weakPayView = payview;
    [payview setButtonActionBlock:^(NewPayView *payInfoView, RDButtonActionType type, NSString *pass){
        
        if (type == RDButtonActionTypeClose) {
            [weakSelf removeAllViews];
            [RPRedpacketPayManager releasePayManager];
            
        }else if (type == RDButtonActionTypePay) {
            if (payInfoView.payType == RDPayTypeAlipay) {
                //  MARK:支付宝支付
                [weakSelf sendAlipayInfoRequest];
                
            }
#ifdef WeChatAvaliable
            else if (payInfoView.payType == RDPayTypeWeChatPay) {
                //  MARK:微信支付
                [weakSelf sendWechatInfoRequest];
                
            }
#endif
            else {
                
                if (affordMoney > model.WithOutPassQuota.remain) {
                    
                    //  提示超过无密限额
                    NSString *message = nil;
                    if (model.WithOutPassQuota.remain > 0.0) {
                        message = rpString(@"当前免密支付剩余额度%.2f元。为了您的账户安全，请通过银行卡验证身份并设置支付密码。", model.WithOutPassQuota.remain);
                    }else {
                        message = rpString(@"为了您的账户安全，请通过银行卡验证身份并设置支付密码。");
                    }
                    
                    [weakSelf alertExcessWithOutPassLimitMessage:message];
                    [weakSelf removeAllViews];
                    
                }else {
                    
                    //  MARK:免密支付的确定事件
                    if (weakSelf.paySuccessBlock) {
                        weakSelf.paySuccessBlock(nil, nil);
                    }
                    
                }
                
            }
            
        }else if (type == RDButtonActionTypeForgotPass) {
            //  MARK:忘记密码, 重置密码
            [weakSelf removeAllViews];
            [weakSelf showValidateNameViewController:BindingCardTypeSetPassword andPayMoney:nil];
            
        }else if (type == RDButtonActionTypeResendCode) {
            //  MARK:重新发送验证码
            [weakSelf requestJDPaySMSAtCard:(YZHBankPayInfo *)payInfoView.payInfo];
            
        }else if (type == RDButtonActionTypePassFinished) {
            
            if (payInfoView.payType == RDPayTypeWithValidateCode) {
                //  MARK: 如果是京东支付需要验证验证码
                weakSelf.paymentModel.captcha = pass;
                [weakSelf requestValidateAppleyPaymentTelSMS];
                
            }else {
                
                if (weakSelf.paySuccessBlock) {
                    weakSelf.paySuccessBlock(nil, pass);
                }
                
            }
        }
    }];
    
    _payTypeView = payview;
    
    [YZTransparent showInView:RPPayView touchBlock:nil];
    
    [self popSubView:payview];
    
    [_payTypeView becomeFirstResponder];
}

/**
 *  支付方式选择页面
 */
- (void)showPaySelectionView
{
    [self.payTypeView removeFromSuperview];
    
    NewPaySelectionView *selectionView = [self getNewPaySelectionView];
    _paySelectionView = selectionView;
    [selectionView configWithModel:_accountModel];
    
    rpWeakSelf;
    __weak NewPaySelectionView *weakSelectionView = selectionView;
    __weak NewPayView *weakPayView = self.payTypeView;
    
    [selectionView setSelectionBlock:^(YZHPayInfo *payInfo) {
        
        YZHPayInfoType type = payInfo.payType;
        //银行卡变更
        BOOL isBankCardChanged = payInfo != weakPayView.payInfo;
        
        weakPayView.payInfo = payInfo;
        
        if (type == YZHPayInfoTypeBindCard){
            /**
             *  绑卡并支付
             */
            [weakSelf showValidateNameViewController:BindingCardTypeSend
                                         andPayMoney:self.payMoney];
            
            return ;
        }else if (type == YZHPayInfoTypeJDPay) {
            /**
             *  京东支付
             */
            if (weakPayView.payType != RDPayTypeWithValidateCode) {
                weakPayView.payType = RDPayTypeWithValidateCode;
            }
            
        }else if (type == YZHPayInfoTypeAlipay) {
            /**
             *  支付宝支付
             */
            [weakSelf sendAlipayInfoRequest];
            return;
            
        }
#ifdef WeChatAvaliable
        else if (type == YZHPayInfoTypeWechat) {
            /**
             *  微信支付
             */
            [weakSelf sendWechatInfoRequest];
            return;
            
        }
#endif
        else {
            if (weakSelf.accountModel.isHasPayPass) {
                weakPayView.payType = RDPayTypeWithPass;
                
            }else {
                
                //  无密支付超过限额，但是零钱够用
                if ([[self payMoney] floatValue] > _accountModel.WithOutPassQuota.remain) {
                    
                    weakPayView.payType = RDPayTypeExceedNoPass;
                    
                }else {
                    
                    weakPayView.payType = RDPayTypeWithNoPass;
                    
                }
                
            }
        }
        
        [weakSelectionView removeFromSuperview];
        
        [weakSelf popSubView:weakSelf.payTypeView];
        
        if (weakSelf.payTypeView.payType == RDPayTypeWithPass) {
            [weakSelf.payTypeView becomeFirstResponder];
            
        }else if (weakSelf.payTypeView.payType == RDPayTypeWithValidateCode) {
            
            [weakSelf.payTypeView becomeFirstResponder];
            
            if (!weakPayView.isTimerValid) {
                //  当计时器停止运行时，才重新请求验证码
                [weakSelf requestJDPaySMSAtCard:(YZHBankPayInfo *)payInfo];
            }else {
                if (isBankCardChanged) {
                    [weakPayView timerStop];
                    [weakSelf requestJDPaySMSAtCard:(YZHBankPayInfo *)payInfo];
                    [weakSelf.payTypeView refreshTypeView];
                }
            }
        }
        
    }];
    
    /**
     *  选择支付方式
     */
    __weak NewPaySelectionView *weakSelection = selectionView;
    [selectionView setButtonActionBlock:^(NewPayView *payView, RDButtonActionType type, NSString *pass){
        [weakSelection removeFromSuperview];
        [weakSelf popSubView:weakSelf.payTypeView];
    }];
    
    [self popSubView:selectionView];
}

#pragma mark - ThirdPayPart

- (void)addRedpacketNotifaction
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayCallBack:) name:RedpacketAlipayNotifaction object:nil];
    
#ifdef WeChatAvaliable
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechatPayCallBack:) name:RedpacketWechatPayNotifaction object:nil];
    
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelThridPayPartNotifaction:) name:RedpacketCancelPayNotifaction object:nil];
}

- (void)cancelThridPayPartNotifaction:(NSNotification *)notifaction
{
    [RPPayView rp_removeHudInManaual];
}

#ifdef WeChatAvaliable

#pragma mark - WechatPay

//  MARK: 微信支付
- (void)sendWechatInfoRequest
{
    _promptView = [_payController.view rp_showHudWaitingView:YZHPromptTypeWating];
    NSString *affordMoney = self.payMoney;
    
    RPPayView;
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        [RPPayView rp_removeHudInManaual];
        [weakSelf requestWechatPayView:data];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [RPPayView rp_showHudErrorView:YZHPromptTypeError];
        [weakSelf removeAllViews];
    }];
    
    [request requestWechatpaytInfo:affordMoney];
}

//  发起微信支付
- (void)requestWechatPayView:(NSDictionary *)info
{
    self.billRef = [NSString stringWithFormat:@"%@", [info objectForKey:@"BillRef"]];
    NSDictionary *dict = [info rp_dictionaryForKey:@"OrderInfo"];
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = dict[@"partnerid"];
    request.prepayId= dict[@"prepayid"];
    request.package = dict[@"package"];
    request.nonceStr= dict[@"noncestr"];
    request.timeStamp= [dict[@"timestamp"] unsignedIntValue];
    request.sign= dict[@"sign"];
    [WXApi sendReq:request];
}

- (void)wechatPayCallBack:(NSNotification *)notifaction
{
    if (self.billRef) {
        if ([notifaction.object isKindOfClass:[PayResp class]]){
            PayResp*response=(PayResp*)notifaction.object;
            switch(response.errCode){
                case WXSuccess:
                    //服务器端查询支付通知或查询API返回的结果再提示成功
                    
                    if (self.paySuccessBlock) {
                        
                        self.paySuccessBlock(self.billRef, nil);
                        
                    }
                    
                    [self persistentIsRedpacketAffodByWechatpay:YES];
                    
                    break;
                    
                default:
                    //微信支付失败或者被取消
                    self.billRef = nil;
                    [RPPayView rp_showHudErrorView:@"支付失败"];
                    [self removeAllViews];
                    break;
            }
        }else {
            
            self.billRef = nil;
            [self.promptView removeFromSuperview];
            [self removeAllViews];
            [RPPayView rp_removeHudInManaual];
            
        }
    }else {
        
        
    }
}

#endif

#pragma mark - Alipay

/**
 *  请求支付宝信息
 */
- (void)sendAlipayInfoRequest
{
    _promptView = [RPPayView rp_showHudWaitingView:YZHPromptTypeWating];
    NSString *affordMoney = self.payMoney;
    RPWeakPayView;
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        [weakPayView rp_removeHudInManaual];
        [weakSelf requestAlipayView:data];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakPayView rp_showHudErrorView:error];
        [weakSelf removeAllViews];
    }];
    
    [request requestAlipayInfo:affordMoney];
}

- (void)requestAlipayView:(NSDictionary *)info
{
    self.billRef = [NSString stringWithFormat:@"%@", [info objectForKey:@"BillRef"]];
    
    NSString *orderString = [info rp_stringForKey:@"OrderInfo"];
    NSString *urlScheme = [YZHRedpacketBridge sharedBridge].redacketURLScheme;
    
    if (urlScheme.length == 0) {
        [self alertWithMessage:@"urlScheme为空，无法调用支付宝"];
        [self removeAllViews];
        return;
    }
    
    rpWeakSelf;
    RPWeakPayView;
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:urlScheme callback:^(NSDictionary *resultDic) {
        /**
         *  支付宝网页支付的回调
         */
        NSInteger code = [[resultDic rp_stringIntForKey:@"resultStatus"] integerValue];
        if (code == 9000) {
            /**
             *  支付成功
             */
            if (weakSelf.paySuccessBlock) {
                weakSelf.paySuccessBlock(weakSelf.billRef, nil);
            }
            
            RPDebug(@"红包SDK：网页版支付宝调用了发红包");
            [weakSelf persistentIsRedpacketAffodByAlipay:YES];
            
        }else {
            [weakPayView rp_showHudErrorView:@"支付失败"];
            [weakSelf removeAllViews];
        }
        
        RPDebug(@"reslut = %@",resultDic);
    }];
}

/**
 *  支付宝App支付的回调
 */
- (void)alipayCallBack:(NSNotification *)notifaction
{
    RPDebug(@"红包SDK：\n收到支付宝支付回调：%@\n 当前的控制器：%@", notifaction, self);
    
    if (self.billRef) {
        if ([notifaction.object isKindOfClass:[NSDictionary class]]) {
            NSInteger code = [[notifaction.object valueForKey:@"resultStatus"] integerValue];
            if (code == 9000) {
                
                //  支付成功
                if (self.paySuccessBlock) {
                    
                    self.paySuccessBlock(self.billRef, nil);
                    
                }
                
                [self persistentIsRedpacketAffodByAlipay:YES];
                
            }else {
                
                self.billRef = nil;
                [RPPayView rp_showHudErrorView:@"支付失败"];
                [self removeAllViews];
                
            }
            
        }else {
            
            self.billRef = nil;
            [self.promptView removeFromSuperview];
            [self removeAllViews];
            [RPPayView rp_removeHudInManaual];
            
        }
        
    }else {
        
        //  收到无效Alipay通知
        
    }
}

#pragma mark - JDPay

//  请求京东支付验证码
- (void)requestJDPaySMSAtCard:(YZHBankPayInfo *)payInfo
{
    [RPPayView rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RPWeakPayView;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        /**
         *  京东支付订单号
         */
        NSString *billRef = [data rp_stringForKey:@"BillRef"];
        weakSelf.paymentModel.billRef = billRef;
        [weakSelf.payTypeView timerRun];
        [weakPayView rp_removeHudInManaual];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf.payTypeView timerStop];
        [weakPayView rp_showHudErrorView:error];
    }];
    
    ApplyPaymentModel *model = _paymentModel;
    if (!model) {
        model = [ApplyPaymentModel new];
        _paymentModel = model;
    }
    
    model.amount = self.payMoney;
    
    if (!model.cardInfo) {
        model.cardInfo = [BindCardInfo new];
    }
    
    model.cardInfo.cardId = payInfo.cardID;
    
    [request applyForRedpacketPaymentWithApplyPayment:model];
}

//  验证京东请求支付验证码
- (void)requestValidateAppleyPaymentTelSMS
{
    [RPPayView rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RPWeakPayView;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        
        NSString *billRef = rpString(@"%@", [data valueForKey:@"BillRef"]);
        //京东支付验证码验证成功
        if (weakSelf.paySuccessBlock) {
            weakSelf.paySuccessBlock(billRef, nil);
        }
        
        RPDebug(@"京东支付调用了发红包");
        [weakSelf persistentIsRedpacketAffodByAlipay:NO];
        [weakSelf persistentIsRedpacketAffodByWechatpay:NO];
        [weakPayView rp_removeHudInManaual];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == NSIntegerMax) {
            [weakPayView rp_showHudErrorView:error];
        }else if (code == RedpacketOtherError) {//需要将数字改成type类型
            //???
            //[weakPayView rp_removeHudInManaual];
            //[weakSelf.payTypeView passwordInputError:YES];
            [weakSelf passwordInputError:error];
            
        }else if (code == RedpacketCaptchaInvalid) {//需要将数字改成type类型
            //  验证码错误
            //[weakPayView rp_showHudErrorView:error];
            //[weakSelf.payTypeView passwordInputError:YES];
            
            [weakSelf passwordInputError:error];
            
        }else {
            [weakSelf removeAllViews];
            [weakSelf alertWithMessage:error];
        }
    }];
    
    [request confirmPaymentWithApplyPayment:_paymentModel];
}

- (void)passwordInputError:(NSString *)error
{
    //[self.payTypeView passwordInputError:YES];
    
    [self.payTypeView removeFromSuperview];
    rpWeakSelf;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
    [alert setRp_completionBlock:^( UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        
        [weakSelf popSubView:weakSelf.payTypeView];
        [weakSelf.payTypeView clearPassword];
        [weakSelf.payTypeView becomeFirstResponder];
    
    }];
    
    [alert show];
}

#pragma mark - Alert View

/**
 *  目前的支付方式中的最大可用额度
 */
- (CGFloat)getMaxPayMoneyInPayInfos
{
    CGFloat maxJD = [RPRedpacketSetting shareInstance].jdpayMaxMoney;
    CGFloat maxAli = [RPRedpacketSetting shareInstance].alipayMaxMoney;
    
     QuotaModel *currentPayQuotaModel = [self currentPayQuotaModel];
    
    CGFloat lqRemain = _accountModel.balance;
    CGFloat dayRemain = currentPayQuotaModel.remain;
    CGFloat aliRemain = _accountModel.aliQuota.remain;
    CGFloat jdRemain = .0f;

    for (YZHBankPayInfo *info in _accountModel.payInfos) {
        //  京东各个银行卡之间最大的付款额度
        if ([info isKindOfClass:[YZHBankPayInfo class]]) {
            
            jdRemain = jdRemain > info.balance ? jdRemain : info.balance;
            
        }
    }
    
    aliRemain = aliRemain > maxAli ? maxAli : aliRemain;
    //  如果支付宝不可用，则设置支付宝额度为0
    aliRemain = _accountModel.isAlipayAvaliable ? aliRemain : 0.0f;

    jdRemain = jdRemain > maxJD ? maxJD : jdRemain;
    
    CGFloat maxPay = lqRemain >= aliRemain ? lqRemain : aliRemain;
    maxPay = maxPay > jdRemain ? maxPay : jdRemain;
    
    //  不能超过今日限额(和今日限额比取最小值)
    maxPay = maxPay >= dayRemain ? dayRemain : maxPay;
    
    return maxPay;
}

/**
 *  今日最大支付额度提示
 */
//  所有都超限了， 提示绑卡
- (void)alertMaxPayMoneyInDay
{
    //CGFloat maxPay = [self getMaxPayMoneyInPayInfos];
    
    //  用当日限额
    CGFloat maxPay = _accountModel.dayQuota.remain;
    
    NSString *message;
    if (maxPay < .01) {
        message = rpString(@"当日限额还剩0元，请明天再试");//rpString(@"今日额度已经用完, 请改日再发。");
    }else {
        message = rpString(@"当日限额还剩%.2f元，请修改金额", maxPay);
    }
    
    [self alertWithMessage:message];
}

- (void)alertExcessWithOutPassLimitMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    rpWeakSelf;
    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  设置密码
            [weakSelf showValidateNameViewController:BindingCardTypeChangeQuota andPayMoney:nil];
        }else {
            
            [weakSelf reRequestUserWallet];
        }
    };
    [alert show];
}

- (void)alertOverPayMoneyInPayInfos
{
    /*
    CGFloat maxPay = [self getMaxPayMoneyInPayInfos];
    NSString *message = [NSString stringWithFormat:@"已超最大支付额度%.2f，可绑定新卡支付", maxPay];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"绑定", nil];
    
    rpWeakSelf;
    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  找回密码
            [weakSelf showSetPayPassViewController:BindingCardTypeForgetPass];
        }
    };
     */
    
    CGFloat maxPay = [self getMaxPayMoneyInPayInfos];
    NSString *message = [NSString stringWithFormat:@"已超出银行卡单笔支付限额%.2f，请修改金额", maxPay];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
    
    [alert show];
}


- (void)alertBindCardAndSetPayPass
{
     QuotaModel *currentPayQuotaModel = [self currentPayQuotaModel];
    NSString *message = [_accountModel getBanks].count ? rpString(@"已超过限额，剩余额度为%.2f，绑定银行卡可提高限额", currentPayQuotaModel.remain) : rpString(@"为了账户安全，请先通过银行卡验证是您本人，然后设置支付密码");
    
    NSString *title = [_accountModel getBanks].count ? @"绑定" : @"确定";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:title, nil];
    
    rpWeakSelf;
    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  设置交易密码
            [weakSelf showValidateNameViewController:BindingCardTypeWithDrawNoPass andPayMoney:nil];
        }
    };
    
    [alert show];
}


- (void)alertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark -
#pragma mark 绑卡重置密码

/**
 *  设置支付密码成功
 */
- (void)rebackToChangeWith:(BindingCardType)bindingCardType
{
    [self removeAllViews];
    
    [RPRedpacketSetting asyncRequestRedpacketsettingsIfNeed:nil];
    [self requestUserWallet];
}

//  绑卡成功并发送红包的回调
- (void)rebackwithApplyPaymentModel:(ApplyPaymentModel *)model
{
    [self removeAllViews];
    _paymentModel = model;
    //如果存在支付宝订单号，则清空掉支付宝订单
    _billRef = nil;
    [self requestUserWallet];
}

- (void)removeAllViews
{
    [_paySelectionView removeFromSuperview];
    _paySelectionView = nil;
    
    [self.payTypeView removeFromSuperview];
    [_payTypeView destoryTimer];
    _payTypeView = nil;
    [YZTransparent removeFromSuperView];
}

- (void)popSubView:(UIView *)view
{
    CGPoint center = CGPointMake(CGRectGetWidth(RPPayView.frame) / 2, CGRectGetHeight(RPPayView.frame) / 2);
    CGRect frame = view.frame;
    frame.origin = CGPointMake(center.x - CGRectGetWidth(frame) / 2, center.y - CGRectGetHeight(frame) / 2);
    view.frame = frame;
    [RPPayView rp_popupSubView:view atPosition:PopAnchorCenterX | PopAnchorCenterY];
}

- (void)persistentIsRedpacketAffodByAlipay:(BOOL)used
{
    //  记录当前支付方式是支付宝
    [[NSUserDefaults standardUserDefaults] setValue:@(used) forKey:IsAlipayLastpayKey];
}

- (void)persistentIsRedpacketAffodByWechatpay:(BOOL)used
{
    //  记录当前支付方式是微信支付
    [[NSUserDefaults standardUserDefaults] setValue:@(used) forKey:IsWechatpayLastPayKey];
}

#pragma mark - Controllers
/**
 *  通过绑定银行卡并设置密码 可以提高限额
 */
- (void)showValidateNameViewController:(BindingCardType)bindingCardType
                         andPayMoney:(NSString *)payMoney
{
    RPValidateNameViewController *controller = [[RPValidateNameViewController alloc] init];
    controller.delegate = self;
    controller.bindingCardType = bindingCardType;
    controller.moneyAccount = payMoney;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [RPPayController.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)showValidateUserIDCard:(NSString *)errMsg
{
    ValidateUserIDController *validate = [[ValidateUserIDController alloc] initWithStyle:UITableViewStyleGrouped];
    validate.isValidateFalid = YES;
    validate.validateMsg = errMsg;
    
    [RPPayController.navigationController pushViewController:validate animated:YES];
}

#pragma mark - keyboardnotification

- (void)addKeyboardNotifaction
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)noti
{
    CGRect keyboardFrame = [[noti.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    UIView *topView = [self topInputView];
    
    if(topView && CGRectGetHeight(keyboardFrame) > 0){
        [UIView animateWithDuration:.25 animations:^{
            topView.rp_bottom = CGRectGetMinY(keyboardFrame) - 20 - 64;
        }];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)noti
{
    UIView *topView = [self topInputView];
    [UIView animateWithDuration:.25 animations:^{
        CGPoint center = RPPayView.center;
        center.y -= 100;
        topView.center = center;
    }];
}

- (UIView *)topInputView
{
    UIView *topView;
    UIView *payView = self.payTypeView;
    
    if ( payView && payView.superview) {
        topView = payView;
        
    }
    
    return topView;
}

@end

