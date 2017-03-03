//
//  changePurseViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/4/30.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "changePurseViewController.h"
#import "RPValidateNameViewController.h"
#import "WithDrawViewController.h"
#import "RedpacketDataRequester.h"
#import "UIView+YZHPrompting.h"
#import "ApplyPaymentModel.h"
#import "RedpacketWebController.h"
#import "MyInComeRedPacketViewController.h"
#import "RedpacketErrorView.h"
#import "RedpacketColorStore.h"
#import "MyBankCardsViewController.h"
#import "UIView+YZHExtension.h"
#import "ChangeViewController.h"
#import "ValidateUserIDController.h"
#import "ValidateUserIDSuccessController.h"
#import "YZHRedpacketBridge.h"
#import "RPRedpacketSetting.h"
#import "RPRedpackeNavgationController.h"
#import "RPServerSelectionViewController.h"
#import "YZHRedpacketBridge+Private.h"
#import "ChangePurseModel.h"
#import "RPLayout.h"
#import "RPReceiptsInAlipayViewController.h"

@interface ChangePurseViewController ()<RPValidatedeDelegate,UIAlertViewDelegate,WithDrawViewContrDelegate,MyBankCardsDelegate>
{
    UILabel *_bottomFromlabel;
}

@property (nonatomic) RedpacketErrorView *retryViw;
@property (nonatomic) UIView *accessView;
@property (nonatomic) UIButton *rechangeButton;
@property (nonatomic) UIButton *withDrawButton;
@property (nonatomic) UILabel *changeMoneyLable;
@property (nonatomic) ChangePurseModel *chaneModel;
@property (nonatomic) UIView *horizontingline;
@property (nonatomic) UIView *verticalLine;
@property (nonatomic) UIView *headerView;
@end

static UILabel *serverHostChangeLabel = nil;

@implementation ChangePurseViewController

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    serverHostChangeLabel = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [serverHostChangeLabel removeFromSuperview];
}

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLable.text = @"零钱";
    [self.tableView removeFromSuperview];
    [self loadLQrequest];
    [self isWithDraw];
    self.view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
}

- (UILabel *)serverHostChangeGestureLabel
{
    if (!serverHostChangeLabel) {
        
        UILabel *titleLabel = [UILabel new];
        serverHostChangeLabel = titleLabel;
        
        titleLabel.text = @"ChangeServers";
        titleLabel.textColor = [UIColor clearColor];
        [titleLabel sizeToFit];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(severButtonSelected:)];
        gesture.numberOfTapsRequired = 3;
        titleLabel.rp_height = 44.0f;
        titleLabel.rp_right = CGRectGetWidth(self.view.frame);
        [titleLabel addGestureRecognizer:gesture];
        titleLabel.userInteractionEnabled = YES;
    }
    
    return serverHostChangeLabel;
}

- (void)severButtonSelected:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        RPServerSelectionViewController *serversVC = [[RPServerSelectionViewController alloc] init];
        rpWeakSelf;
        [serversVC setSelectChanged:^{
            [weakSelf loadLQrequest];
            
        }];
        [self.navigationController pushViewController:serversVC animated:YES];
    }
}

- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 203)];
        _headerView.backgroundColor = [RedpacketColorStore rp_textColorRed];
        UILabel *detailLable = [_headerView rp_addsubview:[UILabel class]];
        detailLable.font = [UIFont systemFontOfSize:14.0];
        detailLable.textColor = [UIColor whiteColor];
        detailLable.text = @"我的零钱";
        detailLable.textAlignment = NSTextAlignmentCenter;
        detailLable.backgroundColor = [UIColor clearColor];
        [detailLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(_headerView.rpm_top).offset(31);
            make.centerX.equalTo(_headerView.rpm_centerX).offset(0);
        }];
        
        [_headerView addSubview:self.changeMoneyLable];
        [self.changeMoneyLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(_headerView.rpm_top).offset(63);
            make.centerX.equalTo(_headerView.rpm_centerX).offset(0);
        }];
        
    }
    return _headerView;
}

