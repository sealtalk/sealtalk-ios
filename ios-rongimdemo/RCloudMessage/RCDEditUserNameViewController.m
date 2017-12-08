//
//  RCDEditUserNameViewController.m
//  RCloudMessage
//
//  Created by litao on 15/11/4.
//  Copyright © 2015年 RongCloud. All rights reserved.
//

#import "RCDEditUserNameViewController.h"
#import "AFHttpTool.h"
#import "MBProgressHUD.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDUIBarButtonItem.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"
#import <RongIMLib/RongIMLib.h>

@interface RCDEditUserNameViewController ()

@property(nonatomic, strong) NSDictionary *subViews;

@property(nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@property(nonatomic, strong) RCDUIBarButtonItem *leftBtn;

@property(nonatomic, strong) NSString *nickName;

@end

@implementation RCDEditUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RCDRCIMDataSource shareInstance] getUserInfoWithUserId:[RCIMClient sharedRCIMClient].currentUserInfo.userId
                                                  completion:^(RCUserInfo *userInfo) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.userName.text = userInfo.name;
                                                          self.nickName = self.userName.text;
                                                      });
                                                  }];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    [self setNavigationButton];
    [self setSubViews];
    self.navigationItem.title = @"昵称修改";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldEditChanged:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:self.userName];
}

- (void)saveUserName:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"修改中...";
    [hud show:YES];
    __weak __typeof(&*self) weakSelf = self;
    NSString *errorMsg = @"";
    if (self.userName.text.length == 0) {
        errorMsg = @"用户名不能为空!";
    } else if (self.userName.text.length > 32) {
        errorMsg = @"用户名不能大于32位!";
    }
    if ([errorMsg length] > 0) {
        [hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:errorMsg
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        NSString *userId = [DEFAULTS objectForKey:@"userId"];
        [AFHttpTool modifyNickname:userId
            nickname:weakSelf.userName.text
            success:^(id response) {
                if ([response[@"code"] intValue] == 200) {
                    RCUserInfo *userInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
                    userInfo.name = weakSelf.userName.text;
                    [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
                    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                    [DEFAULTS setObject:weakSelf.userName.text forKey:@"userNickName"];
                    [DEFAULTS synchronize];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
            failure:^(NSError *err) {
                [hud hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"修改失败，请检查输入的名称"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationButton {
    self.leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:@"返回" target:self action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = self.leftBtn;

    self.rightBtn = [[RCDUIBarButtonItem alloc] initWithbuttonTitle:@"保存"
                                                         titleColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                                                        buttonFrame:CGRectMake(0, 0, 50, 30)
                                                             target:self
                                                             action:@selector(saveUserName:)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)setSubViews {
    self.BGView = [UIView new];
    self.BGView.backgroundColor = [UIColor whiteColor];
    self.BGView.layer.borderWidth = 0.5;
    self.BGView.layer.borderColor = [HEXCOLOR(0xdfdfdf) CGColor];
    self.BGView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.BGView];

    UITapGestureRecognizer *clickBGView =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginEditNickname)];
    [self.BGView addGestureRecognizer:clickBGView];

    self.userName = [UITextField new];
    self.userName.borderStyle = UITextBorderStyleNone;
    self.userName.clearButtonMode = UITextFieldViewModeAlways;
    self.userName.font = [UIFont systemFontOfSize:16.f];
    self.userName.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];
    self.userName.delegate = self;
    self.userName.translatesAutoresizingMaskIntoConstraints = NO;
    [self.BGView addSubview:self.userName];

    self.subViews = NSDictionaryOfVariableBindings(_BGView, _userName);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_BGView(44)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_BGView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];

    [self.BGView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9-[_userName]-3-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:self.subViews]];

    [self.BGView addConstraint:[NSLayoutConstraint constraintWithItem:_userName
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.BGView
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1
                                                             constant:0]];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)beginEditNickname {
    [self.userName becomeFirstResponder];
}

- (void)textFieldEditChanged:(NSNotification *)obj {
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    if (![toBeString isEqualToString:self.nickName]) {
        [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor whiteColor] barButtonItem:self.rightBtn];
    } else {
        [self.rightBtn buttonIsCanClick:NO
                            buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                          barButtonItem:self.rightBtn];
    }
}

@end
