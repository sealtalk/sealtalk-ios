//
//  WithDrawViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/4/30.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "WithDrawViewController.h"
#import "AddBankCardInfoController.h"
#import "RedpacketDataRequester.h"
#import "UIView+YZHPrompting.h"
#import "NewPayView.h"
#import "YZTransparent.h"
#import "UIView+YZHAnimation.h"
#import "UIView+YZHExtension.h"
#import "RPValidateNameViewController.h"
#import "RedpacketColorStore.h"
#import "ApplyPaymentModel.h"
#import "RPRedpackeNavgationController.h"
#import "RPRedpacketSetting.h"
#import "RedpacketErrorCode.h"
#import "UIAlertView+YZHAlert.h"


@interface WithDrawViewController ()<RPValidatedeDelegate,UITextFieldDelegate>
{
    UIButton *_wihtDrawBtn;
    BOOL _isHavePoint;
    UILabel *_accountLable;
}

@property (nonatomic) NSString *moneyBalance;
@property (nonatomic, strong) NewPayView *payview;
@property (nonatomic)   UITextField *accoutField;

@end

@implementation WithDrawViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    self.titleLable.text = @"零钱提现";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    _isHavePoint = NO;
    [self loadSubViews];
    [self addKeyboardNotifaction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:nil];
}

- (void)loadSubViews
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        [weakSelf.view rp_removeHudInManaual];
        weakSelf.dict = dict;
        weakSelf.tableView.tableFooterView = [weakSelf tableFooterView];
        weakSelf.tableView.tableFooterView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500);
        [weakSelf.tableView reloadData];
        } andFaliureBlock:^(NSString *error, NSInteger code) {
            [weakSelf.view rp_showHudErrorView:error];
        }];
        [request getPaymentCardInfo];
}


- (UIView *)tableFooterView
{
    UIView *footerView        = [[UIView alloc]initWithFrame:self.tableView.tableFooterView.bounds];
    
    _accountLable = [[UILabel alloc]init];
    _accountLable.text = [NSString stringWithFormat:@"零钱余额￥%@，",self.money];
    _accountLable.font = [UIFont systemFontOfSize:13.0];
    _accountLable.textColor = [RedpacketColorStore rp_colorWithHEX:0x9e9e9e];
    [footerView addSubview:_accountLable];
    
    UIButton *allWithDraw = [[UIButton alloc]init];
    [allWithDraw setTitleColor:[RedpacketColorStore rp_colorWithHEX:0x35b7f3] forState:UIControlStateNormal];
    [allWithDraw setTitle:@"全部提现" forState:UIControlStateNormal];
    allWithDraw.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [allWithDraw addTarget:self action:@selector(clickallWithDrawBtn) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:allWithDraw];
    _accountLable.translatesAutoresizingMaskIntoConstraints = NO;
    allWithDraw.translatesAutoresizingMaskIntoConstraints   = NO;
    [footerView addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:_accountLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeTop multiplier:1 constant:15],
                                [NSLayoutConstraint constraintWithItem:_accountLable attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeLeft multiplier:1 constant:15],
                                [NSLayoutConstraint constraintWithItem:allWithDraw attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_accountLable attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:allWithDraw attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_accountLable attribute:NSLayoutAttributeRight multiplier:1 constant:0]
                                ]
     ];
    UILabel *timeLable = [[UILabel alloc]init];
    timeLable.textAlignment = NSTextAlignmentRight;
    timeLable .text  = @"预计明天24点前到账";
    timeLable.font = [UIFont systemFontOfSize:12.0];
    timeLable.textColor = [RedpacketColorStore rp_colorWithHEX:0x9e9e9e];
    [footerView addSubview:timeLable];
    
    _wihtDrawBtn = [RPRedpacketViews redpacketBlueButtonWithTitle:@"提现" andSelector:@selector(clickWithDrawBtn) andTarget:self];
    if ([UIScreen mainScreen].bounds.size.width < 321) {
        
        timeLable.frame = CGRectMake(15, 30, [UIScreen mainScreen].bounds.size.width -30, 30);
        timeLable.textAlignment = NSTextAlignmentLeft;
        _wihtDrawBtn.frame = CGRectMake(15, timeLable.frame.origin.y + timeLable.bounds.size.height + 2, [UIScreen mainScreen].bounds.size.width - 30, 44);
    }else {
        _wihtDrawBtn.frame = CGRectMake(15, 62, [UIScreen mainScreen].bounds.size.width - 30, 44);
        timeLable.frame = CGRectMake(15, 15, [UIScreen mainScreen].bounds.size.width -30, 13);
    }
    
    [footerView addSubview:_wihtDrawBtn];
    
    
    return footerView;
}

