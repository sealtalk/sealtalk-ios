//
//  RPYZTelphoneValidateView.m
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPTelphoneValidateView.h"
#import "RedpacketColorStore.h"
#import "UIView+YZHExtension.h"
#import "RPRedpacketTool.h"
#import "RPLayout.h"

@interface RPTelphoneValidateView ()<UITextFieldDelegate>

@property (nonatomic)    UILabel *titleLabel;
@property (nonatomic)    UIButton *closeButton;
@property (nonatomic)    UIButton *reSendButton;
@property (nonatomic)    UILabel *describLabel;

@property (nonatomic)    UITextField *passwordField;
@property (nonatomic)    UIView *line;
@property (nonatomic)    UIView *backView;

@property (nonatomic)    UILabel *pass1;
@property (nonatomic)    UILabel *pass2;
@property (nonatomic)    UILabel *pass3;
@property (nonatomic)    UILabel *pass4;
@property (nonatomic)    UILabel *pass5;
@property (nonatomic)    UILabel *pass6;


@property (nonatomic, strong)   NSArray *labels;

@property (nonatomic, strong)   NSTimer *timer;

@property (nonatomic)  NSLayoutConstraint *lineHeightConstraint;

@end

@implementation RPTelphoneValidateView

- (void)dealloc
{
    count = 60;
    [_timer invalidate];
    _timer = nil;
}

static int count = 60;

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(secondRuning) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    
    return _timer;
}

- (void)setTelphone:(NSString *)telphone
{
    count = 60;
    _telphone = telphone;
    _describLabel.text = [NSString stringWithFormat:@"已发送到尾号%@的手机上", telphone];
}

- (void)secondRuning
{
    self.reSendButton.titleLabel.text = [NSString stringWithFormat:@"%d秒后重试", count];
    [self.reSendButton setTitle:[NSString stringWithFormat:@"%d秒后重试", count] forState:UIControlStateNormal];
    
    if (--count == 0) {
        count = 60;
        [self.reSendButton setTitle:@"重新发送" forState:UIControlStateNormal];
        
        [_timer invalidate];
        _timer = nil;
    }
    
    if (count == 59) {
        [self layoutIfNeeded];
    }
    
}

- (void)timerRun
{
    [self.timer fire];
}

- (void)becomeFristResponder
{
    [self.passwordField becomeFirstResponder];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rp_width = 280;
        self.rp_height = 157;
        self.backgroundColor = [UIColor whiteColor];
        [self timerRun];
        self.layer.cornerRadius     = 6.0f;
        self.layer.masksToBounds    = YES;
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    [self.titleLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(15);
        make.centerX.equalTo(self.rpm_centerX).offset(0);
    }];
    
    [self.closeButton rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(8);
        make.left.equalTo(self.rpm_left).offset(15);
        make.height.offset(35);
        make.width.offset(35);
    }];
    
    [self.line rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(45);
        make.left.equalTo(self.rpm_left).offset(0);
        make.right.equalTo(self.rpm_right).offset(0);
        make.height.offset(1);
    }];
    
    [self.describLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(58.5);
        make.left.equalTo(self.rpm_left).offset(15.0);
    }];
    
    [self.reSendButton rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(53.5);
        make.right.equalTo(self.rpm_right).offset(-15);
    }];
    
    [self.backView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(91.5);
        make.left.equalTo(self.rpm_left).offset(0);
        make.right.equalTo(self.rpm_right).offset(0);
        make.right.height.offset(44);
    }];
    
    [self.pass1 rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerY.equalTo(self.backView.rpm_centerY).offset(0);
        make.left.equalTo(self.backView.rpm_left).offset(8);
        make.height.offset(44);
        make.width.offset(44);
    }];
    
    [self.pass2 rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerY.equalTo(self.backView.rpm_centerY).offset(0);
        make.left.equalTo(self.pass1.rpm_right).offset(0);
        make.height.offset(44);
        make.width.offset(44);
    }];
    
    [self.pass2 rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerY.equalTo(self.backView.rpm_centerY).offset(0);
        make.left.equalTo(self.pass1.rpm_right).offset(0);
        make.height.offset(44);
        make.width.offset(44);
    }];
    
    [self.pass3 rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerY.equalTo(self.backView.rpm_centerY).offset(0);
        make.left.equalTo(self.pass2.rpm_right).offset(0);
        make.height.offset(44);
        make.width.offset(44);
    }];
    
    [self.pass4 rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerY.equalTo(self.backView.rpm_centerY).offset(0);
        make.left.equalTo(self.pass3.rpm_right).offset(0);
        make.height.offset(44);
        make.width.offset(44);
    }];
    
    [self.pass5 rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerY.equalTo(self.backView.rpm_centerY).offset(0);
        make.left.equalTo(self.pass4.rpm_right).offset(0);
        make.height.offset(44);
        make.width.offset(44);
    }];
    
    [self.pass6 rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerY.equalTo(self.backView.rpm_centerY).offset(0);
        make.left.equalTo(self.pass5.rpm_right).offset(0);
        make.height.offset(44);
        make.width.offset(44);
    }];
    
    _labels = @[_pass1, _pass2, _pass3, _pass4, _pass5, _pass6];
    [self formatPassLabel:_labels];
    [self setNeedsLayout];
    
    UIButton *passBtns = [[UIButton alloc]init];
    [self addSubview:passBtns];
    [passBtns rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerY.equalTo(self.backView.rpm_centerY).offset(0);
        make.left.equalTo(self.backView.rpm_left).offset(8);
        make.height.offset(44);
        make.right.equalTo(self.pass6.rpm_right).offset(0);
    }];
    [passBtns addTarget:self action:@selector(clickPassBtns) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickPassBtns
{
    [self.passwordField becomeFirstResponder];
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [self rp_addsubview:[UIButton class]];
        [_closeButton setImage:rpRedpacketBundleImage(@"payView_close") forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [self rp_addsubview:[UILabel class]];
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.textColor = [RedpacketColorStore rp_textColorBlack];
        _titleLabel.text = @"请输入短信验证码";
    }
    return _titleLabel;
}

- (UIButton *)reSendButton
{
    if (!_reSendButton) {
        _reSendButton = [self rp_addsubview:[UIButton class]];
        [_reSendButton addTarget:self action:@selector(clickReSendButton) forControlEvents:UIControlEventTouchUpInside];
        _reSendButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_reSendButton setTitleColor:[RedpacketColorStore rp_textColorBlue] forState:UIControlStateNormal];
    }
    return _reSendButton;
}

