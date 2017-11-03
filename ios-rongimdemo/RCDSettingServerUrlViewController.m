//
//  RCDSetttingServerUrlViewController.m
//  RCloudMessage
//
//  Created by Sin on 16/9/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSettingServerUrlViewController.h"
#import "AFHttpTool.h"
#import "MBProgressHUD.h"
#import "RCAnimatedImagesView.h"
#import "RCDCommonDefine.h"
#import "RCDFindPswViewController.h"
#import "RCDLoginViewController.h"
#import "RCDSettingUserDefaults.h"
#import "RCDTextFieldValidate.h"
#import "RCUnderlineTextField.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>

#import "RCDLoginViewController.h"

@interface RCDSettingServerUrlViewController () <UITextFieldDelegate>
@property(nonatomic, strong) UIView *headBackground;
@property(nonatomic, strong) UIImageView *rongLogo;
@property(nonatomic, strong) UIView *inputBackground;
@property(retain, nonatomic) IBOutlet RCAnimatedImagesView *animatedImagesView;
@property(nonatomic, strong) UIView *statusBarView;
@property(nonatomic, strong) UILabel *licenseLb;
@property(nonatomic, strong) UILabel *errorMsgLb;
//@property(strong, nonatomic) IBOutlet UILabel *countDownLable;
@end