//点击 提现
- (void)clickWithDrawBtn
{
    [self.view endEditing:YES];
    _wihtDrawBtn.enabled = NO;
    if (![self showIsWithDrawError:self.accoutField.text]) {
        rpWeakSelf;
        [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
        RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
            _wihtDrawBtn.enabled = YES;
            [weakSelf.view rp_removeHudInManaual];
            weakSelf.dict = dict;
            NSString *BankBranchCode = [weakSelf.dict rp_stringForKey:@"BankBranchCode"];
            NSString *BankBranchName = [weakSelf.dict rp_stringForKey:@"BankBranchName"];
            NSString *City = [weakSelf.dict rp_stringForKey:@"City"];
            NSString *Province = [weakSelf.dict rp_stringForKey:@"Province"];
            
            //银行卡相信信息如果有一个为空，则需要完善卡信息
            if (BankBranchCode.length < 1|| BankBranchName.length < 1|| City.length < 1||Province.length < 1) {
                
                RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
                    [weakSelf.view rp_removeHudInManaual];
                    AddBankCardInfoController *cardInfoContr = [[AddBankCardInfoController alloc]init];
                    cardInfoContr.bankNmame = [weakSelf.dict rp_stringForKey:@"BankName"];
                    cardInfoContr.cardId = [weakSelf.dict rp_stringForKey:@"CardId"];
                    cardInfoContr.cardNo = [weakSelf.dict rp_stringForKey:@"CardNo"];
                    cardInfoContr.bankNo = [weakSelf.dict rp_stringForKey:@"BankNo"];
                    cardInfoContr.provArray = (NSArray *)dict;
                    [weakSelf.navigationController pushViewController:cardInfoContr animated:YES];
                } andFaliureBlock:^(NSString *error, NSInteger code) {
                    if (error) {
                        if ([weakSelf withString:error]) {
                            AddBankCardInfoController *cardInfoContr = [[AddBankCardInfoController alloc]init];
                            cardInfoContr.bankNmame = [weakSelf.dict rp_stringForKey:@"BankName"];
                            cardInfoContr.cardId = [weakSelf.dict rp_stringForKey:@"CardId"];
                            cardInfoContr.cardNo = [weakSelf.dict rp_stringForKey:@"CardNo"];
                            cardInfoContr.bankNo = [weakSelf.dict rp_stringForKey:@"BankNo"];
                            cardInfoContr.provArray = [weakSelf withString:error];
                            [weakSelf.view rp_removeHudInManaual];
                            [weakSelf.navigationController pushViewController:cardInfoContr animated:YES];
                        }else
                        {
                            [weakSelf.view rp_showHudErrorView:error];
                        }
                    }
                }];
                [request getBankCardProv];
                
            }else
            {
                [YZTransparent showInView:weakSelf.view touchBlock:nil];
                //弹出支付密码确认提示
                [self showNewPayView];
            }
            
            
        } andFaliureBlock:^(NSString *error, NSInteger code) {
            _wihtDrawBtn.enabled = YES;
            if (code == NSIntegerMax) {
                [weakSelf.view rp_showHudErrorView:error];
            }else {
                [weakSelf.view rp_removeHudInManaual];
                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:error delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
                [alertView show];
            }    }];
        
        [request getPaymentCardInfo];
        
    } else {
        _wihtDrawBtn.enabled = YES;
    }
}

- (NSArray *)withString:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization  JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSDictionary *infoDict = array[0];
    if (infoDict[@"pname"]) {
        return array;
    }
    return nil;
}

#pragma mark - PopDrawView

