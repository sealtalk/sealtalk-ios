//
//  TransferViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/8/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "TransferViewController.h"
#import "RedpacketColorStore.h"
#import "RedpacketWebController.h"
#import "RPRedpacketSetting.h"
#import "RedpacketViewControl.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketViews.h"
#import "RPSendRedPacketAutoKeyboardHandle.h"
#import "RedpacketErrorView.h"
#import "RPSendRedPacketItem.h"
#import "RPRedpacketSendControl.h"
#import "YZHRedpacketBridge+Private.h"


@interface TransferViewController ()<UITextFieldDelegate>
{
    NSString *_prompt;
}

@property (nonatomic, assign) CGFloat transMaxMoney;
@property (nonatomic, assign) CGFloat transMinMoney;
@property (nonatomic,strong)RPSendRedPacketAutoKeyboardHandle * keyboardAuto;
@property (nonatomic) UIImageView *headImageView;

@property (nonatomic) UILabel *nameLable;

@property (nonatomic) UIImageView *backImageView;

@property (nonatomic) UILabel *instructionLable;

@property (nonatomic) UILabel *moneySymbolLable;

@property (nonatomic) UITextField *moneyTextField;

@property (nonatomic) UIButton *instructionButton;

@property (nonatomic,weak)RedpacketErrorView * errorView;

@property (nonatomic,strong)RPSendRedPacketItem * rawItem;

@property (nonatomic,strong)UILabel * warnPromptLabel;

@end

@implementation TransferViewController

- (void)dealloc
{
    [RPRedpacketSendControl releaseSendControl];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLable.text = @"转账给朋友";
    self.tableView.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self configNetworking];
    
    self.cuttingLineHidden = YES;
    self.rawItem = [RPSendRedPacketItem new];
    self.rawItem.redPacketType = RedpacketTransfer;
    [self.view addSubview:self.warnPromptLabel];
    _transMinMoney = [RPRedpacketSetting shareInstance].transferMinMoney;
    _transMaxMoney = [RPRedpacketSetting shareInstance].transferMaxMoney;
    self.instructionButton.enabled = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.barStyle       = UIBarStyleDefault;
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:@"关闭" rightButtonTitle:@""];
    self.keyboardAuto = [RPSendRedPacketAutoKeyboardHandle new];
    self.keyboardAuto.topMargin = 81;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.moneyTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.keyboardAuto = nil;
}

- (void)clickButtonLeft
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configNetworking{
    rpWeakSelf;
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken:^(NSInteger code, NSString *msg) {
        [weakSelf.view rp_removeHudInManaual];
        if (code == 0) {
            [RPRedpacketSetting asyncRequestRedpacketSettings:^{
                weakSelf.subLable.text = [NSString stringWithFormat:@"%@红包服务",[RPRedpacketSetting shareInstance].redpacketOrgName];
                if (weakSelf) {
                    weakSelf.transMinMoney = [RPRedpacketSetting shareInstance].transferMinMoney;
                    weakSelf.transMaxMoney = [RPRedpacketSetting shareInstance].transferMaxMoney;
                }
            }];
            [weakSelf showErrorView:NO];
        }else {
            [weakSelf.view endEditing:YES];
            [weakSelf showErrorView:YES];
        }
    }];
}

- (void)showErrorView:(BOOL)show{
    rpWeakSelf;
    CGFloat top;
    NSInteger tag;
    if (show && self.errorView.tag == 1) {
        tag = 0;
        top = 0;
    }else if (!show && self.errorView.tag == 0){
        tag = 1;
        top = RP_SCREENHEIGHT;
    }else{
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.errorView.rp_top = top;
    } completion:^(BOOL finished) {
        weakSelf.errorView.tag = tag;
    }];
}

- (RedpacketErrorView *)errorView{
    if (_errorView == nil) {
        rpWeakSelf;
        RedpacketErrorView * errorView = [[RedpacketErrorView alloc]init];
        errorView.tag = 1;
        errorView.frame = CGRectMake(0, RP_SCREENHEIGHT, RP_SCREENWIDTH, RP_SCREENHEIGHT);
        errorView.buttonClickBlock = ^(){
            [weakSelf configNetworking];
        };
        [self.view addSubview:errorView];
        _errorView = errorView;
    }
    return _errorView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TransferViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [cell addSubview:self.headImageView];
    [cell addSubview:self.nameLable];
    [cell addSubview:self.backImageView];
    [cell addSubview:self.instructionLable];
    [cell addSubview:self.moneySymbolLable];
    [cell addSubview:self.moneyTextField];
    [cell addSubview:self.instructionButton];
    cell.backgroundColor = [UIColor  clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 350;
}

- (UIImageView *)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.rp_width - 70)*.5, 36, 70, 70)];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.layer.cornerRadius = CGRectGetWidth(_headImageView.frame) / 2.0f;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.borderWidth = 0.0;
        _headImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return _headImageView;
}

- (UILabel *)nameLable
{
    if (!_nameLable) {
        _nameLable = [[UILabel alloc]initWithFrame:CGRectMake(0, self.headImageView.rp_bottom + 10, self.view.rp_width, 16)];
        _nameLable.font = [UIFont systemFontOfSize:15.0];
        _nameLable.textAlignment = NSTextAlignmentCenter;
        _nameLable.textColor = [RedpacketColorStore rp_textColorGray];
    }
    return _nameLable;
}

- (UIImageView *)backImageView
{
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.nameLable.rp_bottom + 30, self.view.rp_width, 110)];
        _backImageView.backgroundColor = [UIColor whiteColor];
    }
    return _backImageView;
}

