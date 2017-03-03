//
//  RedPacketDetailViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedPacketDetailViewController.h"
#import "RedpacketDetailCell.h"
#import "RedpacketColorStore.h"
#import "MyInComeRedPacketViewController.h"
#import "UIImageView+YZHWebCache.h"
#import "YZHRedpacketBridge.h"
#import "NSDictionary+YZHExtern.h"
#import "RPRedpacketTool.h"
#import "RPRedpacketSetting.h"
#import "RedpacketDataRequester.h"
#import "RPRedpacketDetailHeaderView.h"
#import "RedPacketInfoModel.h"
#import "RPReceiptsInAlipayViewController.h"


@interface RedPacketDetailViewController ()

@property (nonatomic, strong) RPRedpacketDetailHeaderView *headerView;
@property (nonatomic, strong) UILabel *describeLabel;
@property (nonatomic, strong) RedPacketInfoModel *infoModel;


@end

@implementation RedPacketDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLable.text = @"红包";
    self.cuttingLineHidden = YES;
    [self addCloseBarButtonItem];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset  = UIEdgeInsetsZero;
    self.tableView.tableHeaderView = self.headerView;
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 22)];
    footer.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = footer;
    [self loadSettingContent];
    [self clearBackBarButtonItemTitle];
    
    [self loadDetail];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self loadDetail];
}
    
- (void)loadSettingContent
{
    rpWeakSelf;
    [RPRedpacketSetting asyncRequestRedpacketSettings:^{
        [weakSelf refreshTitle];
    }];
}

- (void)refreshTitle
{
    self.subLable.text = [NSString stringWithFormat:@"%@红包服务", [RPRedpacketSetting shareInstance].redpacketOrgName];
}

- (void)setMessageModel:(RedpacketMessageModel *)messageModel
{
    _messageModel = messageModel;
    self.headerView.messageModel = messageModel;
    [self configWithRedpacketDetailDic:messageModel.redpacketDetailDic];
}

- (void)loadDetail
{
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
        weakSelf.messageModel.redpacketDetailDic = dict;
        [weakSelf configWithRedpacketDetailDic:dict];
        [weakSelf refreshTableContent:dict];
        [weakSelf tableViewDidFinishTriggerHeader:NO reload:NO];
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        
    }];
    //ID=46677909661&Offset=192&Length=12&UserId=max66
    NSString *firstUserId = [[_infoModel.recipientsGroup firstObject] objectForKey:@"userid"];
    [request requestRedpacketDetail:_messageModel.redpacketId
                         pageOffset:_infoModel.recipientsGroup.count
                     andFirstUserId:firstUserId];
}

    - (void)refreshTableContent:(NSDictionary *)dict
    {
        NSDictionary *Recipients = [dict rp_dictionaryForKey:@"RecipientsGroup"];
        NSArray *array = [Recipients valueForKey:@"List"];
        
        self.showRefreshFooter = array.count == 20 ? YES : NO;
        
        if (array.count) {
            [_infoModel.recipientsGroup addObjectsFromArray:array];
            [self.tableView reloadData];
        }
    }

    
- (void)configWithRedpacketDetailDic:(NSDictionary *)redpacketDic
{
    NSString *prompt = [NSString stringWithFormat:@"超过1天未被领取，金额%@元已退至您的零钱",_messageModel.redpacket.redpacketMoney];
    
#ifdef AliAuthPay
    
    prompt = [NSString stringWithFormat:@"超过1天未被领取，金额%@元已退至您的支付宝账号",_messageModel.redpacket.redpacketMoney];
    
#endif
    if (!_infoModel) {
        _infoModel = [RedPacketInfoModel initWithDict:redpacketDic];
    }
    
    [_infoModel refreshWithDict:redpacketDic];
    
    if (_messageModel.redpacketStatusType == RedpacketStatusTypeOutDate && _messageModel.isRedacketSender && !_infoModel.isGetFinish) {
        if (_messageModel.redpacketType == RedpacketTypeSingle) {
            self.describeLabel.text = prompt;
        } else {
            self.describeLabel.text = [NSString  stringWithFormat:@"该红包已过期，已领取%@/%@个，共%@/%@元",_infoModel.taken,_infoModel.total,_infoModel.takenAmmount,_messageModel.redpacket.redpacketMoney];
        }
    }else if(!_infoModel.isInfoDict) {
        self.describeLabel.text = @"";
    }else if(_messageModel.isRedacketSender) {
        if (_messageModel.redpacketType == RedpacketTypeSingle) {
            if (_infoModel.isGetFinish) {
                self.describeLabel.text = [NSString stringWithFormat:@"%@个红包，共%@元，已被对方领取",  _infoModel.total,_messageModel.redpacket.redpacketMoney];
            }else {
                self.describeLabel.text = [NSString stringWithFormat:@"红包金额%@元，等待被领取", _messageModel.redpacket.redpacketMoney];
            }
        }else {
            if (_infoModel.isGetFinish) {
                self.describeLabel.text = [NSString stringWithFormat:@"%@个红包共%@元， %@被抢光",_infoModel.total,_messageModel.redpacket.redpacketMoney, _infoModel.timeLength];
            }else {
                self.describeLabel.text = [NSString stringWithFormat:@"已领取%@/%@个，共%@/%@元", _infoModel.taken, _infoModel.total ,_infoModel.takenAmmount, _messageModel.redpacket.redpacketMoney];
            }
        }
    }else {
        if (_messageModel.redpacketType == RedpacketTypeAvg || _messageModel.redpacketType == RedpacketTypeSingle) {
            self.describeLabel.text = @"";
        }else {
            if (_infoModel.isGetFinish) {
                self.describeLabel.text = [NSString stringWithFormat:@"%@个红包，%@被抢光",_infoModel.total, _infoModel.timeLength];
            }else
            {
                self.describeLabel.text = [NSString stringWithFormat:@"领取%@/%@个",_infoModel.taken,_infoModel.total ];
            }
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - TabelViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        self.view.backgroundColor = [RedpacketColorStore rp_textColorRed];
        
    }else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (UILabel *)describeLabel
{
    if (!_describeLabel) {
        _describeLabel                 = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, 260, 20)];
        _describeLabel.backgroundColor = [UIColor clearColor];
        _describeLabel.font            = [UIFont systemFontOfSize:12.0f];
        _describeLabel.textColor       = [RedpacketColorStore rp_textColorGray];
    }
    
    return _describeLabel;
}