- (void)isWithDraw
{
    if ([RPRedpacketSetting shareInstance].isWithDraw) {
        [_rechangeButton removeFromSuperview];
        _rechangeButton = nil;
        [self.headerView addSubview:self.horizontingline];
        [self.horizontingline rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.headerView .rpm_bottom).offset(-50);
            make.height.offset(1 / [UIScreen mainScreen].scale);
            make.left.equalTo(self.headerView.rpm_left).offset(0);
            make.right.equalTo(self.headerView.rpm_right).offset(0);
        }];
        
        [self.headerView  addSubview:self.verticalLine];
        [self.verticalLine rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.headerView .rpm_bottom).offset(-49);
            make.bottom.equalTo(self.headerView .rpm_bottom).offset(0);
            make.centerX.equalTo(self.headerView .rpm_centerX).offset(0);
            make.width.offset(1 / [UIScreen mainScreen].scale);
        }];
        
        [self.headerView  addSubview:self.rechangeButton];
        [self.rechangeButton rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.horizontingline.rpm_bottom).offset(0);
            make.left.equalTo(self.headerView .rpm_left).offset(0);
            make.bottom.equalTo(self.headerView .rpm_bottom).offset(0);
            make.right.equalTo(self.headerView .rpm_centerX).offset(-1);
        }];
        
        [self.headerView  addSubview:self.withDrawButton];
        [self.withDrawButton rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.horizontingline.rpm_bottom).offset(0);
            make.left.equalTo(self.headerView .rpm_centerX).offset(1);
            make.right.equalTo(self.headerView .rpm_right).offset(0);
            make.bottom.equalTo(self.headerView .rpm_bottom).offset(0);
        }];
    }else
    {
        [_horizontingline removeFromSuperview];
        _horizontingline = nil;
        [_verticalLine removeFromSuperview];
        _verticalLine = nil;
        [_withDrawButton removeFromSuperview];
        _withDrawButton = nil;
        [self.headerView addSubview:self.rechangeButton];
        [self.rechangeButton rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.headerView.rpm_top).offset(133);
            make.centerX.equalTo(self.headerView.rpm_centerX).offset(0);
            make.height.offset(35);
            make.width.offset(100);
        }];
        self.rechangeButton.layer.cornerRadius = 17.5f;
        self.rechangeButton.layer.masksToBounds = YES;
        self.rechangeButton.layer.borderWidth = .7;
        self.rechangeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

- (UIView *)heardView1
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 203)];
    headView.backgroundColor = [RedpacketColorStore rp_textColorRed];
    
    UILabel *detailLable = [headView rp_addsubview:[UILabel class]];
    detailLable.font = [UIFont systemFontOfSize:14.0];
    detailLable.textColor = [UIColor whiteColor];
    detailLable.text = @"我的零钱";
    detailLable.textAlignment = NSTextAlignmentCenter;
    detailLable.backgroundColor = [UIColor clearColor];
    [detailLable rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(headView.rpm_top).offset(31);
        make.centerX.equalTo(headView.rpm_centerX).offset(0);
    }];
    
    [headView addSubview:self.changeMoneyLable];
    [self.changeMoneyLable rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(headView.rpm_top).offset(63);
        make.centerX.equalTo(headView.rpm_centerX).offset(0);
    }];
    
    [headView addSubview:self.horizontingline];
    [self.horizontingline rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(headView.rpm_bottom).offset(-50);
        make.width.equalTo(headView.rpm_width).offset(0);
        make.left.equalTo(self.headerView.rpm_left).offset(0);
        make.right.equalTo(self.headerView.rpm_right).offset(0);
    }];
    
    [headView addSubview:self.verticalLine];
    [self.verticalLine rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(headView.rpm_bottom).offset(-49);
        make.bottom.equalTo(headView.rpm_bottom).offset(0);
        make.centerX.equalTo(headView.rpm_centerX).offset(0);
        make.width.offset(1 / [UIScreen mainScreen].scale);
    }];
    
    [headView addSubview:self.rechangeButton];
    [self.rechangeButton rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.horizontingline.rpm_bottom).offset(0);
        make.left.equalTo(headView.rpm_left).offset(0);
        make.bottom.equalTo(headView.rpm_bottom).offset(0);
        make.right.equalTo(headView.rpm_centerX).offset(-1);
    }];
    
    [headView addSubview:self.withDrawButton];
    [self.withDrawButton rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.horizontingline.rpm_bottom).offset(0);
        make.left.equalTo(headView.rpm_centerX).offset(1);
        make.right.equalTo(headView.rpm_right).offset(0);
        make.bottom.equalTo(headView.rpm_bottom).offset(0);
    }];
    
    
    return headView;
}

