//
//  RPValidateNameViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/10/18.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPValidateNameViewController.h"
#import "SecurityCodeViewController.h"
#import "RedpacketDataRequester.h"
#import "UIView+YZHPrompting.h"
#import "ApplyPaymentModel.h"
#import "RedpacketWebController.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketSetting.h"
#import "UIAlertView+YZHAlert.h"
#import "NSDictionary+YZHExtern.h"
#import "RPLayout.h"
#import "RPSendRedPacketAutoKeyboardHandle.h"
#import "RedpacketErrorView.h"

@interface RPValidateNameViewController ()<UITextFieldDelegate,SecurityCodeDelegate,UIAlertViewDelegate>
{
    UIButton *_nextBtn;
    BOOL _isTrueCardNumber,_isTableViewActio ,_isValidateName;
    NSDictionary *_cardIfoDict;
    long int _location;
    UILabel *_bottomFromlabel;
}

@property (nonatomic) UIButton *timeButton;

@property (nonatomic,strong)RPSendRedPacketAutoKeyboardHandle * keyboardAuto;

@property (nonatomic) UITextField *cardNumberTextField;

@property (nonatomic) UILabel *bankCardNameLable;

@property (nonatomic) UITextField *nameTextField;

@property (nonatomic) UITextField *IDCardNumberTextField;

@property (nonatomic) UITextField *phoneNumberTextfield;

@property (nonatomic) UIButton *phoneNumHelpBtn;

@property (nonatomic) RPValidateNameModel *validateNameModel;

@property (nonatomic) BindCardInfo *cardInfo;

@property (nonatomic) RedpacketErrorView *retryViw;

@end

@implementation RPValidateNameViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView removeFromSuperview];
    [self loadUserValidateInfo];
    self.cuttingLineHidden = YES;
}

- (void)loadUserValidateInfo
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        [weakSelf.view rp_removeHudInManaual];
        [weakSelf.retryViw removeFromSuperview];
        if ([data rp_stringForKey:@"RealName"].length) {
            _isValidateName = YES;
            weakSelf.cardInfo.realName = [data rp_stringForKey:@"RealName"];
            weakSelf.cardInfo.IDCard = [data rp_stringForKey:@"IDCard"];
            weakSelf.IDCardNumberTextField.text = weakSelf.cardInfo.IDCard;
            weakSelf.tableView.tableFooterView = [weakSelf tableFooterView];
            weakSelf.tableView.tableFooterView.frame = CGRectMake(0, 800, [UIScreen mainScreen].bounds.size.width, 500);
        } else {
            _isValidateName = NO;
        }
        [weakSelf loadSubViews];
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf LoadretryView];
    }];
    [request fetchUserValidateState];
} 

- (void)loadSubViews
{
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [RedpacketColorStore flashColorWithRed:239  green:239  blue:239  alpha:1];
    _bottomFromlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64 -24, [UIScreen mainScreen].bounds.size.width, 12)];
    _bottomFromlabel.text = [RPRedpacketSetting shareInstance].insuranceDes;
    _bottomFromlabel.textColor = [RedpacketColorStore rp_colorWithHEX:0x999999];
    _bottomFromlabel.font = [UIFont systemFontOfSize:12.0];
    _bottomFromlabel.textAlignment = NSTextAlignmentCenter;
    [self.tableView addSubview:_bottomFromlabel];
    UIButton *btn = [[UIButton alloc]initWithFrame:_bottomFromlabel.frame];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(clickGuaranteeTaipingyangProtocol) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *bottomFromlabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64 - 48, [UIScreen mainScreen].bounds.size.width, 12)];
    bottomFromlabel1.text = @"银行卡付款业务由京东支付支持";
    bottomFromlabel1.textColor = [RedpacketColorStore rp_colorWithHEX:0x999999];
    bottomFromlabel1.font = [UIFont systemFontOfSize:12.0];
    bottomFromlabel1.textAlignment = NSTextAlignmentCenter;
    [self.tableView addSubview:bottomFromlabel1];
}


