//
//  SendRedPacketBaseViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "SendRedPacketBaseViewController.h"
#import "RedpacketColorStore.h"
#import "YZTransparent.h"
#import "UIView+YZHAnimation.h"
#import "UIView+YZHExtension.h"
#import "UIView+YZHPrompting.h"
#import "YZHRedpacketBridge.h"
#import "YZTelphoneValidateView.h"
#import "NSDictionary+YZHExtern.h"
#import "UIAlertView+YZHAlert.h"
#import "YZHRedpacketGlobal.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketDataRequester.h"
#import "RedpacketWebController.h"
#import "NSBundle+RedpacketBundle.h"
#import "NewPayView.h"
#import "ValidatedeNameTableViewController.h"
#import "AlipaySDK.h"
#import "RedpacketOpenConst.h"
#import "ValidateUserIDController.h"
#import "WXApi.h"


#define IsAlipayLastpayKey      @"IsAlipayLastpayKey"
#define IsWechatLastpayKey      @"IsWechatLastpayKey"

#define Redpacket_max_numbers   100 //红包个数

@interface SendRedPacketBaseViewController () <ValidatedeDelegate>
{
    CGRect _viewFrame;
}
@property (nonatomic, copy  ) NSString               *redpacketId;
@property (nonatomic, strong) NewPayView             *payTypeView;
@property (nonatomic, weak  ) YZTelphoneValidateView *telView;
@property (nonatomic, strong) UserAccoutModel        *accountModel;

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
@property (nonatomic, assign) BOOL isWechatLastpay;

/**
 *  用户输入的密码
 */
@property (nonatomic, copy) NSString *userPass;

/**
 *  支付相关信息
 */
@property (nonatomic, strong) ApplyPaymentModel *paymentModel;

/**
 *  支付宝流水
 */
@property (nonatomic, copy) NSString *billRef;

/**
 *  短信验证码请求返回的流水号
 */
@property (nonatomic, copy) NSString *smsBillRef;


@end


@implementation SendRedPacketBaseViewController

- (void)dealloc
{
    [self removeKeyboardNotifaction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNavgationBarBackgroundColor:[RedpacketColorStore rp_textColorRed] titleColor:[RedpacketColorStore rp_textcolorYellow] leftButtonTitle:@"关闭" rightButtonTitle:@""];
    [self registerForKeyboardNotifications];
    _viewFrame = self.view.frame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  注册微信支付
    BOOL isRegisterOk = [WXApi registerApp:@"wx634a5f53be1b66bd" withDescription:@"iOS_RedpacketSDK"];
    
    _isAlipayLastpay = [[[NSUserDefaults standardUserDefaults] valueForKey:IsAlipayLastpayKey] boolValue];
    _isWechatLastpay = [[[NSUserDefaults standardUserDefaults] valueForKey:IsWechatLastpayKey] boolValue];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(backButtonSender) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = self.view.bounds;
    [self.view addSubview:backButton];
    [self.view sendSubviewToBack:backButton];
    
    //  同步Token
    rpWeakSelf;
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken:^(NSInteger code, NSString *msg) {
        
        if (code == 0) {
            //  生成红包ID
            [weakSelf requestRedpacketId];
            
            //  请求红包资源接口
            [weakSelf requestRedpacketSetting];
            
            //  用户行为统计
            [weakSelf sendUserActionAnalysisRequest];
            
        }else {
            [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
        }
        
    }];
    
    [self configViewStyle];
    
    [self configSubViews];
    
    [self addKeyboardNotifaction];
    [self addRedpacketNotifaction];
    
    [self addHelpBarButtonItem];
    
    self.totalRedPacketField.delegate = self;
    
    //单个红包最高限额赋值
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *max_money = [defaults stringForKey:@"SingleHbQuota"];
    if ([max_money intValue] > 1) {
        _redpacket_max_money = [max_money intValue];
    }else{
        _redpacket_max_money = 100;
    }
}

/**
 *  统计发红包页面的打开频率
 */
- (void)sendUserActionAnalysisRequest
{
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:nil andFaliureBlock:nil];
    
    [request analysisUserDataWithViewUrl:@"page.send_red_packet"];
}

- (void)requestRedpacketSetting
{
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        [YZHRedpacketGlobal shareInstance].redpacketSettingDic = dict;
        weakSelf.redpacket_max_money = [YZHRedpacketGlobal shareInstance].singlePayLimit;
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
    }];
    
    [request requestRedpacketSetting:[YZHRedpacketGlobal shareInstance].redpacketSettingDic ? NO : YES];
}

- (void)requestRedpacketId
{
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        NSNumber *redpacketId = [dict valueForKey:@"ID"];
        weakSelf.redpacketId = redpacketId.description;
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
    }];
    
    [request requestRedpacketID];
}


#pragma mark - TextFiledDelegate

