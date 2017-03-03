//
//  AddBankCardInfoController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/4/30.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "AddBankCardInfoController.h"
#import "RedpacketDataRequester.h"
#import "UIView+YZHPrompting.h"
#import "ApplyPaymentModel.h"
#import "SearchInfoViewController.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketViews.h"


@interface AddBankCardInfoController ()<SearchViewDelegate>
{
    NSIndexPath *_indexPath;
    NSString *_pName, *_pNo, *_cName, *_cNo, *_branchBankName,*_longbranchBankName, *_branchNo;
    NSInteger _row;
}
@property (nonatomic) UILabel *cardInFoLable;

@property (nonatomic) UILabel *cardNumberLable;

@property (nonatomic) UIButton *pickSureBtn;

@property (nonatomic) UIButton *pickCanceBtn;

@property (nonatomic) NSArray *cityArray;

@property (nonatomic) NSArray *branchBankArray;

@end

@implementation AddBankCardInfoController

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLable.text = @"完善卡信息";
    self.titleLable.textColor = [RedpacketColorStore rp_textColorBlack];
    self.subLable.textColor   = [RedpacketColorStore rp_textColorBlack];
    self.tableView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    self.tableView.tableFooterView = [self tableFooterView];
    self.tableView.tableFooterView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500);
    self.tableView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
    }
    return self;
}

- (UIView *)tableFooterView
{
    UIView *footerView = [[UIView alloc]initWithFrame:self.tableView.tableFooterView.bounds];
    
    UIButton *sureBtn  = [RPRedpacketViews redpacketBlueButtonWithTitle:@"确定" andSelector:@selector(clickNextBtn) andTarget:self];
    
    [footerView addSubview:sureBtn];
    
    return footerView;
}

- (void)clickNextBtn
{
    rpWeakSelf;
    [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        [weakSelf.view rp_removeHudInManaual];
        [weakSelf.view rp_showHudSuccessView:@"卡信息已经提交"];
        [weakSelf performSelector:@selector(dissmisSelf) withObject:nil afterDelay:1.0f];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf.view rp_showHudErrorView:error];
    }];
    
    ApplyPaymentModel *model = [ApplyPaymentModel new];
    BindCardInfo *cardInfo = [BindCardInfo new];
    
    cardInfo.cardId = self.cardId;
    cardInfo.province = _pName;
    cardInfo.city = _cName;
    cardInfo.bankBranchName = _longbranchBankName;
    cardInfo.bankBranchCode = _branchNo;
    model.cardInfo = cardInfo;
    [request updateCardInfoWith:model];
    
}
- (void)dissmisSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 1;
    }
    return 3;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"validateName";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier ];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"银行卡号";
        self.cardNumberLable.text = self.cardNo;
        [cell addSubview:self.cardNumberLable];
    }else if (indexPath.section == 1)
    {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"选择省";
            cell.detailTextLabel.text = _pName;
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"选择市";
            cell.detailTextLabel.text = _cName;
        }else if (indexPath.row == 2) {
            cell.textLabel.text = @"开户行名称";
            cell.detailTextLabel.text = _branchBankName;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, view.bounds.size.width, 14)];
        lable.text = @"您的提现银行卡";
        lable.textColor = [RedpacketColorStore flashColorWithRed:110  green:110  blue:110  alpha:1];
        lable.font = [UIFont systemFontOfSize:14.0];
        [view addSubview:lable];
        return view;
        
    }
    if (section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, view.bounds.size.width, 14)];
        lable.text = @"完善银行卡信息，以便快速到账";
        lable.textColor = [RedpacketColorStore flashColorWithRed:110  green:110  blue:110  alpha:1];
        lable.font = [UIFont systemFontOfSize:14.0];
        [view addSubview:lable];
        return view;
    }
    return [[UIView alloc]init];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        
        self.cardInFoLable.text = self.bankNmame;
        
        [view addSubview:self.cardInFoLable];
        return view;
    }
    return [[UIView alloc]init];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
            SearchInfoViewController *searchCon = [[SearchInfoViewController alloc]init];
            searchCon.cardInfoarray = self.provArray;
            searchCon.keyName = @"pname";
            searchCon.delegate = self;
            [self.navigationController pushViewController:searchCon animated:YES];
            
            
        }else if (indexPath.row == 1){
            
            if (_pNo.length < 1) {
                
                [self.view rp_showHudAuto:@"请先选择省份"];
            }else
            {
                rpWeakSelf;
                [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
                RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
                    [weakSelf.view rp_removeHudInManaual];
                    
                    weakSelf.cityArray = (NSArray *)dict;
                    SearchInfoViewController *searchCon = [[SearchInfoViewController alloc]init];
                    searchCon.cardInfoarray = (NSArray *)dict;
                    searchCon.keyName = @"cname";
                    searchCon.delegate = weakSelf;
                    [weakSelf.navigationController pushViewController:searchCon animated:YES];
                    
                } andFaliureBlock:^(NSString *error, NSInteger code) {
                    weakSelf.cityArray = [weakSelf withString:error];
                    SearchInfoViewController *searchCon = [[SearchInfoViewController alloc]init];
                    searchCon.cardInfoarray = [weakSelf withString:error];
                    searchCon.keyName = @"cname";
                    searchCon.delegate = weakSelf;
                    if (searchCon.cardInfoarray) {
                        [weakSelf.view rp_removeHudInManaual];
                        [weakSelf.navigationController pushViewController:searchCon animated:YES];
                    }else
                    {
                        [weakSelf.view rp_showHudErrorView:error];
                    }
                }];
                
                [request getBankCardCityWith:_pNo];
            }
            
        }else if (indexPath.row == 2){
            
            if (_pNo.length < 1) {
                
                [self.view rp_showHudAuto:@"请先选择省份"];
                
            }else if(_cNo.length < 1){
                
                [self.view rp_showHudAuto:@"请先选择城市"];
                
            }else{
                
                rpWeakSelf;
                [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
                RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
                    [weakSelf.view rp_removeHudInManaual];
                    weakSelf.branchBankArray = (NSArray *)dict;
                    SearchInfoViewController *searchCon = [[SearchInfoViewController alloc]init];
                    searchCon.cardInfoarray = (NSArray *)dict;
                    searchCon.keyName = @"sbname";
                    searchCon.delegate = weakSelf;
                    [weakSelf.navigationController pushViewController:searchCon animated:YES];
                } andFaliureBlock:^(NSString *error, NSInteger code) {
                    weakSelf.branchBankArray = [weakSelf withString:error];
                    SearchInfoViewController *searchCon = [[SearchInfoViewController alloc]init];
                    searchCon.cardInfoarray = [weakSelf withString:error];
                    searchCon.keyName = @"sbname";
                    searchCon.delegate = weakSelf;
                    if (searchCon.cardInfoarray) {
                        [weakSelf.view rp_removeHudInManaual];
                        [weakSelf.navigationController pushViewController:searchCon animated:YES];
                    }else
                    {
                        [weakSelf netWorkErrorShow:@"没有查询到该城市的营业网点，建议您选择上一级城市分行营业部。"];
                    }
                    
                }];
                [request getBranchBancWith:_cNo with:self.bankNo with:self.bankNmame ];
                
            }
        }
    }
}

