//
//  NewPayView.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "NewPayView.h"
#import "RPRedpacketTool.h"
#import "RedpacketColorStore.h"
#import "UIView+YZHExtension.h"
#import "PassSettingView.h"
#import "RPPayViewCell.h"
#import "RPRedpacketViews.h"


typedef NS_ENUM(NSInteger, RDPayViewType) {
    /**
     *  支付页面
     */
    RDPayViewTypePay,
    /**
     *  支付方式选择
     */
    RDPayViewTypeSelect
};

@interface NewPayView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)   UIButton *backButton;
@property (nonatomic, strong)   UILabel *moneLabel;
@property (nonatomic, strong)   UIView *titleLine;
@property (nonatomic, strong)   UILabel *titleLabel;
@property (nonatomic, strong)   UILabel *subTitleLabel;
@property (nonatomic, strong)   UITableView *tableView;
@property (nonatomic, strong)   PassSettingView *paypassField;
@property (nonatomic, strong)   UILabel *passPromptLabel;

@property (nonatomic, strong)   UIButton *resendOrForgotButton;

@property (nonatomic, strong) UserAccoutModel *userAccountModel;
@property (nonatomic, assign) RDPayViewType payViewType;

@property (nonatomic, strong)   NSTimer *timer;
@property (nonatomic, assign)   NSInteger count;

- (void)createView;

@end


@implementation NewPayView

- (void)dealloc
{
    RPDebug(@"~~dealloc:%@",  NSStringFromClass([self class]));
    [self destoryTimer];
}

- (instancetype)initWithRecharge
{
    self = [self init];
    if (self) {
        _titleLabel.text = @"支付";
        _subTitleLabel.text = @"充值";
    }
    
    return self;
}

- (instancetype)initWithTransfer
{
    self = [self init];
    if (self) {
        _titleLabel.text = @"支付";
        _subTitleLabel.text = @"转账";
    }
    
    return self;
}

- (instancetype)init
{
    CGFloat margin;
    if (CGRectGetWidth([UIScreen mainScreen].bounds) > 320) {
        margin = 32.0f;
    }else {
        margin = 16.0f;
    }
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - margin * 2;
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    
    if (self) {
        _count = 60;
        _payViewType = RDPayViewTypePay;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius     = 5.0f;
        self.layer.masksToBounds    = YES;
        
        [self createView];
        
        _titleLabel.text = @"支付";
    }
    return self;
}

- (void)createView
{
    //标题
    [self addTitleView];
    
    // 选项
    [self addSubview:self.tableView];
    
    if (_payViewType == RDPayViewTypePay) {
        [self refreshContentView];
    }
}

- (void)setPayType:(RDPayType)payType
{
    if (_payType != payType) {
        _payType = payType;
        [self refreshTypeView];
        
        if (_payType == RDPayTypeWithValidateCode && self.isTimerValid) {
            //  如果是验证码且计时器在运行则直接倒计时
            self.resendOrForgotButton.titleLabel.text = [NSString stringWithFormat:@"%d", (int)_count];
            [self.resendOrForgotButton setTitle:[NSString stringWithFormat:@"%d", (int)_count] forState:UIControlStateNormal];
        }
        
        //  恢复输入框状态
        if (_paypassField) {
            
            if (_payType == RDPayTypeWithValidateCode) {
                _paypassField.isSecurity = NO;
            }else {
                _paypassField.isSecurity = YES;
            }
            
            [_paypassField clearPassword];
            [_paypassField passwordInputError:NO];
        }
    }
}

- (void)configWithModel:(UserAccoutModel *)model
{
    _userAccountModel = model;
    [self refreshTypeView];
}

- (void)refreshTypeView
{
    [self refreshContentView];
    [self.tableView reloadData];
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

- (void)refreshContentView
{
    if (_payViewType == RDPayViewTypePay) {
        self.tableView.tableHeaderView = [self moneyView];
    }
    
    // 底部视图
    UIView *footerView;
    
    if (_payType == RDPayTypeWithNoPass) {
        footerView = [self sumbmitWithNoPass:NO];
        
    }else if (_payType == RDPayTypeExceedNoPass) {
        footerView = [self sumbmitWithNoPass:YES];
        
    } else if (_payType == RDPayTypeWithPass ||
              _payType == RDPayTypeWithDrawMoney) {
        
        footerView = [self passViewWithType:RDPayTypeWithPass];
        
    }else if (_payType == RDPayTypeWithValidateCode) {
        footerView = [self passViewWithType:RDPayTypeWithValidateCode];
        
    }else if (_payType == RDPayTypeAlipay ||
              _payType == RDPayTypeWeChatPay){
        footerView = [self submitView];
        
    }else {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0,  0, CGRectGetWidth(self.frame), 20)];
    }
    
    self.tableView.tableFooterView = footerView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.rp_height = self.tableView.contentSize.height;
    self.rp_height = self.tableView.rp_bottom;
}