- (BOOL)isMoneyOutOfLimit:(CGFloat)money
{
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    CGFloat money = [replacedString floatValue];
    
    int numbers = [self.totalRedPacketField.text intValue];
    
    NSArray *array = [replacedString componentsSeparatedByString:@"."];
    if (array.count == 2) {
        NSString *decimalString = array[1];
        NSString *numberString = array[0];
        
        if (decimalString.length > 2) {
            return NO;
        }
        
        if (numberString.length > 5) {
            return NO;
        }
    }else if(replacedString.length > 5) {
        return NO;
    }
    //只能输入一个小数点
    NSString *temp;
    int pointNnumber = 0;
    for(int i =0; i < [replacedString length]; i++)
    {
        temp = [replacedString substringWithRange:NSMakeRange(i, 1)];
        if ([temp isEqualToString:@"."]) {
            pointNnumber++;
            if (pointNnumber > 1.1) {
                return NO;
            }
        }
    }
    
    if (self.totalRedPacketField.isFirstResponder == YES) {
        CGFloat price = [self.priceField.text floatValue];
        NSString* number=@"^[0-9]+$";
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
        //包个数不能超过3位
        if (replacedString.length > 3) {
            return NO;
        }
        //红包个数不能超过100个
        if (money > Redpacket_max_numbers && ![replacedString isEqualToString:@""]) {
            [self addWarmPromtLableWith:[NSString stringWithFormat:@"一次最多发%d个红包",Redpacket_max_numbers]];
            self.submitButton.enabled = NO;
            [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
        }else if (money < 1&& ![replacedString isEqualToString:@""]) {
            [self addWarmPromtLableWith:@"请输入红包个数"];
            self.submitButton.enabled = NO;
            [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
        }else{
            [self delWarmPromtLable];
        }
        
        if ([_groupType isEqualToString:@"rand"] || [_groupType isEqualToString:@"member"]) {
            //随机红包总金额不能大于人数乘以100
            if (price/money > _redpacket_max_money &&money>0 && price >0) {
                [self addWarmPromtLableWith:[NSString stringWithFormat:@"单个红包金额不能超过%d元",  (int)_redpacket_max_money]];
                [self changeLabelsWarning:YES];
                self.submitButton.enabled = NO;
                [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                
            }else if (money*price == 0 || money > Redpacket_max_numbers) {
                self.submitButton.enabled = NO;
                [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
            } else {
                [self changeLabelsWarning:NO];
                self.submitButton.enabled = YES;
                [self.submitButton setBackgroundColor:[RedpacketColorStore rp_textColorRed]];
            }

            _priceBigLabel.text = [NSString stringWithFormat:@"￥ %.2f", [self.priceField.text floatValue]];
            //普通群红包
        }else if ([_groupType isEqualToString:@"avg"]&&money>0 && price >0)
        {
            _priceBigLabel.text = [NSString stringWithFormat:@"¥ %.2f", money*numbers];
            
            if (price/money > _redpacket_max_money) {
                [self addWarmPromtLableWith:[NSString stringWithFormat:@"单个红包金额不能超过%d元",  (int)_redpacket_max_money]];
                [self changeLabelsWarning:YES];
                self.submitButton.enabled = NO;
                [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                
            }else if (money == 0) {
                self.submitButton.enabled = NO;
                [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                [self delWarmPromtLable];
            } else {
                [self changeLabelsWarning:NO];
                self.submitButton.enabled = YES;
                [self.submitButton setBackgroundColor:[RedpacketColorStore rp_textColorRed]];
                [self delWarmPromtLable];
            }
            if (money == 0 || numbers == 0) {
                _priceBigLabel.text = [NSString stringWithFormat:@"¥ %.2f", money*numbers];
                
            }
        }
    
        if (([string isEqualToString:@""])|| [numberPre evaluateWithObject:string]) {
            if ([_groupType isEqualToString:@"avg"])
            {
                _priceBigLabel.text = [NSString stringWithFormat:@"¥ %.2f", money*price];
                if (money*price>0) {
                    self.submitButton.enabled = YES;
                    [self.submitButton setBackgroundColor:[RedpacketColorStore rp_textColorRed]];
                }else
                {
                    self.submitButton.enabled = NO;
                    [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                }
            }
            return YES;
        }
        return NO;
    }else
    {   //type值为空 则为个人红包
        if (_groupType.length < 1) {
            _priceBigLabel.text = [NSString stringWithFormat:@"¥ %.2f", money];
            if ([self isMoneyOutOfLimit:money]) {
                [self addWarmPromtLableWith:[NSString stringWithFormat:@"单个红包金额不能超过%d元", (int)_redpacket_max_money]];
                [self changeLabelsWarning:YES];
                self.submitButton.enabled = NO;
                [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                
            }else if (money == 0) {
                self.submitButton.enabled = NO;
                [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                
            } else {
                [self changeLabelsWarning:NO];
                self.submitButton.enabled = YES;
                [self.submitButton setBackgroundColor:[RedpacketColorStore rp_textColorRed]];
                [self delWarmPromtLable];
            }
        }else
        {
            if ([_groupType isEqualToString:@"rand"] || [_groupType isEqualToString:@"member"]) {
                //随机红包总金额不能大于人数乘以100
                if (money > numbers *_redpacket_max_money &&money>0 && numbers >0 ) {
                    [self addWarmPromtLableWith:[NSString stringWithFormat:@"单个红包金额不能超过%d元",  (int)_redpacket_max_money]];
                    [self changeLabelsWarning:YES];
                    self.submitButton.enabled = NO;
                    [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                    
                }else if (money *numbers == 0 || numbers > Redpacket_max_numbers) {
                    self.submitButton.enabled = NO;
                    [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                } else {
                    [self changeLabelsWarning:NO];
                    self.submitButton.enabled = YES;
                    [self.submitButton setBackgroundColor:[RedpacketColorStore rp_textColorRed]];
                    [self delWarmPromtLable];
                }
                
                _priceBigLabel.text = [NSString stringWithFormat:@"¥ %.2f", money];
                    //普通群红包
            }else if ([_groupType isEqualToString:@"avg"]&&money>0 && numbers >0)
                {
                
                    if (money > _redpacket_max_money) {
                        [self addWarmPromtLableWith:[NSString stringWithFormat:@"单个红包金额不能超过%d元",  (int)_redpacket_max_money]];
                        [self changeLabelsWarning:YES];
                        self.submitButton.enabled = NO;
                        [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                        
                    }else if (money == 0 || numbers > Redpacket_max_numbers) {
                        self.submitButton.enabled = NO;
                        [self.submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
                    } else {
                        [self changeLabelsWarning:NO];
                        self.submitButton.enabled = YES;
                        [self.submitButton setBackgroundColor:[RedpacketColorStore rp_textColorRed]];
                        [self delWarmPromtLable];
                    }
                    _priceBigLabel.text = [NSString stringWithFormat:@"¥ %.2f", money*numbers];
                }
            if (money == 0 || numbers == 0) {
                _priceBigLabel.text = [NSString stringWithFormat:@"¥ %.2f", money*numbers];
            }
        }
    }
   
    // 判断输入是否数字或者小数点
    NSString* number=@"^[0-9]+$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    if (([string isEqualToString:@""]) || [string isEqualToString:@"."] || [numberPre evaluateWithObject:string]) {
        return YES;
    }
    return NO;
}

// 为了禁止四舍五入
- (NSString *)notRounding:(float)price afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

#pragma makr - submit Button
- (IBAction)submitButtonSender:(UIButton *)button
{
    [self.view endEditing:YES];
    
    if (self.redpacketId.length == 0) {
        [self requestRedpacketIDAndUserWallet];
    }else {
        [self requestUserWallet];
    }
}

#pragma mark - 请求红包ID
- (void)requestRedpacketIDAndUserWallet
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        NSNumber *redpacketId = [dict valueForKey:@"ID"];
        weakSelf.redpacketId = redpacketId.description;
        [weakSelf requestUserWallet];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        if (code == NSIntegerMax) {
            [weakSelf.view rp_removeHudInManaual];
            [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
            
        }else {
            [weakSelf.view rp_showHudErrorView:error];
        }

    }];
    
    [request requestRedpacketID];
}

#pragma mark - Request User Wallet
//  查看用户零钱,并展示支付页面
- (void)requestUserWallet
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        [weakSelf.view rp_removeHudInManaual];
        [weakSelf showNewPayViewWithDic:dict];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        if (code == NSIntegerMax) {
            [weakSelf.view rp_removeHudInManaual];
            [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
            
        }else {
            [weakSelf.view rp_showHudErrorView:error];
        }
        
    }];
    
    [request requestLQDetail];
}

- (CGFloat)getAffordMoney
{
    CGFloat payMoney =[self.priceField.text floatValue];
    
    if (_isGrop) {
        CGFloat numbers = [self.totalRedPacketField.text integerValue];
        
        if ([_groupType isEqualToString:@"rand"]|| [_groupType isEqualToString:@"member"]) {
            //  手气红包
            return payMoney;
            
        }else {
            //  平均红包
            return payMoney * numbers;
        }
        
    }else {
        return payMoney;
    }
}

#pragma mark -  PassView && jdpay
#pragma mark -
- (void)showNewPayViewWithDic:(NSDictionary *)dict
{
    NewPayView *payview = [NewPayView new];
    
    CGFloat affordMoney = [self getAffordMoney];
    
    UserAccoutModel *model = [UserAccoutModel accountModelWithDic:dict];
    model.payMoney = rpString(@"%.2f", affordMoney);
    _accountModel = model;
    
    if (model.isWechatAvaliable) {
        model.isWechatAvaliable = [WXApi isWXAppInstalled];
    }
    
    //  是从绑卡支付过来的
    if (_paymentModel && _paymentModel.cardInfo.cardNo.length > 0) {
        //  如果有绑卡信息, 要把相关的绑卡信息放到 BankInfo里边
        NSMutableArray *banks = [NSMutableArray arrayWithArray:model.bankCards];
        YZHBankInfo *info = [YZHBankInfo new];
        info.bankName = _paymentModel.cardInfo.bankName;
        NSString *cardNo = _paymentModel.cardInfo.cardNo;
        cardNo = [cardNo substringWithRange:NSMakeRange(cardNo.length - 4, 4)];
        info.cardSuffix = cardNo;
        
        NSString *tel = _paymentModel.cardInfo.telephone;
        NSString *replace = [tel substringWithRange:NSMakeRange(3, 4)];
        tel = [tel stringByReplacingOccurrencesOfString:replace withString:@"****"];
        
        info.telephone = tel;
        
        /**
         *  虚拟的单笔支付， 今日限额。
         */
        if(banks.count) {
            YZHBankInfo *info1 = banks[0];
            info.onceLimit = info1.onceLimit;
            info.balance = 10000.0f;
            
        }else {
            info.onceLimit = 200.0f;
            info.balance = 10000.0f;
        }
        
        [banks insertObject:info atIndex:0];
        model.bankCards = [banks copy];
        
        //  直接通过
        payview.payType = RDPayTypeWithValidateCode;
        [payview timerRun];
        /**
         *  绑卡页面会发送一次短信验证码
         */
        //[self requestApplyPaymentTelSMS];
        
    }else {
        if (model.dayQuota.remain >= affordMoney) {
            // 没有超日限额
            
            if (model.balance >= affordMoney) {
                // 零钱足够
                if (model.isHasPayPass) {
                    payview.payType = RDPayTypeWithPass;
                }else {
                    payview.payType = RDPayTypeWithNoPass;
                    [self.view endEditing:YES];
                }
                
            }else {
                
                if (_isAlipayLastpay && model.isAlipayAvaliable) {
                    // 零钱不够, 上次付款是支付宝支付且支付宝支付可用
                    payview.payType = RDPayTypeAlipay;
                    
                }else if (_isWechatLastpay && model.isWechatAvaliable) {
                    // 零钱不够, 上次付款是微信支付 且微信支付可用
                    payview.payType = RDPayTypeWeChatPay;
                    
                }else if (model.isAlipayAvaliable) {
                    //  上次支付既不是微信也不是支付宝， 但是支付宝可用
                    payview.payType = RDPayTypeAlipay;
                    
                }else if (model.isWechatAvaliable) {
                    //  上次支付既不是微信也不是支付宝， 但是支付宝可用
                    payview.payType = RDPayTypeWeChatPay;
                    
                } else {
                    
                    if (model.bankCards.count) {
                        BOOL isAvaliable = NO;
                        NSInteger index = -1;
                        for (YZHBankInfo *info in model.bankCards) {
                            if ([model.payMoney floatValue] <= info.balance) {
                                isAvaliable = YES;
                                break;
                            }
                        }
                        
                        if (isAvaliable) {
                            //  京东限额足够
                            payview.payType = RDPayTypeWithValidateCode;
                            [self requestJDPaySMSAtCardIndex:index];
                            
                        }else {
                            //  支付宝可用
                            if (model.isAlipayAvaliable) {
                                payview.payType = RDPayTypeAlipay;
                                
                            }else if (model.isWechatAvaliable) {
                                payview.payType = RDPayTypeWeChatPay;
                                
                            } else {
                                //  最大可发金额
                                [self alertMaxPayMoneyInDay];
                                return;
                            }
                        }
                    }else {
                        if (model.isAlipayAvaliable) {
                            payview.payType = RDPayTypeAlipay;
                            
                        }else if (model.isWechatAvaliable) {
                            payview.payType = RDPayTypeWeChatPay;
                            
                        }else {
                            //  未绑卡
                            [self.view endEditing:YES];
                            
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
                //  提示绑卡
                [self alertBindCardAndSetPayPass];
                return;
            }
        }
    }
    
    [payview configWithModel:model];
    
    rpWeakSelf;
    [payview setSelectionBlock:^(RDPaySelectionType type) {
        if (type == RDPaySelectionTypeBindCard){
            // 绑卡并支付
            [weakSelf removeAllViews];
            [weakSelf showBindCardAndPayViewController];
            
        }else if (type == RDPaySelectionTypeJDPay) {
            //  京东支付
            [weakSelf showPaySelectionView];
            
        }else {
            [weakSelf showPaySelectionView];
        }
        
    }];
    
    /**
     *  界面上的用户行为回调
     */
    [payview setButtonActionBlock:^(NewPayView *payView, RDButtonActionType type, NSString *pass){
        
        if (type == RDButtonActionTypeClose) {
            [weakSelf removePayView];
        }else if (type == RDButtonActionTypePay) {
            if (payview.payType == RDPayTypeAlipay) {
                //  MARK:支付宝支付
                [weakSelf sendAlipayInfoRequest];
                
            }else if(payview.payType == RDPayTypeWeChatPay) {
                //  MARK:微信支付
                [weakSelf sendWechatInfoRequest];
                
            } else {
                //  MARK:免密支付的确定事件
                [weakSelf sendRedpacketRequest];
            }
            
        }else if (type == RDButtonActionTypeForgotPass) {
            //  MARK:忘记密码, 重置密码
            [weakSelf removeAllViews];
            [weakSelf showSetPayPassViewController:ForgetTpe];
            
        }else if (type == RDButtonActionTypeResendCode) {
            //  MARK:重新发送验证码
            [weakSelf requestJDPaySMSAtCardIndex:-1];
            
        }else if (type == RDButtonActionTypePassFinished) {
            if (payView.payType == RDPayTypeWithValidateCode) {
                //  MARK: 如果是京东支付需要验证验证码
                weakSelf.paymentModel.captcha = pass;
                [weakSelf requestValidateAppleyPaymentTelSMS];
                
            }else {
                //  零钱支付则清空支付订单
                _paymentModel.billRef = nil;
                
                //  密码支付
                weakSelf.userPass = pass;
                
                //  调用发送红包的接口
                [weakSelf sendRedpacketRequest];
            }
        }
    }];
    
    _payTypeView = payview;
    
    [YZTransparent showInView:self.view touchBlock:nil];
    
    [self popSubView:payview];
    
    [_payTypeView becomeFirstResponder];
}

//  支付方式选择页面
- (void)showPaySelectionView
{
    [self.payTypeView removeFromSuperview];
    
    NewPaySelectionView *selectionView = [NewPaySelectionView new];
    [selectionView configWithModel:_accountModel];
    
    rpWeakSelf;
    __weak NewPaySelectionView *weakSelectionView = selectionView;
    __weak NewPayView *weakPayView = self.payTypeView;
    
    [selectionView setSelectionBlock:^(RDPaySelectionType type) {
        
        [weakSelectionView removeFromSuperview];
        
        if (type == RDPaySelectionTypeBindCard){
            // 绑卡并支付
            [weakSelf removeAllViews];
            [weakSelf showBindCardAndPayViewController];
            
            return ;
        }else if (type == RDPaySelectionTypeJDPay) {
            /**
             *  京东支付
             */
            
            //   被选中的银行卡
            BOOL isBankCardChanged = weakPayView.bankSelectionIndex != weakSelectionView.bankSelectionIndex;
            weakPayView.bankSelectionIndex = weakSelectionView.bankSelectionIndex;
            
            if (weakPayView.payType != RDPayTypeWithValidateCode) {
                
                if (!weakPayView.isTimerValid) {
                     //  当计时器停止运行时，才重新请求验证码
                    [weakSelf requestJDPaySMSAtCardIndex:-1];
                }
                
                weakPayView.payType = RDPayTypeWithValidateCode;
            }else {
                if (isBankCardChanged) {
                    [weakPayView timerStop];
                    [weakSelf requestJDPaySMSAtCardIndex:-1];
                    [weakSelf.payTypeView refreshTypeView];
                }
            }
            
        }else if (type == RDPaySelectionTypeZhifuBao) {
            /**
             *  支付宝支付
             */
        
            //weakPayView.payType = RDPayTypeAlipay;
            [self sendAlipayInfoRequest];
            return;
            
        }else if (type == RDPaySelectionTypeWechat) {
            /**
             *  微信支付
             */
            [self sendWechatInfoRequest];
            return;
            
        }else {
            if (weakSelf.accountModel.isHasPayPass) {
                weakPayView.payType = RDPayTypeWithPass;
                
            }else {
                weakPayView.payType = RDPayTypeWithNoPass;
            }
        }
        
        [weakSelf popSubView:weakSelf.payTypeView];
        
        if (weakSelf.payTypeView.payType == RDPayTypeWithPass ||
            weakSelf.payTypeView.payType == RDPayTypeWithValidateCode) {
            [weakSelf.payTypeView becomeFirstResponder];
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

- (void)removePayView
{
    [self.payTypeView removeFromSuperview];
    _payTypeView = nil;
    [YZTransparent removeFromSuperView];
}

/**
 *  今日最大支付额度为：
 */
- (void)alertMaxPayMoneyInDay
{
    CGFloat lqRemain = _accountModel.balance;
    CGFloat dayRemain = _accountModel.dayQuota.remain;
    CGFloat jdRemain = .0f;
    
    for (YZHBankInfo *info in _accountModel.bankCards) {
        //  京东各个银行卡之间最大的付款额度
        jdRemain = jdRemain > info.balance ? jdRemain : info.balance;
    }
    
    //   是否是零钱大
    BOOL isChangeMax = lqRemain >= jdRemain;
    CGFloat maxPay;
    
    NSString *message;
    if (isChangeMax) {
        maxPay = lqRemain > dayRemain ? dayRemain : lqRemain;
        if (maxPay < .01) {
                message = rpString(@"今日剩余额度为0元, 不能再发了哦...");
        }else {
            message = rpString(@"今日剩余最大额度为%.2f元,请修改红包金额。",maxPay);
        }
        
    }else {
        maxPay = jdRemain > dayRemain ? dayRemain : jdRemain;
        if (maxPay < .01) {
            message = rpString(@"今日剩余额度为0元, 不能再发了哦...");
            
        }else {
            /*
            message = rpString(@"%@%@今日剩余最大额度为%.2f元,请修改红包金额。",
                               _accountModel.bankInfo.bankName,
                               _accountModel.bankInfo.cardSuffix,
                               maxPay);
             */
            message = _accountModel.jdQuota.message;
        }
    }
    
    [self alertWithMessage:message];
}

- (void)alertBindCardAndSetPayPass
{
    [self removeAllViews];
    NSString *message = _accountModel.bankCards.count ? rpString(@"已超过无密码限额，剩余额度为%.2f，绑定银行卡并设置支付密码可提高限额", _accountModel.dayQuota.remain) : rpString(@"已超过无密码限额，剩余额度为%.2f，设置支付密码可提高限额", _accountModel.dayQuota.remain);

    //NSString *message = @"为了您的账户安全，需要通过一张银行卡验证您的身份信息";
    
    NSString *title = _accountModel.bankCards.count ? @"绑定" : @"设置";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:title, nil];
    
    rpWeakSelf;
    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  设置交易密码
            [weakSelf showSetPayPassViewController:PayType];
        }
    };
    [alert show];
}

- (void)alertPassRetryLimit
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"支付密码输入次数超限，可点击'忘记密码'重新设置" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"忘记密码", nil];
    
    rpWeakSelf;
    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  找回密码
            [weakSelf showSetPayPassViewController:ForgetTpe];
        }
    };
    [alert show];
}

- (void)alertValidateUserIDCard:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"上传", nil];
    
    rpWeakSelf;
    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  验证身份信息
            [weakSelf showValidateUserIDCard:nil];
        }
    };
    [alert show];
}

- (void)alertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    [alert show];
}

- (void)showValidateUserIDCard:(NSString *)errMsg
{
    ValidateUserIDController *validate = [[ValidateUserIDController alloc] initWithStyle:UITableViewStyleGrouped];
    validate.isValidateFalid = YES;
    validate.validateMsg = errMsg;

    [self.navigationController pushViewController:validate animated:YES];
}

- (void)showVerifyIDCardViewController
{
    ValidatedeNameTableViewController *controller = [[ValidatedeNameTableViewController alloc] init];
    controller.isWithDrawing = YES;
    controller.isVerify = YES;
    controller.delegate = self;
    controller.titleType = VerificationType;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)showBindCardAndPayViewController
{
    ValidatedeNameTableViewController *controller = [[ValidatedeNameTableViewController alloc] init];
    controller.delegate = self;
    controller.titleType = AddType;
    controller.moneyAccount = rpString(@"%.2f", [self getAffordMoney]);
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

//  绑卡成功并发送红包的回调
- (void)rebackwithApplyPaymentModel:(ApplyPaymentModel *)model
{
    [self removeAllViews];
    _paymentModel = model;
    [self requestUserWallet];
}

/**
 *  通过绑定银行卡并设置密码 可以提高限额
 */
- (void)showSetPayPassViewController:(ShowType)titleType
{
    ValidatedeNameTableViewController *controller = [[ValidatedeNameTableViewController alloc] init];
    controller.isWithDrawing = YES;
    controller.delegate = self;
    controller.titleType = titleType;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

/**
 *  设置支付密码成功
 */
- (void)rebackToChange
{
    [YZHRedpacketGlobal shareInstance].isSetPassWordSha256 = YES;
    [self requestRedpacketSetting];
    [self requestUserWallet];
}

/*------------------------------------------
 *  群红包
 ------------------------------------------*/

- (void)showPayViewWithCount:(int)count with:(NSString *)str with:(NSString *)groupID with:(NSString *)type
{
    if ([_groupType isEqualToString:@"rand"]|| [_groupType isEqualToString:@"member"]) {
        CGFloat money =[self.priceField.text floatValue];
        CGFloat numbers = [self.totalRedPacketField.text floatValue];
        if (money/numbers > 0.00999 || money/numbers == 0.01) {
            [self requestUserWallet];
            
        }else{
            [self.view rp_showHudErrorView:@"单个红包金额不可低于0.01元"];
        }
        
    }else{
        [self requestUserWallet];
        
    }
    //群红包参数赋值
    _groupNumbers = count;
    _groupType = type;
}

- (void)removeTelView
{
    [_telView removeFromSuperview];
    _telView = nil;
    
    [YZTransparent removeFromSuperView];
}

- (void)removeAllViews
{
    [self removeTelView];
    
    [self removePayView];
}

- (void)popSubView:(UIView *)view
{
    rpWeakSelf;
    CGPoint center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame) / 2);
    CGRect frame = view.frame;
    frame.origin = CGPointMake(center.x - CGRectGetWidth(frame) / 2, center.y - CGRectGetHeight(frame) / 2);
    view.frame = frame;
    [weakSelf.view rp_popupSubView:view atPosition:PopAnchorCenterX | PopAnchorCenterY];
}

#pragma mark - Requests

- (void)cancelThridPayPartNotifaction:(NSNotification *)notifaction
{
    [_promptView removeFromSuperview];
    [self removeAllViews];
    [self.view rp_removeHudInManaual];
}

//  MARK: 微信支付
- (void)sendWechatInfoRequest
{
    _promptView = [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    NSString *affordMoney = rpString(@"%.2f", [self getAffordMoney]);
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        [weakSelf.view rp_removeHudInManaual];
        [weakSelf requestWechatPayView:data];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
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
    request.timeStamp= [dict[@"timestamp"] longLongValue];
    request.sign= dict[@"sign"];
    [WXApi sendReq:request];
}

- (void)wechatPayCallBackNotifaction:(NSNotification *)notifaction
{
    rpWeakSelf;
    if (self.billRef) {
        if ([notifaction.object isKindOfClass:[PayResp class]]){
            PayResp*response=(PayResp*)notifaction.object;
            switch(response.errCode){
                case WXSuccess:
                    //服务器端查询支付通知或查询API返回的结果再提示成功
                    [weakSelf sendRedpacketRequest];
                    [weakSelf presistentIsRedpacketAffordByWechat:YES];
                    break;
                default:
                    //微信支付失败或者被取消
                    [weakSelf.view rp_showHudErrorView:@"支付失败"];
                    [weakSelf removeAllViews];
                    break;
            }
        }
    }else {
        
        
    }
}

//  MARK: 请求支付宝信息
- (void)sendAlipayInfoRequest
{
    _promptView = [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    NSString *affordMoney = rpString(@"%.2f", [self getAffordMoney]);
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        [weakSelf.view rp_removeHudInManaual];
        weakSelf.billRef = [NSString stringWithFormat:@"%@", [data objectForKey:@"BillRef"]];
        NSString *orderString = [data rp_stringForKey:@"OrderInfo"];
        NSString *urlScheme = [YZHRedpacketBridge sharedBridge].redacketURLScheme;
        if (urlScheme.length == 0) {
            NSLog(@"urlScheme为空，不能调用支付宝");
            return;
        }
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:urlScheme callback:^(NSDictionary *resultDic) {
            NSInteger code = [[resultDic rp_stringIntForKey:@"resultStatus"] integerValue];
            if (code == 9000) {
                [weakSelf sendRedpacketRequest];
                [weakSelf persistentIsRedpacketAffodByAlipay:YES];
                
            }else {
                [weakSelf.view rp_showHudErrorView:@"支付失败"];
                [weakSelf removeAllViews];
            }
            
            NSLog(@"reslut = %@",resultDic);
        }];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
        [weakSelf removeAllViews];
    }];
    
    [request requestAlipayInfo:affordMoney];
}

- (void)alipayCallBack:(NSNotification *)notifaction
{
    if (self.billRef) {
        if ([notifaction.object isKindOfClass:[NSDictionary class]]) {
            NSInteger code = [[notifaction.object valueForKey:@"resultStatus"] integerValue];
            if (code == 9000) {
                [self persistentIsRedpacketAffodByAlipay:YES];
                [self sendRedpacketRequest];
                
            }else {
                _billRef = nil;
                [self.view rp_showHudErrorView:@"支付失败"];
                [self removeAllViews];
            }
            
        }else {
            _billRef = nil;
            [_promptView removeFromSuperview];
            [self removeAllViews];
            [self.view rp_removeHudInManaual];
        }
        
    }else {
        //  收到无效Alipay通知
        
    }
}

- (void)persistentIsRedpacketAffodByAlipay:(BOOL)used
{
    _isAlipayLastpay = used;
    //  记录当前支付方式是支付宝
    [[NSUserDefaults standardUserDefaults] setValue:@(used) forKey:IsAlipayLastpayKey];
}

- (void)presistentIsRedpacketAffordByWechat:(BOOL)isWechat
{
    _isWechatLastpay = isWechat;
    //  记录当前支付方式是微信支付
    
    [[NSUserDefaults standardUserDefaults] setValue:@(isWechat) forKey:IsWechatLastpayKey];
}

//  MARK:发送红包请求
- (void)sendRedpacketRequest
{
    RedpacketMessageModel *model = [RedpacketMessageModel new];
    NSString *message = [self.textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (_textView.text.length > 0) {
        message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        message = _textView.placeholder;
    }
    
    model.redpacket.redpacketMoney = rpString(@"%.2f", [self getAffordMoney]);
    model.redpacketReceiver.userId = self.conversationInfo.userId;
    model.redpacket.redpacketGreeting = message;
    model.redpacketId = self.redpacketId;
    model.redpacketSender = model.currentUser;
    
    if (_isGrop) {
        model.redpacket.redpacketCount = _groupNumbers;
        model.redpacket.groupRedpacketType = _groupType;
        [model redpacketTypeVoluationWithGroupType:_groupType];
        model.redpacket.toReceiverDuid = _userId;
    }
    
    //  需要交易密码, 如果对方没有绑卡设密码， 200块钱以内是可以免密支付
    if (self.userPass.length == 0) {
        self.userPass = @"";
        
    }else {
        
    }
    
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        //  回调发送红包
        [weakSelf invokeSendRedpacketCallback:dict];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == NSIntegerMax) {
            [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
            
        }else {
            if (code == 3002) {
                //  余额不足
                [weakSelf.view rp_removeHudInManaual];
                [weakSelf removeAllViews];
                [weakSelf alertWithMessage:error];
                
            }else if (code == 3005) {
                [weakSelf.view rp_removeHudInManaual];
                [weakSelf removeAllViews];
                
                //  FIXME:密码使用次数达到限制后。。。
                [weakSelf alertPassRetryLimit];
                
            }else if (code == 101){
                //  设备号变更，需要短信验证
                [weakSelf.payTypeView removeFromSuperview];
                [weakSelf.view rp_removeHudInManaual];
                
                [weakSelf requestTelSMSAndShowView:YES];
            
            }else if (code == 1021 || code == 1024) {
                //  零钱累计支付超过1000， 或者身份证审核未通过
                [weakSelf removeAllViews];
                [weakSelf alertValidateUserIDCard:error];
                
            }else if (code == 1023) {
                //  身份信息正在审核中
                [weakSelf removeAllViews];
                [weakSelf alertWithMessage:error];
                
            }else {
                
                if (code == 3003) {
                    //  密码错误
                    [weakSelf.view rp_showHudErrorView:error];
                    [weakSelf.payTypeView passwordInputError:YES];
                    
                }else {
                    [weakSelf.view rp_removeHudInManaual];
                    [weakSelf alertWithMessage:error];
                    [weakSelf removeAllViews];
                }
            }
        }
    }];
    
    NSString *billRef = _billRef;
    //  清空本地的流水号
    _billRef = nil;
    if (billRef.length == 0) {
        billRef = _paymentModel.billRef;
    }
    
    [request sendRedpacketByModel:model andPayPass:self.userPass orTradeNum:billRef];
}

- (void)showTelphoneValidate:(NSDictionary *)dict
{
    YZTelphoneValidateView *telView = [[[NSBundle RedpacketBundle] loadNibNamed:NSStringFromClass([YZTelphoneValidateView class]) owner:self options:nil] lastObject];
    
    _telView = telView;
    
    telView.telphone = [dict rp_stringForKey:@"TelSuffix"];
    NSString *billRef = [dict rp_stringForKey:@"BillRef"];
    _smsBillRef = billRef;
    [telView becomeFristResponder];
    
    rpWeakSelf;
    [telView setPassFinishBlock:^(NSString *pass) {
        [weakSelf requestTelSMSValidate:pass andBillRef:_smsBillRef];
    }];
    
    [telView setReSendButtonBlock:^(YZTelphoneValidateView *view) {
        [weakSelf requestTelSMSAndShowView:NO];
    }];
    
    [telView setCloseButtonBlock:^(YZTelphoneValidateView *view) {
        [view removeFromSuperview];
        [weakSelf removeAllViews];
    }];
    
    [self popSubView:telView];
}

//  请求京东支付验证码
- (void)requestJDPaySMSAtCardIndex:(NSInteger)index
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        /**
         *  京东支付订单号
         */
        weakSelf.paymentModel.billRef = [data rp_stringForKey:@"BillRef"];
        [weakSelf.payTypeView timerRun];
        [weakSelf.view rp_removeHudInManaual];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf.payTypeView timerStop];
        
        if (code == NSUIntegerMax) {
            [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
            
        }else {
            [weakSelf.view rp_removeHudInManaual];
            [weakSelf.view rp_showHudErrorView:error];
        }
    }];
    
    ApplyPaymentModel *model = _paymentModel;
    if (!model) {
        model = [ApplyPaymentModel new];
        _paymentModel = model;
        model.amount = [NSString stringWithFormat:@"%.2f", [self getAffordMoney]];
    }
    
    {
        // 设置支付卡
        if (index < 0) {
            //  当支付界面出现时，用支付界面上的索引值
            index = _payTypeView.bankSelectionIndex;
        }
        
        if (!model.cardInfo) {
            model.cardInfo = [BindCardInfo new];
        }
        
        YZHBankInfo *bankInfo = [_accountModel.bankCards objectAtIndex:index];
        model.cardInfo.cardId = bankInfo.cardID;
    }
    
    [request applyForRedpacketPaymentWithApplyPayment:model];
}

