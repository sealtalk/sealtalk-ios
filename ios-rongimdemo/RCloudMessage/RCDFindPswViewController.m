//
//  RCDFindPswViewController.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/23.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDFindPswViewController.h"
#import "AFHttpTool.h"
#import "MBProgressHUD.h"
#import "RCDLoginViewController.h"
#import "RCDRegisterViewController.h"
#import "RCUnderlineTextField.h"
#import "UIColor+RCColor.h"
#import "RCDIndicateTextField.h"
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDLanguageManager.h"
#import "AppDelegate.h"
@interface RCDFindPswViewController () <UITextFieldDelegate, RCDCountryListControllerDelegate>
@property(nonatomic, strong) RCDCountry *currentRegion;

@property(nonatomic, strong) RCDIndicateTextField *countryTextField;
@property(nonatomic, strong) RCDIndicateTextField *phoneTextField;

@property(nonatomic, strong) UIView *headBackground;
@property(nonatomic, strong) UIImageView *rongLogo;
@property(nonatomic, strong) UIView *inputBackground;
@property(strong, nonatomic) RCAnimatedImagesView *animatedImagesView;
@property(nonatomic, strong) UIView *statusBarView;
@property(nonatomic, strong) UILabel *licenseLb;
@property(nonatomic, strong) UILabel *errorMsgLb;
@end