- (void)addTitleView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = RDButtonActionTypeClose;
    _backButton = button;
    button.frame = CGRectMake(8, 11, 28, 28);
    [button setImage:rpRedpacketBundleImage(@"payView_close") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonActionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, width, 23)];
    _titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:17.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [RedpacketColorStore rp_textColorBlack];
    [self addSubview:titleLabel];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.rp_bottom + 14, CGRectGetWidth(self.frame), 1)];
    _titleLine = line;
    line.backgroundColor = [RedpacketColorStore rp_lineColorLightGray];
    line.rp_height = 1 / [UIScreen mainScreen].scale;
    [self addSubview:line];
}

#pragma mark - ContentViews

- (UIView *)moneyView
{
    CGFloat bottom = _titleLine.rp_bottom;
    CGFloat width = CGRectGetWidth(self.bounds);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, width, 0)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, width, 13)];
    if (_subTitleLabel) {
        titleLabel.text = _subTitleLabel.text;
    }else {
        titleLabel.text = @"红包";
    }
    _subTitleLabel = titleLabel;
    titleLabel.textColor = [RedpacketColorStore rp_textColorGray];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    
    UILabel *moneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.rp_bottom + 10, width, 24.0f)];
    moneLabel.text = rpString(@"¥ %@", _userAccountModel.payMoney);
    _moneLabel = moneLabel;
    moneLabel.font = [UIFont systemFontOfSize:32.0f];
    moneLabel.textColor = [RedpacketColorStore rp_textColorBlack];
    moneLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:moneLabel];
    
    view.rp_height = moneLabel.rp_bottom + 15.0f;
    
    if (_payType == RDPayTypeWithDrawMoney) {
        titleLabel.text = @"提现";
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.rp_bottom - 1, CGRectGetWidth(self.frame), 1)];
        line.backgroundColor = [RedpacketColorStore rp_lineColorLightGray];
        line.rp_height = 1 / [UIScreen mainScreen].scale;
        [self addSubview:line];
    }
    
    return view;
}

- (UIView *)sumbmitWithNoPass:(BOOL)isExceedNoPassLimit
{
    CGFloat width = CGRectGetWidth(self.bounds);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    CGFloat bottom = 0.0f;
    
    if (!isExceedNoPassLimit) {
        UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, width, 20)];
        prompt.textAlignment = NSTextAlignmentCenter;
        prompt.font = [UIFont systemFontOfSize:13.0f];
        prompt.textColor = [RedpacketColorStore rp_textColorGray];
        prompt.text = @"本次交易免密码";
        [view addSubview:prompt];
        bottom += prompt.rp_bottom;
    }
    
    UIButton *submit = [self submitButton];
    submit.frame = CGRectMake(15, 15 + bottom, width - 30, 44);
    [view addSubview:submit];
    
    view.rp_height = submit.rp_bottom + 15;
    
    return view;
}

- (UIView *)submitView
{
    CGFloat width = CGRectGetWidth(self.bounds);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    
    UIButton *submit = [self submitButton];
    submit.frame = CGRectMake(15, 15, width - 30, 44);
    [view addSubview:submit];
    
    view.rp_height = submit.rp_bottom + 15;
    
    return view;
}

