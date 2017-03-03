//
//  MyBankCardsViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/6/3.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "MyBankCardsViewController.h"
#import "MybankCellTableViewCell.h"
#import "RedpacketColorStore.h"
#import "NSDictionary+YZHExtern.h"
#import "RPValidateNameViewController.h"
#import "YZHRedpacketBridge.h"
#import "UIView+YZHPrompting.h"
#import "RedpacketDataRequester.h"
#import "RedpacketErrorView.h"
#import "RPRedpacketTool.h"
#import "RPRedpacketSetting.h"
#import "RPRedpackeNavgationController.h"

@interface MyBankCardsViewController ()<RPValidatedeDelegate>
{
    NSIndexPath *_currentIndexPath;
}
@property (nonatomic, assign)   BOOL isUpHeigh;
@property (nonatomic, strong)   NSArray *historyArray;
@property (nonatomic, strong)   RedpacketErrorView *retryViw;
@property (nonatomic, strong)   UIImageView *addBankImageView;
@end

@implementation MyBankCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLable.text = @"我的银行卡";
    self.tableView.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self requestRedpacketGetBankCardsList];
    [self addRightBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:nil];
}

- (void)addRightBarButtonItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:rpRedpacketBundleImage(@"paypassView_addIcon") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addPayBankCard) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *btn_left = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = - 8;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, btn_left, nil];
}

- (void)addPayBankCard
{
    RPValidateNameViewController *controller = [[RPValidateNameViewController alloc]init];
    controller.delegate = self;
    controller.bindingCardType = BindingCardTypeAddBankCard;
    controller.cardArray = _historyArray;
    RPRedpackeNavgationController *nav = [[RPRedpackeNavgationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)requestRedpacketGetBankCardsList
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        weakSelf.tableView.hidden = NO;
        [weakSelf.view rp_removeHudInManaual];
        weakSelf.historyArray = [data rp_arrayForKey:@"Cards"];
        
        [weakSelf.retryViw removeFromSuperview];
        weakSelf.retryViw = nil;
        
        if (weakSelf.historyArray.count > 0) {
            [weakSelf.addBankImageView removeFromSuperview];
        }else{
            weakSelf.tableView.tableFooterView = [[UIView alloc]init];
            [weakSelf.tableView addSubview:weakSelf.addBankImageView];
        }
        
        [weakSelf.tableView reloadData];
        weakSelf.isUpHeigh = NO;
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf.view rp_removeHudInManaual];
        [weakSelf.tableView addSubview:weakSelf.retryViw];
        weakSelf.retryViw.frame = weakSelf.tableView.bounds;
    }];
    [request getHongbaoPaymentCardsList];
    
}

