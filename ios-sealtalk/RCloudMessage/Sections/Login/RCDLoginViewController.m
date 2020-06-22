//
//  LoginViewController.m
//  RongCloud
//
//  Created by Liv on 14/11/5.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//
#import "RCDLoginViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDCommonDefine.h"
#import "RCDFindPswViewController.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDRegisterViewController.h"
#import "RCDTextFieldValidate.h"
#import "RCDUtilities.h"
#import "RCUnderlineTextField.h"
#import "UIColor+RCColor.h"
#import "UITextFiled+Shake.h"
#import "RCDIndicateTextField.h"
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDLanguageManager.h"
#import "AppDelegate.h"
#import "RCDBuglyManager.h"
#import "RCDLoginManager.h"
#import "RCDCommonString.h"
#import "RCDUserInfoManager.h"
#import "RCDIMService.h"

#define UserTextFieldTag 1000
#define PassWordFieldTag 1001

@interface RCDLoginViewController () <UITextFieldDelegate, RCDCountryListControllerDelegate>

@property (nonatomic, strong) RCAnimatedImagesView *animatedImagesView;
@property (nonatomic, strong) RCDIndicateTextField *countryTextField;
@property (nonatomic, strong) RCDIndicateTextField *phoneTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) NSTimer *retryTimer;
@property (nonatomic, strong) UIImageView *rongLogoView;
@property (nonatomic, strong) UIView *inputBackground;
@property (nonatomic, strong) UIView *bottomBackground;
@property (nonatomic, strong) UILabel *errorMsgLb;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *userProtocolButton;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *forgetPswButton;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, assign) int loginFailureTimes;
@property (nonatomic, strong) NSString *loginUserName;
@property (nonatomic, strong) NSString *loginUserId;
@property (nonatomic, strong) NSString *loginToken;
@property (nonatomic, strong) NSString *loginPassword;
@property (nonatomic, strong) RCDCountry *currentRegion;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation RCDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.currentRegion = [[RCDCountry alloc] initWithDict:[DEFAULTS objectForKey:RCDCurrentCountryKey]];
    self.loginFailureTimes = 0;
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
    [self stopRetryTimerIfNeed];
    [self.animatedImagesView stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload {
    [self setAnimatedImagesView:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - action
- (void)loginEvent:(id)sender {
    [self startRetryTimer];

    NSString *userName = self.phoneTextField.textField.text;
    NSString *userPwd = self.passwordTextField.text;

    [self login:userName password:userPwd];
}

- (void)login:(NSString *)userName password:(NSString *)password {

    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];

    if (RC_NotReachable == status) {
        self.errorMsgLb.text = RCDLocalizedString(@"network_can_not_use_please_check");
        return;
    } else {
        self.errorMsgLb.text = @"";
    }

    if ([self validateUserName:userName userPwd:password]) {
        self.hud.labelText = RCDLocalizedString(@"logining");
        [self.hud show:YES];
        [DEFAULTS removeObjectForKey:RCDUserCookiesKey];
        [RCDLoginManager loginWithPhone:userName
            password:password
            region:self.currentRegion.phoneCode
            success:^(NSString *_Nonnull token, NSString *_Nonnull userId) {
                [self loginRongCloud:userName userId:userId token:token password:password];
            }
            error:^(RCDLoginErrorCode errorCode) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hide:YES];
                    if (errorCode == RCDLoginErrorCodeWrongPassword) {
                        self.errorMsgLb.text = RCDLocalizedString(@"mobile_number_or_password_error");
                        [self.pwdTextField shake];
                    } else if (errorCode == RCDLoginErrorCodeUserNotRegistered) {
                        self.errorMsgLb.text = RCDLocalizedString(@"UserNotRegistered");
                    } else {
                        self.errorMsgLb.text = RCDLocalizedString(@"Login_fail_please_check_network");
                    }
                });
            }];
    } else {
        self.errorMsgLb.text = RCDLocalizedString(@"please_check_mobile_number_and_password");
    }
}

