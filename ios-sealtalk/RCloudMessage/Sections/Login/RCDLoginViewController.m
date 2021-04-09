//
//  RCDFindPswViewController.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/23.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDLoginViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCUnderlineTextField.h"
#import "UIColor+RCColor.h"
#import "RCDIndicateTextField.h"
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDLanguageManager.h"
#import "AppDelegate.h"
#import "RCDCommonString.h"
#import "RCDLoginManager.h"
#import "RCDUserInfoManager.h"
#import "RCDBuglyManager.h"
#import "RCDRCIMDataSource.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import <Masonry/Masonry.h>
#import "RCDRegistrationAgreementController.h"
#import "RCDIMService.h"
#define UserTextFieldTag 1000

@interface RCDLoginViewController () <UITextFieldDelegate, RCDCountryListControllerDelegate, UITextViewDelegate>
@property (nonatomic, strong) RCDCountry *currentRegion;

@property (nonatomic, strong) RCDIndicateTextField *countryTextField;
@property (nonatomic, strong) RCDIndicateTextField *phoneTextField;

@property (nonatomic, strong) UIImageView *rongLogo;
@property (nonatomic, strong) UIView *inputBackground;

@property (nonatomic, strong) UILabel *errorMsgLb;

@property (nonatomic, strong) RCUnderlineTextField *verificationCodeField;
@property (nonatomic, strong) UIButton *sendCodeButton;
@property (nonatomic, strong) UILabel *vCodeTimerLb;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, assign) int seconds;
@end

@implementation RCDLoginViewController {
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.currentRegion = [[RCDCountry alloc] initWithDict:[DEFAULTS objectForKey:RCDCurrentCountryKey]];

    [self initSubviews];

    [self setLayout];

    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - action
- (void)didTapLoginButtonClicked:(UIButton *)sender{
    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        self.errorMsgLb.text = RCDLocalizedString(@"network_can_not_use_please_check");
        return;
    } else {
        self.errorMsgLb.text = @"";
    }
    
    if (![self checkContent]){
        return;
    }

    NSString *phone = self.phoneTextField.textField.text;
    NSString *verifyCode = self.verificationCodeField.text;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = RCDLocalizedString(@"logining");
    [hud show:YES];
    [DEFAULTS removeObjectForKey:RCDUserCookiesKey];
    __weak typeof(self) weakSelf = self;
    [RCDLoginManager loginWithPhone:phone verificationCode:verifyCode region:self.currentRegion.phoneCode success:^(NSString * _Nonnull token, NSString * _Nonnull userId, NSString * _Nonnull nickName) {
        [weakSelf loginRongCloud:phone userName:nickName userId:userId token:token];
    } error:^(RCDLoginErrorCode errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            if (errorCode == RCDLoginErrorCodeVerificationCodeError) {
                weakSelf.errorMsgLb.text = RCDLocalizedString(@"verification_code_error");
            }else if(errorCode == RCDLoginErrorCodeVerificationCodeExpired){
                weakSelf.errorMsgLb.text = RCDLocalizedString(@"captcha_overdue");
            }else{
                weakSelf.errorMsgLb.text = [NSString stringWithFormat:@"%@ : %ld",RCDLocalizedString(@"Login_fail"),(long)errorCode];
            }
        });
    }];
}

/*发送验证码*/
- (void)sendCodeEvent {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    [hud show:YES];
    self.errorMsgLb.text = @"";
    NSString *phoneNumber = self.phoneTextField.textField.text;
    if (phoneNumber.length > 0) {
        [self getVerifyCode:self.currentRegion.phoneCode phoneNumber:phoneNumber];
    } else {
        [hud hide:YES];
        self.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
    }
}

- (void)didTapCountryTextField {
    RCDCountryListController *countryListVC = [[RCDCountryListController alloc] init];
    countryListVC.delegate = self;
    [self.navigationController pushViewController:countryListVC animated:YES];
}

- (void)didTapSwitchLanguage:(UIButton *)button {
    NSString *currentLanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
    if ([currentLanguage isEqualToString:@"en"]) {
        [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:@"zh-Hans"];
    } else if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:@"en"];
    }
    RCDLoginViewController *temp = [[RCDLoginViewController alloc] init];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;        //可更改为其他方式
    transition.subtype = kCATransitionFromLeft; //可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:temp animated:NO];
}

