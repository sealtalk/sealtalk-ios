//
//  RCDFindPswViewController.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/23.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDFindPswViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDLoginViewController.h"
#import "RCDRegisterViewController.h"
#import "RCUnderlineTextField.h"
#import "UIColor+RCColor.h"
#import "RCDIndicateTextField.h"
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDLanguageManager.h"
#import "AppDelegate.h"
#import "RCDCommonString.h"
#import "RCDLoginManager.h"

#define UserTextFieldTag 1000

@interface RCDFindPswViewController () <UITextFieldDelegate, RCDCountryListControllerDelegate>
@property (nonatomic, strong) RCDCountry *currentRegion;

@property (nonatomic, strong) RCDIndicateTextField *countryTextField;
@property (nonatomic, strong) RCDIndicateTextField *phoneTextField;

@property (nonatomic, strong) UIImageView *rongLogo;
@property (nonatomic, strong) UIView *inputBackground;
@property (nonatomic, strong) RCAnimatedImagesView *animatedImagesView;
@property (nonatomic, strong) UILabel *licenseLb;
@property (nonatomic, strong) UILabel *errorMsgLb;

@property (nonatomic, strong) RCUnderlineTextField *verificationCodeField;
@property (nonatomic, strong) UIButton *sendCodeButton;
@property (nonatomic, strong) UILabel *vCodeTimerLb;
@property (nonatomic, strong) RCUnderlineTextField *passwordTextField;
@property (nonatomic, strong) UILabel *pswMsgLb;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) UIView *bottomBackground;

@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, assign) int seconds;
@end

@implementation RCDFindPswViewController {
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentRegion = [[RCDCountry alloc] initWithDict:[DEFAULTS objectForKey:RCDCurrentCountryKey]];

    [self initSubviews];

    [self setLayout];

    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.animatedImagesView startAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.animatedImagesView stopAnimating];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - action
/*发送验证码*/
- (void)sendCodeEvent {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    [hud show:YES];
    self.errorMsgLb.text = @"";
    NSString *phoneNumber = self.phoneTextField.textField.text;
    if (phoneNumber.length > 0) {
        // check phone number
        __weak typeof(self) ws = self;
        [RCDLoginManager
            checkPhoneNumberAvailable:self.currentRegion.phoneCode
                          phoneNumber:phoneNumber
                             complete:^(BOOL success, BOOL numberAvailable) {
                                 rcd_dispatch_main_async_safe(^{
                                     if (success) {
                                         if (!numberAvailable) {
                                             // get verify code
                                             [ws getVerifyCode:self.currentRegion.phoneCode phoneNumber:phoneNumber];
                                         } else {
                                             [hud hide:YES];
                                             ws.errorMsgLb.text = @"手机号未注册";
                                         }
                                     } else {
                                         [hud hide:YES];
                                         ws.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
                                     }
                                 });
                             }];
    } else {
        [hud hide:YES];
        self.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
    }
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
                } else {
                    ws.errorMsgLb.text = errorMsg;
                }
            });
        }];
}