- (void)loginSuccess:(NSString *)userName
              userId:(NSString *)userId
               token:(NSString *)token
            password:(NSString *)password {
    [self stopRetryTimerIfNeed];
    [DEFAULTS setObject:userName forKey:RCDUserNameKey];
    [DEFAULTS setObject:password forKey:RCDUserPasswordKey];
    [DEFAULTS setObject:token forKey:RCDIMTokenKey];
    [DEFAULTS setObject:userId forKey:RCDUserIdKey];
    [DEFAULTS synchronize];

    [RCDUserInfoManager
        getUserInfoFromServer:userId
                     complete:^(RCDUserInfo *userInfo) {
                         [RCIM sharedRCIM].currentUserInfo = userInfo;
                         [RCDBuglyManager
                             setUserIdentifier:[NSString stringWithFormat:@"%@ - %@", userInfo.userId, userInfo.name]];
                         [DEFAULTS setObject:userInfo.portraitUri forKey:RCDUserPortraitUriKey];
                         [DEFAULTS setObject:userInfo.name forKey:RCDUserNickNameKey];
                         [DEFAULTS setObject:userInfo.stAccount forKey:RCDSealTalkNumberKey];
                         [DEFAULTS setObject:userInfo.gender forKey:RCDUserGenderKey];
                         [DEFAULTS synchronize];
                     }];

    [RCDDataSource syncAllData];
    dispatch_async(dispatch_get_main_queue(), ^{
        RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
        RCDNavigationViewController *rootNavi =
            [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
        [UIApplication sharedApplication].delegate.window.rootViewController = rootNavi;
    });
}

- (void)loginRongCloud:(NSString *)userName
                userId:(NSString *)userId
                 token:(NSString *)token
              password:(NSString *)password {
    self.loginUserName = userName;
    self.loginUserId = userId;
    self.loginToken = token;
    self.loginPassword = password;

    [[RCDIMService sharedService] connectWithToken:token
        dbOpened:^(RCDBErrorCode code) {
            NSLog(@"RCDBOpened %@", code ? @"failed" : @"success");
        }
        success:^(NSString *userId) {
            NSLog([NSString stringWithFormat:@"token is %@  userId is %@", token, userId], nil);
            self.loginUserId = userId;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loginSuccess:self.loginUserName
                            userId:self.loginUserId
                             token:self.loginToken
                          password:self.loginPassword];
            });

        }
        error:^(RCConnectErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == RC_CONN_TOKEN_INCORRECT) {
                    NSLog(@"IncorrectToken");
                    if (self.loginFailureTimes < 1) {
                        self.loginFailureTimes++;
                        [RCDLoginManager getToken:^(BOOL success, NSString *_Nonnull token, NSString *_Nonnull userId) {
                            if (success) {
                                [self loginRongCloud:userName userId:userId token:token password:password];
                            } else {
                                rcd_dispatch_main_async_safe(^{
                                    [self.hud hide:YES];
                                    NSLog(@"Token无效");
                                    _errorMsgLb.text = RCDLocalizedString(@"can_not_connect_server");
                                });
                            }
                        }];
                    }
                } else {
                    [self.hud hide:YES];
                    NSLog(@"RCConnectErrorCode is %ld", (long)status);
                    _errorMsgLb.text =
                        [NSString stringWithFormat:@"%@ Status: %zd", RCDLocalizedString(@"Login_fail"), status];
                    [_pwdTextField shake];
                }
            });
        }];
}

/*阅读用户协议*/
- (void)userProtocolEvent {
}