- (void)setBindingCardType:(BindingCardType)bindingCardType
{
    _bindingCardType = bindingCardType;
    self.validateNameModel.bindingCardType = bindingCardType;
    self.titleLable.text = self.validateNameModel.title;
    self.titleLable.textColor = [RedpacketColorStore rp_textColorBlack];
    self.subLable.textColor = [RedpacketColorStore rp_textColorBlack];
}

- (void)setNavgationbarBtn
{
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:@"取消"];
    // 同意设置为返回
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
}

//点击右上角取消
- (void)clickButtonRight
{
    [self.view endEditing:YES];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:self.validateNameModel.cancelNotice delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        [_cardNumberTextField becomeFirstResponder];
    }
}

// 设置状态栏的颜色
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self setNavgationbarBtn];
    [self.cardNumberTextField becomeFirstResponder];
    self.keyboardAuto = [RPSendRedPacketAutoKeyboardHandle new];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.keyboardAuto = nil;
}

// section 的样式
- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

// tableViewfooterViw
- (UIView *)tableFooterView
{
    UIView *footerView        = [[UIView alloc]initWithFrame:self.tableView.tableFooterView.bounds];
    UILabel *noticeLable = [[UILabel alloc]init];
    noticeLable.text = @"该操作代表我已同意";
    noticeLable.font = [UIFont systemFontOfSize:12.0];
    noticeLable.textColor = [RedpacketColorStore rp_colorWithHEX:0x9e9e9e];
    [noticeLable sizeToFit];
    [footerView addSubview:noticeLable];
    
    UIButton *noticeBtn = [[UIButton alloc]init];
    NSString *orgName = [RPRedpacketSetting shareInstance].redpacketOrgName;
    [noticeBtn setTitle:[NSString stringWithFormat:@"《%@用户服务协议》", orgName] forState:UIControlStateNormal];
    [noticeBtn setTitleColor:[RedpacketColorStore rp_colorWithHEX:0x35b7f3] forState:UIControlStateNormal];
    noticeBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [noticeBtn addTarget:self action:@selector(clicknoticeBtn) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:noticeBtn];
    if (self.bindingCardType != BindingCardTypeSend) {
        _nextBtn = [RPRedpacketViews redpacketBlueButtonWithTitle:@"下一步"
                                                      andSelector:@selector(clickNextBtn)
                                                        andTarget:self];
    }else{
        _nextBtn = [RPRedpacketViews redpacketBlueButtonWithTitle:@"确定"
                                                      andSelector:@selector(clickNextBtn)
                                                        andTarget:self];
    }
    _nextBtn.enabled = NO;
     [footerView addSubview:_nextBtn];
    [_nextBtn rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(footerView.rpm_top).offset(15);
        make.left.equalTo(footerView.rpm_left).offset(15);
        make.right.equalTo(footerView.rpm_right).offset(-15);
        make.height.offset(44);
    }];
    
    [noticeLable rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(_nextBtn.rpm_bottom).offset(10);
        make.left.equalTo(footerView.rpm_left).offset(15);
    }];
    
    [noticeBtn rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.left.equalTo(noticeLable.rpm_right);
        make.centerY.equalTo(noticeLable.rpm_centerY);
    }];
    
    return footerView;
}

// 点击手机号码帮助
- (void)clickphoneNumHelpBtn
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"银行预留手机号是您在办理该银行卡时所填写的手机号。\n没有预留、已停用或忘记手机号码，请拨打银行客服电话更新处理。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
    
    [alertView show];
}

//点击 环信用户服务协议
- (void)clicknoticeBtn
{
    UIViewController *protocolCtr = [RedpacketWebController bindCardProtocolControllerWithTitleColor:[RedpacketColorStore rp_textColorBlack]];
    [self .navigationController pushViewController:protocolCtr animated:YES];
}

//点击 个人资金账户损失保险
- (void)clickGuaranteeTaipingyangProtocol
{
    UIViewController *webVc = [RedpacketWebController guaranteeTaipingyangProtocolWithTitleColor:[RedpacketColorStore rp_textColorBlack]];
    [self .navigationController pushViewController:webVc animated:YES];
}

