//
//  RedpacketSendControl.m
//  RedpacketLib
//
//  Created by Mr.Yang on 2016/10/17.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketSendControl.h"
#import "RedpacketDataRequester.h"
#import "RPRedpacketTool.h"
#import "RPRedpacketPayManager.h"
#import "UIView+YZHPrompting.h"
#import "RPRedpacketDeviceChangeControl.h"
#import "UIAlertView+YZHAlert.h"
#import "RPValidateNameViewController.h"
#import "ValidateUserIDController.h"
#import "RedpacketErrorCode.h"
#import "RedpacketViewControl+RedpacketID.h"
#import "UIViewController+RP_Private.h"


#ifdef AliAuthPay

#import "RPAliAuthPay.h"

#endif

#define RPPayController self.payController
#define RPPayView   RPPayController.view
#define RPWeakPayView __weak UIView* weakPayView = RPPayController.view


static RPRedpacketSendControl *__redpacketSendControl = nil;

static RPRedpacketDeviceChangeControl *deviceControl;

@interface RPRedpacketSendControl() <RPValidatedeDelegate>

#ifdef AliAuthPay
@property (nonatomic, strong) RPAliAuthPay *authPay;
#endif

@property (nonatomic, copy) NSString *userPass;
@property (nonatomic, copy) NSString *redpacketID;

@property (nonatomic, weak) UIViewController *payController;
@property (nonatomic, strong)   RedpacketMessageModel *redpacketModel;
@property (nonatomic, copy) RedpacketSendSccessBlock sendSuccessBlock;


/// 子类重写
- (void)requestWithRequester:(RedpacketDataRequester *)request;

@end


@implementation RPRedpacketSendControl

- (void)dealloc
{
    RPDebug(@"~~dealloc:%@", NSStringFromClass([self class]));
    
    [RPRedpacketPayManager releasePayManager];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)currentControl
{
    if (!__redpacketSendControl) {
        __redpacketSendControl = [[[self class] alloc] init];
        [__redpacketSendControl addKeyboardNotifaction];
    }

    return __redpacketSendControl;
}

+ (void)releaseSendControl
{
    __redpacketSendControl = nil;
}

#pragma mark RequestIDs
- (void)requestIDWithBlock:(void(^)(void))successBlock
{
    [RPPayView rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RPWeakPayView;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        
        weakSelf.redpacketID = [dict valueForKey:@"ID"];
        
        /* 回调RedpacketID **/
        RedpacketViewControl *currentControl = self.hostViewController.rp_control;
        if (currentControl) {
            if (currentControl.generateBlock) {
                currentControl.generateBlock(weakSelf.redpacketID);
            }
        }
        
        if (successBlock) {
            successBlock();
        }
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == NSIntegerMax) {
            
            [weakPayView rp_removeHudInManaual];
            [weakPayView rp_showHudErrorView:error];
            
        }else {
            
            [weakPayView rp_showHudErrorView:error];
            
        }
        
    }];
    
    [self requestWithRequester:request];
}

- (void)requestWithRequester:(RedpacketDataRequester *)request
{
    [request requestRedpacketID];
}

- (void)payMoney:(NSString *)money withMessageModel:(RedpacketMessageModel *)model
                                       inController:(UIViewController *)viewController
                                    andSuccessBlock:(RedpacketSendSccessBlock)successBlock
{
    _payController = viewController;
    _redpacketModel = model;
    _sendSuccessBlock = successBlock;
    
    if (_redpacketID.length == 0) {
        
        rpWeakSelf;
        [self requestIDWithBlock:^{
            
            [weakSelf payMoneyInPayControl:money];
            
        }];
        
    }else {
        
        [self payMoneyInPayControl:money];
        
    }
}