/*注册*/
- (void)registerEvent {
    RCDRegisterViewController *temp = [[RCDRegisterViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

/*找回密码*/
- (void)forgetPswEvent {
    RCDFindPswViewController *temp = [[RCDFindPswViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

// timer
- (void)retryConnectionFailed {
    [[RCIM sharedRCIM] disconnect];
    [self stopRetryTimerIfNeed];
    [self.hud hide:YES];
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

#pragma mark UITextFieldDelegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    switch (textField.tag) {
    case UserTextFieldTag:
        [DEFAULTS removeObjectForKey:RCDUserNameKey];
        self.passwordTextField.text = nil;
    case PassWordFieldTag:
        [DEFAULTS removeObjectForKey:RCDUserPasswordKey];
        break;
    default:
        break;
    }
    return YES;
}

//验证用户信息格式
- (BOOL)validateUserName:(NSString *)userName userPwd:(NSString *)userPwd {
    NSString *alertMessage = nil;
    if (userName.length == 0) {
        alertMessage = RCDLocalizedString(@"username_can_not_nil");
    } else if (userPwd.length == 0) {
        alertMessage = RCDLocalizedString(@"password_can_not_nil");
    }

    if (alertMessage) {
        _errorMsgLb.text = alertMessage;
        [_pwdTextField shake];
        return NO;
    }
    if ([RCDTextFieldValidate validatePassword:userPwd] == NO) {
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

/*获取用户账号*/
- (NSString *)getDefaultUserName {
    NSString *defaultUser = [DEFAULTS objectForKey:RCDUserNameKey];
    return defaultUser;
}

/*获取用户密码*/
- (NSString *)getDefaultUserPwd {
    NSString *defaultUserPwd = [DEFAULTS objectForKey:RCDUserPasswordKey];
    return defaultUserPwd;
}

// timer
- (void)stopRetryTimerIfNeed {
    if (self.retryTimer && [self.retryTimer isValid]) {
        [self.retryTimer invalidate];
        self.retryTimer = nil;
    }
}

- (void)startRetryTimer {
    [self stopRetryTimerIfNeed];
    self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                       target:self
                                                     selector:@selector(retryConnectionFailed)
                                                     userInfo:nil
                                                      repeats:NO];
}

//键盘升起时动画
- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardBounds = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat space =
        self.inputBackground.frame.origin.y + CGRectGetMaxY(self.passwordTextField.frame) - keyboardBounds.origin.y;
    if (space > 0) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.view.frame =
                                 CGRectMake(0.f, -space, self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:nil];
    }
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame =
                             CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:nil];
}

- (void)didConnectStatusUpdate:(NSNotification *)notifi {
    RCConnectionStatus status = [notifi.object integerValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == ConnectionStatus_Connected) {
            [RCIM sharedRCIM].connectionStatusDelegate =
                (id<RCIMConnectionStatusDelegate>)[UIApplication sharedApplication].delegate;
            [self loginSuccess:self.loginUserName
                        userId:self.loginUserId
                         token:self.loginToken
                      password:self.loginPassword];
        } else if (status == ConnectionStatus_NETWORK_UNAVAILABLE) {
            self.errorMsgLb.text = RCDLocalizedString(@"network_can_not_use_please_check");
        } else if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
            self.errorMsgLb.text = RCDLocalizedString(@"accout_kicked");
        } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
            NSLog(@"Token无效");
            self.errorMsgLb.text = RCDLocalizedString(@"can_not_connect_server");
            if (self.loginFailureTimes < 1) {
                self.loginFailureTimes++;
                [RCDLoginManager getToken:^(BOOL success, NSString *_Nonnull token, NSString *_Nonnull userId) {
                    if (success) {
                        [self loginRongCloud:self.loginUserName userId:userId token:token password:self.loginPassword];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.hud hide:YES];
                            NSLog(@"Token无效");
                            self.errorMsgLb.text = RCDLocalizedString(@"can_not_connect_server");
                        });
                    }
                }];
            }
        } else {
            NSLog(@"RCConnectErrorCode is %zd", status);
        }
    });
}

#pragma mark - private method

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectStatusUpdate:)
                                                 name:RCKitDispatchConnectionStatusChangedNotification
                                               object:nil];
}