- (void)showNewPayView
{
    rpWeakSelf;
    UserAccoutModel *model = [UserAccoutModel new];
    model.payMoney = [NSString stringWithFormat:@"%.2f",[weakSelf.accoutField.text doubleValue]];
    weakSelf.payview.payType = RDPayTypeWithDrawMoney;
    [weakSelf.payview configWithModel:model];
    
    [weakSelf.payview setButtonActionBlock:^(NewPayView *payView, RDButtonActionType type, NSString *pass) {
        
        if (type == RDButtonActionTypeClose) {
            /**
             *  关闭对话框
             */
            [weakSelf.payview clearPassword];
            [weakSelf.payview removeFromSuperview];
            
            [YZTransparent removeFromSuperView];
            
        }else if ( type == RDButtonActionTypeForgotPass) {
            /**r
             *  重新设置密码
             */
            RPValidateNameViewController *validateVc = [[RPValidateNameViewController alloc]init];
            validateVc.delegate = weakSelf;
            validateVc.bindingCardType = BindingCardTypeSetPassword;//绑卡类型修改
            RPRedpackeNavgationController *nav = [[RPRedpackeNavgationController alloc] initWithRootViewController:validateVc];
            [weakSelf.navigationController presentViewController:nav animated:YES completion:nil];
            
        }else {
            // 发送提现到银行卡请求
            [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
            RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
                [weakSelf.view rp_removeHudInManaual];
                
                /**
                 *  密码输入完成
                 */
                [weakSelf.payview removeFromSuperview];
                [YZTransparent removeFromSuperView];
                [weakSelf.view rp_showHudSuccessView:@"提现申请已受理"];
                weakSelf.moneyBalance =[dict rp_stringFloatForKey:@"Balance"];
                [weakSelf performSelector:@selector(dissmisSelf) withObject:nil afterDelay:1.0f];
                
            } andFaliureBlock:^(NSString *error, NSInteger code) {
                
                if (code == RedpacketHBPayPWDFailed) {
                    /**
                     *  密码输入错误
                     */
                    [weakSelf passwordInputError:error];
                    
                }else{
                    
                    [weakSelf.payview  removeFromSuperview];
                    weakSelf.payview = nil;
                    [YZTransparent removeFromSuperView];
                    [weakSelf.view rp_removeHudInManaual];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:error delegate:weakSelf cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
                    [alertView show];
                }
            }];
            
            ApplyPaymentModel *model = [ApplyPaymentModel new];
            BindCardInfo *cardInfo = [BindCardInfo new];
            
            [cardInfo parseDic:weakSelf.dict];
            model.amount = [NSString stringWithFormat:@"%.2f",[weakSelf.accoutField.text doubleValue]];
            model.passWord = pass;
            model.cardInfo = cardInfo;
            
            [request withDrawPaymentWith:model];
        }
        
    }];
    [self popSubView:weakSelf.payview];
    [weakSelf.payview  becomeFirstResponder];
}

- (void)passwordInputError:(NSString *)error
{
    [self.payview removeFromSuperview];
    rpWeakSelf;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
    [alert setRp_completionBlock:^( UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        
        [weakSelf popSubView:weakSelf.payview];
        [weakSelf.payview clearPassword];
        [weakSelf.payview becomeFirstResponder];
    }];
    
    [alert show];
}

- (void)popSubView:(UIView *)view
{
    CGPoint center = self.view.center;
    center.y -= view.rp_height / 2;
    view.center = center;
    [self.view rp_popupSubView:view atPosition:PopAnchorCenterX | PopAnchorCenterY];
}

#pragma ValidatedeDelegate
- (void)rebackToChangeWith:(BindingCardType)bindingCardType
{
    [RPRedpacketSetting asyncRequestRedpacketsettingsIfNeed:nil];
    [_payview removeFromSuperview];
    [YZTransparent removeFromSuperView];
}

- (void)dissmisSelf
{
    [self.delegate withDrawSuccessfulWithMoney:_moneyBalance];
    _accountLable.text = _moneyBalance;
    [self.navigationController popViewControllerAnimated:YES];
}

//点击 全部提现
- (void)clickallWithDrawBtn
{
    self.accoutField.text = self.money;
}

