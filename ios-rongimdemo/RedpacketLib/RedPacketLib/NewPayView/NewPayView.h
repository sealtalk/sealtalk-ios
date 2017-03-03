//
//  NewPayView.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAccoutModel.h"

typedef NS_ENUM(NSUInteger, RDPayType) {
    /**
     *  免密支付
     */
    RDPayTypeWithNoPass = 1,
    /**
     *  超过免密支付的额度
     */
    RDPayTypeExceedNoPass,
    /**
     *  密码支付
     */
    RDPayTypeWithPass,
    /**
     *  提现
     */
    RDPayTypeWithDrawMoney,
    /**
     *  短信验证支付
     */
    RDPayTypeWithValidateCode,
    /**
     *  没有零钱也没有银行卡
     */
    RDPayTypeWithNoMoneyAndNoCard,
    /**
     *  零钱不足且没有银行卡
     */
    RDPayTypeMoneNotEnoughAndNoCard,
    /**
     *  支付宝支付
     */
    RDPayTypeAlipay,
    /**
     *  微信支付
     */
    RDPayTypeWeChatPay
};

typedef NS_ENUM(NSInteger, RDButtonActionType) {
    /**
     *   免密支付的确定
     */
    RDButtonActionTypePay = 1,
    /**
     *   关闭对话框
     */
    RDButtonActionTypeClose,
    /**
     *  忘记密码
     */
    RDButtonActionTypeForgotPass,
    /**
     *  重新发送验证码
     */
    RDButtonActionTypeResendCode,
    /**
     *  密码输入完成
     */
    RDButtonActionTypePassFinished

};

@class NewPayView;

typedef void(^PayTypeSelectionBlock)(YZHPayInfo *payInfo);
typedef void(^BackButtonBlock)(NewPayView *payView, RDButtonActionType type, NSString *pass);

@interface NewPayView : UIView

@property (nonatomic, copy  ) PayTypeSelectionBlock selectionBlock;
@property (nonatomic, copy  ) BackButtonBlock       buttonActionBlock;
@property (nonatomic, assign) RDPayType             payType;
@property (nonatomic, strong) YZHPayInfo            *payInfo;

- (instancetype)initWithRecharge;
- (instancetype)initWithTransfer;

- (void)refreshTypeView;

- (void)configWithModel:(UserAccoutModel *)model;

@end


@interface NewPayView (InputView)

- (void)becomeFirstResponder;
- (void)resignFirstResponder;

- (void)clearPassword;

//  Private
- (void)passwordInputError:(BOOL)error;

@end


@interface NewPayView (ValidateTimer)

//  销毁计时器
- (void)destoryTimer;
/**
 *  检测计时器是否在运行
 */
- (BOOL)isTimerValid;

/**
 *  开始计时
 */
- (void)timerRun;

/**
 *  停止计时
 */
- (void)timerStop;

//  Private
- (void)secondRuning;

@end


@interface NewPaySelectionView : NewPayView

- (instancetype)initWithRecharge;
- (instancetype)initWithTransfer;

@end