//  验证京东请求支付验证码
- (void)requestValidateAppleyPaymentTelSMS
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        //  京东支付验证码验证成功后发送红包
        [weakSelf sendRedpacketRequest];
        [weakSelf persistentIsRedpacketAffodByAlipay:NO];
        [weakSelf presistentIsRedpacketAffordByWechat:NO];
        [weakSelf.view rp_removeHudInManaual];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == NSIntegerMax) {
            [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
        }else if (code ==  100) {
            //???
            [weakSelf.view rp_removeHudInManaual];
            [weakSelf.payTypeView passwordInputError:YES];
            
        }else if (code == 1005) {
            //  验证码错误
            [weakSelf.view rp_showHudErrorView:error];
            [weakSelf.payTypeView passwordInputError:YES];
            
        }else {
            [weakSelf removeAllViews];
            [weakSelf alertWithMessage:error];
        }
  }];
    
    [request confirmPaymentWithApplyPayment:_paymentModel];
}

//  请求设备变更验证码
- (void)requestTelSMSAndShowView:(BOOL)shouldShow
{
    [self.view rp_removeHudInManaual];
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        [weakSelf.view rp_removeHudInManaual];
        
        weakSelf.smsBillRef = [dict valueForKey:@"BillRef"];
        if (shouldShow) {
            [weakSelf showTelphoneValidate:dict];
        }
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == NSIntegerMax) {
            [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
        }else {
            [weakSelf.view rp_showHudErrorView:error];
        }
        
        [weakSelf removeAllViews];
    }];
    
    [request deviceChangedSMSRequest];
}

