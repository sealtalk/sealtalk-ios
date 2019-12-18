//
//  RCDChangePasswordViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/2/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDChangePasswordViewController.h"
#import "RCDCommonDefine.h"
#import "RCDUIBarButtonItem.h"
#import "UIColor+RCColor.h"
#import "RCDCommonString.h"
#import "RCDLoginManager.h"

@interface RCDChangePasswordViewController ()
@property (nonatomic, strong) UILabel *oldPwdLabel;
@property (nonatomic, strong) UILabel *newsPwdLabel;
@property (nonatomic, strong) UILabel *confirmPwdLabel;

@property (nonatomic, strong) UITextField *oldPwdTextField;
@property (nonatomic, strong) UITextField *newsPwdTextField;
@property (nonatomic, strong) UITextField *confirmPwdTextField;

@property (nonatomic, strong) UIView *oldPwdView;
@property (nonatomic, strong) UIView *newsPwdView;
@property (nonatomic, strong) UIView *confirmPwdView;

@property (nonatomic, strong) RCDUIBarButtonItem *leftBtn;
@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@property (nonatomic, strong) NSDictionary *subViews;

@end

@implementation RCDChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = RCDLocalizedString(@"change_password");

    [self initialize];
    [self setNavigationButton];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldEditChanged:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:nil];
}

- (void)saveNewPassword:(id)sender {
    __weak __typeof(self) weakSelf = self;
    NSString *userPwd = [DEFAULTS objectForKey:RCDUserPasswordKey];
    if ([userPwd isEqualToString:self.oldPwdTextField.text]) {
        NSInteger newPwdLength = self.newsPwdTextField.text.length;
        if (newPwdLength < 6 || newPwdLength > 20) {
            [self AlertShow:RCDLocalizedString(@"password_alert")];
        } else {
            if ([self.newsPwdTextField.text isEqualToString:self.confirmPwdTextField.text]) {
                [RCDLoginManager
                    changePassword:self.oldPwdTextField.text
                            newPwd:self.newsPwdTextField.text
                          complete:^(BOOL success) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (success) {
                                      [DEFAULTS setObject:self.newsPwdTextField.text forKey:RCDUserPasswordKey];
                                      [DEFAULTS synchronize];
                                      [weakSelf.navigationController popViewControllerAnimated:YES];
                                  }
                              });
                          }];
            } else {
                [self AlertShow:RCDLocalizedString(@"old_and_new_friend_different")];
            }
        }
    } else {
        [self AlertShow:RCDLocalizedString(@"old_password_error")];
    }
}

- (void)initialize {
    self.oldPwdLabel = [self setLabel:RCDLocalizedString(@"old_password")];
    self.oldPwdView = [self setSubView];
    self.oldPwdTextField = [self setTextField:nil];
    [self.view addSubview:self.oldPwdLabel];
    [self.view addSubview:self.oldPwdView];
    [self.oldPwdView addSubview:self.oldPwdTextField];

    self.newsPwdLabel = [self setLabel:RCDLocalizedString(@"new_password")];
    self.newsPwdView = [self setSubView];
    self.newsPwdTextField = [self setTextField:RCDLocalizedString(@"password_hint")];
    [self.view addSubview:self.newsPwdLabel];
    [self.view addSubview:self.newsPwdView];
    [self.newsPwdView addSubview:self.newsPwdTextField];

    self.confirmPwdLabel = [self setLabel:RCDLocalizedString(@"confirm_new_password")];
    self.confirmPwdView = [self setSubView];
    self.confirmPwdTextField = [self setTextField:RCDLocalizedString(@"password_hint")];
    [self.view addSubview:self.confirmPwdLabel];
    [self.view addSubview:self.confirmPwdView];
    [self.confirmPwdView addSubview:self.confirmPwdTextField];

    [self setAutoLayout];
}

- (void)setNavigationButton {
    self.leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"settings")
                                                              target:self
                                                              action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = self.leftBtn;

    self.rightBtn = [[RCDUIBarButtonItem alloc]
        initWithbuttonTitle:RCDLocalizedString(@"save")

                 titleColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                     darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                buttonFrame:CGRectMake(0, 0, 50, 30)
                     target:self
                     action:@selector(saveNewPassword:)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
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
    subView.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                       darkColor:[HEXCOLOR(0x808080) colorWithAlphaComponent:0.2]];
    subView.layer.borderWidth = 0.5;
    subView.layer.borderColor = [RCDDYCOLOR(0xdfdfdd, 0x000000) CGColor];
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    return subView;
}

- (UITextField *)setTextField:(NSString *)placeholder {
    UITextField *subTextField = [[UITextField alloc] init];
    subTextField.borderStyle = UITextBorderStyleNone;
    subTextField.clearButtonMode = UITextFieldViewModeAlways;
    subTextField.secureTextEntry = YES;
    subTextField.font = [UIFont systemFontOfSize:14.f];
    subTextField.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    if (placeholder != nil) {
        subTextField.placeholder = placeholder;
    }
    subTextField.delegate = self;
    subTextField.translatesAutoresizingMaskIntoConstraints = NO;
    if (subTextField.placeholder) {
        NSAttributedString *attrString =
            [[NSAttributedString alloc] initWithString:subTextField.placeholder
                                            attributes:@{
                                                NSForegroundColorAttributeName : RCDDYCOLOR(0x999999, 0x666666),
                                                NSFontAttributeName : subTextField.font
                                            }];
        subTextField.attributedPlaceholder = attrString;
    }
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

    [self.oldPwdView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_oldPwdTextField]-0-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:self.subViews]];

    [self.newsPwdView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9-[_newsPwdTextField]-3-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.subViews]];
    [self.newsPwdView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_newsPwdTextField]-0-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.subViews]];

    [self.confirmPwdView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9-[_confirmPwdTextField]-3-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:self.subViews]];
    [self.confirmPwdView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_confirmPwdTextField]-0-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:self.subViews]];
}

- (void)AlertShow:(NSString *)content {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:content preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldEditChanged:(NSNotification *)obj {
    if (self.oldPwdTextField.text.length > 0 || self.newsPwdTextField.text.length > 0 ||
        self.confirmPwdTextField.text.length > 0) {
        [self.rightBtn buttonIsCanClick:YES buttonColor:RCDDYCOLOR(0xffffff, 0xA8A8A8) barButtonItem:self.rightBtn];

    } else {
        [self.rightBtn
            buttonIsCanClick:NO
                 buttonColor:[RCDUtilities generateDynamicColor:HEXCOLOR(0x9fcdfd)
                                                      darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
               barButtonItem:self.rightBtn];
    }
}
@end
