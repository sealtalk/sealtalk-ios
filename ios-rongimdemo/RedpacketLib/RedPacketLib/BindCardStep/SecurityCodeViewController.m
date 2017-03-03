//
//  SecurityCodeViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/4/29.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "SecurityCodeViewController.h"
#import "SettingPaypasswordViewController.h"
#import "RedpacketDataRequester.h"
#import "UIView+YZHPrompting.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketViews.h"


@interface SecurityCodeViewController ()<SettingPayDelegate,UITextFieldDelegate>
{
    UIButton *_nextBtn;
}

@property (nonatomic, assign) BOOL isRequest;

@property (nonatomic) UIButton *timeButton;

@property (nonatomic) UITextField *securityCodeTextFeild;

@property (nonatomic, assign)   dispatch_source_t codeTimer;

@end

@implementation SecurityCodeViewController

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_codeTimer) {
        dispatch_source_cancel(_codeTimer);
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLable.text = @"输入短信验证码";
    self.titleLable.textColor = [RedpacketColorStore rp_textColorBlack];
    self.subLable.textColor = [RedpacketColorStore rp_textColorBlack];
    //基本布局
    self.tableView.backgroundColor = [RedpacketColorStore flashColorWithRed:239   green:239   blue:239   alpha:1];
    self.tableView.tableFooterView = [self tableFooterView];
    self.tableView.tableFooterView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500);
    
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:nil];
    
    
    _isRequest = NO;
    [self startOn];
}

// 设置状态栏的颜色
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self setNavgationbarBtn];
    [self.securityCodeTextFeild becomeFirstResponder];
}

- (void)setNavgationbarBtn
{
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:nil];
    // 同意设置为返回
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
}

- (void)getSecurityCode
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        weakSelf.paymentModel.billRef = [data rp_stringForKey:@"BillRef"];
        [weakSelf.view rp_removeHudInManaual];
        [weakSelf.view rp_showHudSuccessView:@"验证码已发送"];
        [weakSelf startOn];
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf.view rp_showHudErrorView:error];
        
    }];
    
    [request bindCardInTradeOrWithDraw:_paymentModel];
}

- (UIView *)tableFooterView
{
    UIView *footerView  = [[UIView alloc]initWithFrame:self.tableView.tableFooterView.bounds];
    _nextBtn = [RPRedpacketViews redpacketBlueButtonWithTitle:@"确定" andSelector:@selector(clickNextBtn) andTarget:self];
    
    _nextBtn.enabled = NO;
    [footerView addSubview:_nextBtn];
    
    return footerView;
}

// 点击 收不到验证码?
- (void)clicktopHelpBtn
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"短信验证码已发送至银行预留手机。\n如未收到：\n1.请确认当前使用的号码是否为银行预留手机号。\n2.请检查短信是否被安全软件拦截。" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
    [alertView show];
    
}

//点击确定按钮
- (void)clickNextBtn
{
    //验证验证码
    self.paymentModel.captcha = self.securityCodeTextFeild.text;
    rpWeakSelf;
    [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        [weakSelf.view rp_removeHudInManaual];
        if (weakSelf.bindingCardType == BindingCardTypeAddBankCard || weakSelf.bindingCardType == BindingCardTypeWithDrawNoCard || weakSelf.bindingCardType == BindingCardTypeChangeDeveice) {
            [weakSelf.delegate rebackToChangeWith:weakSelf.bindingCardType];
        }else
        {
            SettingPaypasswordViewController *payPassSet = [[SettingPaypasswordViewController alloc]init];
            payPassSet.bindingCardType = weakSelf.bindingCardType;
            payPassSet.delegate = weakSelf;
            payPassSet.captcha  = data[@"Captcha"];
            [weakSelf.navigationController pushViewController:payPassSet animated:YES];
        }
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf alertMessage:error];
    }];
    [request bindCardVerifyInTradeOrWithDraw:weakSelf.paymentModel];
}

- (void)alertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
    
    [alert show];
}

#pragma SettingPayDelegate
- (void)rebackToChangeWith:(BindingCardType)bindingCardType
{
    if ([self.delegate respondsToSelector:@selector(rebackToChangeWith:)]) {
        [self.delegate rebackToChangeWith:self.bindingCardType];
    }
}