//  验证设备变更验证码
- (void)requestTelSMSValidate:(NSString *)validateCode andBillRef:(NSString *)billRef
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        
        weakSelf.billRef = [data valueForKey:@"BillRef"];
        [weakSelf removeTelView];
        [weakSelf sendRedpacketRequest];

    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == NSIntegerMax) {
            [weakSelf.view rp_showHudErrorView:YZHPromptTypeError];
        }else {
            [weakSelf.telView clearInputField];
            [weakSelf.view rp_showHudErrorView:error];
        }
    }];
    
    [request deviceChangedSMSVerify:validateCode andBillRef:billRef];
}

//  发红包接口成功后，回调环信的消息接口。
- (void)invokeSendRedpacketCallback:(NSDictionary *)dict
{
    RedpacketMessageModel *model = [[RedpacketMessageModel alloc] init];
    model.messageType = RedpacketMessageTypeRedpacket;
    if (_isGrop) {
          model.redpacket.groupRedpacketType = _groupType;
        model.redpacket.toReceiverDuid = _userId;
    }
    [model configWithRedpacketDic:dict];
    
    if (self.sendRedPacketBlock) {
        NSString *blessString = [self.textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if (_textView.text.length > 0) {
            blessString = [blessString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }else{
            blessString = _textView.placeholder;
        }

        model.redpacket.redpacketGreeting = blessString;
        
        model.redpacketReceiver = self.conversationInfo;
        
    }
    
    rpWeakSelf;
    [self dismissViewControllerAnimated:YES completion:^{
            weakSelf.sendRedPacketBlock(model);
    }];
}

#pragma mark - TextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 30) {
        textView.text = [textView.text substringToIndex:30];
    }
}

