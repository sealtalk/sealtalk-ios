//
//  ChangeViewController.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/6/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "ChangeViewController.h"
#import "RPRedpacketSetting.h"
#import "RPRedpackeNavgationController.h"
#import "RPRedpacketPayManager.h"

@interface ChangeViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) UITextField *rechargeField;
@property (nonatomic, strong) UIButton *rechargeButton;

@end

@implementation ChangeViewController

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [RPRedpacketPayManager releasePayManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [RedpacketColorStore rp_backGroundGrayColor];
    
    self.titleLable.text = @"充值";

    [self configView];
}

- (void)rechangeButtonClicked
{
    CGFloat payMoney = [self getAffordMoney];
    CGFloat singlePayLimit = [RPRedpacketSetting shareInstance].jdpayMaxMoney;
    if (payMoney > singlePayLimit) {
        [self.view rp_showHudErrorView:rpString(@"充值金额单笔不能超过%d元", (int)singlePayLimit)];
        return;
    }
    
    rpWeakSelf;
    NSString *moneyStr =[NSString stringWithFormat:@"%.2f", payMoney];
    [[RPRedpacketPayManager currentManager] payMoney:moneyStr
                                       inController:self
                               withRedpacketPayType:RedpacketPayUseTypeChange
                                        andPayBlock:^(NSString *billRef, NSString *password) {
        
        [weakSelf.view rp_showHudSuccessView:@"充值成功"];
        [weakSelf performSelector:@selector(controllerDismiss) withObject:nil afterDelay:1];
        
    }];
}

- (CGFloat)getAffordMoney
{
    CGFloat payMoney =[self.rechargeField.text floatValue];
    
    return payMoney;
}

- (void)controllerDismiss
{
    if (_finishBlock) {
        _finishBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    CGFloat money = [replacedString floatValue];
    
    if (money > 0.009) {
        _rechargeButton.enabled = YES;
    }else{
        _rechargeButton.enabled = NO;
    }
    
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
    
    NSArray *array = [replacedString componentsSeparatedByString:@"."];
    if (array.count > 2) {
        return NO;
    }else {
        if (array.count == 2) {
            NSString *decimalString = array[1];
            NSString *numberString = array[0];
            if (decimalString.length > 2) {
                return NO;
            }
            
            if (numberString.length > 10) {
                return NO;
            }
        }else if(replacedString.length > 10) {
            return NO;
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

#pragma mark - 

- (void)configView
{
    UIView *backView = [UIView new];
    backView.backgroundColor = [UIColor whiteColor];
    backView.frame = CGRectMake(0, 17.0f, self.view.rp_width, 44.0f);
    [self.view addSubview:backView];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake(15, 0, 0, 44.0f);
    titleLabel.text = @"充值金额";
    titleLabel.textColor = [RedpacketColorStore rp_textColorBlack];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [titleLabel sizeToFit];
    titleLabel.rp_top = 0;
    titleLabel.rp_height = 44.0f;
    [backView addSubview:titleLabel];
    
    UILabel *label = [UILabel new];
    label.text = @"元";
    label.textColor = [RedpacketColorStore rp_textColorBlack];
    label.font = [UIFont systemFontOfSize:14.0f];
    [label sizeToFit];
    label.rp_right = backView.rp_right - 15.0f;
    label.rp_height = 44.0f;
    label.rp_top = 0.0;
    [backView addSubview:label];
    
    UITextField *textField = [UITextField new];
    _rechargeField = textField;
    textField.frame = CGRectMake(0, 0, 200, 44);
    textField.delegate = self;
    textField.textAlignment = NSTextAlignmentRight;
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    textField.font = [UIFont systemFontOfSize:14.0f];
    textField.placeholder = rpString(@"单笔限额%d", (int)[RPRedpacketSetting shareInstance].jdpayMaxMoney);
    textField.textColor = [RedpacketColorStore rp_textColorBlack];
    [backView addSubview:textField];
    
    textField.rp_right = label.rp_left - 10.0f;
    [backView addSubview:textField];

    
    _rechargeButton = [RPRedpacketViews redpacketBlueButtonWithTitle:@"充值" andSelector:@selector(rechangeButtonClicked) andTarget:self];
    _rechargeButton.frame = CGRectMake(15, backView.rp_bottom + 30, self.view.rp_width - 30, 44.0f);
    [self.view addSubview:_rechargeButton];
    _rechargeButton.enabled = NO;
    
    [_rechargeField becomeFirstResponder];
}



@end