#pragma mark - RCDCountryListControllerDelegate
- (void)fetchCountryPhoneCode:(RCDCountry *)country {
    [DEFAULTS setObject:[country getModelJson] forKey:RCDCurrentCountryKey];
    self.currentRegion = country;
    self.countryTextField.textField.text = country.countryName;
    self.phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@", self.currentRegion.phoneCode];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == UserTextFieldTag) {
        self.sendCodeButton.enabled = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"registrationterms"]) {
        //《注册条款》点击事件
        RCDRegistrationAgreementController *vc = [[RCDRegistrationAgreementController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}

#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardBounds = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat space = CGRectGetMaxY(self.inputBackground.frame) - 50 - keyboardBounds.origin.y;
    if (space > 0) {
        self.view.frame = CGRectMake(0.f, -space, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame =
                             CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:nil];
}

#pragma mark - private method
- (void)loginRongCloud:(NSString *)phone
              userName:(NSString *)userName
                userId:(NSString *)userId
                 token:(NSString *)token{
    __weak typeof(self) weakSelf = self;
    [[RCDIMService sharedService] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
        NSLog(@"RCDBOpened %@", code ? @"failed" : @"success");
    } success:^(NSString *userId) {
        NSLog([NSString stringWithFormat:@"token is %@  userId is %@", token, userId], nil);
        [weakSelf saveLoginData:phone userId:userId userName:userName token:token];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
            RCDNavigationViewController *rootNavi =
            [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
            [UIApplication sharedApplication].delegate.window.rootViewController = rootNavi;
        });
    } error:^(RCConnectErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            NSLog(@"RCConnectErrorCode is %ld", (long)status);
            _errorMsgLb.text = [NSString stringWithFormat:@"%@ Status: %zd", RCDLocalizedString(@"Login_fail"), status];
        });
    }];
}

- (void)saveLoginData:(NSString *)phone
               userId:(NSString *)userId
             userName:(NSString *)userName
                token:(NSString *)token {
    //保存默认用户
    [DEFAULTS setObject:phone forKey:RCDPhoneKey];
    [DEFAULTS setObject:token forKey:RCDIMTokenKey];
    [DEFAULTS setObject:userId forKey:RCDUserIdKey];
    [DEFAULTS synchronize];

    [RCDUserInfoManager
        getUserInfoFromServer:userId
                     complete:^(RCDUserInfo *userInfo) {
                         [RCDBuglyManager
                             setUserIdentifier:[NSString stringWithFormat:@"%@ - %@", userInfo.userId, userInfo.name]];
                         [RCIM sharedRCIM].currentUserInfo = userInfo;
                         [DEFAULTS setObject:userInfo.portraitUri forKey:RCDUserPortraitUriKey];
                         [DEFAULTS setObject:userInfo.name forKey:RCDUserNickNameKey];
                         [DEFAULTS setObject:userInfo.stAccount forKey:RCDSealTalkNumberKey];
                         [DEFAULTS setObject:userInfo.gender forKey:RCDUserGenderKey];
                         [DEFAULTS synchronize];
                     }];
    //同步群组
    [RCDDataSource syncAllData];
}

- (void)getVerifyCode:(NSString *)phoneCode phoneNumber:(NSString *)phoneNumber {
    __weak typeof(self) ws = self;
    [RCDLoginManager getVerificationCode:self.currentRegion.phoneCode
        phoneNumber:phoneNumber
        success:^(BOOL success) {
            rcd_dispatch_main_async_safe(^{
                [hud hide:YES];
                if (success) {
                    ws.vCodeTimerLb.hidden = NO;
                    ws.sendCodeButton.hidden = YES;
                    [ws countDown:60];
                }
            });
        }
        error:^(RCDLoginErrorCode errorCode, NSString *_Nonnull errorMsg) {
            rcd_dispatch_main_async_safe(^{
                [hud hide:YES];
                if (errorCode == RCDLoginErrorCodeParameterError) {
                    ws.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
                } else if (errorCode == RCDLoginErrorCodeVerificationCodeFrequencyTransfinite){
                    ws.errorMsgLb.text = RCDLocalizedString(@"verification_code_send_over_limit");
                } else if(errorCode){
                    ws.errorMsgLb.text = errorMsg;
                }else{
                    ws.errorMsgLb.text = RCDLocalizedString(@"failed");
                }
            });
        }];
}

- (BOOL)checkContent {
    NSString *vCode = self.verificationCodeField.text;
    if (vCode.length == 0) {
        self.errorMsgLb.text = RCDLocalizedString(@"verification_code_can_not_nil");
        return NO;
    }
    NSString *phone = self.phoneTextField.textField.text;
    if (phone.length == 0) {
        self.errorMsgLb.text = RCDLocalizedString(@"mobile_number_error");
        return NO;
    }
    return YES;
}