#pragma mark - SubViewsConfig

- (void)configSubViews
{
    _backView1.backgroundColor = [UIColor whiteColor];
    _backView2.backgroundColor = [UIColor whiteColor];
    
    [self changeLabelsWarning:NO];
    
    _priceBigLabel.text    = @"¥0.00";
    _priceBigLabel.rp_centerX = self.view.rp_centerX;
    _priceBigLabel.rp_width = self.view.rp_width;
    _priceBigLabel.textAlignment = NSTextAlignmentCenter;
    
    _priceField.placeholder  = @"填写金额";
    _priceField.delegate     = self;
    _priceField.keyboardType = UIKeyboardTypeDecimalPad;

    _textView.delegate       = self;
    _textView.textColor      = [RedpacketColorStore rp_textColorBlack];
    _textView.font = [UIFont systemFontOfSize:15.0];
    _textView.placeholder    = @"恭喜发财，大吉大利！";

    
    _submitButton.enabled = NO;
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitButton setBackgroundColor:[RedpacketColorStore rp_redButtonDisableColor]];
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius  = 3.0f;

    _describeLabel.textColor = [RedpacketColorStore rp_textColorGray];
    
    [_blessButton setImage:rpRedpacketBundleImage(@"redpacket_redpacketSend_luckBless") forState:UIControlStateNormal];
    _blessButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)changeLabelsWarning:(BOOL)warning
{
    UIColor *titleColor = warning ? [RedpacketColorStore rp_textColorRed] : [RedpacketColorStore rp_textColorBlack];
    
    self.titleLabel.textColor = titleColor;
    self.priceLabel.textColor = titleColor;
    self.priceField.textColor = titleColor;
}