- (void)initSubviews {
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    //添加动态图
    [self.view addSubview:self.animatedImagesView];
    [self.animatedImagesView addSubview:[self getSwitchLanguageBtn]];
    [self.view addSubview:self.rongLogoView];
    //中部内容输入区
    [self.view addSubview:self.inputBackground];
    [self.view addSubview:self.errorMsgLb];
    [self.inputBackground addSubview:self.countryTextField];
    //用户名
    self.phoneTextField.textField.text = [self getDefaultUserName];
    [self.inputBackground addSubview:self.phoneTextField];
    //密码
    [self.inputBackground addSubview:self.passwordTextField];
    self.passwordTextField.text = [self getDefaultUserPwd];
    [self.inputBackground addSubview:self.loginButton];
    //设置按钮
    [_inputBackground addSubview:self.settingButton];
    self.settingButton.hidden = YES;
    [self.view addSubview:self.userProtocolButton];
    [self.view addSubview:self.bottomBackground];
    //底部按钮区
    [self.bottomBackground addSubview:self.registerButton];
    [self.bottomBackground addSubview:self.forgetPswButton];
    [self.bottomBackground addSubview:self.footerLabel];
}

- (void)setLayout {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBackground
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:20]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_rongLogoView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];

    NSDictionary *views = NSDictionaryOfVariableBindings(_errorMsgLb, _rongLogoView, _inputBackground,
                                                         _userProtocolButton, _bottomBackground);

    NSArray *viewConstraints = [[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-41-[_inputBackground]-41-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:views]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-70-[_rongLogoView(100)]-10-["
                                                                      @"_errorMsgLb(==15)]-20-["
                                                                      @"_inputBackground(380)]-20-["
                                                                      @"_userProtocolButton(==20)]"
                                                              options:0
                                                              metrics:nil
                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:[_bottomBackground(==BOTTOMOHEIGHT)]"
                                                              options:0
                                                              metrics:@{
                                                                  @"BOTTOMOHEIGHT" : @(50 + RCDExtraBottomHeight)
                                                              }
                                                                views:views]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_bottomBackground]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_errorMsgLb]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rongLogoView(100)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];

    [self.view addConstraints:viewConstraints];

    NSLayoutConstraint *userProtocolLabelConstraint = [NSLayoutConstraint constraintWithItem:_userProtocolButton
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.f
                                                                                    constant:0];
    [self.view addConstraint:userProtocolLabelConstraint];
    NSDictionary *inputViews = NSDictionaryOfVariableBindings(_countryTextField, _phoneTextField, _passwordTextField,
                                                              _loginButton, _settingButton);

    NSArray *inputViewConstraints = [[[[[
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_phoneTextField]|" options:0 metrics:nil views:inputViews]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_countryTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_passwordTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-[_countryTextField(60)]-[_phoneTextField("
                                                                      @"60)]-[_passwordTextField(60)]-[_loginButton("
                                                                      @"50)]-40-[_settingButton(50)]"
                                                              options:0
                                                              metrics:nil
                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_loginButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_settingButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]];

    [_inputBackground addConstraints:inputViewConstraints];
}

#pragma mark - Getters and setters
- (UIButton *)getSwitchLanguageBtn {
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

- (RCAnimatedImagesView *)animatedImagesView {
    if (!_animatedImagesView) {
        _animatedImagesView = [[RCAnimatedImagesView alloc]
            initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _animatedImagesView.delegate = self;
    }
    return _animatedImagesView;
}

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
        _phoneTextField.tag = UserTextFieldTag;
        _phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@", self.currentRegion.phoneCode];
        _phoneTextField.userInteractionEnabled = YES;
        _phoneTextField.textField.adjustsFontSizeToFitWidth = YES;
        _phoneTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
        if (_phoneTextField.textField.text.length > 0) {
            [_phoneTextField.textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
        }
        _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneTextField.textField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"mobile_number")
                                            attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    return _phoneTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        RCUnderlineTextField *passwordTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
        passwordTextField.tag = PassWordFieldTag;
        passwordTextField.textColor = [UIColor whiteColor];
        passwordTextField.returnKeyType = UIReturnKeyDone;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.delegate = self;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

        passwordTextField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"password")
                                            attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

        passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField = passwordTextField;
    }
    return _passwordTextField;
}