- (NSArray *)withString:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization  JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (array.count > 0) {
        NSDictionary *infoDict = array[0];
        if (infoDict[@"pname"]) {
            return array;
        }
    }
    return nil;
}


#pragma SearchViewDelegate
- (void)repackWithDiction:(NSDictionary *)dict
{
    if (_indexPath.row == 0) {
        
        _pName = dict[@"pname"];
        _pNo = dict[@"pno"];
        
    }else if(_indexPath.row == 1){
        
        _cName = dict[@"cname"];
        _cNo = dict[@"cno"];
        
    }else{
        
        _branchBankName = dict[@"sbname"];
        _longbranchBankName = dict[@"sbname"];
        NSRange range;
        range = [_branchBankName rangeOfString:@"公司"];
        
        if (range.location != NSNotFound) {
            _branchBankName = [_branchBankName substringFromIndex:range.location + range.length];
        }
        
        _branchNo = dict[@"sbno"];
        
    }
    
    [self.tableView reloadData];
    
}

- (UILabel *)cardInFoLable
{
    if (!_cardInFoLable) {
        _cardInFoLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 12, [UIScreen mainScreen].bounds.size.width, 14)];
        _cardInFoLable.text = @"";
        _cardInFoLable.textColor = [RedpacketColorStore flashColorWithRed:158  green:158  blue:158  alpha:1];
        _cardInFoLable.font = [UIFont systemFontOfSize:12.0];
    }
    return _cardInFoLable;
}

- (UILabel *)cardNumberLable
{
    if (!_cardNumberLable) {
        _cardNumberLable = [[UILabel alloc]initWithFrame:CGRectMake(95, 15, [UIScreen mainScreen].bounds.size.width - 95, 15)];
        _cardNumberLable.textColor = [RedpacketColorStore rp_colorWithHEX:0x9e9e9e];
        _cardNumberLable.font = [UIFont systemFontOfSize:14.0];
    }
    return _cardNumberLable;
}

@end