- (void)addHelpBarButtonItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:rpRedpacketBundleImage(@"redpacket_FAQ") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(helpBarButtonSender) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *btn_left = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    negativeSpacer.width = - 8;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, btn_left, nil];
}

- (IBAction)blessSender:(id)sender
{
    _textView.text = [self blessString];
}

- (NSString *)blessString
{
    static int i = 1;
    NSArray *blessArray = [self blessArray];
    
    if (i == blessArray.count ) {
        i = 0;
    }
    
    return blessArray[i++];
}

- (NSArray *)blessArray
{
    //GreetingsArray 红包祝福语
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *GreetingsArray = [defaults arrayForKey:@"GreetingsArray"];
    
    if (GreetingsArray.count > 1) {
        return GreetingsArray;
    }
    return @[@"恭喜发财，大吉大利！",
             @"情绪不对，红包安慰！",
             @"打赏你哒！",
             @"膜拜大神Orz",
             @"约起来吧！"];
}

#pragma mark - Notifaction

- (void)addKeyboardNotifaction
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)addRedpacketNotifaction
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelThridPayPartNotifaction:) name:RedpacketCancelPayNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayCallBack:) name:RedpacketAlipayNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechatPayCallBackNotifaction:) name:RedpacketWechatPayNotifaction object:nil];
}