- (UIImageView *)rongLogoView {
    if (!_rongLogoView) {
        UIImage *rongLogoImage = [UIImage imageNamed:@"login_logo"];
        _rongLogoView = [[UIImageView alloc] initWithImage:rongLogoImage];
        _rongLogoView.contentMode = UIViewContentModeScaleAspectFit;
        _rongLogoView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _rongLogoView;
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

- (UIButton *)loginButton {
    if (!_loginButton) {

        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton addTarget:self action:@selector(loginEvent:) forControlEvents:UIControlEventTouchUpInside];
        //    [loginButton setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateNormal];
        [loginButton setTitle:RCDLocalizedString(@"Login") forState:UIControlStateNormal];
        loginButton.backgroundColor = [UIColor colorWithRed:28 / 255.0 green:119 / 255.0 blue:211 / 255.0 alpha:0.95];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginButton.layer.cornerRadius = 3;
        loginButton.titleLabel.font = [UIFont systemFontOfSize:23];
        loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        _loginButton = loginButton;
    }
    return _loginButton;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingButton setTitle:RCDLocalizedString(@"private_cloud_setting") forState:UIControlStateNormal];
        [settingButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                            forState:UIControlStateNormal];
        [settingButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:17.0]];
        settingButton.translatesAutoresizingMaskIntoConstraints = NO;
        _settingButton = settingButton;
    }
    return _settingButton;
}

- (UIButton *)userProtocolButton {
    if (!_userProtocolButton) {
        UIButton *userProtocolButton = [[UIButton alloc] initWithFrame:CGRectZero];
        //    [userProtocolButton setTitle:@"阅读用户协议"
        //    forState:UIControlStateNormal];
        [userProtocolButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                                 forState:UIControlStateNormal];

        [userProtocolButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        [userProtocolButton addTarget:self
                               action:@selector(userProtocolEvent)
                     forControlEvents:UIControlEventTouchUpInside];
        userProtocolButton.translatesAutoresizingMaskIntoConstraints = NO;
        _userProtocolButton = userProtocolButton;
    }
    return _userProtocolButton;
}

- (UIView *)bottomBackground {
    if (!_bottomBackground) {
        _bottomBackground = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomBackground.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bottomBackground;
}

- (UIButton *)registerButton {
    if (!_registerButton) {
        UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, 120, 50)];
        [registerButton setTitle:RCDLocalizedString(@"forgot_password") forState:UIControlStateNormal];
        [registerButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                             forState:UIControlStateNormal];
        registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [registerButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        [registerButton addTarget:self action:@selector(forgetPswEvent) forControlEvents:UIControlEventTouchUpInside];
        _registerButton = registerButton;
    }
    return _registerButton;
}

- (UIButton *)forgetPswButton {
    if (!_forgetPswButton) {
        UIButton *forgetPswButton =
            [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, -16, 80, 50)];
        [forgetPswButton setTitle:RCDLocalizedString(@"new_user") forState:UIControlStateNormal];
        [forgetPswButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                              forState:UIControlStateNormal];
        forgetPswButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [forgetPswButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        [forgetPswButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
        _forgetPswButton = forgetPswButton;
    }
    return _forgetPswButton;
}

- (UILabel *)footerLabel {
    if (!_footerLabel) {
        CGRect screenBounds = self.view.frame;
        UILabel *footerLabel = [[UILabel alloc] init];
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.frame = CGRectMake(screenBounds.size.width / 2 - 100, -2, 200, 21);
        footerLabel.text = @"Powered by RongCloud";
        [footerLabel setFont:[UIFont systemFontOfSize:12.f]];
        [footerLabel setTextColor:[UIColor colorWithHexString:@"484848" alpha:1.0]];
        _footerLabel = footerLabel;
    }
    return _footerLabel;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
        [self.view bringSubviewToFront:_hud];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    }
    return _hud;
}
@end