- (BOOL)isRebindCard
{
    if (_cardArray.count) {
        NSString *inputCard = [[_cardNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *inputCardSuffix = [inputCard substringWithRange:NSMakeRange(inputCard.length - 4, 4)];
        
        for (NSDictionary *dict in _cardArray) {
            NSString *cardSuffix = [dict rp_stringForKey:@"Suffix"];
            if ([inputCardSuffix isEqualToString:cardSuffix]) {
                return YES;
            }
        }
    }
    return NO;
}

// 点击下一步按钮
- (void)clickNextBtn
{
    if (_cardNumberTextField.text.length < 16) {
        [self.view rp_showHudErrorView:@"请输入正确的卡号"];
    }else if (_phoneNumberTextfield.text.length < 11){
        [self.view rp_showHudErrorView:@"请输入正确的手机号"];
    }else if(_IDCardNumberTextField.text.length< 15 && !_isValidateName){
        [self.view rp_showHudErrorView:@"请输入正确的身份证号"];
    }else if(_nameTextField.text.length < 2 && !_isValidateName){
        [self.view rp_showHudErrorView:@"请输入正确的姓名"];
    }else if([self isRebindCard]) {
        [self alertRebindCard];
    }else {
        [self sendBindCardRequest];
    }
}

- (void)sendBindCardRequest
{
    ApplyPaymentModel *paymentModel = [ApplyPaymentModel new];
    self.cardInfo.cardNo = [self bankNumToNormalNumWithString:self.cardNumberTextField.text];
    self.cardInfo.bankId = _cardIfoDict[@"BankId"];
    self.cardInfo.bankName = _cardIfoDict[@"BankName"];
    self.cardInfo.IDCard = self.IDCardNumberTextField.text;
    self.cardInfo.realName = self.nameTextField.text;
    self.cardInfo.telephone = self.phoneNumberTextfield.text;
    paymentModel.cardInfo = self.cardInfo;
    paymentModel.amount = self.moneyAccount;
    
    rpWeakSelf;
    [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
    if(self.validateNameModel.bindingCardType == BindingCardTypeSend) {
        ApplyPaymentModel *weakPaymentModel = paymentModel;
        RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
            [weakSelf.view rp_removeHudInManaual];
            weakPaymentModel.billRef = [data rp_stringForKey:@"BillRef"];
            if ([weakSelf.delegate respondsToSelector:@selector(rebackwithApplyPaymentModel:)]) {
                [weakSelf.delegate rebackwithApplyPaymentModel:paymentModel];
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } andFaliureBlock:^(NSString *error, NSInteger code) {
            if (code == NSIntegerMax) {
                [weakSelf.view rp_showHudErrorView:error];
            }else {
                [weakSelf.view rp_removeHudInManaual];
                [weakSelf netWorkErrorShow:error];
            }
        }];
        [request applyForRedpacketPaymentWithApplyPayment:paymentModel];
    }else {
        RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
            [weakSelf.view rp_removeHudInManaual];
            SecurityCodeViewController *payPassSet = [[SecurityCodeViewController alloc]init];
            payPassSet.bindingCardType = self.validateNameModel.bindingCardType;
            payPassSet.paymentModel = paymentModel;
            payPassSet.paymentModel.billRef = data[@"BillRef"];
            payPassSet.delegate = weakSelf;
            [weakSelf.navigationController pushViewController:payPassSet animated:YES];
        } andFaliureBlock:^(NSString *error, NSInteger code) {
            if (code == NSIntegerMax) {
                [weakSelf.view rp_showHudErrorView:error];
            }else {
                [weakSelf.view rp_removeHudInManaual];
                [weakSelf netWorkErrorShow:error];
            }
        }];
        [request bindCardInTradeOrWithDraw:paymentModel];
    }
}

- (void)alertRebindCard
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"这张卡似乎已经添加过，确定要继续吗？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    rpWeakSelf;
    [alert setRp_completionBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [weakSelf sendBindCardRequest];
        }
    }];
    
    [alert show];
}

