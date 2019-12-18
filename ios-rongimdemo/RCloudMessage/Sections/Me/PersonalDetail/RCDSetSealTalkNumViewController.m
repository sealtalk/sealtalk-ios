//
//  RCDSetSealTalkNumViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDSetSealTalkNumViewController.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDCommonString.h"
#import "RCDUtilities.h"
#import "UIView+MBProgressHUD.h"
#import "NormalAlertView.h"
#import "RCDUIBarButtonItem.h"
@interface RCDSetSealTalkNumViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *portraitBgView;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *numberBgView;
@property (nonatomic, strong) UILabel *sealTalkNumLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation RCDSetSealTalkNumViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNavi];
    [self setupUI];
    [self setupUserInfo];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    if (string.length == 0 || [RCDUtilities judgeSealTalkAccount:string]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Target Action
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (![RCDUtilities isLowerLetter:textField.text]) {
            self.hintLabel.text = RCDLocalizedString(@"SetSealTalkNumError");
            self.hintLabel.textColor = [UIColor colorWithHexString:@"FF1612 " alpha:1];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        } else {
            self.hintLabel.text = RCDLocalizedString(@"SetSealTalkNumHint");
            self.hintLabel.textColor = [UIColor colorWithHexString:@"666666 " alpha:1];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.hintLabel.text = RCDLocalizedString(@"SetSealTalkNumHint");
        self.hintLabel.textColor = [UIColor colorWithHexString:@"666666 " alpha:1];
    }
}

- (void)save {
    [self.textField resignFirstResponder];
    NSString *sealTalkAccount = self.textField.text;

    if (![self judgeSealTalkAccount:sealTalkAccount]) {
        [self showAlert:RCDLocalizedString(@"STAccountInvalidFormat")];
        return;
    }

    [NormalAlertView
        showAlertWithTitle:RCDLocalizedString(@"MakeSureSetStAccount")
                   message:[NSString stringWithFormat:RCDLocalizedString(@"SetStAccountHint"), sealTalkAccount]
             highlightText:sealTalkAccount
             describeTitle:nil
                 leftTitle:RCDLocalizedString(@"cancel")
                rightTitle:RCDLocalizedString(@"confirm")
                    cancel:nil
                   confirm:^{
                       [self setSTAccount:sealTalkAccount];
                   }];
}

- (void)tapAction {
    [self.textField resignFirstResponder];
}

#pragma mark - Private Method
- (void)setNavi {
    self.title = RCDLocalizedString(@"SetSealTalkNumber");
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"save")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                             target:self
                                                                             action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupUI {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];

    [self.view addSubview:self.portraitBgView];
    [self.view addSubview:self.numberBgView];
    [self.portraitBgView addSubview:self.portraitImageView];
    [self.portraitBgView addSubview:self.nameLabel];
    [self.numberBgView addSubview:self.sealTalkNumLabel];
    [self.numberBgView addSubview:self.textField];
    [self.view addSubview:self.hintLabel];

    [self.portraitBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@79);
    }];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.portraitBgView);
        make.left.equalTo(self.portraitBgView).offset(8);
        make.height.width.equalTo(@59);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitImageView.mas_right).offset(12);
        make.centerY.equalTo(self.portraitImageView);
        make.right.equalTo(self.portraitBgView).offset(-8);
        make.height.equalTo(@23);
    }];

    [self.numberBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.portraitBgView.mas_bottom).offset(13.5);
        make.height.equalTo(@40);
    }];

    [self.sealTalkNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.numberBgView).offset(8);
        make.centerY.equalTo(self.numberBgView);
        make.width.equalTo(@79);
        make.height.equalTo(@21);
    }];

    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sealTalkNumLabel.mas_right).offset(8);
        make.right.equalTo(self.numberBgView).offset(-8);
        make.centerY.equalTo(self.sealTalkNumLabel);
        make.height.equalTo(self.numberBgView);
    }];

    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(9);
        make.top.equalTo(self.numberBgView.mas_bottom).offset(5);
        make.bottom.lessThanOrEqualTo(self.view);
    }];
}