- (void)payMoneyInPayControl:(NSString *)money
{
#ifdef AliAuthPay
    _authPay = [RPAliAuthPay new];
    rpWeakSelf;
    [_payController.view endEditing:YES];
    [_authPay payMoney:money inController:self.payController andFinishBlock:^(NSString *billRef) {
        
        [weakSelf sendRedpacketRequestWithRedpacketID:weakSelf.redpacketID
                                          andUserPass:nil
                                            orBillRef:billRef];
    }];
#else
    rpWeakSelf;
    [[RPRedpacketPayManager currentManager] payMoney:money
                                        inController:self.payController
                                withRedpacketPayType:RedpacketPayUseTypeRedpacketSend
                                         andPayBlock:^(NSString *billRef, NSString *password) {
                                             
                                             [weakSelf sendRedpacketRequestWithRedpacketID:weakSelf.redpacketID
                                                                               andUserPass:password
                                                                                 orBillRef:billRef];
                                         }];
#endif
}

#pragma mark  - SendRedpacekt

//  MARK:发送红包请求
- (void)sendRedpacketRequestWithRedpacketID:(NSString *)redpacketID
                                andUserPass:(NSString *)userPass
                                  orBillRef:(NSString *)billRef
{
    [RPPayView rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    RPWeakPayView;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        //  回调发送红包
        if (weakSelf.redpacketModel.redpacketType == RedpacketTransfer) {
            weakSelf.redpacketModel.redpacket.tranferTime = [dict rp_stringIntForKey:@"DateTime"];
        }
        
        if (weakSelf.sendSuccessBlock){
            weakSelf.sendSuccessBlock(weakSelf.redpacketModel);
            __redpacketSendControl = nil;
        }
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == NSIntegerMax) {
            [weakSelf payJudgementNoticeWithBillRef:billRef
                                          withModel:weakSelf.redpacketModel];
            
        }else {
            if (code == RedpacketHBMoneyInsuf) {//需要将数字改成type类型
                //  余额不足
                [weakPayView rp_removeHudInManaual];
                [[RPRedpacketPayManager currentManager] removeAllViews];
                [weakSelf alertWithMessage:error];
                
            }else if (code == RedpacketHBPayPWDErrorLimit) {//需要将数字改成type类型
                [weakPayView rp_removeHudInManaual];
                [[RPRedpacketPayManager currentManager] removeAllViews];
                
                //  FIXME:密码使用次数达到限制后。。。
                [weakSelf alertPassRetryLimitWithMessage:error];
                
            }else if (code == RedpacketChangeDevice){//需要将数字改成type类型
                //  设备号变更，需要短信验证
                [[RPRedpacketPayManager currentManager] removeAllViews];
                
                deviceControl = [RPRedpacketDeviceChangeControl showValidateTelViewOnController:weakSelf.payController
                                                                               andValidateBlock:^(BOOL isSuccess) {
                                                                                   if (isSuccess) {
                                                                                       
                                                                                       [weakSelf sendRedpacketRequestWithRedpacketID:redpacketID
                                                                                                                         andUserPass:userPass
                                                                                                                           orBillRef:billRef];
                                                                                       
                                                                                   }else {
                                                                                       [[RPRedpacketPayManager currentManager] removeAllViews];
                                                                                   }
                                                                                   
                                                                                   deviceControl = nil;
                                                                               }];
                
            }else if (code == RedpacketVerifyIDCard || code == RedpacketVerifyIDCardFailed) {
                //  零钱累计支付超过1000， 或者身份证审核未通过
                [[RPRedpacketPayManager currentManager] removeAllViews];
                [weakSelf alertValidateUserIDCard:error];
                
            }else if (code == RedpacketVerifyIDCarding) {
                //  身份信息正在审核中
                [[RPRedpacketPayManager currentManager] removeAllViews];
                [weakSelf alertWithMessage:error];
                
            }else if (code == RedpacketHBPayPWDFailed) {
                //  密码错误
                [[RPRedpacketPayManager currentManager] passwordInputError:error];
                [weakPayView rp_removeHudInManaual];
                
            }else if(code == RedpacketHBQuotaNoPayPWD){
                //超过无密码支付剩余额度
                [weakPayView rp_removeHudInManaual];
                [weakSelf alertViewWithMessage:error];
                
            }else{
                [weakPayView rp_removeHudInManaual];
                [weakSelf alertWithMessage:error];
            }
        }
        
    }];
    
    self.redpacketModel.redpacketId = redpacketID;
    
    [self sendPayURLRequest:request
           byRedpacketModel:self.redpacketModel
                withPayPass:userPass
                orTradeNumb:billRef];
}