- (UIView *)horizontingline
{
    if (!_horizontingline) {
        _horizontingline = [[UIView alloc]init];
        _horizontingline.backgroundColor = [UIColor whiteColor];
    }
    return _horizontingline;
}

- (UIView *)verticalLine
{
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc]init];
        _verticalLine.backgroundColor = [UIColor whiteColor];
    }
    return _verticalLine;
}

- (UILabel *)changeMoneyLable
{
    if (!_changeMoneyLable) {
        _changeMoneyLable = [[UILabel alloc]init];
        _changeMoneyLable.font = [UIFont systemFontOfSize:44];
        _changeMoneyLable.textColor = [UIColor whiteColor];
        _changeMoneyLable.textAlignment = NSTextAlignmentCenter;
        _changeMoneyLable.backgroundColor = [UIColor clearColor];
    }
    return _changeMoneyLable;
}

- (UIButton *)rechangeButton
{
    if (!_rechangeButton) {
        _rechangeButton = [RPRedpacketViews redpacketRedButtonWithTitle:@"充值" andSelector:@selector(rechangeButtonClicked) andTarget:self];
    }
    return _rechangeButton;
}

- (UIButton *)withDrawButton
{
    if (!_withDrawButton) {
        _withDrawButton = [RPRedpacketViews redpacketRedButtonWithTitle:@"提现" andSelector:@selector(withDrawButtonClicked) andTarget:self];
    }
    return _withDrawButton;
}

- (UIView *)footerView
{
    UIView *footerView = [[UIView alloc]init];
    CGFloat height;
    if (self.chaneModel.isBindCard) {
        height = 582;
    }else
    {
        height = 532;
    }
    if ([UIScreen mainScreen].bounds.size.width > 321) {
        footerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - height);
    }else
    {
        footerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 82);
    }
    [footerView setBackgroundColor:[RedpacketColorStore rp_backGroundColor]];
    _bottomFromlabel = [footerView rp_addsubview:[UILabel class]];
    [_bottomFromlabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerX.equalTo(footerView.rpm_centerX).offset(0);
        make.bottom.equalTo(footerView.rpm_bottom).offset(-27);
    }];
    _bottomFromlabel.text = [RPRedpacketSetting shareInstance].insuranceDes;
    _bottomFromlabel.textColor = [RedpacketColorStore rp_textColorGray];
    _bottomFromlabel.font = [UIFont systemFontOfSize:12.0];
    _bottomFromlabel.textAlignment = NSTextAlignmentCenter;
    
    UIButton *bottomFromlabelBtn = [footerView rp_addsubview:[UIButton class]];
    [bottomFromlabelBtn rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerX.equalTo(footerView.rpm_centerX).offset(0);
        make.width.equalTo(_bottomFromlabel.rpm_width).offset(0);
        make.height.equalTo(_bottomFromlabel.rpm_height).offset(0);
        make.bottom.equalTo(footerView.rpm_bottom).offset(-27);
    }];
    bottomFromlabelBtn.backgroundColor = [UIColor clearColor];
    [bottomFromlabelBtn addTarget:self action:@selector(clickGuaranteeTaipingyangProtocol) forControlEvents:UIControlEventTouchUpInside];
    return footerView;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.chaneModel.isBindCard || section == 0) {
        return 3;
        
    }else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ChangePurseViewControllerCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier ];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.textLabel.textColor =[RedpacketColorStore rp_textColorBlack];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"零钱明细";
            cell.imageView.image = rpRedpacketBundleImage(@"changePurse_cell_list");
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"我的银行卡";
            cell.imageView.image = rpRedpacketBundleImage(@"changePurse_cell_cardList");
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"我的红包记录";
            cell.imageView.image = rpRedpacketBundleImage(@"changePurse_cell_redpacktLIst");
        }
        
    }else{
        NSInteger index = self.chaneModel.isBindCard ? indexPath.row : indexPath.row + 1;
        
        if (index == 0 ) {
            cell.textLabel.text = @"验证身份";
            cell.imageView.image = rpRedpacketBundleImage(@"changePurse_cell_verify");
            UIView *accessView = [self accessView:self.chaneModel.certificationStatus];
            if (_accessView) {
                [_accessView removeFromSuperview];
            }
            _accessView = accessView;
            accessView.rp_centerY = cell.contentView.rp_centerY + 2;
            accessView.rp_right = CGRectGetWidth([UIScreen mainScreen].bounds) - 20.0f;
            [cell.contentView addSubview:accessView];
        }else if (index == 1) {
            cell.textLabel.text = @"管理支付密码";
            cell.imageView.image = rpRedpacketBundleImage(@"changePurse_cell_lock");
            if (!self.chaneModel.isBindCard) {
                [_accessView removeFromSuperview];
            }
        }else if (index == 2){
            cell.textLabel.text = @"常见问题";
            cell.imageView.image = rpRedpacketBundleImage(@"changePurse_cell_question");
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 17;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self showChangeListView];
        }else if (indexPath.row == 1){
            MyBankCardsViewController *myBankCardsVC = [[MyBankCardsViewController alloc]init];
            myBankCardsVC.delegate = self;
            [self.navigationController  pushViewController:myBankCardsVC animated:YES];
        }else if (indexPath.row == 2){
            [self myInComeRedPacket];
        }
        
    }else{
        NSInteger index = self.chaneModel.isBindCard ? indexPath.row : indexPath.row + 1;
        if (index == 0) {
            [self validateUserIDCardViewController];
        }else if (index == 1) {
            [self clickchangePayPassBtn];
        }else if (index == 2){
            [self clickbottomBtn];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        self.view.backgroundColor = [RedpacketColorStore rp_textColorRed];
        
    }else {
        self.view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    }
}

