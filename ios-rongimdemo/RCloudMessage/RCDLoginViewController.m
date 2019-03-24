//
//  LoginViewController.m
//  RongCloud
//
//  Created by Liv on 14/11/5.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//
#import "RCDLoginViewController.h"
#import "AFHttpTool.h"
#import "AppkeyModel.h"
#import "MBProgressHUD.h"
#import "RCDCommonDefine.h"
#import "RCDFindPswViewController.h"
#import "RCDHttpTool.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDRegisterViewController.h"
#import "RCDSettingServerUrlViewController.h"
#import "RCDTextFieldValidate.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "RCUnderlineTextField.h"
#import "UIColor+RCColor.h"
#import "UITextFiled+Shake.h"
#import "RCDIndicateTextField.h"
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDLanguageManager.h"
#import "AppDelegate.h"
#import "RCDBuglyManager.h"
@interface RCDLoginViewController () <UITextFieldDelegate, RCIMConnectionStatusDelegate, UIAlertViewDelegate, RCDCountryListControllerDelegate>

@property(retain, nonatomic) IBOutlet RCAnimatedImagesView *animatedImagesView;

@property(nonatomic, strong) RCDIndicateTextField *countryTextField;
@property(nonatomic, strong) RCDIndicateTextField *phoneTextField;