- (BOOL)showIsWithDrawError:(NSString *)money
{
    CGFloat minMoney = [RPRedpacketSetting shareInstance].withDrawMinMoney;
    CGFloat maxMoney = [RPRedpacketSetting shareInstance].withDrawMaxMoney;
    NSString *prompt;
    BOOL isError = NO;
    
    if ([money floatValue] > [self.money floatValue]) {
        isError = YES;
        prompt = @"提现金额超出零钱余额";
        
    }else if ([money floatValue] < minMoney) {
        isError = YES;
        prompt = [NSString stringWithFormat:@"单笔提现最少%.2f元", minMoney];
        
    }else if ([self.accoutField.text floatValue]> maxMoney){
        isError = YES;
        prompt = [NSString stringWithFormat:@"单笔提现最大%d", (int)maxMoney];
    }
    
    if (isError) {
        [self.view rp_showHudErrorView:prompt];
    }
    
    return isError;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"WihtDrawingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier ];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"到账银行卡";
        if (self.dict.count >0) {
            NSString *cardNo = [self.dict rp_stringForKey:@"CardNo"];
            NSString *lastFourNo = [cardNo substringFromIndex:cardNo.length - 4];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)",[self.dict rp_stringForKey:@"BankName"],lastFourNo];
        }
    }else
    {
        cell.textLabel.text = @"提现金额";
        cell.detailTextLabel.text = @"元";
        cell.detailTextLabel.textColor = [RedpacketColorStore rp_textColorBlack];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
        [cell addSubview:self.accoutField];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        [_accoutField becomeFirstResponder];
        
    }else{
        [self.view endEditing:YES];
    }
}

// 懒加载
- (UITextField *)accoutField
{
    if (!_accoutField) {
        _accoutField = [[UITextField alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width -237, 18, 200, 15)];
        _accoutField.font = [UIFont systemFontOfSize:15];
        _accoutField.textAlignment = NSTextAlignmentRight;
        _accoutField.keyboardType = UIKeyboardTypeDecimalPad;
        _accoutField.delegate = self;
    }
    
    NSString *prompt = @"请输入提现金额";
    _accoutField.placeholder = prompt;
    
    return _accoutField;
}

- (NewPayView *)payview
{
    if (!_payview) {
        _payview = [NewPayView new];
    }
    return _payview;
}

#pragma UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSString *temp;
    int pointNnumber = 0;
    for(int i =0; i < [replacedString length]; i++)
    {
        temp = [replacedString substringWithRange:NSMakeRange(i, 1)];
        if ([temp isEqualToString:@"."]) {
            pointNnumber++;
            if (pointNnumber > 1.1) {
                return NO;
            }
        }
    }
    
    NSArray *array = [replacedString componentsSeparatedByString:@"."];
    if (array.count == 2) {
        _isHavePoint = YES;
        NSString *decimalString = array[1];
        NSString *numberString = array[0];
        if (decimalString.length > 2) {
            return NO;
        }
        
        if (numberString.length > 10) {
            return NO;
        }
    }else if(replacedString.length > 10) {
        return NO;
    }
    
    // 判断输入是否数字或者小数点
    NSString* number=@"^[0-9]+$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    if (([string isEqualToString:@""]) || [string isEqualToString:@"."] || [numberPre evaluateWithObject:string]) {
        return YES;
    }
    
    return NO;
}


- (void)addKeyboardNotifaction
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)noti
{
    CGRect keyboardFrame = [[noti.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    UIView *topView = [self topInputView];
    CGFloat interval = CGRectGetMinY(keyboardFrame) - topView.rp_bottom - 64;
    if (interval < 0) {
        [UIView animateWithDuration:.25 animations:^{
            topView.rp_top = topView.rp_top + interval;
        }];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)noti
{
    UIView *topView = [self topInputView];
    [UIView animateWithDuration:.25 animations:^{
        CGPoint center = self.view.center;
        center.y -= 100;
        topView.center = center;
    }];
}

- (UIView *)topInputView
{
    UIView *topView;
    if (_payview && _payview.superview) {
        topView = _payview;
    }else {
        topView = _payview;
    }
    
    return topView;
}

@end