- (void)setupUserInfo {
    NSString *userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    RCUserInfo *userInfo = [RCDUserInfoManager getUserInfo:userId];
    [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:nil];
    self.nameLabel.text = userInfo.name;
}

- (BOOL)judgeSealTalkAccount:(NSString *)account {
    if (account.length >= 6 && account.length <= 20 && [RCDUtilities judgeSealTalkAccount:account]) {
        return YES;
    }
    return NO;
}

- (void)setSTAccount:(NSString *)account {
    [RCDUserInfoManager setSTAccount:account
        complete:^(BOOL success) {
            if (success) {
                rcd_dispatch_main_async_safe(^{
                    [DEFAULTS setObject:account forKey:RCDSealTalkNumberKey];
                    [self.view showHUDMessage:RCDLocalizedString(@"setting_success")];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
        error:^(RCDUserErrorCode errorCode) {
            rcd_dispatch_main_async_safe(^{
                if (errorCode == RCDUserErrorCodeStAccountIsExist) {
                    [self showAlert:RCDLocalizedString(@"STAccountIsExist")];
                } else if (errorCode == RCDUserErrorCodeInvalidFormat) {
                    [self showAlert:RCDLocalizedString(@"STAccountInvalidFormat")];
                }
            });
        }];
}

- (void)showAlert:(NSString *)alertContent {
    [NormalAlertView showAlertWithTitle:RCDLocalizedString(@"SetStAccountFailure")
                                message:alertContent
                          describeTitle:nil
                           confirmTitle:RCDLocalizedString(@"confirm")
                                confirm:^{
                                }];
}

#pragma mark - Getter && Setter
- (UIView *)portraitBgView {
    if (!_portraitBgView) {
        _portraitBgView = [[UIView alloc] init];
        _portraitBgView.backgroundColor =
            [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                     darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    }
    return _portraitBgView;
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.cornerRadius = 4;
        _portraitImageView.layer.masksToBounds = YES;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
        if (IOS_FSystenVersion >= 8.2) {
            _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        } else {
            _nameLabel.font = [UIFont systemFontOfSize:16];
        }
    }
    return _nameLabel;
}

- (UIView *)numberBgView {
    if (!_numberBgView) {
        _numberBgView = [[UIView alloc] init];
        _numberBgView.backgroundColor =
            [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                     darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    }
    return _numberBgView;
}

- (UILabel *)sealTalkNumLabel {
    if (!_sealTalkNumLabel) {
        _sealTalkNumLabel = [[UILabel alloc] init];
        _sealTalkNumLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
        _sealTalkNumLabel.font = [UIFont systemFontOfSize:15];
        _sealTalkNumLabel.text = RCDLocalizedString(@"SealTalkNumber");
    }
    return _sealTalkNumLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = RCDDYCOLOR(0x000000, 0x999999);
        _textField.placeholder = RCDLocalizedString(@"SetSealTalkNumPlaceholder");
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.font = [UIFont systemFontOfSize:12];
        _textField.adjustsFontSizeToFitWidth = YES;
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        NSAttributedString *attrString =
            [[NSAttributedString alloc] initWithString:_textField.placeholder
                                            attributes:@{
                                                NSForegroundColorAttributeName : RCDDYCOLOR(0x999999, 0x666666),
                                                NSFontAttributeName : _textField.font
                                            }];
        _textField.attributedPlaceholder = attrString;
    }
    return _textField;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.numberOfLines = 0;
        _hintLabel.textColor = [UIColor colorWithHexString:@"666666" alpha:1];
        _hintLabel.font = [UIFont systemFontOfSize:12];
        _hintLabel.text = RCDLocalizedString(@"SetSealTalkNumHint");
    }
    return _hintLabel;
}

@end