@property(weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property(nonatomic, strong) NSTimer *retryTime;

@property(nonatomic, strong) UIView *headBackground;
@property(nonatomic, strong) UIImageView *rongLogo;
@property(nonatomic, strong) UIView *inputBackground;
@property(nonatomic, strong) UIView *statusBarView;
@property(nonatomic, strong) UILabel *errorMsgLb;
@property(nonatomic, strong) UITextField *passwordTextField;

@property(nonatomic, strong) UIButton *settingButton;

@property(nonatomic, strong) AppkeyModel *currentModel;

@property(nonatomic) int loginFailureTimes;
@property(nonatomic) BOOL rcDebug;

@property(nonatomic, strong) NSString *loginUserName;
@property(nonatomic, strong) NSString *loginUserId;
@property(nonatomic, strong) NSString *loginToken;
@property(nonatomic, strong) NSString *loginPassword;
@property(nonatomic, strong) RCDCountry *currentRegion;

@end

@implementation RCDLoginViewController
#define UserTextFieldTag 1000
#define PassWordFieldTag 1001
@synthesize animatedImagesView = _animatedImagesView;
@synthesize inputBackground = _inputBackground;
MBProgressHUD *hud;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentRegion = [[RCDCountry alloc] initWithDict:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentCountry"]];
    self.rcDebug = NO;
#if RCDPrivateCloudManualMode
    self.rcDebug = YES;
#endif

    _loginFailureTimes = 0;

    [self.navigationController setNavigationBarHidden:YES animated:YES];

    //    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    //添加动态图
    self.animatedImagesView = [[RCAnimatedImagesView alloc]
        initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.animatedImagesView];
    self.animatedImagesView.delegate = self;

    //添加头部内容
    _headBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -100, self.view.bounds.size.width, 50)];
    _headBackground.userInteractionEnabled = YES;
    _headBackground.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:_headBackground];

    UIButton *registerHeadButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 120, 50)];
    [registerHeadButton setTitle:RCDLocalizedString(@"forgot_password") forState:UIControlStateNormal];
    [registerHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                             forState:UIControlStateNormal];
    registerHeadButton.titleLabel.font = [UIFont systemFontOfSize:16];
    registerHeadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [registerHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerHeadButton addTarget:self action:@selector(forgetPswEvent) forControlEvents:UIControlEventTouchUpInside];

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
    
    //添加图标
    UIImage *rongLogoSmallImage = [UIImage imageNamed:@"title_logo_small"];
    UIImageView *rongLogoSmallImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 60, 5, 100, 40)];
    [rongLogoSmallImageView setImage:rongLogoSmallImage];

    [rongLogoSmallImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    rongLogoSmallImageView.contentMode = UIViewContentModeScaleAspectFit;
    rongLogoSmallImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    rongLogoSmallImageView.clipsToBounds = YES;
    [_headBackground addSubview:rongLogoSmallImageView];

    //顶部按钮
    UIButton *forgetPswHeadButton =
        [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 0, 70, 50)];
    [forgetPswHeadButton setTitle:RCDLocalizedString(@"new_user") forState:UIControlStateNormal];
    [forgetPswHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                              forState:UIControlStateNormal];
    forgetPswHeadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [forgetPswHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswHeadButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
    [_headBackground addSubview:forgetPswHeadButton];

    UIImage *rongLogoImage = [UIImage imageNamed:@"login_logo"];
    _rongLogo = [[UIImageView alloc] initWithImage:rongLogoImage];
    _rongLogo.contentMode = UIViewContentModeScaleAspectFit;
    _rongLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_rongLogo];

    //中部内容输入区
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
    
    self.countryTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:self.countryTextField];
    //用户名

    self.phoneTextField.textField.text = [self getDefaultUserName];
    [_inputBackground addSubview:self.phoneTextField];

    //密码
    RCUnderlineTextField *passwordTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
    passwordTextField.tag = PassWordFieldTag;
    passwordTextField.textColor = [UIColor whiteColor];
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.delegate = self;
    // passwordTextField.delegate = self;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

    passwordTextField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"password") attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    // passwordTextField.text = [self getDefaultUserPwd];
    [_inputBackground addSubview:passwordTextField];
    passwordTextField.text = [self getDefaultUserPwd];
    self.passwordTextField = passwordTextField;

    // UIEdgeInsets buttonEdgeInsets = UIEdgeInsetsMake(0, 7.f, 0, 7.f);
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
//    [loginButton setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateNormal];
    [loginButton setTitle:RCDLocalizedString(@"Login") forState:UIControlStateNormal];
    loginButton.backgroundColor = [UIColor colorWithRed:28 / 255.0 green:119 / 255.0 blue:211 / 255.0 alpha:0.95];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.layer.cornerRadius = 3;
    loginButton.titleLabel.font = [UIFont systemFontOfSize:23];
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:loginButton];

    //设置按钮
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setTitle:RCDLocalizedString(@"private_cloud_setting") forState:UIControlStateNormal];
    [settingButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                        forState:UIControlStateNormal];
    [settingButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:17.0]];
    [settingButton addTarget:self action:@selector(settingEvent) forControlEvents:UIControlEventTouchUpInside];
    settingButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:settingButton];
    self.settingButton = settingButton;
    settingButton.hidden = !self.rcDebug;

    UIButton *userProtocolButton = [[UIButton alloc] initWithFrame:CGRectZero];
    //    [userProtocolButton setTitle:@"阅读用户协议"
    //    forState:UIControlStateNormal];
    [userProtocolButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                             forState:UIControlStateNormal];

    [userProtocolButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [userProtocolButton addTarget:self
                           action:@selector(userProtocolEvent)
                 forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:userProtocolButton];

    //底部按钮区
    UIView *bottomBackground = [[UIView alloc] initWithFrame:CGRectZero];
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, 120, 50)];
    [registerButton setTitle:RCDLocalizedString(@"forgot_password") forState:UIControlStateNormal];
    [registerButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                         forState:UIControlStateNormal];
    registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [registerButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerButton addTarget:self action:@selector(forgetPswEvent) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:registerButton];

    UIButton *forgetPswButton =
        [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, -16, 80, 50)];
    [forgetPswButton setTitle:RCDLocalizedString(@"new_user") forState:UIControlStateNormal];
    [forgetPswButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                          forState:UIControlStateNormal];
    forgetPswButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [forgetPswButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:forgetPswButton];

    CGRect screenBounds = self.view.frame;
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.frame = CGRectMake(screenBounds.size.width / 2 - 100, -2, 200, 21);
    footerLabel.text = @"Powered by RongCloud";
    [footerLabel setFont:[UIFont systemFontOfSize:12.f]];
    [footerLabel setTextColor:[UIColor colorWithHexString:@"484848" alpha:1.0]];
    [bottomBackground addSubview:footerLabel];

    [self.view addSubview:bottomBackground];

    bottomBackground.translatesAutoresizingMaskIntoConstraints = NO;
    userProtocolButton.translatesAutoresizingMaskIntoConstraints = NO;
    passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;

    //添加约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomBackground
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:20]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_rongLogo
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];

    NSDictionary *views =
        NSDictionaryOfVariableBindings(_errorMsgLb, _rongLogo, _inputBackground, userProtocolButton, bottomBackground);

    NSArray *viewConstraints = [[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-41-[_inputBackground]-41-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:views]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[_rongLogo(100)]-10-[_"
                                                                                      @"errorMsgLb(==10)]-20-[_"
                                                                                      @"inputBackground(380)]-20-["
                                                                                      @"userProtocolButton(==20)]"
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
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_errorMsgLb]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rongLogo(100)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];

    [self.view addConstraints:viewConstraints];

    NSLayoutConstraint *userProtocolLabelConstraint = [NSLayoutConstraint constraintWithItem:userProtocolButton
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.f
                                                                                    constant:0];
    [self.view addConstraint:userProtocolLabelConstraint];
    NSDictionary *inputViews =
        NSDictionaryOfVariableBindings(_countryTextField, _phoneTextField, passwordTextField, loginButton, settingButton);

    NSArray *inputViewConstraints = [[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_phoneTextField]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:inputViews]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_countryTextField]|"
                                                                                                              options:0
                                                                                                              metrics:nil
                                                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[passwordTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:
            [NSLayoutConstraint
                constraintsWithVisualFormat:
                    @"V:|-[_countryTextField(60)]-[_phoneTextField(60)]-[passwordTextField(60)]-[loginButton(50)]-40-[settingButton(50)]"
                                    options:0
                                    metrics:nil
                                      views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[loginButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[settingButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]];

    [_inputBackground addConstraints:inputViewConstraints];

    //    CGPoint footerLabelCenter = footerLabel.center;
    //    settingButton.center = CGPointMake(footerLabelCenter.x, footerLabelCenter.y-12);

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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self.view setNeedsLayout];
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - RCDCountryListControllerDelegate
- (void)fetchCountryPhoneCode:(RCDCountry *)country{
    self.currentRegion = country;
    self.countryTextField.textField.text = country.countryName;
    self.phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@",self.currentRegion.phoneCode];
}

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
        [DEFAULTS removeObjectForKey:@"userName"];
        self.passwordTextField.text = nil;
    case PassWordFieldTag:
        [DEFAULTS removeObjectForKey:@"userPwd"];
        break;
    default:
        break;
    }
    return YES;
}