#pragma SecurityCodeDelegate
- (void)rebackToChangeWith:(BindingCardType)bindingCardType
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(rebackToChangeWith:)]) {
            [self.delegate rebackToChangeWith:self.bindingCardType];
        }
    }];
}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isValidateName) {
        if (_isTrueCardNumber) {
            return 3;
        }
        return 2;
    }else
    {
        if (_isTrueCardNumber) {
            return 2;
        }
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isValidateName) {
        if (_isTrueCardNumber) {
            return 1;
        }else
        {
            if (section == 1) {
                return 2;
            }
            return 1;
        }
    }else
    {
        if (_isTrueCardNumber) {
            if (section == 0) {
                return 1;
            }
            return 3;
        }
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"validateName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier ];
        if (_isValidateName) {
            if (!_isTrueCardNumber) {
                if (indexPath.section == 0) {
                    cell.textLabel.text = @"持卡人";
                    [self layoutViewWith:cell with:self.nameTextField with:NO];
                    self.nameTextField.text = self.cardInfo.realName;
                    self.nameTextField.enabled = NO;
                }else if (indexPath.section == 1){
                    if (indexPath.row == 0) {
                        cell.textLabel.text = @"银行卡号";
                        [self layoutViewWith:cell with:self.cardNumberTextField with:NO];
                    }else
                    {
                        cell.textLabel.text = @"手机号码";
                        [self layoutViewWith:cell with:self.phoneNumberTextfield with:NO];
                        [self layoutViewWith:cell with:self.phoneNumHelpBtn with:YES];
                    }
                }
            }else
            {
                if (indexPath.section == 0) {
                    cell.textLabel.text = @"持卡人";
                    [self layoutViewWith:cell with:self.nameTextField with:NO];
                    self.nameTextField.text = self.cardInfo.realName;
                    self.nameTextField.enabled = NO;
                }else if (indexPath.section == 1)
                {
                    cell.textLabel.text = @"银行卡号";
                    [self layoutViewWith:cell with:self.cardNumberTextField with:NO];
                }else
                {
                    cell.textLabel.text = @"手机号码";
                    [self layoutViewWith:cell with:self.phoneNumberTextfield with:NO];
                    [self layoutViewWith:cell with:self.phoneNumHelpBtn with:YES];
                }
            }
        }else
        {
            if (indexPath.section == 0) {
                cell.textLabel.text = @"银行卡号";
                [self layoutViewWith:cell with:self.cardNumberTextField with:NO];
            }else if (indexPath.section == 1){
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"真实姓名";
                    [self layoutViewWith:cell with:self.nameTextField with:NO];
                }else if (indexPath.row == 1){
                    cell.textLabel.text = @"身份证号";
                    [self layoutViewWith:cell with:self.IDCardNumberTextField with:NO];
                }else if (indexPath.row == 2) {
                    cell.textLabel.text = @"手机号码";
                    [self layoutViewWith:cell with:self.phoneNumberTextfield with:NO];
                    [self layoutViewWith:cell with:self.phoneNumHelpBtn with:YES];
                }
            }
        }
            }
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
//布局
- (void)layoutViewWith:(UIView *)fatherView with:(UIView *)subView with:(BOOL)isBtn
{
    [fatherView addSubview:subView];
    if (!isBtn) {
        [subView rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.left.equalTo(fatherView.rpm_left).offset(90);
            make.right.equalTo(fatherView.rpm_right).offset(-40);
            make.top.equalTo(fatherView.rpm_top).offset(0);
            make.bottom.equalTo(fatherView.rpm_bottom).offset(0);
        }];
    }else
    {
        [subView rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.right.equalTo(fatherView.rpm_right).offset(-15);
            make.height.offset(35);
            make.width.offset(35);
            make.centerY.equalTo(fatherView.rpm_centerY).offset(0);
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat margin = 40.0f;
    if (CGRectGetHeight([UIScreen mainScreen].bounds) == 480) {
        margin = 20.0f;
    }
    if (_isValidateName) {
        if (section == 2&& _isTrueCardNumber) {
            return 40;
        }
    }
    if (section == 0) {
        return margin;
    }
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat margin = 40.0f;
    if (CGRectGetHeight([UIScreen mainScreen].bounds) == 480) {
        margin = 20.0f;
    }
    if (section == 0 && _isValidateName) {
        return 10.0f;
    }
    if (section == 0) {
        return margin;
    }
    
    return .001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat margin = 15.0f;
    CGFloat height = 40.0f;
    if (CGRectGetHeight([UIScreen mainScreen].bounds) == 480) {
        margin = 4.0f;
        height = 20.0f;
    }
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, margin, view.bounds.size.width, 14)];
        lable.text = self.validateNameModel.detaile;
        lable.textColor = [RedpacketColorStore rp_textColorGray];
        lable.font = [UIFont systemFontOfSize:14.0];
        [view addSubview:lable];
        return view;
    }
    if (section == 2&& _isTrueCardNumber) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        if (_cardIfoDict.count > 0) {
            self.bankCardNameLable.text = [NSString stringWithFormat:@"%@%@",_cardIfoDict[@"BankName"],_cardIfoDict[@"CardType"]];
        }
        [view addSubview:self.bankCardNameLable];
        [_bankCardNameLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(view.rpm_top).offset(0);
            make.left.equalTo(view.rpm_left).offset(15);
            make.centerY.equalTo(view.rpm_centerY).offset(0);
        }];
        return view;
    }
    return [[UIView alloc]init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (!_isValidateName) {
        if (section == 0) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
            if (_cardIfoDict.count > 0) {
               self.bankCardNameLable.text = [NSString stringWithFormat:@"%@%@",_cardIfoDict[@"BankName"],_cardIfoDict[@"CardType"]];
            }
            [view addSubview:self.bankCardNameLable];
            [_bankCardNameLable rpm_makeConstraints:^(RPConstraintMaker *make) {
                make.top.equalTo(view.rpm_top).offset(0);
                make.left.equalTo(view.rpm_left).offset(15);
                make.centerY.equalTo(view.rpm_centerY).offset(0);
            }];
            return view;
        }
    }
        return [[UIView alloc]init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [_cardNumberTextField becomeFirstResponder];
    }else if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            [_nameTextField becomeFirstResponder];
        }else if(indexPath.row == 1)
        {
            [_IDCardNumberTextField becomeFirstResponder];
        }else if (indexPath.row == 2)
        {
            [_phoneNumberTextfield becomeFirstResponder];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
// 取消头部悬停
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 40.00;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma textFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (_cardNumberTextField.isFirstResponder == YES) {
        if (replacedString.length >= 16 && _nameTextField.text.length > 1 && _IDCardNumberTextField.text.length>=15 && _phoneNumberTextfield.text.length == 11) {
            _nextBtn.enabled = YES;
        } else {
            _nextBtn.enabled = NO;
        }
    } else if (_nameTextField.isFirstResponder == YES) {
        if (replacedString.length >= 2 && _cardNumberTextField.text.length >= 16 && _IDCardNumberTextField.text.length>=15 && _phoneNumberTextfield.text.length == 11) {
            _nextBtn.enabled = YES;
        } else {
            _nextBtn.enabled = NO;
        }
    } else if (_IDCardNumberTextField.isFirstResponder == YES) {
        if (replacedString.length >= 15 && _cardNumberTextField.text.length >= 16 && _nameTextField.text.length>=2 && _phoneNumberTextfield.text.length == 11) {
            _nextBtn.enabled = YES;
        } else {
            _nextBtn.enabled = NO;
        }
    } else if (_phoneNumberTextfield.isFirstResponder == YES) {
        if (replacedString.length >= 11 && _cardNumberTextField.text.length >= 16 && _nameTextField.text.length>=2 && _IDCardNumberTextField.text.length >= 15) {
            _nextBtn.enabled = YES;
        } else {
            _nextBtn.enabled = NO;
        }
    }
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if (_cardNumberTextField.isFirstResponder == YES) {
        if (textField == _cardNumberTextField) {
            NSString *text = [_cardNumberTextField text];
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
                return NO;
            }
            text = [text stringByReplacingCharactersInRange:range withString:string];
            text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *newString = @"";
            while (text.length > 0) {
                _location = range.location;
                NSString *subString = [text substringToIndex:MIN(text.length, 4)];
                newString = [newString stringByAppendingString:subString];
                if (subString.length == 4) {
                    newString = [newString stringByAppendingString:@" "];
                }
                text = [text substringFromIndex:MIN(text.length, 4)];
            }
            newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
            // 限制长度
            if (newString.length >= 25) {
                return NO;
            }
            [_cardNumberTextField setText:newString];
            if (_location + 2 < newString.length) {
                [textField offsetFromPosition:textField.beginningOfDocument
                                   toPosition:textField.selectedTextRange.start];
                UITextPosition *targetPosition =
                [textField positionFromPosition:[textField beginningOfDocument]
                                         offset:_location + 1];
                if (!targetPosition) {
                    UITextPosition* beginning = textField.beginningOfDocument;
                    UITextPosition* startPosition = [textField positionFromPosition:beginning offset:_location];
                    UITextPosition* endPosition = [textField positionFromPosition:beginning offset:_location + range.length];
                    [textField textRangeFromPosition:startPosition toPosition:endPosition];
                }
                else
                {
                    [textField setSelectedTextRange:
                     [textField textRangeFromPosition:targetPosition
                     toPosition                      :targetPosition]
                     ];
                }
                if (range.location < 7&&newString.length > 7) {
                    newString = [[self bankNumToNormalNumWithString:newString] substringWithRange:NSMakeRange(0, 6)];
                    [self requestCardInfoWith:newString];
                }
            }
            [self requestCardInfoWith:newString];
            return NO;
        }
    }
    if (_IDCardNumberTextField.isFirstResponder == YES) {
        if (replacedString.length >= 18) {
            textField.text = replacedString;
            [_phoneNumberTextfield becomeFirstResponder];
        }
        // 判断输入是否数字或者小数点
        NSString* number=@"^[0-9]";
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
        if ([numberPre evaluateWithObject:string] && replacedString.length < 18){
            return YES;
        }else if(replacedString.length == 18 && ([string isEqualToString:@"x"] || [string isEqualToString:@"X"]))
        {
            return YES;
        }else
        {
            return NO;
        }
    }
    if (_phoneNumberTextfield.isFirstResponder == YES) {
        // 判断输入是否数字或者小数点
        NSString* number=@"^[0-9]+$";
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
        if (([numberPre evaluateWithObject:string] && replacedString.length < 12)) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

// 银行卡号转正常号 － 去除4位间的空格
-(NSString *)bankNumToNormalNumWithString:(NSString *)str;
{
    return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
}

// 根据银行卡信息拉取银行卡列表
- (void)requestCardInfoWith:(NSString *)cardNumber
{
    NSString *cardNum = [self bankNumToNormalNumWithString:cardNumber];
    if (cardNum.length == 6) {
        RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
            _isTrueCardNumber = YES;
            _cardIfoDict  = data;
            _bankCardNameLable.text = [NSString stringWithFormat:@"%@%@",_cardIfoDict[@"BankName"],_cardIfoDict[@"CardType"]];
            if (_isValidateName && !_isTableViewActio) {
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationBottom];
                [self.tableView endUpdates];
                _isTableViewActio = YES;
            }
            if ([self bankNumToNormalNumWithString:_cardNumberTextField.text].length == [_cardIfoDict[@"CardNoLen"] intValue]) {
                _isTrueCardNumber = YES;
                if (_isValidateName) {
                    [self.phoneNumberTextfield becomeFirstResponder];
                }else if (!_isTableViewActio) {
                    self.tableView.tableFooterView = [self tableFooterView];
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
                    self.tableView.tableFooterView.frame = CGRectMake(0, 800, [UIScreen mainScreen].bounds.size.width, 500);
                    [UIView animateWithDuration:.8 animations:^{
                        self.tableView.tableFooterView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500);
                        [_nameTextField becomeFirstResponder];
                    }];
                    _isTableViewActio = YES;
                }else
                {
                    [_nameTextField becomeFirstResponder];
                }
            }
        } andFaliureBlock:^(NSString *error, NSInteger code) {
            _bankCardNameLable.text = @"";
            if (_isValidateName && _isTableViewActio) {

            }
        }];
        
        [request getCardBInInfoWith:cardNum];
        
    }else if (cardNum.length == [_cardIfoDict[@"CardNoLen"] intValue])
    {
        _isTrueCardNumber = YES;
        if (_isValidateName) {
            [self.phoneNumberTextfield becomeFirstResponder];
        }else if (!_isTableViewActio) {
            _cardNumberTextField.text = cardNumber;
            self.tableView.tableFooterView = [self tableFooterView];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
            self.tableView.tableFooterView.frame = CGRectMake(0, 800, [UIScreen mainScreen].bounds.size.width, 500);
            [UIView animateWithDuration:.8 animations:^{
                self.tableView.tableFooterView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500);
                    [_nameTextField becomeFirstResponder];
            }];
            _isTableViewActio = YES;
        }else
        {
            [_nameTextField becomeFirstResponder];
        }
    }else if (cardNum.length >= 16 && !_isTableViewActio && [_cardIfoDict[@"CardNoLen"] intValue]== 0 && !_isValidateName) {
        _isTrueCardNumber = YES;
        self.tableView.tableFooterView = [self tableFooterView];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
        self.tableView.tableFooterView.frame = CGRectMake(0, 800, [UIScreen mainScreen].bounds.size.width, 500);
        [UIView animateWithDuration:.8 animations:^{
            self.tableView.tableFooterView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500);
        }];
        _isTableViewActio = YES;
    }
}


