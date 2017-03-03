//
//  SettingPaypasswordViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/4/29.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "SettingPaypasswordViewController.h"
#import "RedpacketDataRequester.h"
#import "UIView+YZHPrompting.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketSetting.h"


@interface SettingPaypasswordViewController () <UITextFieldDelegate>
{
    UIImageView *_payPasswordImageView;
    UITextField *_payPasswordTextField;
    NSString *_temp, *_firstPassword;
    UILabel *_label, *_toplable, *_bottomLable;
    UIButton *_nextBtn;
}
@end

@implementation SettingPaypasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.tableFooterView.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    self.titleLable.text = @"设置支付密码";
    self.titleLable.textColor = [RedpacketColorStore rp_textColorBlack];
    self.subLable.tintColor   = [RedpacketColorStore rp_textColorBlack];
    [self loadsubViews];
    self.tableView.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.cuttingLineHidden = YES;
}

- (void)loadsubViews
{
    _toplable  = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, [UIScreen mainScreen].bounds.size.width, 14)];
    _toplable.text = @"请输入6位数字支付密码(1/2)";
    _toplable.font = [UIFont systemFontOfSize:14.0];
    _toplable.textAlignment = NSTextAlignmentCenter;
    _toplable.textColor = [UIColor colorWithRed:110/255.0 green:110/255.0 blue:110/255.0 alpha:1];
    [self.tableView addSubview:_toplable];
    
    _payPasswordImageView = [[UIImageView alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 264)*.5, 43, 264, 44)];
    UIImage *image = rpRedpacketBundleImage(@"redpacket_SettingPaypasswordVC_password_in");
    [_payPasswordImageView setImage:image];
    _payPasswordImageView.userInteractionEnabled = YES;
    [self.tableView addSubview:_payPasswordImageView];
    
    UIButton *keyBoardBtn = [[UIButton alloc]initWithFrame:_payPasswordImageView.frame];
    [keyBoardBtn addTarget:self action:@selector(keyboardAppear) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:keyBoardBtn];
    
    _payPasswordTextField = [[UITextField alloc]init];
    _payPasswordTextField.delegate = self;
    _payPasswordTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.tableView addSubview:_payPasswordTextField];
    [_payPasswordTextField becomeFirstResponder];
    
    _bottomLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 101, [UIScreen mainScreen].bounds.size.width, 12)];
    _bottomLable.text = @"";
    _bottomLable.textColor = [UIColor colorWithRed:241/255.0 green:78/255.0 blue:70/255.0 alpha:1];
    _bottomLable.font = [UIFont systemFontOfSize:12.0];
    _bottomLable.textAlignment = NSTextAlignmentCenter;
    [self.tableView addSubview:_bottomLable];
}

// 设置状态栏的颜色
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self setNavgationbarBtn];
}

- (void)setNavgationbarBtn
{
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:nil];
    // 同意设置为返回
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
}


#pragma textDeldgate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _temp = [textField.text stringByReplacingCharactersInRange:range withString:string];

    NSString *reg = @"^[0-9]+$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",reg];
    
    if (![numberPre evaluateWithObject:string]&&![string isEqualToString:@""]) {
        return NO;
    }
    
    if ([string isEqualToString:@""]) {
        
        [self setYuandianFrameWith:_temp.length isAdd:NO];
        
    }else
    {
        _temp =[textField.text stringByAppendingString:string];
        if (_temp.length >6 ) {
            return NO;
        }
        [self setYuandianFrameWith:_temp.length isAdd:YES];
    }
    return YES;
}

- (void)setYuandianFrameWith:(NSInteger)figure isAdd:(BOOL)isAdd
{
    if (isAdd&&figure<7) {
        
        UIImageView *yuandian = [[UIImageView alloc]initWithImage:rpRedpacketBundleImage(@"redpacket_SettingPaypasswordVC_yuan")];
        yuandian.center = CGPointMake(_payPasswordImageView.bounds.size.width/12.0+_payPasswordImageView.bounds.size.width/6.0*(figure - 1), _payPasswordImageView.bounds.size.height*.5);
        yuandian.tag = figure - 1;
        [_payPasswordImageView addSubview:yuandian];
    }else
    {
        for (UIView *view in _payPasswordImageView.subviews) {
            if (view.tag == figure) {
                [view removeFromSuperview];
            }
        }
    }
    if (figure == 6) {
        [self logPaypassWord];
    }
}

- (void)keyboardAppear
{
    [_payPasswordTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)logPaypassWord
{
    if (_firstPassword.length < 1 ) {
        _toplable.text = @"请输入6位数字支付密码(2/2)";
        [self performSelector:@selector(logPaypassWord2) withObject:nil afterDelay:1.0f];
        _firstPassword = _temp;
    }else if ([_temp isEqualToString:_firstPassword]) {
        rpWeakSelf;
        [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
        RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
            [weakSelf.view rp_removeHudInManaual];
            [RPRedpacketSetting shareInstance].isSetPassWordSha256 = YES;
            // 判断是零钱页面过来的 还是 发送红包页面的过来的
            if (weakSelf.bindingCardType != BindingCardTypeForgetPass && weakSelf.bindingCardType != BindingCardTypeSetPassword) {
                [weakSelf.view rp_showHudSuccessView:@"密码设置成功"];
                [weakSelf performSelector:@selector(logPaypassWord3) withObject:nil afterDelay:1.0f];
            }else {
                [weakSelf.view rp_showHudSuccessView:@"密码设置成功"];
                [weakSelf performSelector:@selector(dismissSelf) withObject:nil afterDelay:1.0f];
            }
            [RPRedpacketSetting asyncRequestRedpacketsettingsIfNeed:nil];
        } andFaliureBlock:^(NSString *error, NSInteger code) {
            [weakSelf.view rp_showHudErrorView:error];
        }];
        [request resetPayPasswordWith:_firstPassword with:weakSelf.captcha];
    }else
    {
        _bottomLable.text = @"两次密码输入不一致，请重新输入";
        [self performSelector:@selector(passWordDiff) withObject:nil afterDelay:1.5f];
    }
}

- (void)logPaypassWord2
{
    _payPasswordTextField.text = @"";

    for (UIView *view in _payPasswordImageView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)logPaypassWord3
{
    if ([self.delegate respondsToSelector:@selector(rebackToChangeWith:)]) {
        [self.delegate rebackToChangeWith:self.bindingCardType];
    }
}

- (void)passWordDiff
{
    _payPasswordTextField.text = @"";
    _toplable.text = @"请输入6位数字支付密码(1/2)";
    _firstPassword = @"";
    _bottomLable.text = @"";
    for (UIView *view in _payPasswordImageView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)dismissSelf
{
    [self logPaypassWord3];
    UIViewController *superContr = (UIViewController *)self.navigationController.viewControllers[0];
    [superContr dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