- (UIView *)passViewWithType:(RDPayType)type
{
    NSString *promptTitle = nil;
    NSString *buttonTitle = nil;
    RDButtonActionType tagType;
    if (type == RDPayTypeWithValidateCode) {
        YZHBankPayInfo *bankInfo = (YZHBankPayInfo *)_payInfo;
        promptTitle = rpString(@"请输入您%@手机号收到的验证码", bankInfo.telephone);
        buttonTitle = @"重新获取";
        tagType = RDButtonActionTypeResendCode;
        
    }else if (type == RDPayTypeWithDrawMoney) {
        //提现
        promptTitle = @"请输入支付密码";
        buttonTitle = @"忘记密码";
        tagType = RDButtonActionTypeForgotPass;
        
    }else {
        promptTitle = @"请输入支付密码";
        buttonTitle = @"忘记密码";
        tagType = RDButtonActionTypeForgotPass;
    }
    
    CGFloat width = CGRectGetWidth(self.bounds);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, width - 30, 20)];
    _passPromptLabel = prompt;
    prompt.text = promptTitle;
    prompt.font = [UIFont systemFontOfSize:12.0f];
    prompt.textColor = [RedpacketColorStore rp_textColorGray];
    [view addSubview:prompt];

    self.paypassField.rp_top = prompt.rp_bottom + 5;
    [view addSubview:self.paypassField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = tagType;
    _resendOrForgotButton = button;
    button.frame = CGRectMake(0, self.paypassField.rp_bottom, self.rp_width, 44);
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button setTitleColor:[RedpacketColorStore rp_blueButtonNormalColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonActionClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    view.rp_height = button.rp_bottom;
    
    return view;
}

#pragma mark - 

- (UIButton *)submitButton
{
    UIButton *button = [RPRedpacketViews redpacketRedButtonWithTitle:@"确定" andSelector:@selector(buttonActionClick:) andTarget:self];
    button.tag = RDButtonActionTypePay;
    return button;
}

- (void)buttonActionClick:(UIButton *)button
{
    if (button.tag == RDButtonActionTypeResendCode) {
        if ([_timer isValid]) {
            return;
        }else {
             [self timerRun];
        }
    }
    
    if (_buttonActionBlock) {
        _buttonActionBlock(self, button.tag, nil);
    }
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat bottom = _titleLine.rp_bottom;
        CGFloat width = CGRectGetWidth(self.bounds);
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, bottom, width, 0) style:UITableViewStyleGrouped];
        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorInset = UIEdgeInsetsZero;
    }

    return _tableView;
}

#pragma mark - 
#pragma mark TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_payType == RDPayTypeMoneNotEnoughAndNoCard) {
        //  显示零钱 和 绑卡选项
        return 2;
        
    }else if (_payType == RDPayTypeWithDrawMoney) {
        //  提现
        return 0;
        
    }else {
        //  零钱， 绑卡， 支付宝
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    RPPayViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[RPPayViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        rpWeakSelf;
        [cell setToucheBlock:^(RPPayViewCell *touchCell) {
            
            if (weakSelf.selectionBlock) {
                weakSelf.selectionBlock(touchCell.payInfo);
            }
            
        }];
        
    }
    
    YZHPayInfo *payInfo;
    if (indexPath.row == 0) {
        if (_payType == RDPayTypeWithNoMoneyAndNoCard) {
            payInfo = [self.userAccountModel getPayInfo:YZHPayInfoTypeBindCard];
            
        }else if (_payType == RDPayTypeWithValidateCode){
            if (_payInfo) {
                payInfo = _payInfo;
            }else {
                payInfo = [self.userAccountModel getPayInfo:YZHPayInfoTypeJDPay];
            }
            
        }else if (_payType == RDPayTypeAlipay){
            payInfo = [self.userAccountModel getPayInfo:YZHPayInfoTypeAlipay];
            
        }else if (_payType == RDPayTypeWeChatPay) {
            payInfo = [self.userAccountModel getPayInfo:YZHPayInfoTypeWechat];
            
        }else {
            payInfo = [self.userAccountModel getPayInfo:YZHPayInfoTypeChangeMoney];
        }
        
    }else if (indexPath.row == 1) {
        payInfo = [self.userAccountModel getPayInfo:YZHPayInfoTypeBindCard];
    }
    
    [cell configWithPayInfo:payInfo];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .01f;
}

#pragma mark - 


- (PassSettingView *)paypassField
{
    if (!_paypassField) {
        _paypassField = [[PassSettingView alloc] initWithWith:CGRectGetWidth(self.bounds) andPadding:15];
        
        rpWeakSelf;
        [_paypassField setPassViewBlock:^(NSString *pass) {
            
            if (weakSelf.buttonActionBlock) {
                weakSelf.buttonActionBlock(weakSelf, RDButtonActionTypePassFinished, pass);
            }
            
        }];
        
        [_paypassField setPassViewInputingBlock:^(NSString *pass) {
            if (pass.length == 0) {
                [weakSelf passwordInputError:NO];
            }
        }];
    }
    
    return _paypassField;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(secondRuning) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    
    return _timer;
}


