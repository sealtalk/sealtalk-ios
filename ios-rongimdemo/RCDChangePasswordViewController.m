//
//  RCDChangePasswordViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/2/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDChangePasswordViewController.h"
#import "AFHttpTool.h"
#import "RCDCommonDefine.h"
#import "RCDUIBarButtonItem.h"
#import "UIColor+RCColor.h"

@interface RCDChangePasswordViewController ()
@property(nonatomic, strong) UILabel *oldPwdLabel;
@property(nonatomic, strong) UILabel *newsPwdLabel;
@property(nonatomic, strong) UILabel *confirmPwdLabel;

@property(nonatomic, strong) UITextField *oldPwdTextField;
@property(nonatomic, strong) UITextField *newsPwdTextField;
@property(nonatomic, strong) UITextField *confirmPwdTextField;

@property(nonatomic, strong) UIView *oldPwdView;
@property(nonatomic, strong) UIView *newsPwdView;
@property(nonatomic, strong) UIView *confirmPwdView;

@property(nonatomic, strong) RCDUIBarButtonItem *leftBtn;
@property(nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@property(nonatomic, strong) NSDictionary *subViews;

@end

@implementation RCDChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = RCDLocalizedString(@"change_password")
;

    [self initialize];
    [self setNavigationButton];

    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldEditChanged:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialize {
    self.oldPwdLabel = [self setLabel:RCDLocalizedString(@"old_password")];
    self.oldPwdView = [self setSubView];
    self.oldPwdTextField = [self setTextField:nil];
    [self.view addSubview:self.oldPwdLabel];
    [self.view addSubview:self.oldPwdView];
    [self.oldPwdView addSubview:self.oldPwdTextField];

    self.newsPwdLabel = [self setLabel:RCDLocalizedString(@"new_password")
];
    self.newsPwdView = [self setSubView];
    self.newsPwdTextField = [self setTextField:RCDLocalizedString(@"password_hint")];
    [self.view addSubview:self.newsPwdLabel];
    [self.view addSubview:self.newsPwdView];
    [self.newsPwdView addSubview:self.newsPwdTextField];

    self.confirmPwdLabel = [self setLabel:RCDLocalizedString(@"confirm_new_password")
];
    self.confirmPwdView = [self setSubView];
    self.confirmPwdTextField = [self setTextField:RCDLocalizedString(@"password_hint")];
    [self.view addSubview:self.confirmPwdLabel];
    [self.view addSubview:self.confirmPwdView];
    [self.confirmPwdView addSubview:self.confirmPwdTextField];

    [self setAutoLayout];
}

- (void)setNavigationButton {
    self.leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"settings") target:self action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = self.leftBtn;

    self.rightBtn = [[RCDUIBarButtonItem alloc] initWithbuttonTitle:RCDLocalizedString(@"save")

                                                         titleColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                                                        buttonFrame:CGRectMake(0, 0, 50, 30)
                                                             target:self
                                                             action:@selector(saveNewPassword:)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (UILabel *)setLabel:(NSString *)labelName {
    UILabel *label = [[UILabel alloc] init];
    label.text = labelName;
    label.font = [UIFont systemFontOfSize:14.f];
    label.textColor = [UIColor colorWithHexString:@"999999" alpha:1.f];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (UIView *)setSubView {
    UIView *subView = [[UIView alloc] init];
    subView.backgroundColor = [UIColor whiteColor];
    subView.layer.borderWidth = 0.5;
    subView.layer.borderColor = [[UIColor colorWithHexString:@"dfdfdd" alpha:1.f] CGColor];
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    return subView;
}

- (UITextField *)setTextField:(NSString *)placeholder {
    UITextField *subTextField = [[UITextField alloc] init];
    subTextField.borderStyle = UITextBorderStyleNone;
    subTextField.clearButtonMode = UITextFieldViewModeAlways;
    subTextField.secureTextEntry = YES;
    subTextField.font = [UIFont systemFontOfSize:14.f];
    subTextField.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];
    if (placeholder != nil) {
        subTextField.placeholder = placeholder;
    }
    subTextField.delegate = self;
    subTextField.translatesAutoresizingMaskIntoConstraints = NO;
    return subTextField;
}

- (void)setAutoLayout {
    self.subViews =
        NSDictionaryOfVariableBindings(_oldPwdLabel, _oldPwdView, _oldPwdTextField, _newsPwdLabel, _newsPwdView,
                                       _newsPwdTextField, _confirmPwdLabel, _confirmPwdView, _confirmPwdTextField);

    [self.view
        addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:|-9-[_oldPwdLabel]-8-[_oldPwdView(44)]-9-[_newsPwdLabel]-8-["
                                                       @"_newsPwdView(44)]-9-[_confirmPwdLabel]-8-[_confirmPwdView(44)]"
                                               options:0
                                               metrics:nil
                                                 views:self.subViews]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_oldPwdLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_oldPwdView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_newsPwdLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_newsPwdView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_confirmPwdLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_confirmPwdView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];

    [self.oldPwdView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9-[_oldPwdTextField]-3-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:self.subViews]];

    [self.oldPwdView addConstraint:[NSLayoutConstraint constraintWithItem:_oldPwdTextField
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.oldPwdView
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1
                                                                 constant:0]];

    [self.newsPwdView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9-[_newsPwdTextField]-3-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.subViews]];

    [self.newsPwdView addConstraint:[NSLayoutConstraint constraintWithItem:_newsPwdTextField
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.newsPwdView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];

    [self.confirmPwdView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9-[_confirmPwdTextField]-3-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:self.subViews]];

    [self.confirmPwdView addConstraint:[NSLayoutConstraint constraintWithItem:_confirmPwdTextField
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.confirmPwdView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1
                                                                     constant:0]];
}

- (void)saveNewPassword:(id)sender {
    __weak __typeof(self) weakSelf = self;
    NSString *userPwd = [DEFAULTS objectForKey:@"userPwd"];
    if ([userPwd isEqualToString:self.oldPwdTextField.text]) {
        NSInteger newPwdLength = self.newsPwdTextField.text.length;
        if (newPwdLength < 6 || newPwdLength > 20) {
            [self AlertShow:RCDLocalizedString(@"password_alert")
];
        } else {
            if ([self.newsPwdTextField.text isEqualToString:self.confirmPwdTextField.text]) {
                [AFHttpTool changePassword:self.oldPwdTextField.text
                                    newPwd:self.newsPwdTextField.text
                                   success:^(id response) {
                                       if ([response[@"code"] intValue] == 200) {
                                           [DEFAULTS setObject:self.newsPwdTextField.text forKey:@"userPwd"];
                                           [DEFAULTS synchronize];
                                           [weakSelf.navigationController popViewControllerAnimated:YES];
                                       }
                                   }
                                   failure:^(NSError *err){

                                   }];

            } else {
                [self AlertShow:RCDLocalizedString(@"old_and_new_friend_different")
];
            }
        }

    } else {
        [self AlertShow:RCDLocalizedString(@"old_password_error")
];
    }
}

- (void)AlertShow:(NSString *)content {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:content
                                                   delegate:self
                                          cancelButtonTitle:RCDLocalizedString(@"confirm")

                                          otherButtonTitles:nil];
    [alert show];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldEditChanged:(NSNotification *)obj {
    if (self.oldPwdTextField.text.length > 0 || self.newsPwdTextField.text.length > 0 ||
        self.confirmPwdTextField.text.length > 0) {
        [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor whiteColor] barButtonItem:self.rightBtn];

    } else {
        [self.rightBtn buttonIsCanClick:NO
                            buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                          barButtonItem:self.rightBtn];
    }
}
@end
