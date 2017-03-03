//
//  MyInComeRedPacketViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "MyInComeRedPacketViewController.h"
#import "RPMyInComeHeaderView.h"
#import "RPMyIncomeRedPacketCell.h"
#import "YZHRedpacketBridge.h"
#import "UIView+YZHPrompting.h"
#import "NSDictionary+YZHExtern.h"
#import "RedpacketColorStore.h"
#import "RedpacketDataRequester.h"
#import "NSDictionary+YZHExtern.h"
#import "RedpacketErrorView.h"
#import "NSBundle+RedpacketBundle.h"


static NSInteger pageSize = 12;

@interface MyInComeRedPacketViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) RedpacketErrorView *retryViw;

@end

@implementation MyInComeRedPacketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLable.text           = @"收到的红包";
    self.view.backgroundColor      = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[RPMyIncomeRedPacketCell class] forCellReuseIdentifier:@"RPMyIncomeRedPacketCell"];
    [self.tableView registerClass:[RPMyIncomeHeaderView class] forCellReuseIdentifier:@"RPMyIncomeHeaderView"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showTableBlankView        = YES;
    [self requestRedpacketGetDetailReplacer];
    self.isSend = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavgationBarBackgroundColor:[RedpacketColorStore rp_textColorRed]
                              titleColor:[RedpacketColorStore rp_textcolorYellow]
                         leftButtonTitle:nil
                        rightButtonTitle:@"我的红包"];
}

- (void)addCloseBarButtonItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [button setTitleColor:rp_hexColor(0x35b7f3) forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(closeBarButtonSender) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)closeBarButtonSender
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)clickButtonRight
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"收到的红包",@"发出的红包", nil];
    [actionSheet showInView:self.view ];
}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        self.titleLable.text = buttonIndex?@"发出的红包":@"收到的红包";
        self.isSend = buttonIndex;
        self.dataArray = nil;
        [self.tableView reloadData];
        [self requestRedpacketGetDetail];
    }
}

- (void)requestRedpacketGetDetailReplacer
{
    [self requestRedpacketGetDetail];
}

- (void)requestRedpacketGetDetail
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        [weakSelf.view rp_removeHudInManaual];
        [weakSelf.retryViw removeFromSuperview];
        weakSelf.responseData = data;
        NSArray * array = [data rp_arrayForKey:@"List"];
        [weakSelf handleHistoryArray:array];
        [weakSelf tableViewDidFinishTriggerHeader:NO reload:YES];
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        if (code == NSIntegerMax) {
            if (self.dataArray.count < 1) {
                [weakSelf.view rp_removeHudInManaual];
                [self LoadretryView];
            }else{
                [weakSelf.view rp_showHudErrorView:error];
            }
        }else {
            [weakSelf.view rp_showHudErrorView:error];
        }
    }];
    if (weakSelf.isSend) {
        [request requestInComeMoneySenderDetailOffset:self.dataArray.count];
    } else {
        [request requestInComeMoneyDetailOffset:self.dataArray.count];
    }
}

- (void)handleHistoryArray:(NSArray *)array
{
    if (array.count == 0) {
        return;
    }
    
    if (array.count >= pageSize) {
        self.showRefreshFooter = YES;
    }else {
        self.showRefreshFooter = NO;
    }
    
    [self.dataArray addObjectsFromArray:array];
    
    [self.tableView reloadData];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section) {
        return self.dataArray.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section) {
        return 58.0f;
    }
    
    return self.isSend?282:324;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section) {
        RPMyIncomeRedPacketCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RPMyIncomeRedPacketCell" forIndexPath:indexPath];
        cell.isSend = self.isSend;
        NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
        cell.incomeCellData = dic;
        return cell;
    }else {
        RPMyIncomeHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:@"RPMyIncomeHeaderView" forIndexPath:indexPath];
        cell.isSend = self.isSend;
        cell.incomeHeaderDic = self.responseData;
        return cell;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self requestRedpacketGetDetail];
}

#pragma mark - other

- (RedpacketErrorView *)retryViw
{
    rpWeakSelf;
    if (!_retryViw) {
        _retryViw = [RedpacketErrorView viewWithWith:self.view.bounds.size.width];
        [_retryViw setButtonClickBlock:^{
            [weakSelf requestRedpacketGetDetail];
        }];
    }
    return _retryViw;
}

- (void)LoadretryView
{
    [self.view insertSubview:self.retryViw aboveSubview:self.tableView];
    self.retryViw.frame = self.view.bounds;
}

@end