#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"validateSecurityCode";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier ];
        
        [cell addSubview:self.securityCodeTextFeild];
        
        UIView *rimLine = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 109, 0, .5, 44)];
        rimLine.backgroundColor = [RedpacketColorStore flashColorWithRed:199   green:199   blue:199   alpha:1];
        [cell addSubview:rimLine];
        
        self.timeButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 109, 0, 109, 44);
        
        [cell addSubview:self.timeButton];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, view.bounds.size.width, 14)];
        NSString *originTel = self.paymentModel.cardInfo.telephone;
        NSString *tel = [originTel stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        lable.text = [NSString stringWithFormat:@"验证码已经发送到手机%@",tel];
        if ([UIScreen mainScreen].bounds.size.width < 321) {
            lable.text = [NSString stringWithFormat:@"验证码已发送至%@",tel];
        }
        lable.textColor = [RedpacketColorStore flashColorWithRed:110   green:110   blue:110   alpha:1];
        lable.font = [UIFont systemFontOfSize:14.0];
        [view addSubview:lable];
        
        UIButton *topHelpBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 100 - 15, 15, 100, 15)];
        [topHelpBtn setTitle:@"收不到验证码？" forState:UIControlStateNormal];
        [topHelpBtn setTitleColor:[RedpacketColorStore rp_colorWithHEX:0x358b7f3] forState:UIControlStateNormal];
        topHelpBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [topHelpBtn addTarget:self action:@selector(clicktopHelpBtn) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:topHelpBtn];
        return view;
        
    }
    if (section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, view.bounds.size.width, 14)];
        lable.text = @"验证者身份信息";
        lable.textColor = [RedpacketColorStore flashColorWithRed:110   green:110   blue:110   alpha:1];
        lable.font = [UIFont systemFontOfSize:14.0];
        [view addSubview:lable];
        return view;
    }
    return [[UIView alloc]init];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        
        return view;
    }
    return [[UIView alloc]init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_securityCodeTextFeild becomeFirstResponder];
}

#pragma  UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if (textField.text.length > 2) {
        _nextBtn.enabled = YES;
        
    }else{
        _nextBtn.enabled = NO;
        
    }
    
    if (textField.text.length > 10) {
        return NO;
    }
    
    return YES;
}
//懒加载

- (UITextField *)securityCodeTextFeild
{
    
    if (!_securityCodeTextFeild) {
        _securityCodeTextFeild = [[UITextField alloc]initWithFrame:CGRectMake(15, 16, [UIScreen mainScreen].bounds.size.width - 196, 14)];
        _securityCodeTextFeild.font = [UIFont systemFontOfSize:14.0];
        _securityCodeTextFeild.placeholder = @"请输入短信验证码";
        _securityCodeTextFeild.keyboardType = UIKeyboardTypeNumberPad;
        _securityCodeTextFeild.delegate = self;
    }
    return _securityCodeTextFeild;
    
}

// 以下为倒计时按钮实现及逻辑
- (UIButton *)timeButton
{
    if (!_timeButton) {
        _timeButton = [[UIButton alloc]init];
        [_timeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_timeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_timeButton setBackgroundColor:[UIColor clearColor]];
        [_timeButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_timeButton setTitleColor:[RedpacketColorStore flashColorWithRed:53   green:183   blue:243   alpha:1] forState:UIControlStateNormal];
        [_timeButton addTarget:self action:@selector(startOn) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _timeButton;
}


- (void)startOn
{
    __block int timeout = 60; //倒计时时间
    rpWeakSelf;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    _codeTimer = _timer;
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        if(timeout <= 0){
            //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [weakSelf.timeButton setTitle:@"重新获取" forState:UIControlStateNormal];
                weakSelf.timeButton.userInteractionEnabled = YES;
                [weakSelf.timeButton addTarget:weakSelf action:@selector(getSecurityCode) forControlEvents:UIControlEventTouchUpInside];
            });
            
        }else{
            
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置界面的按钮显示 根据自己需求设置
                if ([strTime intValue] != 0) {
                    [weakSelf.timeButton setTitle:[NSString stringWithFormat:@"%@s",strTime] forState:UIControlStateNormal];
                }
                
                weakSelf.timeButton.userInteractionEnabled = NO;
                
            });
            
            timeout--;
        }
    });
    dispatch_resume(_timer);
    
    if (_isRequest) {
        [self getSecurityCode];
    }
}

@end