@end

#pragma mark - InputView


@implementation NewPayView (InputView)

- (void)becomeFirstResponder
{
    if (_paypassField) {
        [_paypassField becomeFirstResponder];
    }
}

- (void)resignFirstResponder
{
    if (_paypassField) {
        [_paypassField resignFirstResponder];
    }
}

#pragma mark - Input

- (void)passwordInputError:(BOOL)error
{
    if (error) {
        if (_payType == RDPayTypeWithValidateCode) {
            _passPromptLabel.text = @"验证码输入错误，请重新输入";
        }else {
            _passPromptLabel.text = @"密码输入错误，请重新输入";
        }
        
        _passPromptLabel.textColor = [UIColor redColor];
        
        [self clearPassword];
        
    }else {
        if (_payType == RDPayTypeWithValidateCode) {
            _passPromptLabel.text = @"请输入验证码";
        }else {
            _passPromptLabel.text = @"请输入支付密码";
        }
        
        _passPromptLabel.textColor = [RedpacketColorStore rp_textColorGray];
    }
    
    [self.paypassField passwordInputError:error];
}

- (void)clearPassword
{
    [self.paypassField clearPassword];
}

@end


@implementation NewPayView (ValidateTimer)

- (void)destoryTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (BOOL)isTimerValid
{
    return _timer.isValid;
}

- (void)timerRun
{
    self.resendOrForgotButton.titleLabel.text = [NSString stringWithFormat:@"%ds", (int)_count];
    [self.resendOrForgotButton setTitle:[NSString stringWithFormat:@"%ds", (int)_count] forState:UIControlStateNormal];
    
    [self.timer fire];
}

- (void)timerStop
{
    if (self.payType == RDPayTypeWithValidateCode) {
        [self.resendOrForgotButton setTitle:@"重新发送" forState:UIControlStateNormal];
    }
    
    _count = 60;
    [_timer invalidate];
    _timer = nil;
}

- (void)secondRuning
{
    if (_payType == RDPayTypeWithValidateCode) {
        self.resendOrForgotButton.titleLabel.text = [NSString stringWithFormat:@"%d秒后重试", (int)_count];
        [self.resendOrForgotButton setTitle:[NSString stringWithFormat:@"%d秒后重试", (int)_count] forState:UIControlStateNormal];
    }
    
    if (--_count == 0) {
        [self timerStop];
    }
}

@end


@interface NewPaySelectionView ()

/**
 *  是否是充值
 */
@property (nonatomic, assign) BOOL isRecharge;

@end


@implementation NewPaySelectionView

- (instancetype)initWithRecharge
{
    self = [self init];
    if (self) {
        self.titleLabel.text = @"选择支付方式";
        self.isRecharge = YES;
    }
    
    return self;
}

- (instancetype)initWithTransfer
{
    self = [self init];
    if (self) {
        self.titleLabel.text = @"选择转账方式";
        self.isRecharge = YES;
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.payViewType = RDPayViewTypeSelect;
        self.titleLabel.text = @"选择支付方式";
        UIImage *arrowImage = rpRedpacketBundleImage(@"payview_arrow_left");
        [self.backButton setImage:arrowImage forState:UIControlStateNormal];
        
        self.tableView.rp_top -= 1 / [UIScreen mainScreen].scale;
    }

    return self;
}

- (void)createView
{
    //标题
    [self addTitleView];
    
    // 选项
    [self addSubview:self.tableView];
}

#pragma mark -
#pragma mark TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userAccountModel.payInfos.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    RPPayViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[RPPayViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        rpWeakSelf;
        [cell setToucheBlock:^(RPPayViewCell *touchCell) {
           
            if (weakSelf.selectionBlock) {
                weakSelf.selectionBlock(touchCell.payInfo);
            }
            
        }];
        
    }
    
    YZHPayInfo *info;
    info = [self.userAccountModel.payInfos objectAtIndex:indexPath.row];
    
    [cell configWithPayInfo:info];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat maxHeight = 44 * 4 + 20;
    BOOL isOutMax = self.tableView.contentSize.height > maxHeight;
    CGFloat height  = isOutMax ? maxHeight : self.tableView.contentSize.height;
    self.tableView.rp_height = height;
    self.rp_height = self.tableView.rp_bottom;
}

@end