//键盘升起时动画
- (void)keyboardWillShow:(NSNotification *)notif {

    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [_rongLogo.layer addAnimation:animation forKey:nil];

    _rongLogo.hidden = YES;

    [UIView animateWithDuration:0.25
                     animations:^{

                         self.view.frame =
                             CGRectMake(0.f, -50, self.view.frame.size.width, self.view.frame.size.height);
                         _headBackground.frame = CGRectMake(0, 70, self.view.bounds.size.width, 50);
                         _statusBarView.frame = CGRectMake(0.f, 50, self.view.frame.size.width, 20);
                     }
                     completion:nil];
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification *)notif {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [_rongLogo.layer addAnimation:animation forKey:nil];

    _rongLogo.hidden = NO;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame =
                             CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
                         CGRectMake(0, -100, self.view.bounds.size.width, 50);
                         _headBackground.frame = CGRectMake(0, -100, self.view.bounds.size.width, 50);
                         _statusBarView.frame = CGRectMake(0.f, 0, self.view.frame.size.width, 20);
                     }
                     completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *userName = self.phoneTextField.textField.text;
    NSRange foundObj = [userName rangeOfString:@"@" options:NSCaseInsensitiveSearch];
    if (foundObj.length > 0) {
        self.phoneTextField.textField.text = @"";
        UITextField *Password = (UITextField *)[self.view viewWithTag:PassWordFieldTag];
        Password.text = @"";
    }
    if (userName.length > 0) {
        [self.phoneTextField.textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
    }
    [super viewWillAppear:animated];
    [self.animatedImagesView startAnimating];
    if (self.rcDebug) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self invalidateRetryTime];
    [self.animatedImagesView stopAnimating];
}

/*阅读用户协议*/
- (void)userProtocolEvent {
}