- (void)loadLQrequest
{
    rpWeakSelf;
    [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken:^(NSInteger code, NSString *msg) {
        if (code == 0) {
            [weakSelf.retryViw removeFromSuperview];
            [weakSelf requestChangeMoney];
            
            [RPRedpacketSetting asyncRequestRedpacketSettings:^{
                [weakSelf refreshTitle];
            }];
        }else {
            [weakSelf LoadretryView];
            [weakSelf.view rp_showHudErrorView:msg];
        }
    }];
}

- (void)refreshTitle
{
    self.subLable.text = [NSString stringWithFormat:@"%@红包服务", [RPRedpacketSetting shareInstance].redpacketOrgName];
    _bottomFromlabel.text = [RPRedpacketSetting shareInstance].insuranceDes;
    [self isWithDraw];
    _changeMoneyLable.text = [NSString stringWithFormat:@"￥%@",self.chaneModel.balance];
    [self.tableView reloadData];
}

- (void)requestChangeMoney
{
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        [weakSelf.view rp_removeHudInManaual];
        [weakSelf.retryViw removeFromSuperview];
        weakSelf.retryViw = nil;
        [weakSelf.view addSubview:weakSelf.tableView];
        weakSelf.tableView.tableHeaderView = self.headerView;
        weakSelf.tableView.tableFooterView = [weakSelf footerView];
        weakSelf.tableView.backgroundColor = [UIColor clearColor];
        weakSelf.tableView.frame = weakSelf.view.bounds;
        _chaneModel = [ChangePurseModel configWith:dict];
        _changeMoneyLable.text = [NSString stringWithFormat:@"￥%@",self.chaneModel.balance];
        [weakSelf lineLeftAlign];
        weakSelf.tableView.tableFooterView = [weakSelf footerView];
        [weakSelf.tableView reloadData];
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        if (code == NSIntegerMax) {
            [weakSelf LoadretryView];
            [weakSelf.view rp_showHudErrorView:error];
        }else{
            [weakSelf.view rp_removeHudInManaual];
            [weakSelf netWorkErrorShow:error];
            [weakSelf LoadretryView];
        }
        _changeMoneyLable.text = @"￥-.--";
    }];
    [request getPaymentMoney];
}