- (void)removeKeyboardNotifaction
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardDidAppear:(NSNotification *)noti
{
    CGRect keyboardFrame = [[noti.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    UIView *topView = [self topInputView];
    CGFloat interval = CGRectGetMinY(keyboardFrame) - topView.rp_bottom - 64;
    if (interval < 0) {
        [UIView animateWithDuration:.25 animations:^{
            topView.rp_top = topView.rp_top + interval;
        }];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)noti
{
    UIView *topView = [self topInputView];
    [UIView animateWithDuration:.25 animations:^{
        CGPoint center = self.view.center;
        center.y -= 100;
        topView.center = center;
    }];
}

- (UIView *)topInputView
{
    UIView *topView;
    if (_payTypeView && _payTypeView.superview) {
        topView = _payTypeView;
    }else {
        topView = _telView;
    }
    
    return topView;
}

#pragma mark - modifyLessFunctions

- (void)clickButtonLeft
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)helpBarButtonSender
{
    UIViewController *controller = [RedpacketWebController myRechangeQaWebControllerWithTitleColor:[RedpacketColorStore rp_textColorBlack]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)backButtonSender
{
    [self.view endEditing:YES];
}

#pragma mark - ViewStyle
- (void)configViewStyle
{
    self.navigationController.navigationBar.barTintColor   = [RedpacketColorStore rp_textColorRed];
    self.navigationController.navigationBar.barStyle       = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent    = NO;
    self.navigationController.navigationBar.tintColor      = [UIColor whiteColor];
    self.navigationController.navigationBar.backItem.title = @"";
    
    self.navigationController.navigationBar.backIndicatorImage = rpRedpacketBundleImage(@"redpacket_navigationbar_return");
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = rpRedpacketBundleImage(@"redpacket_navigationbar_return");
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:18]};
    
    self.view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    
    [self clearBackBarButtonItemTitle];
}

- (void)clearBackBarButtonItemTitle
{
    //  左侧返回标题为空
    UIBarButtonItem *returnButtonItem     = [[UIBarButtonItem alloc] init];
    returnButtonItem.title                = @"";
    self.navigationItem.backBarButtonItem = returnButtonItem;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UILabel *)warnPromptLabel
{
    if (!_warnPromptLabel) {
        _warnPromptLabel = [[UILabel alloc]init];
        _warnPromptLabel.backgroundColor = [UIColor colorWithRed:161/255.0 green:23/255.0 blue:16/255.0 alpha:1.0];
        _warnPromptLabel.textColor = [UIColor colorWithRed:240/255.0 green:220/255.0 blue:74/255.0 alpha:1];
        _warnPromptLabel.textAlignment = NSTextAlignmentCenter;
        _warnPromptLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _warnPromptLabel;
}

- (void)addWarmPromtLableWith:(NSString *)content
{
    if (self.warnPromptLabel.frame.origin.x == 0.01) {
        
    }else{
    [self.view addSubview:self.warnPromptLabel];
    self.warnPromptLabel.text = content;
    self.warnPromptLabel.frame = CGRectMake(0, -25, [UIScreen mainScreen].bounds.size.width,25);
    [UIView animateWithDuration:0.5 animations:^{
        self.warnPromptLabel.frame = CGRectMake(0, 0.01, [UIScreen mainScreen].bounds.size.width,25);
    }];
    }
}

- (void)delWarmPromtLable
{
    [UIView animateWithDuration:0.5 animations:^{
        self.warnPromptLabel.frame = CGRectMake(0, -25, [UIScreen mainScreen].bounds.size.width,25);
    } completion:^(BOOL finished) {
        [self.view willRemoveSubview:self.warnPromptLabel];
    }];
}

// textView键盘遮挡问
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self unregisterForKeyboardNotifications];
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (_textView.isFirstResponder == YES && _isGrop == YES && ([UIScreen mainScreen].bounds.size.height - 365 < keyboardRect.size.height)) {
        NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView beginAnimations:@"TEXTVIEW_KEYBOARD" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = CGRectMake(0, _viewFrame.origin.y - keyboardRect.size.height + 80, _viewFrame.size.width, _viewFrame.size.height);
        [UIView commitAnimations];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification{
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"TEXTVIEW_KEYBOARD" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = _viewFrame;
    [UIView commitAnimations];
}
@end