@implementation RCDSettingServerUrlViewController {
    //    NSTimer *_CountDownTimer;
    int _Seconds;
    NSString *_PhoneNumber;
    MBProgressHUD *hud;
}
#define demoServerTextFieldTag 1000
#define fileServerTextFieldTag 1001
#define appKeyTextFieldTag 1002
//#define NickNameFieldTag 1003
#define naviServerTextFieldTag 1004
@synthesize animatedImagesView = _animatedImagesView;
@synthesize inputBackground = _inputBackground;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.animatedImagesView = [[RCAnimatedImagesView alloc]
        initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.animatedImagesView];
    self.animatedImagesView.delegate = self;

    _headBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -100, self.view.bounds.size.width, 50)];
    _headBackground.userInteractionEnabled = YES;
    _headBackground.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:_headBackground];

    UIButton *registerHeadButton =
        [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 0, 70, 50)];
    [registerHeadButton setTitle:@"登录" forState:UIControlStateNormal];
    [registerHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                             forState:UIControlStateNormal];
    [registerHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerHeadButton addTarget:self action:@selector(loginPageEvent) forControlEvents:UIControlEventTouchUpInside];

    [_headBackground addSubview:registerHeadButton];
    UIImage *rongLogoSmallImage = [UIImage imageNamed:@"title_logo_small"];

    UIImageView *rongLogoSmallImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 60, 5, 100, 40)];
    [rongLogoSmallImageView setImage:rongLogoSmallImage];

    [rongLogoSmallImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    rongLogoSmallImageView.contentMode = UIViewContentModeScaleAspectFit;
    rongLogoSmallImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    rongLogoSmallImageView.clipsToBounds = YES;
    [_headBackground addSubview:rongLogoSmallImageView];
    UIButton *forgetPswHeadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];

    [forgetPswHeadButton setTitle:@"找回密码" forState:UIControlStateNormal];
    [forgetPswHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                              forState:UIControlStateNormal];
    [forgetPswHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswHeadButton addTarget:self action:@selector(forgetPswEvent) forControlEvents:UIControlEventTouchUpInside];
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
    RCUnderlineTextField *demoServerTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];

    demoServerTextField.backgroundColor = [UIColor clearColor];
    demoServerTextField.tag = demoServerTextFieldTag;
    //_account.placeholder=[NSString stringWithFormat:@"Email"];
    UIColor *color = [UIColor whiteColor];
    demoServerTextField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:@"请输入demo服务器地址"
                                        attributes:@{NSForegroundColorAttributeName : color}];
    demoServerTextField.textColor = [UIColor whiteColor];
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    demoServerTextField.translatesAutoresizingMaskIntoConstraints = NO;
    demoServerTextField.adjustsFontSizeToFitWidth = YES;
    demoServerTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    demoServerTextField.text = [RCDSettingUserDefaults getRCDemoServer];
    [_inputBackground addSubview:demoServerTextField];
    demoServerTextField.font = [UIFont fontWithName:@"Heiti SC" size:20.0];
    [demoServerTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    UILabel *userNameMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
    //    userNameMsgLb.text = @"demo server";

    userNameMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:10.0];
    userNameMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
    userNameMsgLb.textColor = [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
    [_inputBackground addSubview:userNameMsgLb];
    _PhoneNumber = demoServerTextField.text;
    demoServerTextField.delegate = self;

    RCUnderlineTextField *naviServerTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];

    naviServerTextField.backgroundColor = [UIColor clearColor];
    naviServerTextField.tag = naviServerTextFieldTag;
    naviServerTextField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:@"请输入导航服务器地址"
                                        attributes:@{NSForegroundColorAttributeName : color}];
    naviServerTextField.textColor = [UIColor whiteColor];
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    naviServerTextField.translatesAutoresizingMaskIntoConstraints = NO;
    naviServerTextField.adjustsFontSizeToFitWidth = YES;
    naviServerTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    naviServerTextField.text = [RCDSettingUserDefaults getRCNaviServer];
    [_inputBackground addSubview:naviServerTextField];
    naviServerTextField.font = [UIFont fontWithName:@"Heiti SC" size:20.0];
    [naviServerTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    naviServerTextField.delegate = self;

    RCUnderlineTextField *fileServerTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
    fileServerTextField.tag = fileServerTextFieldTag;
    fileServerTextField.textColor = [UIColor whiteColor];
    fileServerTextField.returnKeyType = UIReturnKeyDone;
    fileServerTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    fileServerTextField.font = [UIFont fontWithName:@"Heiti SC" size:20.0];
    // fileServerTextField.secureTextEntry = YES;
    fileServerTextField.delegate = self;
    fileServerTextField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:@"请输入文件服务器地址"
                                        attributes:@{NSForegroundColorAttributeName : color}];
    fileServerTextField.translatesAutoresizingMaskIntoConstraints = NO;
    fileServerTextField.adjustsFontSizeToFitWidth = YES;
    fileServerTextField.text = [RCDSettingUserDefaults getRCFileServer];
    [_inputBackground addSubview:fileServerTextField];
    UILabel *pswMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
    //    pswMsgLb.text = @"6-16位字符区分大小写";
    pswMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:10.0];
    pswMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
    pswMsgLb.textColor = [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
    [_inputBackground addSubview:pswMsgLb];

    RCUnderlineTextField *appKeyTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
    appKeyTextField.tag = appKeyTextFieldTag;
    appKeyTextField.delegate = self;
    appKeyTextField.textColor = [UIColor whiteColor];
    appKeyTextField.returnKeyType = UIReturnKeyDone;
    // appKeyTextField.secureTextEntry = YES;
    // fileServerTextField.delegate = self;
    appKeyTextField.adjustsFontSizeToFitWidth = YES;
    appKeyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    appKeyTextField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:@"请输入App Key"
                                        attributes:@{NSForegroundColorAttributeName : color}];
    appKeyTextField.translatesAutoresizingMaskIntoConstraints = NO;
    appKeyTextField.text = [RCDSettingUserDefaults getRCAppKey];
    [appKeyTextField addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    [_inputBackground addSubview:appKeyTextField];
    appKeyTextField.font = [UIFont fontWithName:@"Heiti SC" size:20.0];
    // UIEdgeInsets buttonEdgeInsets = UIEdgeInsetsMake(0, 7.f, 0, 7.f);
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"confirm_button"] forState:UIControlStateNormal];
    confirmButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:confirmButton];

    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tipLabel.text = @"注：服务器地址请不要输入'http://'";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    tipLabel.font = [UIFont systemFontOfSize:12];
    [_inputBackground addSubview:tipLabel];

    UIButton *userProtocolButton = [[UIButton alloc] initWithFrame:CGRectZero];
    //  [userProtocolButton setTitle:@"阅读用户协议"
    //  forState:UIControlStateNormal];
    [userProtocolButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                             forState:UIControlStateNormal];
    userProtocolButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [userProtocolButton addTarget:self
                           action:@selector(userProtocolEvent)
                 forControlEvents:UIControlEventTouchUpInside];

    userProtocolButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:userProtocolButton];

    UIView *bottomBackground = [[UIView alloc] initWithFrame:CGRectZero];
    bottomBackground.translatesAutoresizingMaskIntoConstraints = NO;
    UIButton *registerButton =
        [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, -16, 80, 50)];
    [registerButton setTitle:@"登录" forState:UIControlStateNormal];
    [registerButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                         forState:UIControlStateNormal];
    [registerButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerButton addTarget:self action:@selector(loginPageEvent) forControlEvents:UIControlEventTouchUpInside];

    [bottomBackground addSubview:registerButton];

    UIButton *forgetPswButton = [[UIButton alloc] initWithFrame:CGRectMake(-10, -16, 80, 50)];
    [forgetPswButton setTitle:@"找回密码" forState:UIControlStateNormal];
    [forgetPswButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                          forState:UIControlStateNormal];
    forgetPswButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [forgetPswButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswButton addTarget:self action:@selector(forgetPswEvent) forControlEvents:UIControlEventTouchUpInside];
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

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pswMsgLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:fileServerTextField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pswMsgLb
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:fileServerTextField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];

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

    NSDictionary *views = NSDictionaryOfVariableBindings(_errorMsgLb, _licenseLb, _rongLogo, _inputBackground,
                                                         userProtocolButton, bottomBackground);

    NSArray *viewConstraints = [[[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-41-[_inputBackground]-41-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-70-[_rongLogo(100)]-10-[_errorMsgLb(=="
                                                                      @"12)]-1-[_inputBackground(==350)]-"
                                                                      @"80-[userProtocolButton(==20)]"
                                                              options:0
                                                              metrics:nil
                                                                views:views]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rongLogo(100)]"
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
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_errorMsgLb]-10-|"
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
        NSDictionaryOfVariableBindings(userNameMsgLb, pswMsgLb, demoServerTextField, fileServerTextField, confirmButton,
                                       appKeyTextField, naviServerTextField, tipLabel);

    NSArray *inputViewConstraints = [[[[[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[demoServerTextField]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:inputViews]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[naviServerTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[demoServerTextField]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[fileServerTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[appKeyTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|["
                                                                      @"appKeyTextField(50)]-["
                                                                      @"demoServerTextField(60)]-["
                                                                      @"naviServerTextField(60)]-["
                                                                      @"fileServerTextField(60)]-["
                                                                      @"confirmButton(50)]-[tipLabel(21)]"
                                                              options:0
                                                              metrics:nil
                                                                views:inputViews]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[naviServerTextField]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[confirmButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tipLabel]|"
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == demoServerTextFieldTag) {
        if (textField.text.length > 0) {
            //            _getVerificationCodeBt.enabled = YES;
            //            [_getVerificationCodeBt
            //             setBackgroundColor:[[UIColor alloc] initWithRed:23 / 255.f
            //                                                       green:136 / 255.f
            //                                                        blue:213 / 255.f
            //                                                       alpha:1]];
        }
        if (textField.text.length == 0) {
            //            _getVerificationCodeBt.enabled = NO;
            //            [_getVerificationCodeBt
            //             setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f
            //                                                       green:133 / 255.f
            //                                                        blue:133 / 255.f
            //                                                       alpha:1]];
        }
    }

    if (textField.text.length == 0) {
        //        [textField setFont:[UIFont fontWithName:@"Heiti SC" size:18.0]];
    } else {
        if (textField.tag == demoServerTextFieldTag) {
            _PhoneNumber = textField.text;
        }
        [textField setFont:[UIFont fontWithName:@"Heiti SC" size:20.0]];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
/*找回密码*/
- (void)forgetPswEvent {
    RCDFindPswViewController *temp = [[RCDFindPswViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

- (IBAction)btnDoneClicked:(id)sender {
    if (![self checkContent])
        return;

    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];

    if (RC_NotReachable == status) {
        _errorMsgLb.text = @"当前网络不可用，请检查！";
    }
    NSString *appKeyString = [(UITextField *)[self.view viewWithTag:appKeyTextFieldTag] text];
    NSString *demoServerString = [(UITextField *)[self.view viewWithTag:demoServerTextFieldTag] text];
    NSString *naviServerString = [(UITextField *)[self.view viewWithTag:naviServerTextFieldTag] text];
    NSString *fileServerString = [(UITextField *)[self.view viewWithTag:fileServerTextFieldTag] text];

    //将数据保存到本地
    [RCDSettingUserDefaults setRCAppKey:appKeyString];
    [RCDSettingUserDefaults setRCDemoServer:demoServerString];
    [RCDSettingUserDefaults setRCNaviServer:naviServerString];
    [RCDSettingUserDefaults setRCFileServer:fileServerString];
    //确定之后需要
    [[RCIM sharedRCIM] initWithAppKey:appKeyString];
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"file path %@", filePaths[0]);
    //    [self.navigationController popViewControllerAnimated:YES];
    RCDLoginViewController *vc = [[RCDLoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [[RCIM sharedRCIM] disconnect];
    [[RCIMClient sharedRCIMClient] setServerInfo:naviServerString fileServer:fileServerString];
}

/**
 *  检查输入内容
 *
 *  @return 是否合法输入
 */
- (BOOL)checkContent {
    NSString *appKey = [(UITextField *)[self.view viewWithTag:appKeyTextFieldTag] text];
    NSString *demoServer = [(UITextField *)[self.view viewWithTag:demoServerTextFieldTag] text];
    NSString *naviServer = [(UITextField *)[self.view viewWithTag:naviServerTextFieldTag] text];
    NSString *fileServer = [(UITextField *)[self.view viewWithTag:fileServerTextFieldTag] text];

    if (appKey.length == 0) {
        _errorMsgLb.text = @"appKey不能为空";
        return NO;
    }
    if (demoServer.length == 0) {
        _errorMsgLb.text = @"demo server不能为空!";
        return NO;
    }
    if (naviServer.length == 0) {
        _errorMsgLb.text = @"导航server不能为空";
        return NO;
    }
    if (fileServer.length == 0) {
        _errorMsgLb.text = @"文件server不能为空!";
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

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little
 preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