- (void)settingEvent {
    RCDSettingServerUrlViewController *temp = [[RCDSettingServerUrlViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
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

/*获取用户账号*/
- (NSString *)getDefaultUserName {
    NSString *defaultUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    return defaultUser;
}

/*获取用户密码*/
- (NSString *)getDefaultUserPwd {
    NSString *defaultUserPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPwd"];
    return defaultUserPwd;
}

- (IBAction)actionLogin:(id)sender {
    NSString *userName = self.phoneTextField.textField.text;
    NSString *userPwd = [(UITextField *)[self.view viewWithTag:PassWordFieldTag] text];

    if (self.retryTime) {
        [self invalidateRetryTime];
    }

    self.retryTime = [NSTimer scheduledTimerWithTimeInterval:60
                                                      target:self
                                                    selector:@selector(retryConnectionFailed)
                                                    userInfo:nil
                                                     repeats:NO];

    [self login:userName password:userPwd];
}

- (void)retryConnectionFailed {
    [[RCIM sharedRCIM] disconnect];
    [self invalidateRetryTime];
    [hud hide:YES];
}

- (void)invalidateRetryTime {
    [self.retryTime invalidate];
    self.retryTime = nil;
}

- (void)loginSuccess:(NSString *)userName
              userId:(NSString *)userId
               token:(NSString *)token
            password:(NSString *)password {
    [self invalidateRetryTime];
    //保存默认用户
    [DEFAULTS setObject:userName forKey:@"userName"];
    [DEFAULTS setObject:password forKey:@"userPwd"];
    [DEFAULTS setObject:token forKey:@"userToken"];
    [DEFAULTS setObject:userId forKey:@"userId"];
    [DEFAULTS synchronize];
    //保存“发现”的信息
    [RCDHTTPTOOL getSquareInfoCompletion:^(NSMutableArray *result) {
        [DEFAULTS setObject:result forKey:@"SquareInfoList"];
        [DEFAULTS synchronize];
    }];
    
    [AFHttpTool getUserInfo:userId
                    success:^(id response) {
                        if ([response[@"code"] intValue] == 200) {
                            NSDictionary *result = response[@"result"];
                            NSString *nickname = result[@"nickname"];
                            NSString *portraitUri = result[@"portraitUri"];
                            RCUserInfo *user =
                                [[RCUserInfo alloc] initWithUserId:userId name:nickname portrait:portraitUri];
                            if (!user.portraitUri || user.portraitUri.length <= 0) {
                                user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                            }
                            [[RCDataBaseManager shareInstance] insertUserToDB:user];
                            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
                            [RCIM sharedRCIM].currentUserInfo = user;
                            [RCDBuglyManager setUserIdentifier:[NSString stringWithFormat:@"%@ - %@", user.userId,user.name]];
                            [DEFAULTS setObject:user.portraitUri forKey:@"userPortraitUri"];
                            [DEFAULTS setObject:user.name forKey:@"userNickName"];
                            [DEFAULTS synchronize];
                        }
                    }
                    failure:^(NSError *err){

                    }];
    //同步群组
    [RCDDataSource syncGroups];
    [RCDDataSource syncFriendList:userId
                         complete:^(NSMutableArray *friends){
                         }];
    dispatch_async(dispatch_get_main_queue(), ^{
        RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
        RCDNavigationViewController *rootNavi =
            [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
        [UIApplication sharedApplication].delegate.window.rootViewController = rootNavi;
    });
}
/**
 *  登录融云服务器
 *
 *  @param userName 用户名
 *  @param token    token
 *  @param password 密码
 */
- (void)loginRongCloud:(NSString *)userName
                userId:(NSString *)userId
                 token:(NSString *)token
              password:(NSString *)password {
    self.loginUserName = userName;
    self.loginUserId = userId;
    self.loginToken = token;
    self.loginPassword = password;

    //登录融云服务器
    [[RCIM sharedRCIM] connectWithToken:token
        success:^(NSString *userId) {
            NSLog([NSString stringWithFormat:@"token is %@  userId is %@", token, userId], nil);
            self.loginUserId = userId;
            [self loginSuccess:self.loginUserName
                        userId:self.loginUserId
                         token:self.loginToken
                      password:self.loginPassword];
        }
        error:^(RCConnectErrorCode status) {
            //关闭HUD

            //        [hud hide:YES];
            //        NSLog(@"RCConnectErrorCode is %ld", (long)status);
            //        _errorMsgLb.text = [NSString stringWithFormat:@"登陆失败！Status: %zd", status];
            //        [_pwdTextField shake];
            dispatch_async(dispatch_get_main_queue(), ^{
                //关闭HUD
                [hud hide:YES];
                NSLog(@"RCConnectErrorCode is %ld", (long)status);
                _errorMsgLb.text = [NSString stringWithFormat:@"%@ Status: %zd",RCDLocalizedString(@"Login_fail"), status];
                [_pwdTextField shake];

                // SDK会自动重连登录，这时候需要监听连接状态
                [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
            });
            //        //SDK会自动重连登陆，这时候需要监听连接状态
            //        [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
        }
        tokenIncorrect:^{
            NSLog(@"IncorrectToken");

            if (_loginFailureTimes < 1) {
                _loginFailureTimes++;
                [AFHttpTool getTokenSuccess:^(id response) {
                    NSString *token = response[@"result"][@"token"];
                    NSString *userId = response[@"result"][@"userId"];
                    [self loginRongCloud:userName userId:userId token:token password:password];
                }
                    failure:^(NSError *err) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [hud hide:YES];
                            NSLog(@"Token无效");
                            _errorMsgLb.text = RCDLocalizedString(@"can_not_connect_server");
                        });
                    }];
            }
        }];
}

/**
 *  登录
 */
- (void)login:(NSString *)userName password:(NSString *)password {

    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];

    if (RC_NotReachable == status) {
        _errorMsgLb.text = RCDLocalizedString(@"network_can_not_use_please_check");
        return;
    } else {
        _errorMsgLb.text = @"";
    }

    if ([self validateUserName:userName userPwd:password]) {

        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
        hud.labelText = RCDLocalizedString(@"logining");
        [hud show:YES];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserCookies"];
        //        [[RCIM sharedRCIM] initWithAppKey:@"p5tvi9dst25b4"];
        [AFHttpTool loginWithPhone:userName
            password:password
            region:self.currentRegion.phoneCode
            success:^(id response) {
                if ([response[@"code"] intValue] == 200) {
                    NSString *token = response[@"result"][@"token"];
                    NSString *userId = response[@"result"][@"id"];
                    [self loginRongCloud:userName userId:userId token:token password:password];
                } else {
                    //关闭HUD
                    [hud hide:YES];
                    int _errCode = [response[@"code"] intValue];
                    NSLog(@"NSError is %d", _errCode);
                    if (_errCode == 1000) {
                        _errorMsgLb.text = RCDLocalizedString(@"mobile_number_or_password_error");
                    }
                    [_pwdTextField shake];
                }
            }
            failure:^(NSError *err) {
                [hud hide:YES];
                _errorMsgLb.text = RCDLocalizedString(@"Login_fail_please_check_network");
            }];
    } else {
        _errorMsgLb.text = RCDLocalizedString(@"please_check_mobile_number_and_password");
    }
}

//验证用户信息格式
- (BOOL)validateUserName:(NSString *)userName userPwd:(NSString *)userPwd {
    NSString *alertMessage = nil;
    if (userName.length == 0) {
        alertMessage = RCDLocalizedString(@"username_can_not_nil");
        return NO;
    } else if (userPwd.length == 0) {
        alertMessage = RCDLocalizedString(@"password_can_not_nil");
        return NO;
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

- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
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
                [AFHttpTool getTokenSuccess:^(id response) {
                    self.loginToken = response[@"result"][@"token"];
                    self.loginUserId = response[@"result"][@"userId"];
                    [self loginRongCloud:self.loginUserName
                                  userId:self.loginUserId
                                   token:self.loginToken
                                password:self.loginPassword];
                }
                    failure:^(NSError *err) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [hud hide:YES];
                            NSLog(@"Token无效");
                            self.errorMsgLb.text = RCDLocalizedString(@"can_not_connect_server");
                        });
                    }];
            }
        } else {
            NSLog(@"RCConnectErrorCode is %zd", status);
        }
    });
}

- (NSUInteger)animatedImagesNumberOfImages:(RCAnimatedImagesView *)animatedImagesView {
    return 2;
}

- (UIImage *)animatedImagesView:(RCAnimatedImagesView *)animatedImagesView imageAtIndex:(NSUInteger)index {
    return [UIImage imageNamed:@"login_background.png"];
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
    RCDLoginViewController *temp = [[RCDLoginViewController alloc] init];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;        //可更改为其他方式
    transition.subtype = kCATransitionFromLeft; //可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:temp animated:NO];
}

#pragma mark - UI

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload {
    [self setAnimatedImagesView:nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
        _phoneTextField.tag = UserTextFieldTag;
        _phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@",self.currentRegion.phoneCode];
        _phoneTextField.userInteractionEnabled = YES;
        _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneTextField.textField.adjustsFontSizeToFitWidth = YES;
        _phoneTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
        if (_phoneTextField.textField.text.length > 0) {
            [_phoneTextField.textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
        }
    }
    return _phoneTextField;
}
@end