//cell下划线 左边间距
- (void)lineLeftAlign
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset: UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins: UIEdgeInsetsZero];
    }
}

- (void)LoadretryView
{
    [self.view addSubview:self.retryViw];
    self.retryViw.frame = self.view.bounds;
}

- (RedpacketErrorView *)retryViw
{
    rpWeakSelf;
    if (!_retryViw) {
        _retryViw = [RedpacketErrorView new];
        [_retryViw setButtonClickBlock:^{
            [weakSelf loadLQrequest];
                }];
    }
    return _retryViw;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.cuttingLineHidden = YES;
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barStyle       = UIBarStyleBlack;
    if (self.navigationController.viewControllers.count == 1) {
        [self setNavgationBarBackgroundColor:[RedpacketColorStore rp_textColorRed] titleColor:[RedpacketColorStore rp_textcolorYellow] leftButtonTitle:@"关闭" rightButtonTitle:@""];
    }else {
        [self setNavgationBarBackgroundColor:[RedpacketColorStore rp_textColorRed] titleColor:[RedpacketColorStore rp_textcolorYellow] leftButtonTitle:@"" rightButtonTitle:@""];
    }
    
    if ([YZHRedpacketBridge sharedBridge].isDebug) {
        UILabel *gestureLabel = [self serverHostChangeGestureLabel];
        [self.navigationController.navigationBar addSubview:gestureLabel];
    }

}


//  充值
- (void)rechangeButtonClicked
{
    ChangeViewController *controller = [ChangeViewController new];
    rpWeakSelf;
    [controller setFinishBlock:^{
        [weakSelf performSelector:@selector(loadLQrequest) withObject:nil afterDelay:1.0f];
    }];
    
    [self.navigationController pushViewController:controller animated:YES];
}