- (UILabel *)instructionLable
{
    if (!_instructionLable) {
        _instructionLable = [[UILabel alloc]initWithFrame:CGRectMake(18, 173, 200, 16)];
    }
    _instructionLable.text = @"转账金额";
    _instructionLable.font = [UIFont systemFontOfSize:15.0];
    _instructionLable.textColor = [RedpacketColorStore rp_textColorGray];
    return _instructionLable;
}

- (UILabel *)moneySymbolLable
{
    if (!_moneySymbolLable) {
        _moneySymbolLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 215, 100, 38)];
    }
    _moneySymbolLable.text = @"￥";
    _moneySymbolLable.textColor = [RedpacketColorStore rp_textColorBlack];
    _moneySymbolLable.font = [UIFont systemFontOfSize:37];
    return _moneySymbolLable;
}

- (UITextField *)moneyTextField
{
    if (!_moneyTextField) {
        _moneyTextField = [[UITextField alloc]initWithFrame:CGRectMake(48, 215, self.view.rp_width, 38)];
    }
    _moneyTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _moneyTextField.font = [UIFont systemFontOfSize:37.0];
    _moneyTextField.delegate = self;
    return _moneyTextField;
}

- (void)setUserInfo:(RedpacketUserInfo *)userInfo
{
    _userInfo = userInfo;
    NSURL *receiveheaderUrl = [NSURL URLWithString:userInfo.userAvatar];
    [self.headImageView rp_setImageWithURL:receiveheaderUrl placeholderImage:rpRedpacketBundleImage(@"redpacket_header")];
    self.nameLable.text = userInfo.userNickname;
}

- (UIButton *)instructionButton
{
    if (!_instructionButton) {
        _instructionButton = [RPRedpacketViews redpacketBlueButtonWithTitle:@"转账" andSelector:@selector(clickInstructionButton) andTarget:self];
    }
    _instructionButton.rp_top = 305;
    
    return _instructionButton;
}

- (void)clickInstructionButton
{
    if ([self.moneyTextField.text floatValue] > 0.0099) {
        RedpacketMessageModel *model = self.rawItem.messageModel;
        model.redpacketReceiver = self.userInfo;
        model.redpacket.redpacketMoney = [NSString stringWithFormat:@"%.2f",[self.moneyTextField.text floatValue]];
        model.messageType = RedpacketMessageTypeTransfer;
        model.redpacket.redpacketGreeting = @"[转账]";

        rpWeakSelf;
        [[RPRedpacketTransferControl currentControl] payMoney:model.redpacket.redpacketMoney withMessageModel:model inController:self andSuccessBlock:^(id object) {
           
            if (weakSelf.sendRedPacketBlock) {
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    weakSelf.sendRedPacketBlock(model);
                }];
            }
            
        }];
        
    }else{
        [self.view rp_showHudErrorView:@"金额不能小于0.01元"];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    RPCheckNmuberStringType checkType = [RPUntility checkNumberString:text
                                                         decimalLimit:@(2)
                                                           wholeLimit:@(8)
                                                            minNumber:@(_transMinMoney)
                                                            maxNumber:@(_transMaxMoney)
                                                        decimalLength:nil
                                                          wholeLength:nil];
    
    switch (checkType) {
        case RPNmuberStringInputError:
        case RPNmuberStringDecimalError:
        case RPNmuberStringWholeLimitError:
        case RPNmuberStringDecimalLimitError: {
            return NO;
            break;
        }
        case RPNmuberStringSuccess:
        {
            _prompt = @"";
            self.instructionButton.enabled = YES;
            break;
        }
        case RPNmuberStringMaxNumberError:
        {
            _prompt  = [NSString stringWithFormat:@"单笔最高限额为%.2f元",_transMaxMoney];
            self.instructionButton.enabled = NO;
            break;
        }
        case RPNmuberStringMinNumberError:
        {
            NSArray *array = [text componentsSeparatedByString:@"."];
            if (array.count == 2) {
                NSString *decimalString = array[1];
                if (decimalString.length  == 2) {
                    _prompt  = @"金额输入错误";
                }
            }else if(text.length == 8) {
                _prompt  = @"金额输入错误";
            }
            self.instructionButton.enabled = NO;
            break;
        }
    }
    
    [self showWarmPromtLableWith:_prompt];
    
    return YES;
}

#pragma mark - WarmPromtLable

- (UILabel *)warnPromptLabel
{
    if (!_warnPromptLabel) {
        _warnPromptLabel = [[UILabel alloc]init];
        _warnPromptLabel.backgroundColor = [RedpacketColorStore rp_colorWithHEX:0xe8584d];
        _warnPromptLabel.textColor = [UIColor whiteColor];
        _warnPromptLabel.textAlignment = NSTextAlignmentCenter;
        _warnPromptLabel.font = [UIFont systemFontOfSize:14.0f];
        _warnPromptLabel.frame = CGRectMake(0, -25, [UIScreen mainScreen].bounds.size.width,25);
        _warnPromptLabel.tag = 0;
        [self.view addSubview:_warnPromptLabel];
    }
    return _warnPromptLabel;
}
- (void)showWarmPromtLableWith:(NSString *)content
{
    self.warnPromptLabel.text = content;
    if (content.length && self.warnPromptLabel.tag != 1) {
        self.warnPromptLabel.tag = 1;
        [UIView animateWithDuration:0.5 animations:^{
            self.warnPromptLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,25);
        }];
    }else if (!content.length && self.warnPromptLabel.tag) {
        [UIView animateWithDuration:0.5 animations:^{
            self.warnPromptLabel.frame = CGRectMake(0, -25, [UIScreen mainScreen].bounds.size.width,25);
        } completion:^(BOOL finished) {
            self.warnPromptLabel.tag = 0;
        }];
    }
}

@end