#pragma mark - ValidatedeDelegate
- (void)rebackToChangeWith:(BindingCardType)bindingCardType
{
    [RPRedpacketSetting asyncRequestRedpacketsettingsIfNeed:nil];
    
    [self requestRedpacketGetBankCardsList];
    
    if ([self.delegate respondsToSelector:@selector(binCardSucessRefreshChangeMoneyAndisBinCard:)]) {
        
        BOOL isBincard;
        if (_historyArray.count > 0) {
            isBincard = YES;
        } else {
            isBincard = NO;
        }
        
        [self.delegate binCardSucessRefreshChangeMoneyAndisBinCard:isBincard];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.historyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"MyBankCardsViewControllerCellID";
    
    MybankCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        cell = [[MybankCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *bankInfoDict = self.historyArray[indexPath.section];
    cell.bankNameLable.text = [bankInfoDict rp_stringForKey:@"BankName"];
    cell.bankNoLable.text = [NSString stringWithFormat:@"**** **** **** %@",[bankInfoDict rp_stringForKey:@"Suffix"]];
    cell.backImageView.backgroundColor = [RedpacketColorStore  colorWithHexString:[bankInfoDict rp_stringForKey:@"Color"] alpha:1];
    cell.cardTypeLable.text = @"支付卡";
    
    if (indexPath.section == 0) {
        cell.cardTypeLable.text = @"提现卡  支付卡";
    }
    
    cell.bankTypeLable.text = @"借记卡";

    if (_isUpHeigh && _currentIndexPath.section == indexPath.section) {
        
        [cell addfooterViewWithOnceMoney:[bankInfoDict rp_stringIntForKey:@"QuotaSingleItem"] withDayMoney:[bankInfoDict rp_stringIntForKey:@"QuotaSingleDay"]];
        rpWeakSelf;
        [cell setSelectionBlockDel:^{
            [weakSelf clickdelBankcardBtnWith:[bankInfoDict rp_stringForKey:@"CardId"]];
        }];
        
    }else{
        
        [cell delFooterView];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 17.00;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_isUpHeigh == YES)&& indexPath.section == _currentIndexPath.section) {
        return 285;
    }
    return 125.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isUpHeigh ) {
        _isUpHeigh = YES;
        _currentIndexPath = indexPath;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if (_isUpHeigh && _currentIndexPath.section == indexPath.section) {
        _isUpHeigh = NO;
        _currentIndexPath = indexPath;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else
    {
        _isUpHeigh = NO;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        _isUpHeigh = YES;
        _currentIndexPath = indexPath;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
// 取消头部悬停
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 17.00;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (RedpacketErrorView *)retryViw
{
    rpWeakSelf;
    if (!_retryViw) {
        _retryViw = [RedpacketErrorView viewWithWith:self.view.bounds.size.width];
        [_retryViw setButtonClickBlock:^{
            [weakSelf requestRedpacketGetBankCardsList];
        }];
    }
    return _retryViw;
}

- (void)clickdelBankcardBtnWith:(NSString *)cardId
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        [weakSelf requestRedpacketGetBankCardsList];
        [weakSelf.view rp_showHudSuccessView:@"银行卡移除成功"];
        [weakSelf rebackToChangeWith:0];
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        if (code == NSIntegerMax) {
            [weakSelf.view rp_showHudErrorView:error];
        }else {
            [weakSelf.view rp_removeHudInManaual];
            [weakSelf netWorkErrorShow:error];
        }
    }];
    [request removeBankCardWith:cardId];
}

- (UIImageView *)addBankImageView
{
    if (!_addBankImageView) {
        _addBankImageView = [[UIImageView alloc]initWithFrame:self.tableView.bounds];
        
        UIImageView *noCardImageView = [[UIImageView alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 63) * .5, 49, 63, 63)];
        [noCardImageView setImage:rpRedpacketBundleImage(@"redpacket_myBankCardsVC_noBankcardView")];
        [_addBankImageView addSubview:noCardImageView];
    
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, noCardImageView.frame.origin.y + noCardImageView.bounds.size.height + 12, [UIScreen mainScreen].bounds.size.width, 12)];
        lable.text = @"你还没有银行卡";
        lable.font = [UIFont systemFontOfSize:16.0];
        lable.textColor = [RedpacketColorStore rp_textColorGray];
        lable.textAlignment = NSTextAlignmentCenter;
        [_addBankImageView addSubview:lable];
        
        UIButton *addBankCardBtn  = [[UIButton alloc]initWithFrame:CGRectMake(15, 187, [UIScreen mainScreen].bounds.size.width - 30, 44)];
        addBankCardBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [addBankCardBtn setTitle:@"添加一张银行卡" forState:UIControlStateNormal];
        [addBankCardBtn setTitleColor:[RedpacketColorStore rp_textColorBlack] forState:UIControlStateNormal];
        addBankCardBtn.layer.cornerRadius = 3.0;
        addBankCardBtn.layer.borderWidth = 1;
        addBankCardBtn.layer.borderColor = [UIColor clearColor].CGColor;
        addBankCardBtn.layer.masksToBounds = YES;
        [addBankCardBtn setBackgroundColor:[UIColor whiteColor]];
        [addBankCardBtn addTarget:self action:@selector(addPayBankCard) forControlEvents:UIControlEventTouchUpInside];
        _addBankImageView.userInteractionEnabled = YES;
        [_addBankImageView addSubview:addBankCardBtn];
    }
    return _addBankImageView;
}

@end