- (void)sendPayURLRequest:(RedpacketDataRequester *)request
         byRedpacketModel:(RedpacketMessageModel *)model
              withPayPass:(NSString *)userPass
              orTradeNumb:(NSString *)billRef
{
    [request sendRedpacketByModel:model andPayPass:userPass orTradeNum:billRef];
}

- (void)alertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
    
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

- (void)alertPassRetryLimitWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"忘记密码", nil];
    
    rpWeakSelf;
    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  找回密码
            [weakSelf showSetPayPassViewController:BindingCardTypeForgetPass];
        }
    };
    [alert show];
}

- (void)alertViewWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@,请前往设置支付密码",message] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    rpWeakSelf;
    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  找回密码
            [weakSelf showSetPayPassViewController:BindingCardTypeSetPassword];
        }
    };
    [alert show];
}

//支付完成，回调逻辑。错误显示文案。
- (void)payJudgementNoticeWithBillRef:(NSString *)billRef withModel:(RedpacketMessageModel *)model
{
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        if (weakSelf.redpacketModel.redpacketType == RedpacketTransfer) {
            weakSelf.redpacketModel.redpacket.tranferTime = [dict rp_stringIntForKey:@"DateTime"];
        }
        
        if (weakSelf.sendSuccessBlock){
            weakSelf.sendSuccessBlock(weakSelf.redpacketModel);
            __redpacketSendControl = nil;
        }
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == RedpacketHBExpried) {
            //需要将数字改成type类型
            if (billRef) {
                NSString *message = [NSString stringWithFormat:@"网络异常，发送失败。支付的%@元已存入零钱，可下次发送时使用。",model.redpacket.redpacketMoney];
#ifdef AliAuthPay
                
                message = @"红包发送失败，若已扣款，24小时后会为您退款。";
                
#endif
                
                [weakSelf alertWithMessage:message];
            }else{
                [weakSelf alertWithMessage:@"网络异常，红包发送失败，请稍后重试。"];
            }
        }else {
            
            [weakSelf alertWithMessage:error];
        }
    }];
    
    [request checkRedpacketIsExist:model.redpacketId];
    
}

#pragma mark - Controllers
/**
 *  通过绑定银行卡并设置密码 可以提高限额
 */
- (void)showSetPayPassViewController:(BindingCardType)bindingCardType
{
    RPValidateNameViewController *controller = [[RPValidateNameViewController alloc] init];
    controller.bindingCardType = bindingCardType;
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
    UIView *payView = [RPRedpacketPayManager currentManager].payTypeView;
    UIView *phoneView = deviceControl.validateView;
    
    if ( payView && payView.superview) {
        topView = payView;
        
    }else if (phoneView && phoneView.superview){
        topView = phoneView;
        
    }
    
    return topView;
}

@end


@implementation RPRedpacketTransferControl

- (void)requestWithRequester:(RedpacketDataRequester *)request
{
    [request requestTransferID];
}

- (void)sendPayURLRequest:(RedpacketDataRequester *)request
         byRedpacketModel:(RedpacketMessageModel *)model
              withPayPass:(NSString *)userPass
              orTradeNumb:(NSString *)billRef
{
    [request transferByModel:model andPayPass:userPass orTradeNum:billRef];
}

- (void)payMoneyInPayControl:(NSString *)money
{
    rpWeakSelf;
    [[RPRedpacketPayManager currentManager] payMoney:money
                                        inController:self.payController
                                withRedpacketPayType:RedpacketPayUseTypeTransfer
                                         andPayBlock:^(NSString *billRef, NSString *password) {
                                             
                                             [weakSelf sendRedpacketRequestWithRedpacketID:weakSelf.redpacketID
                                                                               andUserPass:password
                                                                                 orBillRef:billRef];
                                         }];
}

@end