- (void)registerEvent {
    RCDRegisterViewController *temp = [[RCDRegisterViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

/*阅读用户协议*/
- (void)userProtocolEvent {
}
/*注册*/
- (void)loginPageEvent {
    RCDLoginViewController *temp = [[RCDLoginViewController alloc] init];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;        //可更改为其他方式
    transition.subtype = kCATransitionFromLeft; //可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:temp animated:NO];
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
    RCDFindPswViewController *temp = [[RCDFindPswViewController alloc] init];
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

#pragma mark UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == UserTextFieldTag) {
        BOOL enable = textField.text.length > 0;
        UIColor *color = [[UIColor alloc] initWithRed:23 / 255.f green:136 / 255.f blue:213 / 255.f alpha:1];
        if (!enable) {
            color = [[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1];
        }
        self.sendCodeButton.enabled = YES;
        self.sendCodeButton.backgroundColor = color;
    }

    if (textField.text.length == 0) {
        [textField setFont:[UIFont fontWithName:@"Heiti SC" size:18.0]];
    } else {
        [textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
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

- (void)btnDoneClicked:(id)sender {
    _errorMsgLb.text = @"";
    if (![self checkContent])
        return;
    NSString *phone = self.phoneTextField.textField.text;
    NSString *userPwd = self.passwordTextField.text;
    NSString *vCode = self.verificationCodeField.text;
    __weak typeof(self) ws = self;
    [RCDLoginManager verifyVerificationCode:self.currentRegion.phoneCode
        phoneNumber:phone
        verificationCode:vCode
        success:^(BOOL success, NSString *_Nonnull codeToken) {
            if (success) {
                [RCDLoginManager
                    resetPassword:userPwd
                           vToken:codeToken
                         complete:^(BOOL success) {
                             if (success) {
                                 rcd_dispatch_main_async_safe(^{
                                     _errorMsgLb.text = RCDLocalizedString(@"change_success");
                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_MSEC),
                                                    dispatch_get_main_queue(), ^{
                                                        [ws.navigationController popViewControllerAnimated:YES];
                                                    });
                                 });
                             }
                         }];
            }
        }
        error:^(RCDLoginErrorCode errorCode){
        }];
}

/**
 *  检查输入内容
 *
 *  @return 是否合法输入
 */
- (BOOL)checkContent {
    NSString *userPwd = self.passwordTextField.text;
    NSString *vCode = self.verificationCodeField.text;

    if (userPwd.length > 20) {
        self.errorMsgLb.text = RCDLocalizedString(@"password_can_not_more_than_20");
    }
    if (userPwd.length == 0) {
        self.errorMsgLb.text = RCDLocalizedString(@"password_can_not_nil");
        return NO;
    }
    if (vCode.length == 0) {
        self.errorMsgLb.text = RCDLocalizedString(@"verification_code_can_not_nil");
        return NO;
    }
    return YES;
}

- (NSUInteger)animatedImagesNumberOfImages:(RCAnimatedImagesView *)animatedImagesView {
    return 2;
}

- (UIImage *)animatedImagesView:(RCAnimatedImagesView *)animatedImagesView imageAtIndex:(NSUInteger)index {
    return [UIImage imageNamed:@"login_background.png"];
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    [self.view addSubview:self.animatedImagesView];

    [self.animatedImagesView addSubview:[self getSwitchLanguage]];
    [self.view addSubview:self.licenseLb];
    [self.view addSubview:self.rongLogo];

    [self.view addSubview:self.inputBackground];

    [self.view addSubview:self.errorMsgLb];

    [self.inputBackground addSubview:self.countryTextField];
    [self.inputBackground addSubview:self.phoneTextField];

    if (self.phoneTextField.textField.text.length > 0) {
        [self.phoneTextField.textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
    }

    [self.inputBackground addSubview:self.verificationCodeField];

    [self.inputBackground addSubview:self.sendCodeButton];

    [self.inputBackground addSubview:self.vCodeTimerLb];

    [self.inputBackground addSubview:self.passwordTextField];

    [self.inputBackground addSubview:self.pswMsgLb];

    [self.inputBackground addSubview:self.loginButton];

    [self.view addSubview:self.bottomBackground];

    [self.bottomBackground addSubview:[self getRegisterButton]];
    [self.bottomBackground addSubview:[self getLoginButton]];

    [self.bottomBackground addSubview:[self getFooterLabel]];
}

- (void)setLayout {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_sendCodeButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_sendCodeButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-7]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_sendCodeButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_sendCodeButton
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBackground
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:20]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pswMsgLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_passwordTextField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:4]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pswMsgLb
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_passwordTextField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_rongLogo
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];

    NSDictionary *views = NSDictionaryOfVariableBindings(_errorMsgLb, _licenseLb, _rongLogo, _inputBackground,
                                                         _bottomBackground, _vCodeTimerLb);

    NSArray *viewConstraints = [[[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-41-[_inputBackground]-41-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rongLogo(100)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[_rongLogo(100)]-[_"
                                                                                      @"errorMsgLb(==15)]-[_"
                                                                                      @"inputBackground("
                                                                                      @"==295)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomBackground(==50)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_bottomBackground]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_licenseLb]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_errorMsgLb]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];

    [self.view addConstraints:viewConstraints];

    NSDictionary *inputViews =
        NSDictionaryOfVariableBindings(_verificationCodeField, _pswMsgLb, _countryTextField, _phoneTextField,
                                       _passwordTextField, _loginButton, _vCodeTimerLb, _sendCodeButton);

    NSArray *inputViewConstraints = [[[[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_countryTextField]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:inputViews]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_phoneTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_passwordTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_verificationCodeField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_verificationCodeField]-(<=0)-[_sendCodeButton(80)]"
                                                    options:0
                                                    metrics:nil
                                                      views:inputViews]]
        arrayByAddingObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_verificationCodeField]-(<=0)-[_vCodeTimerLb]"
                                                    options:0
                                                    metrics:nil
                                                      views:inputViews]]
        arrayByAddingObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:
                                    @"V:|[_countryTextField(60)]-[_phoneTextField(60)]-[_verificationCodeField(50)]-["
                                    @"_passwordTextField(55)]-[_loginButton(50)]"
                                                    options:0
                                                    metrics:nil
                                                      views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_loginButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]];

    [_inputBackground addConstraints:inputViewConstraints];
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
        _countryTextField.translatesAutoresizingMaskIntoConstraints = NO;
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
        _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneTextField.textField.adjustsFontSizeToFitWidth = YES;
        _phoneTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.textField.delegate = self;
        if (_phoneTextField.textField.text.length > 0) {
            [_phoneTextField.textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
        }
    }
    return _phoneTextField;
}