- (void)countDown:(int)seconds {
    self.seconds = seconds;
    [self startCountDownTimer];
}
- (void)timeFireMethod {
    self.seconds--;
    self.vCodeTimerLb.text = [NSString stringWithFormat:RCDLocalizedString(@"after_x_seconds_send"), self.seconds];
    if (self.seconds == 0) {
        [self stopCountDownTimerIfNeed];
        self.sendCodeButton.hidden = NO;
        self.vCodeTimerLb.hidden = YES;
        self.vCodeTimerLb.text = RCDLocalizedString(@"after_60_seconds_send");
    }
}


- (void)startCountDownTimer {
    [self stopCountDownTimerIfNeed];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(timeFireMethod)
                                                         userInfo:nil
                                                          repeats:YES];
}
- (void)stopCountDownTimerIfNeed {
    if (self.countDownTimer && self.countDownTimer.isValid) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
}
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}
- (void)initSubviews {
    self.phoneTextField.textField.text = [DEFAULTS objectForKey:RCDPhoneKey];
    
    self.view.backgroundColor = HEXCOLOR(0x191919);
    
    [self.view addSubview:self.rongLogo];
    [self.view addSubview:self.inputBackground];
    [self.view addSubview:self.errorMsgLb];
    [self.view addSubview:[self getSwitchLanguage]];
    [self.view addSubview:[self getFooterLabel]];

    [self.inputBackground addSubview:self.countryTextField];
    [self.inputBackground addSubview:self.phoneTextField];
    [self.inputBackground addSubview:self.verificationCodeField];
    [self.inputBackground addSubview:self.sendCodeButton];
    [self.inputBackground addSubview:self.vCodeTimerLb];
    [self.inputBackground addSubview:self.loginButton];
}

- (void)setLayout {
    [self.rongLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(100);
        make.top.equalTo(self.view).offset(70);
        make.centerX.equalTo(self.view);
    }];
    
    [self.errorMsgLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(41);
        make.right.equalTo(self.view).offset(-41);
        make.top.equalTo(self.rongLogo.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.height.offset(15);
    }];
    
    [self.inputBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(41);
        make.right.equalTo(self.view).offset(-41);
        make.top.equalTo(self.rongLogo.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
        make.height.offset(250);
    }];
    
    [self.countryTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.inputBackground);
        make.height.offset(60);
    }];
    
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.countryTextField);
        make.top.equalTo(self.countryTextField.mas_bottom);
        make.height.offset(60);
    }];
    
    [self.verificationCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.countryTextField);
        make.top.equalTo(self.phoneTextField.mas_bottom);
        make.height.offset(60);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.inputBackground);
        make.height.offset(50);
    }];
    
    [self.sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.verificationCodeField).offset(-10);
        make.bottom.equalTo(self.verificationCodeField.mas_bottom).offset(-20);
        make.width.offset(80);
        make.height.offset(25);
    }];
    
    [self.vCodeTimerLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.sendCodeButton);
    }];
}

#pragma mark - Getters and setters
- (RCDIndicateTextField *)countryTextField {
    if (!_countryTextField) {
        _countryTextField = [[RCDIndicateTextField alloc] init];
        _countryTextField.indicateInfoLabel.text = RCDLocalizedString(@"country");
        _countryTextField.textField.text = self.currentRegion.countryName;
        _countryTextField.textField.userInteractionEnabled = NO;
        [_countryTextField indicateIconShow:YES];
        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCountryTextField)];
        [_countryTextField addGestureRecognizer:tap];
        _countryTextField.userInteractionEnabled = YES;
    }
    return _countryTextField;
}

