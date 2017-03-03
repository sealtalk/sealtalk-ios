//
//  RedpacketDeviceChangeControl.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/10/14.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketDeviceChangeControl.h"
#import "RPRedpacketTool.h"
#import "NSBundle+RedpacketBundle.h"
#import "NSDictionary+YZHExtern.h"
#import "UIView+YZHPrompting.h"
#import "RedpacketDataRequester.h"
#import "RPValidateNameViewController.h"
#import "UIAlertView+YZHAlert.h"
#import "YZTransparent.h"
#import "RedpacketErrorCode.h"

@interface RPRedpacketDeviceChangeControl () <RPValidatedeDelegate>

@property (nonatomic, weak) UIViewController *showViewController;
@property (nonatomic, copy) DeviceChangeBlock changeBlock;
@property (nonatomic, copy) NSString *billRef;

@end


@implementation RPRedpacketDeviceChangeControl

- (void)dealloc
{
    RPDealloc;
}

+ (RPRedpacketDeviceChangeControl *)showValidateTelViewOnController:(UIViewController *)controller
                                                   andValidateBlock:(DeviceChangeBlock)changeBlock
{
    RPRedpacketDeviceChangeControl *control = [RPRedpacketDeviceChangeControl new];
    control.showViewController = controller;
    control.changeBlock = changeBlock;
    [control requestTelSMSAndShowView:YES];
    
    return control;
}

#pragma mark -  短信验证身份
- (void)showTelphoneValidateWithPhoneSuffix:(NSString *)phoneSuffix
{
    RPTelphoneValidateView *telView = [RPTelphoneValidateView new];
    
    _validateView = telView;
    
    telView.telphone = phoneSuffix;
    
    [telView becomeFristResponder];
    
    rpWeakSelf;
    [telView setPassFinishBlock:^(NSString *validateCode) {
        [weakSelf requestTelSMSValidate:validateCode andBillRef:weakSelf.billRef];
    }];
    
    [telView setReSendButtonBlock:^(RPTelphoneValidateView *view) {
        [weakSelf requestTelSMSAndShowView:NO];
    }];
    
    [telView setCloseButtonBlock:^(RPTelphoneValidateView *view) {
        [view removeFromSuperview];
        [YZTransparent removeFromSuperView];
        
        if (weakSelf.changeBlock) {
            weakSelf.changeBlock(NO);
        }
    }];
    
    [YZTransparent showInView:_showViewController.view touchBlock:^(YZTransparent *view) {
        
    }];
    
    [self popSubView:telView];
}

//  请求设备变更验证码
- (void)requestTelSMSAndShowView:(BOOL)shouldShow
{
    [_showViewController.view rp_removeHudInManaual];
    [_showViewController.view rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        
        [weakSelf.showViewController.view rp_showHudSuccessView:@"验证码已发送"];
        
        weakSelf.billRef = [dict rp_stringForKey:@"BillRef"];
        NSString *phoneSuffix = [dict rp_stringForKey:@"TelSuffix"];
        [weakSelf.showViewController.view rp_removeHudInManaual];
        
        if (shouldShow) {
            [weakSelf showTelphoneValidateWithPhoneSuffix:phoneSuffix];
        }
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == NSIntegerMax) {
            [weakSelf.showViewController.view rp_showHudErrorView:error];
            
        }else if (code == RedpacketOtherError) {//需要将数字改成type类型
            //  用户有密码，但是用户把所有银行卡都解绑了，这时候变更设备，用零钱发红包的时候，短信验证码发送会没有缺少卡片信息，这时候要求用户去绑卡
            [weakSelf alertBindCardToValidateUserIdentifierWith:error];
            
        }else if (code == RedpacketVerifyIDCardFailedWithOutCard) {
            
            [weakSelf alertViewWithValidateUser:error];
            
        }else{
            [YZTransparent removeFromSuperView];
            [weakSelf alertWithMessage:error];
        }
        
        //  mark:remove allView
        if (weakSelf.changeBlock) {
            weakSelf.changeBlock(NO);
        }
    }];
    
    [request deviceChangedSMSRequest];
}

//  验证设备变更验证码
- (void)requestTelSMSValidate:(NSString *)validateCode andBillRef:(NSString *)billRef
{
    [_showViewController.view rp_showHudWaitingView:YZHPromptTypeWating];
    
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {

        RPDebug(@"设备变更短信验证码验证成功，并调用发红包接口");
        
        if (weakSelf.changeBlock) {
            weakSelf.changeBlock(YES);
        }
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
        if (code == NSIntegerMax) {
            
            [weakSelf.showViewController.view rp_showHudErrorView:error];
            
        }else {
            
            [weakSelf.validateView clearInputField];
            [weakSelf.showViewController.view rp_showHudErrorView:error];
            
        }
        
    }];
    
    [request deviceChangedSMSVerify:validateCode andBillRef:billRef];
}

#pragma mark - BindCard


- (void)alertViewWithValidateUser:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  找回密码
            [self showVerifyIDCardViewControllerWithType:BindingCardTypeChangeDeveice];
        }
    };
    
    [alert show];
}

- (void)alertBindCardToValidateUserIdentifierWith:(NSString *)message
{
    //    NSString *message = @"检测到您的设备已经变更，为了您的账户安全，请先验证身份信息。";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];

    alert.rp_completionBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex) {
            //  设置交易密码
            [self showVerifyIDCardViewControllerWithType:BindingCardTypeAddBankCard];
        }
    };
    
    [alert show];
}

- (void)showVerifyIDCardViewControllerWithType:(BindingCardType)bindType
{
    RPValidateNameViewController *controller = [[RPValidateNameViewController alloc] init];
    controller.delegate = self;
    controller.bindingCardType = bindType;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [_showViewController.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)rebackToChangeWith:(BindingCardType)bindingCardType
{
    self.changeBlock(YES);
}

#pragma mark -

- (void)popSubView:(UIView *)view
{
    CGPoint center = _showViewController.view.center;
    center.y -= view.rp_height / 2;
    view.center = center;
    [_showViewController.view rp_popupSubView:view atPosition:PopAnchorCenterX | PopAnchorCenterY];
}

- (void)alertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    [alert show];
}

@end