- (RCAnimatedImagesView *)animatedImagesView {
    if (!_animatedImagesView) {
        _animatedImagesView = [[RCAnimatedImagesView alloc]
            initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

        _animatedImagesView.delegate = self;
    }
    return _animatedImagesView;
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

- (UILabel *)licenseLb {
    if (!_licenseLb) {
        _licenseLb = [[UILabel alloc] initWithFrame:CGRectZero];
        //  _licenseLb.text = @"仅供演示融云 SDK 功能使用";
        _licenseLb.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
        _licenseLb.translatesAutoresizingMaskIntoConstraints = NO;
        _licenseLb.textColor = [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
    }
    return _licenseLb;
}

- (UIImageView *)rongLogo {
    if (!_rongLogo) {
        UIImage *rongLogoImage = [UIImage imageNamed:@"login_logo"];
        _rongLogo = [[UIImageView alloc] initWithImage:rongLogoImage];
        _rongLogo.contentMode = UIViewContentModeScaleAspectFit;
        _rongLogo.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _rongLogo;
}

- (UIView *)inputBackground {
    if (!_inputBackground) {
        _inputBackground = [[UIView alloc] initWithFrame:CGRectZero];
        _inputBackground.translatesAutoresizingMaskIntoConstraints = NO;
        _inputBackground.userInteractionEnabled = YES;
    }
    return _inputBackground;
}

- (UILabel *)errorMsgLb {
    if (!_errorMsgLb) {
        _errorMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _errorMsgLb.text = @"";
        _errorMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
        _errorMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
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
        verificationCodeField.translatesAutoresizingMaskIntoConstraints = NO;
        verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
        _verificationCodeField = verificationCodeField;
    }
    return _verificationCodeField;
}

- (UIButton *)sendCodeButton {
    if (!_sendCodeButton) {
        UIButton *sendCodeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [sendCodeButton
            setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
        [sendCodeButton setTitle:RCDLocalizedString(@"send_verification_code") forState:UIControlStateNormal];
        [sendCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [sendCodeButton addTarget:self action:@selector(sendCodeEvent) forControlEvents:UIControlEventTouchUpInside];
        sendCodeButton.translatesAutoresizingMaskIntoConstraints = NO;
        _sendCodeButton = sendCodeButton;
    }
    return _sendCodeButton;
}

- (UILabel *)vCodeTimerLb {
    if (!_vCodeTimerLb) {
        UILabel *vCodeTimerLb = [[UILabel alloc] initWithFrame:CGRectZero];
        vCodeTimerLb.text = RCDLocalizedString(@"after_60_seconds_obtain");
        vCodeTimerLb.font = [UIFont fontWithName:@"Heiti SC" size:13.0];
        vCodeTimerLb.translatesAutoresizingMaskIntoConstraints = NO;
        //  vCodeTimerLb.textColor =
        //      [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
        [vCodeTimerLb
            setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
        vCodeTimerLb.textColor = [UIColor whiteColor];
        vCodeTimerLb.textAlignment = UITextAlignmentCenter;
        vCodeTimerLb.hidden = YES;
        _vCodeTimerLb = vCodeTimerLb;
    }
    return _vCodeTimerLb;
}

- (RCUnderlineTextField *)passwordTextField {
    if (!_passwordTextField) {
        RCUnderlineTextField *passwordTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
        passwordTextField.textColor = [UIColor whiteColor];
        passwordTextField.returnKeyType = UIReturnKeyDone;
        passwordTextField.delegate = self;
        passwordTextField.secureTextEntry = YES;
        UIColor *color = [UIColor whiteColor];
        passwordTextField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"new_password")
                                            attributes:@{NSForegroundColorAttributeName : color}];
        passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField = passwordTextField;
    }
    return _passwordTextField;
}

- (UILabel *)pswMsgLb {
    if (!_pswMsgLb) {
        UILabel *pswMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
        pswMsgLb.text = RCDLocalizedString(@"char_section_case_sensitive_from6_t16");
        pswMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:10.0];
        pswMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
        pswMsgLb.textColor = [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
        _pswMsgLb = pswMsgLb;
    }
    return _pswMsgLb;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
        [loginButton setTitle:RCDLocalizedString(@"confirm") forState:UIControlStateNormal];
        loginButton.backgroundColor = [UIColor colorWithRed:28 / 255.0 green:119 / 255.0 blue:211 / 255.0 alpha:0.95];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginButton.layer.cornerRadius = 3;
        loginButton.titleLabel.font = [UIFont systemFontOfSize:23];
        loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        _loginButton = loginButton;
    }
    return _loginButton;
}

- (UIView *)bottomBackground {
    if (!_bottomBackground) {
        UIView *bottomBackground = [[UIView alloc] initWithFrame:CGRectZero];
        bottomBackground.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBackground = bottomBackground;
    }
    return _bottomBackground;
}

- (UIButton *)getLoginButton {
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, -16, 80, 50)];
    [loginButton setTitle:RCDLocalizedString(@"Login") forState:UIControlStateNormal];
    [loginButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                      forState:UIControlStateNormal];
    loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [loginButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [loginButton addTarget:self action:@selector(loginPageEvent) forControlEvents:UIControlEventTouchUpInside];
    return loginButton;
}

- (UIButton *)getRegisterButton {
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, 80, 50)];
    [registerButton setTitle:RCDLocalizedString(@"new_user") forState:UIControlStateNormal];
    [registerButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                         forState:UIControlStateNormal];
    registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    registerButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [registerButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
    return registerButton;
}

- (UILabel *)getFooterLabel {
    CGRect screenBounds = self.view.frame;
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.frame = CGRectMake(screenBounds.size.width / 2 - 100, -2, 200, 21);
    footerLabel.text = @"Powered by RongCloud";
    [footerLabel setFont:[UIFont systemFontOfSize:12.f]];
    [footerLabel setTextColor:[UIColor colorWithHexString:@"484848" alpha:1.0]];
    return footerLabel;
}
@end