- (RCDIndicateTextField *)phoneTextField {
    if (!_phoneTextField) {
        _phoneTextField = [[RCDIndicateTextField alloc] initWithFrame:CGRectZero];
        _phoneTextField.backgroundColor = [UIColor clearColor];
        _phoneTextField.textField.tag = UserTextFieldTag;
        [_phoneTextField.textField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
        _phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@", self.currentRegion.phoneCode];
        _phoneTextField.userInteractionEnabled = YES;
        _phoneTextField.textField.adjustsFontSizeToFitWidth = YES;
        _phoneTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.textField.delegate = self;
        _phoneTextField.textField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"mobile_number")
                                            attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    return _phoneTextField;
}

- (UIButton *)getSwitchLanguage {
    UIButton *switchLanguage =
        [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 30, 70, 40)];
    [switchLanguage setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    switchLanguage.titleLabel.font = [UIFont systemFontOfSize:16.];
    NSString *currentlanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
    if ([currentlanguage isEqualToString:@"en"]) {
        [switchLanguage setTitle:@"简体中文" forState:(UIControlStateNormal)];
    } else if ([currentlanguage isEqualToString:@"zh-Hans"]) {
        [switchLanguage setTitle:@"EN" forState:(UIControlStateNormal)];
    }
    [switchLanguage addTarget:self
                       action:@selector(didTapSwitchLanguage:)
             forControlEvents:(UIControlEventTouchUpInside)];
    return switchLanguage;
}

- (UIImageView *)rongLogo {
    if (!_rongLogo) {
        UIImage *rongLogoImage = [UIImage imageNamed:@"login_logo"];
        _rongLogo = [[UIImageView alloc] initWithImage:rongLogoImage];
        _rongLogo.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rongLogo;
}

- (UIView *)inputBackground {
    if (!_inputBackground) {
        _inputBackground = [[UIView alloc] initWithFrame:CGRectZero];
        _inputBackground.userInteractionEnabled = YES;
    }
    return _inputBackground;
}

- (UILabel *)errorMsgLb {
    if (!_errorMsgLb) {
        _errorMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _errorMsgLb.text = @"";
        _errorMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
        _errorMsgLb.textColor = [UIColor colorWithRed:204.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1];
    }
    return _errorMsgLb;
}

- (RCUnderlineTextField *)verificationCodeField {
    if (!_verificationCodeField) {
        RCUnderlineTextField *verificationCodeField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];

        verificationCodeField.backgroundColor = [UIColor clearColor];
        UIColor *color = [UIColor whiteColor];
        verificationCodeField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"verification_code")
                                            attributes:@{NSForegroundColorAttributeName : color}];
        verificationCodeField.textColor = [UIColor whiteColor];
        verificationCodeField.delegate = self;
        verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
        _verificationCodeField = verificationCodeField;
    }
    return _verificationCodeField;
}

- (UIButton *)sendCodeButton {
    if (!_sendCodeButton) {
        UIButton *sendCodeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [sendCodeButton setBackgroundColor:HEXCOLOR(0x0099ff)];
        [sendCodeButton setTitle:RCDLocalizedString(@"send_verification_code") forState:UIControlStateNormal];
        [sendCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [sendCodeButton addTarget:self action:@selector(sendCodeEvent) forControlEvents:UIControlEventTouchUpInside];
        _sendCodeButton = sendCodeButton;
    }
    return _sendCodeButton;
}

- (UILabel *)vCodeTimerLb {
    if (!_vCodeTimerLb) {
        UILabel *vCodeTimerLb = [[UILabel alloc] initWithFrame:CGRectZero];
        vCodeTimerLb.text = RCDLocalizedString(@"after_60_seconds_obtain");
        vCodeTimerLb.font = [UIFont fontWithName:@"Heiti SC" size:13.0];
        [vCodeTimerLb
            setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
        vCodeTimerLb.textColor = [UIColor whiteColor];
        vCodeTimerLb.textAlignment = UITextAlignmentCenter;
        vCodeTimerLb.hidden = YES;
        _vCodeTimerLb = vCodeTimerLb;
    }
    return _vCodeTimerLb;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton addTarget:self action:@selector(didTapLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [loginButton setTitle:RCDLocalizedString(@"Login") forState:UIControlStateNormal];
        loginButton.backgroundColor = HEXCOLOR(0x0099ff);
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginButton.layer.cornerRadius = 4;
        loginButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _loginButton = loginButton;
    }
    return _loginButton;
}

- (UITextView *)getFooterLabel {
    NSString *content = [NSString stringWithFormat:@"新登录用户即注册开通融云开发者账号 \n 且表示同意《注册条款》\n SealTalk V%@",[RCIMClient getVersion]];
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-[RCKitUtility getWindowSafeAreaInsets].bottom-70, self.view.frame.size.width, 70)];
    contentTextView.backgroundColor = self.view.backgroundColor;
    contentTextView.attributedText = [self getContentLabelAttributedText:content];
    contentTextView.textAlignment = NSTextAlignmentCenter;
    contentTextView.delegate = self;
    contentTextView.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    return contentTextView;
}

- (NSAttributedString *)getContentLabelAttributedText:(NSString *)text{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11],NSForegroundColorAttributeName:HEXCOLOR(0x585858)}];
    NSRange range =[attrStr.string rangeOfString:@"《注册条款》"];
    [attrStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x0099ff) range:range];
    [attrStr addAttribute:NSLinkAttributeName value:@"registrationterms://" range:range];
    range = NSMakeRange(0, text.length);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5; // 调整行间距
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attrStr;
}
@end