//  提现
- (void)withDrawButtonClicked
{
    if (self.chaneModel.isBindCard && self.chaneModel.isPwd) {
        WithDrawViewController *contr = [[WithDrawViewController alloc]init];
        contr.money = self.chaneModel.balance;
        contr.delegate = self;
        [self.navigationController pushViewController:contr animated:YES];
    }else {
        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"提示" message:@"为了您的账户安全，请通过银行卡验证是您本人操作，并设置支付密码。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        RPValidateNameViewController *controller = [[RPValidateNameViewController alloc]init];
        controller.delegate = self;
        if (!self.chaneModel.isBindCard && self.chaneModel.isPwd) {
            controller.bindingCardType = BindingCardTypeWithDrawNoCard;
        }else if (!self.chaneModel.isPwd && self.chaneModel.isBindCard) {
            controller.bindingCardType = BindingCardTypeWithDrawNoPass;
        }else {
            controller.bindingCardType = BindingCardTypeWithDrawNoPassAdnNoCard;
        }
        RPRedpackeNavgationController *nav = [[RPRedpackeNavgationController alloc]initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
    }
}

- (void)validateUserIDCardViewController
{
    if (self.chaneModel.certificationStatus == 3) {
        // 不再显示
        //[self.view rp_showHudAuto:@"审核中..."];
        return;
    }
    
    UIViewController *controller = nil;
    if (self.chaneModel.certificationStatus == 1) {
        ValidateUserIDSuccessController *validateVC = [[ValidateUserIDSuccessController alloc] initWithStyle:UITableViewStyleGrouped];
        controller = validateVC;
        
    }else {
        ValidateUserIDController *validateSuccessVC = [[ValidateUserIDController alloc] initWithStyle:UITableViewStyleGrouped];
        validateSuccessVC.isValidateFalid = YES;
        rpWeakSelf;
        [validateSuccessVC setFinishBlock:^{
            [weakSelf performSelector:@selector(loadLQrequest) withObject:nil afterDelay:1.0f];
        }];
        
        if (self.chaneModel.certificationStatus == 2) {
            validateSuccessVC.validateMsg = self.chaneModel.certificationMessage;
        }
        
        controller = validateSuccessVC;
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)alertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    [alert show];
}

- (void)clickchangePayPassBtn
{
    RPValidateNameViewController *controller = [[RPValidateNameViewController alloc] init];
    if (_chaneModel.isPwd) {
        controller.bindingCardType = BindingCardTypeForgetPass;
    }else
    {
        controller.bindingCardType = BindingCardTypeSetPassword;
    }
    controller.delegate = self;
    RPRedpackeNavgationController *nav = [[RPRedpackeNavgationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)myInComeRedPacket
{
    MyInComeRedPacketViewController *myIncome;
#ifdef AliAuthPay
    myIncome = [[RPReceiptsInAlipayViewController alloc] initWithStyle:UITableViewStyleGrouped];
#else
    myIncome = [[MyInComeRedPacketViewController alloc] initWithStyle:UITableViewStyleGrouped];
#endif
    
    [self.navigationController pushViewController:myIncome animated:YES];
}

- (void)clickbottomBtn
{
    UIViewController *qaContr = [RedpacketWebController myRechangeQaWebControllerWithTitleColor:[RedpacketColorStore rp_textColorBlack]];
    [self.navigationController pushViewController:qaContr animated:YES];
}

#pragma rebackToChange

- (void)rebackToChangeWith:(BindingCardType)bindingCardType
{
    _chaneModel.isPwd = YES;//设置支付密码成功
    _chaneModel.isBindCard = YES;//设置支付密码必须要绑卡
    [self requestChangeMoney];
    if (bindingCardType == BindingCardTypeWithDrawNoPass || bindingCardType == BindingCardTypeWithDrawNoCard || bindingCardType == BindingCardTypeWithDrawNoPassAdnNoCard) {
        [RPRedpacketSetting asyncRequestRedpacketsettingsIfNeed:nil];
        WithDrawViewController *contr = [[WithDrawViewController alloc]init];
        contr.money = self.chaneModel.balance;
        contr.delegate = self;
        [self.navigationController pushViewController:contr animated:YES];
    }
}

- (void)binCardSucessRefreshChangeMoneyAndisBinCard:(BOOL)isBinCard;
{
    if (isBinCard) {
        _chaneModel.isBindCard = YES;
    }else
    {
        _chaneModel.isBindCard = NO;
    }
    [self requestChangeMoney];
}

#pragma WithDrawViewContrDelegate
- (void)withDrawSuccessfulWithMoney:(NSString *)money
{
    self.chaneModel.balance = money;
  _changeMoneyLable.text = [NSString stringWithFormat:@"￥%@",money];
}

#pragma mark -
- (void)dismiss
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)clickButtonLeft
{
    [self dismiss];
}
- (void)showChangeListView
{
    UIViewController *changeListView = [RedpacketWebController changeMoneyListWebControllerWithTitleColor:[RedpacketColorStore rp_textColorBlack]];
    [self.navigationController pushViewController:changeListView animated:YES];
}

- (UIView *)accessView:(NSInteger)status
{
    /**
     * status
     * 0  未验证， 1 已验证， 2 验证失败  3 审核中
     */
    
    NSString *statusStr = nil;
    switch (status) {
        case 1: statusStr = @"已验证";break;
        case 2: statusStr = @"验证失败";break;
        case 3: statusStr = @"审核中";break;
        default:statusStr = @"未验证";break;
    }
    
    NSString *imageStr = status == 1 ? @"changepurse_validate_success" : @"changepurse_validate_faile";
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:rpRedpacketBundleImage(imageStr)];
    [imageView sizeToFit];
    imageView.rp_left = 5;
    imageView.rp_top = 0;
    [view addSubview:imageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, 16 * statusStr.length, 20)];
    title.text = statusStr;
    title.font = [UIFont systemFontOfSize:16.0f];
    
    UIColor *textColor = [RedpacketColorStore rp_textColorGray];
    if (status == 0) {
        textColor = [RedpacketColorStore rp_textColorRed];
    }
    
    title.textColor = textColor;
    [title sizeToFit];
    [view addSubview:title];
    
    view.rp_width = title.rp_right + 10;
    return view;
}

//点击 个人资金账户损失保险
- (void)clickGuaranteeTaipingyangProtocol
{
    UIViewController *webVc = [RedpacketWebController guaranteeTaipingyangProtocolWithTitleColor:[RedpacketColorStore rp_textColorBlack]];
    [self .navigationController pushViewController:webVc animated:YES];
}

@end