#pragma mark - TableViewDelegate

static CGFloat rp_cellheight = 58.0f;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    //CGFloat onePix       = 1 / [UIScreen mainScreen].scale;
    if (_messageModel.redpacketType == RedpacketTypeRand || _messageModel.isRedacketSender) {
        [view addSubview:self.describeLabel];
        view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    }else{
        view.backgroundColor = [UIColor whiteColor];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [self footerHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGFloat height = [self footerHeight];
    UIView *view           = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height)];
    view.backgroundColor   = [UIColor whiteColor];
    if ([_messageModel.myAmount floatValue]> 0.009) {
        UIButton *button       = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"查看我的红包记录" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [button setTitleColor:[RedpacketColorStore rp_textColorBlue] forState:UIControlStateNormal];
        button.frame           = CGRectMake(0, height - 40, CGRectGetWidth(self.view.frame), 20);
        [button addTarget:self action:@selector(myRedPacketDetailButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    return view;
}

- (CGFloat)footerHeight
{
    NSInteger number ;
    CGFloat headerHeight;

    if (_messageModel.isRedacketSender || _messageModel.redpacketType == RedpacketTypeRand) {
        number = [_infoModel.recipientsGroup count];
    }else {
        number = 0;
    }
    if ([_messageModel.myAmount floatValue]> 0.009) {
        headerHeight = 275;
    }else {
        headerHeight = 185;
    }
    CGFloat height = CGRectGetHeight(self.view.frame) - number * rp_cellheight  - headerHeight - 64;
    height = height > 0 ? height : 0.01;
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((_messageModel.redpacketType != RedpacketTypeRand)&& (!_messageModel.isRedacketSender))
    {
        return 0;
    }
    return _infoModel.recipientsGroup.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rp_cellheight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RedpacketDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RedpacketDetailCellIdentifier"];
    if (!cell) {
        cell = [[RedpacketDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RedpacketDetailCellIdentifier"];
    }
    if (_infoModel.recipientsGroup.count > indexPath.row) {
        NSDictionary *currentUser = [_infoModel.recipientsGroup objectAtIndex:indexPath.row];
        cell.detailCellData = currentUser;
    }
    return cell;
}

- (void)myRedPacketDetailButtonClick
{
    MyInComeRedPacketViewController *myIncome;
#ifdef AliAuthPay
    myIncome = [[RPReceiptsInAlipayViewController alloc] initWithStyle:UITableViewStyleGrouped];
#else
    myIncome = [[MyInComeRedPacketViewController alloc] initWithStyle:UITableViewStyleGrouped];
#endif
    
    myIncome.messageModel = self.messageModel;
    
    [self.navigationController pushViewController:myIncome animated:YES];
}

#pragma mark - HeaderView

- (RPRedpacketDetailHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[RPRedpacketDetailHeaderView alloc] init];
    }
    return _headerView;
}

- (void)addCloseBarButtonItem
{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barStyle       = UIBarStyleBlack;
    [self setNavgationBarBackgroundColor:[RedpacketColorStore rp_textColorRed] titleColor:[RedpacketColorStore rp_textcolorYellow] leftButtonTitle:@"关闭" rightButtonTitle:nil];
}

- (void)clickButtonLeft
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearBackBarButtonItemTitle
{
    //  左侧返回标题为空
    UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
    returnButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = returnButtonItem;
}

@end