- (UITextField *)cardNumberTextField
{
    if ( !_cardNumberTextField) {
        _cardNumberTextField = [[UITextField alloc]init];
        _cardNumberTextField.font = [UIFont systemFontOfSize:15];
        _cardNumberTextField.placeholder = @"请输入您本人的银行卡卡号";
        _cardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
        _cardNumberTextField.delegate = self;
    }
    return _cardNumberTextField;
}

- (UITextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc]init];
        _nameTextField.font = [UIFont systemFontOfSize:15];
        _nameTextField.placeholder = @"请输入您的姓名";
        _nameTextField.delegate = self;
    }
    return _nameTextField;
}

- (UITextField *)IDCardNumberTextField
{
    if (!_IDCardNumberTextField) {
        _IDCardNumberTextField = [[UITextField alloc]init];
        _IDCardNumberTextField.font = [UIFont systemFontOfSize:15];
        _IDCardNumberTextField.placeholder = @"请输入您的身份证号码";
        _IDCardNumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _IDCardNumberTextField.delegate = self;
    }
    return _IDCardNumberTextField;
}

- (UITextField *)phoneNumberTextfield
{
    if (!_phoneNumberTextfield) {
        _phoneNumberTextfield = [[UITextField alloc]init];
        _phoneNumberTextfield.font = [UIFont systemFontOfSize:15.0];
        _phoneNumberTextfield.placeholder = @"银行预留手机号";
        _phoneNumberTextfield.keyboardType = UIKeyboardTypeNumberPad;
        _phoneNumberTextfield.delegate = self;
    }
    return _phoneNumberTextfield;
}