@implementation RCDFindPswViewController {
    NSTimer *_countDownTimer;
    int _seconds;
    MBProgressHUD *hud;
}
#define UserTextFieldTag 1000
#define PassWordFieldTag 1001
#define RePassWordFieldTag 1002
#define SendCodeButtonTag 1003
#define vCodeTimerLabelTag 1004
#define VerificationCodeField 1005
@synthesize animatedImagesView = _animatedImagesView;
@synthesize inputBackground = _inputBackground;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentRegion = [[RCDCountry alloc] initWithDict:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentCountry"]];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.animatedImagesView = [[RCAnimatedImagesView alloc]
        initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.animatedImagesView];
    self.animatedImagesView.delegate = self;
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    _headBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -100, self.view.bounds.size.width, 50)];
    _headBackground.userInteractionEnabled = YES;
    _headBackground.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:_headBackground];

    UIButton *registerHeadButton =
        [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 90, 0, 80, 50)];
    [registerHeadButton setTitle:RCDLocalizedString(@"Login") forState:UIControlStateNormal];
    [registerHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                             forState:UIControlStateNormal];
    registerHeadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [registerHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerHeadButton addTarget:self action:@selector(loginPageEvent) forControlEvents:UIControlEventTouchUpInside];
    [_headBackground addSubview:registerHeadButton];
    
    UIButton *switchLanguage = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80,30, 70, 40)];
    [switchLanguage setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    switchLanguage.titleLabel.font = [UIFont systemFontOfSize:16.];
    NSString *currentlanguage = [RCDLanguageManager sharedRCDLanguageManager].localzableLanguage;
    if ([currentlanguage isEqualToString:@"en"]) {
        [switchLanguage setTitle:@"简体中文" forState:(UIControlStateNormal)];
    }else if ([currentlanguage isEqualToString:@"zh-Hans"]){
        [switchLanguage setTitle:@"EN" forState:(UIControlStateNormal)];
    }
    [switchLanguage addTarget:self action:@selector(didTapSwitchLanguage:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.animatedImagesView addSubview:switchLanguage];
    UIImage *rongLogoSmallImage = [UIImage imageNamed:@"title_logo_small"];

    UIImageView *rongLogoSmallImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 60, 5, 100, 40)];
    [rongLogoSmallImageView setImage:rongLogoSmallImage];

    [rongLogoSmallImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    rongLogoSmallImageView.contentMode = UIViewContentModeScaleAspectFit;
    rongLogoSmallImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    rongLogoSmallImageView.clipsToBounds = YES;
    [_headBackground addSubview:rongLogoSmallImageView];
    UIButton *forgetPswHeadButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 80, 50)];

    [forgetPswHeadButton setTitle:RCDLocalizedString(@"new_user") forState:UIControlStateNormal];
    [forgetPswHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                              forState:UIControlStateNormal];
    forgetPswHeadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [forgetPswHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswHeadButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
    [_headBackground addSubview:forgetPswHeadButton];
    _licenseLb = [[UILabel alloc] initWithFrame:CGRectZero];
    //  _licenseLb.text = @"仅供演示融云 SDK 功能使用";
    _licenseLb.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
    _licenseLb.translatesAutoresizingMaskIntoConstraints = NO;
    _licenseLb.textColor = [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
    [self.view addSubview:_licenseLb];

    UIImage *rongLogoImage = [UIImage imageNamed:@"login_logo"];
    _rongLogo = [[UIImageView alloc] initWithImage:rongLogoImage];
    _rongLogo.contentMode = UIViewContentModeScaleAspectFit;
    _rongLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_rongLogo];

    _inputBackground = [[UIView alloc] initWithFrame:CGRectZero];
    _inputBackground.translatesAutoresizingMaskIntoConstraints = NO;
    _inputBackground.userInteractionEnabled = YES;
    [self.view addSubview:_inputBackground];
    _errorMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
    _errorMsgLb.text = @"";
    _errorMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
    _errorMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
    _errorMsgLb.textColor = [UIColor colorWithRed:204.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1];
    [self.view addSubview:_errorMsgLb];
    
    UIColor *color = [UIColor whiteColor];
    self.countryTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:self.countryTextField];
    self.phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:self.phoneTextField];
    if (self.phoneTextField.textField.text.length > 0) {
        [self.phoneTextField.textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
    }

    RCUnderlineTextField *verificationCodeField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];

    verificationCodeField.backgroundColor = [UIColor clearColor];
    verificationCodeField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"verification_code") attributes:@{NSForegroundColorAttributeName : color}];
    verificationCodeField.textColor = [UIColor whiteColor];
    verificationCodeField.delegate = self;
    verificationCodeField.translatesAutoresizingMaskIntoConstraints = NO;
    verificationCodeField.tag = VerificationCodeField;
    [_inputBackground addSubview:verificationCodeField];
    verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;

    UIButton *sendCodeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [sendCodeButton
        setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
    [sendCodeButton setTitle:RCDLocalizedString(@"send_verification_code") forState:UIControlStateNormal];
    [sendCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [sendCodeButton addTarget:self action:@selector(sendCodeEvent) forControlEvents:UIControlEventTouchUpInside];
    sendCodeButton.tag = SendCodeButtonTag;
    //    sendCodeButton.enabled = NO;
    sendCodeButton.translatesAutoresizingMaskIntoConstraints = NO;

    [_inputBackground addSubview:sendCodeButton];
    //  UIButton *reSendCodeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    //  [reSendCodeButton setTitle:@"重发验证码" forState:UIControlStateNormal];
    //  [reSendCodeButton
    //      setTitleColor:
    //          [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
    //           forState:UIControlStateDisabled];
    //  [reSendCodeButton setTitleColor:[UIColor blueColor]
    //                         forState:UIControlStateNormal];
    //  reSendCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    //  [reSendCodeButton addTarget:self
    //                       action:@selector(sendCodeEvent)
    //             forControlEvents:UIControlEventTouchUpInside];
    //  [reSendCodeButton setEnabled:false];
    //  reSendCodeButton.translatesAutoresizingMaskIntoConstraints = NO;
    //[_inputBackground addSubview:reSendCodeButton];

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
    vCodeTimerLb.tag = vCodeTimerLabelTag;
    [_inputBackground addSubview:vCodeTimerLb];

    RCUnderlineTextField *passwordTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
    passwordTextField.tag = PassWordFieldTag;
    passwordTextField.textColor = [UIColor whiteColor];
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.delegate = self;
    passwordTextField.secureTextEntry = YES;

    passwordTextField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"new_password")
 attributes:@{NSForegroundColorAttributeName : color}];
    passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:passwordTextField];
    UILabel *pswMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
    pswMsgLb.text = RCDLocalizedString(@"char_section_case_sensitive_from6_t16");
    pswMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:10.0];
    pswMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
    pswMsgLb.textColor = [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
    [_inputBackground addSubview:pswMsgLb];

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:RCDLocalizedString(@"confirm") forState:UIControlStateNormal];
    loginButton.backgroundColor = [UIColor colorWithRed:28 / 255.0 green:119 / 255.0 blue:211 / 255.0 alpha:0.95];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.layer.cornerRadius = 3;
    loginButton.titleLabel.font = [UIFont systemFontOfSize:23];
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:loginButton];

    UIView *bottomBackground = [[UIView alloc] initWithFrame:CGRectZero];
    bottomBackground.translatesAutoresizingMaskIntoConstraints = NO;
    UIButton *registerButton =
        [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, -16, 80, 50)];
    [registerButton setTitle:RCDLocalizedString(@"Login") forState:UIControlStateNormal];
    [registerButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                         forState:UIControlStateNormal];
    registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [registerButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerButton addTarget:self action:@selector(loginPageEvent) forControlEvents:UIControlEventTouchUpInside];

    UIButton *forgetPswButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, 80, 50)];
    [forgetPswButton setTitle:RCDLocalizedString(@"new_user") forState:UIControlStateNormal];
    [forgetPswButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                          forState:UIControlStateNormal];
    forgetPswButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    forgetPswButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [forgetPswButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:forgetPswButton];
    [bottomBackground addSubview:registerButton];

    CGRect screenBounds = self.view.frame;
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.frame = CGRectMake(screenBounds.size.width / 2 - 100, -2, 200, 21);
    footerLabel.text = @"Powered by RongCloud";
    [footerLabel setFont:[UIFont systemFontOfSize:12.f]];
    [footerLabel setTextColor:[UIColor colorWithHexString:@"484848" alpha:1.0]];
    [bottomBackground addSubview:footerLabel];

    [self.view addSubview:bottomBackground];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendCodeButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendCodeButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:verificationCodeField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];
    //  [self.view addConstraint:[NSLayoutConstraint
    //                               constraintWithItem:reSendCodeButton
    //                                        attribute:NSLayoutAttributeBottom
    //                                        relatedBy:NSLayoutRelationEqual
    //                                           toItem:verificationCodeField
    //                                        attribute:NSLayoutAttributeBottom
    //                                       multiplier:1.0
    //                                         constant:-7]];
    //  [self.view addConstraint:[NSLayoutConstraint
    //                               constraintWithItem:reSendCodeButton
    //                                        attribute:NSLayoutAttributeRight
    //                                        relatedBy:NSLayoutRelationEqual
    //                                           toItem:verificationCodeField
    //                                        attribute:NSLayoutAttributeRight
    //                                       multiplier:1.0
    //                                         constant:-33]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:vCodeTimerLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:vCodeTimerLb
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:verificationCodeField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:vCodeTimerLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-7]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:vCodeTimerLb
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:sendCodeButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:vCodeTimerLb
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:sendCodeButton
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomBackground
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:20]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pswMsgLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:passwordTextField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:4]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pswMsgLb
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:passwordTextField
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
                                                         bottomBackground, vCodeTimerLb);

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
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBackground(==50)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[bottomBackground]-10-|"
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
        NSDictionaryOfVariableBindings(verificationCodeField, pswMsgLb, _countryTextField, _phoneTextField, passwordTextField,
                                       loginButton, vCodeTimerLb, sendCodeButton, vCodeTimerLb);

    NSArray *inputViewConstraints = [[[[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_countryTextField]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:inputViews]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_phoneTextField]|"
                                                                                                                options:0
                                                                                                                metrics:nil
                                                                                                                  views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[passwordTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[verificationCodeField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[verificationCodeField]-[sendCodeButton(80)]|"
                                                    options:0
                                                    metrics:nil
                                                      views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[verificationCodeField]-[vCodeTimerLb]|"
                                                              options:0
                                                              metrics:nil
                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_countryTextField(60)]-[_phoneTextField(60)]-[verificationCodeField(50)]-["
                                                            @"passwordTextField(55)]-[loginButton(50)]"
                                                    options:0
                                                    metrics:nil
                                                      views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[loginButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]];

    [_inputBackground addConstraints:inputViewConstraints];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    _statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    _statusBarView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:_statusBarView];
    [self.view setNeedsLayout];
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - RCDCountryListControllerDelegate
- (void)fetchCountryPhoneCode:(RCDCountry *)country{
    self.currentRegion = country;
    self.countryTextField.textField.text = country.countryName;
    self.phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@",self.currentRegion.phoneCode];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == UserTextFieldTag) {
        if (textField.text.length > 0) {
            ((UIButton *)[self.view viewWithTag:SendCodeButtonTag]).enabled = YES;
            [((UIButton *)[self.view viewWithTag:SendCodeButtonTag])
                setBackgroundColor:[[UIColor alloc] initWithRed:23 / 255.f green:136 / 255.f blue:213 / 255.f alpha:1]];
        }
        if (textField.text.length == 0) {
            ((UIButton *)[self.view viewWithTag:SendCodeButtonTag]).enabled = NO;
            [((UIButton *)[self.view viewWithTag:SendCodeButtonTag]) setBackgroundColor:[[UIColor alloc]
                                                                                            initWithRed:133 / 255.f
                                                                                                  green:133 / 255.f
                                                                                                   blue:133 / 255.f
                                                                                                  alpha:1]];
        }
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
- (void)keyboardWillShow:(NSNotification *)notif {

    [UIView animateWithDuration:0.25
                     animations:^{

                         self.view.frame =
                             CGRectMake(0.f, -50, self.view.frame.size.width, self.view.frame.size.height);
                         _headBackground.frame = CGRectMake(0, 70, self.view.bounds.size.width, 50);
                         _rongLogo.hidden = YES;
                         _licenseLb.hidden = YES;
                         _statusBarView.frame = CGRectMake(0.f, 50, self.view.frame.size.width, 20);
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame =
                             CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
                         CGRectMake(0, -100, self.view.bounds.size.width, 50);
                         _headBackground.frame = CGRectMake(0, -100, self.view.bounds.size.width, 50);
                         _rongLogo.hidden = NO;
                         _licenseLb.hidden = NO;
                         _statusBarView.frame = CGRectMake(0.f, 0, self.view.frame.size.width, 20);
                     }
                     completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.animatedImagesView startAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.animatedImagesView stopAnimating];
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
/*发送验证码*/
- (void)sendCodeEvent {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    [hud show:YES];
    _errorMsgLb.text = @"";
    NSString *phoneNumber = self.phoneTextField.textField.text;
    if (phoneNumber.length > 0) {
        [AFHttpTool
            checkPhoneNumberAvailable:self.currentRegion.phoneCode
                          phoneNumber:phoneNumber
                              success:^(id response) {
                                  if ([response[@"code"] intValue] == 200) {
                                      //                if ([[NSString
                                      //                stringWithFormat:@"%@",response[@"message"]]
                                      //                isEqualToString:@"Phone number has already
                                      //                existed."]) {
                                      if ([response[@"result"] integerValue] == 0) {
                                          [AFHttpTool getVerificationCode:self.currentRegion.phoneCode
                                              phoneNumber:phoneNumber
                                              success:^(id response) {
                                                  [hud hide:YES];
                                                  if ([response[@"code"] intValue] == 200) {
                                                      ((UILabel *)[self.view viewWithTag:vCodeTimerLabelTag]).hidden =
                                                          NO;
                                                      ((UIButton *)[self.view viewWithTag:SendCodeButtonTag]).hidden =
                                                          YES;
                                                      [self countDown:60];
                                                  }else{
                                                      if([response[@"code"] intValue] == 3102){
                                                          _errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
                                                      }else{
                                                          _errorMsgLb.text = response[@"result"][@"msg"];
                                                      }
                                                  }
                                              }
                                              failure:^(NSError *err) {
                                                  [hud hide:YES];
                                                  _errorMsgLb.text = RCDLocalizedString(@"network_can_not_use_please_check");
                                                  NSLog(@"%@", err);
                                              }];

                                      } else {
                                          [hud hide:YES];
                                          _errorMsgLb.text = @"手机号未注册";
                                      }
                                  }else{
                                      [hud hide:YES];
                                      _errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
                                  }
                              }
                              failure:^(NSError *err){
                                  [hud hide:YES];
                                  _errorMsgLb.text = RCDLocalizedString(@"network_can_not_use_please_check");
                              }];

    } else {
        [hud hide:YES];
        _errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
    }
}
- (void)registerEvent {
    RCDRegisterViewController *temp = [[RCDRegisterViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

- (IBAction)btnDoneClicked:(id)sender {
    _errorMsgLb.text = @"";
    if (![self checkContent])
        return;
    NSString *phone = self.phoneTextField.textField.text;
    NSString *userPwd = [(UITextField *)[self.view viewWithTag:PassWordFieldTag] text];
    NSString *vCode = [(UITextField *)[self.view viewWithTag:VerificationCodeField] text];
    [AFHttpTool verifyVerificationCode:self.currentRegion.phoneCode
                           phoneNumber:phone
                      verificationCode:vCode
                               success:^(id response) {
                                   if ([response[@"code"] intValue] == 200) {
                                       NSDictionary *result = response[@"result"];
                                       NSString *vToken = result[@"verification_token"];
                                       [AFHttpTool resetPassword:userPwd
                                                          vToken:vToken
                                                         success:^(id response) {
                                                             if ([response[@"code"] intValue] == 200) {
                                                                 _errorMsgLb.text = RCDLocalizedString(@"change_success");
                                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                                                              0.5 * NSEC_PER_MSEC),
                                                                                dispatch_get_main_queue(), ^{
                                                                                    [self.navigationController
                                                                                        popViewControllerAnimated:YES];
                                                                                });
                                                             }

                                                         }
                                                         failure:^(NSError *err){

                                                         }];
                                   }

                               }
                               failure:^(NSError *err){

                               }];
}

/**
 *  检查输入内容
 *
 *  @return 是否合法输入
 */
- (BOOL)checkContent {
    NSString *userPwd = [(UITextField *)[self.view viewWithTag:PassWordFieldTag] text];
    NSString *vCode = [(UITextField *)[self.view viewWithTag:VerificationCodeField] text];

    //  if (![RCDTextFieldValidate validateEmail:userName]) {
    //    _errorMsgLb.text = @"邮箱格式不正确!";
    //    return NO;
    //  }

    //  if (userName.length == 0) {
    //
    //    _errorMsgLb.text = RCDLocalizedString(@"username_can_not_nil");
    //    return NO;
    //  }
    //    if (userPwd.length < 6) {
    //        _errorMsgLb.text = @"密码不能小于6位!";
    //    }
    if (userPwd.length > 20) {
        _errorMsgLb.text = RCDLocalizedString(@"password_can_not_more_than_20");
    }
    if (userPwd.length == 0) {
        _errorMsgLb.text = RCDLocalizedString(@"password_can_not_nil");
        return NO;
    }
    if (vCode.length == 0) {
        _errorMsgLb.text = RCDLocalizedString(@"verification_code_can_not_nil");
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
    _seconds = seconds;
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(timeFireMethod)
                                                     userInfo:nil
                                                      repeats:YES];
}
- (void)timeFireMethod {
    _seconds--;
    ((UILabel *)[self.view viewWithTag:vCodeTimerLabelTag]).text = [NSString stringWithFormat:RCDLocalizedString(@"after_x_seconds_send"), _seconds];
    if (_seconds == 0) {
        [_countDownTimer invalidate];
        ((UILabel *)[self.view viewWithTag:vCodeTimerLabelTag]).hidden = YES;
        ((UIButton *)[self.view viewWithTag:SendCodeButtonTag]).hidden = NO;
        ((UILabel *)[self.view viewWithTag:vCodeTimerLabelTag]).text = RCDLocalizedString(@"after_60_seconds_send");
    }
}

- (void)didTapCountryTextField{
    RCDCountryListController *countryListVC = [[RCDCountryListController alloc] init];
    countryListVC.delegate = self;
    [self.navigationController pushViewController:countryListVC animated:YES];
}

- (void)didTapSwitchLanguage:(UIButton *)button{
    NSString *currentLanguage = [RCDLanguageManager sharedRCDLanguageManager].localzableLanguage;
    if ([currentLanguage isEqualToString:@"en"]) {
        [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:@"zh-Hans"];
    }else if ([currentLanguage isEqualToString:@"zh-Hans"]){
        [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:@"en"];
    }
    RCDFindPswViewController *temp = [[RCDFindPswViewController alloc] init];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;        //可更改为其他方式
    transition.subtype = kCATransitionFromLeft; //可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:temp animated:NO];
}

#pragma mark - Getters and setters
-(RCDIndicateTextField *)countryTextField{
    if (!_countryTextField) {
        _countryTextField = [[RCDIndicateTextField alloc] init];
        _countryTextField.indicateInfoLabel.text = RCDLocalizedString(@"country");
        _countryTextField.textField.text = self.currentRegion.countryName;
        _countryTextField.textField.userInteractionEnabled = NO;
        [_countryTextField indicateIconShow:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCountryTextField)];
        [_countryTextField addGestureRecognizer:tap];
        _countryTextField.userInteractionEnabled = YES;
    }
    return _countryTextField;
}

- (RCDIndicateTextField *)phoneTextField{
    if (!_phoneTextField) {
        _phoneTextField = [[RCDIndicateTextField alloc] initWithFrame:CGRectZero];
        _phoneTextField.backgroundColor = [UIColor clearColor];
        _phoneTextField.textField.tag = UserTextFieldTag;
        [_phoneTextField.textField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
        _phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@",self.currentRegion.phoneCode];
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

@end