- (UILabel *)describLabel
{
    if (!_describLabel) {
        _describLabel = [self rp_addsubview:[UILabel class]];
        _describLabel.font = [UIFont systemFontOfSize:13.0f];
        _describLabel.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _describLabel;
}

- (UITextField *)passwordField
{
    if (!_passwordField) {
        _passwordField = [self rp_addsubview:[UITextField class]];
        _passwordField.delegate = self;
        _passwordField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _passwordField;
}

- (UIView *)line
{
    if (!_line) {
        _line = [self rp_addsubview:[UIView class]];
        _line.backgroundColor = [RedpacketColorStore rp_textColorGray];
    }
    return _line;
}

- (UIView *)backView
{
    if (!_backView) {
        _backView = [self rp_addsubview:[UIView class]];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}

- (UILabel *)pass1
{
    if (!_pass1) {
        _pass1 = [self rp_addsubview:[UILabel class]];
        _pass1.font = [UIFont systemFontOfSize:24.0f];
        _pass1.textAlignment = NSTextAlignmentCenter;
        _pass1.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _pass1;
}

- (UILabel *)pass2
{
    if (!_pass2) {
        _pass2 = [self rp_addsubview:[UILabel class]];
        _pass2.font = [UIFont systemFontOfSize:24.0f];
        _pass2.textAlignment = NSTextAlignmentCenter;
        _pass2.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _pass2;
}

- (UILabel *)pass3
{
    if (!_pass3) {
        _pass3 = [self rp_addsubview:[UILabel class]];
        _pass3.font = [UIFont systemFontOfSize:24.0f];
        _pass3.textAlignment = NSTextAlignmentCenter;
        _pass3.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _pass3;
}

- (UILabel *)pass4
{
    if (!_pass4) {
        _pass4 = [self rp_addsubview:[UILabel class]];
        _pass4.font = [UIFont systemFontOfSize:24.0f];
        _pass4.textAlignment = NSTextAlignmentCenter;
        _pass4.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _pass4;
}

- (UILabel *)pass5
{
    if (!_pass5) {
        _pass5 = [self rp_addsubview:[UILabel class]];
        _pass5.font = [UIFont systemFontOfSize:24.0f];
        _pass5.textAlignment = NSTextAlignmentCenter;
        _pass5.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _pass5;
}

- (UILabel *)pass6
{
    if (!_pass6) {
        _pass6 = [self rp_addsubview:[UILabel class]];
        _pass6.font = [UIFont systemFontOfSize:24.0f];
        _pass6.textAlignment = NSTextAlignmentCenter;
        _pass6.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    return _pass6;
}

- (NSLayoutConstraint *)lineHeightConstraint
{
    if (!_lineHeightConstraint) {
    }
    return _lineHeightConstraint;
}

- (void)clearInputField
{
    _passwordField.text = @"";
    for (UILabel *label in _labels) {
        label.text = @"";
    }
}

- (void)messageInputError:(BOOL)error
{
    for (UILabel *label in _labels) {
        label.layer.borderColor = error ? [RedpacketColorStore rp_textColorRed].CGColor : [RedpacketColorStore rp_textColorLightGray].CGColor;
    }
}

- (void)formatPassLabel:(NSArray *)labels
{
    for (UILabel *label in labels) {
        label.backgroundColor   = [UIColor clearColor];
        label.layer.borderColor = [RedpacketColorStore rp_lineColorLightGray].CGColor;
        label.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        label.text              = @"";
    }
}

- (void)clickCloseBtn
{
    if (_closeButtonBlock) {
        _closeButtonBlock(self);
    }
}

- (void)clickReSendButton
{
    if (_timer) {
        return;
    }
    
    [self timerRun];
    
    if (_reSendButtonBlock) {
        _reSendButtonBlock(self);
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    for (NSLayoutConstraint *constant in _backView.constraints) {
        if (constant.constant == -1) {
            constant.constant = - 1 / [UIScreen mainScreen].scale;
        }
    }
    
    _lineHeightConstraint.constant = 1 / [UIScreen mainScreen].scale;
}

#pragma mark - PassFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *replaceString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (replaceString.length > 6) {
        return NO;
        
    }else{
        //  验证密码
        if (_passFinishBlock && replaceString.length == 6) {
            _passFinishBlock(replaceString);
        }
        
        if ([string isEqualToString:@""]) {
            UILabel *label = [_labels objectAtIndex:replaceString.length];
            label.text = @"";
            
        }else {
            UILabel *label = [_labels objectAtIndex:textField.text.length];
            label.text = string;
        }
    }
    
    return YES;
}

- (void)tapGestureSender
{
    [self becomeFristResponder];
}



@end