- (UIButton *)phoneNumHelpBtn
{
    if (!_phoneNumHelpBtn) {
        _phoneNumHelpBtn = [[UIButton alloc]init];
        [_phoneNumHelpBtn setImage:rpRedpacketBundleImage(@"redpacket_help_high") forState:UIControlStateNormal];
        [_phoneNumHelpBtn addTarget:self action:@selector(clickphoneNumHelpBtn) forControlEvents:UIControlEventTouchUpInside];
        _phoneNumHelpBtn.imageView.contentMode = UIViewContentModeCenter;
    }
    return _phoneNumHelpBtn;
}

- (RPValidateNameModel *)validateNameModel
{
    if (!_validateNameModel) {
        _validateNameModel = [RPValidateNameModel new];
    }
    return _validateNameModel;
}

- (BindCardInfo *)cardInfo
{
    if (!_cardInfo) {
        _cardInfo = [BindCardInfo new];
    }
    return _cardInfo;
}

- (UILabel *)bankCardNameLable
{
    if (!_bankCardNameLable) {
        _bankCardNameLable = [[UILabel alloc]init];
        _bankCardNameLable.font = [UIFont systemFontOfSize:12.0];
        _bankCardNameLable.textColor = [RedpacketColorStore rp_textColorGray];
    }
    return _bankCardNameLable;
}

- (RedpacketErrorView *)retryViw
{
    rpWeakSelf;
    if (!_retryViw) {
        _retryViw = [RedpacketErrorView viewWithWith:self.view.bounds.size.width];
        [_retryViw setButtonClickBlock:^{
            [weakSelf loadUserValidateInfo];
        }];
    }
    return _retryViw;
}

- (void)LoadretryView
{
    [self.view addSubview:self.retryViw];
    self.retryViw.frame = self.view.bounds;
}


@end

