//
//  RPReceiptsViewController.m
//  RedpacketLib
//
//  Created by 都基鹏 on 2016/12/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPReceiptsInAlipayViewController.h"
#import "RPReceiotsInAlipayHeaderView.h"
#import "RPReceiotsInAlipayEmptyTableViewCell.h"
#import "RPAlipayAuth.h"
#import "YZHRedpacketBridge.h"
#import "YZHRedpacketBridge+Private.h"
#import "RedpacketErrorView.h"
#import "RPRedpacketSetting.h"
#import "RPServerSelectionViewController.h"
#import "YZHRedpacketBridge.h"
@interface RPReceiptsInAlipayViewController ()<RPReceiotsInAlipayHeaderViewDelegate>
@property (nonatomic,copy)NSString * username;
@property (nonatomic,weak)RedpacketErrorView * retryViw;
@end

@implementation RPReceiptsInAlipayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self removebindingAliauth:NO];
    [self addCloseBarButtonItem];
    [self.tableView registerClass:[RPReceiotsInAlipayEmptyTableViewCell class] forCellReuseIdentifier:@"RPReceiotsInAlipayEmptyTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([YZHRedpacketBridge sharedBridge].customswitch) {
        UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btn_right, nil];
    }
}

- (void)removebindingAliauth:(BOOL)removeBinding {
    
    rpWeakSelf;
    [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken:^(NSInteger code, NSString *msg) {
        if (code == 0) {
            [weakSelf.retryViw removeFromSuperview];
            [RPRedpacketSetting asyncRequestRedpacketSettings:^{
                [weakSelf refreshTitle];
            }];
            
            [weakSelf requestRedpacketGetDetail];
            RedpacketDataRequester * request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
                [weakSelf.view rp_removeHudInManaual];
                NSString * username = [data rp_stringForKey:@"Username"];
                weakSelf.username = username;
                [weakSelf.tableView reloadData];
                
            } andFaliureBlock:^(NSString *error, NSInteger code) {
                [weakSelf.view rp_showHudErrorView:error];
            }];
            [request requestWithBindingAli:!removeBinding];
        }else {
            [weakSelf LoadretryView];
            [weakSelf.view rp_showHudErrorView:msg];
        }
    }];
}

- (void)refreshTitle {
    self.subLable.text = [NSString stringWithFormat:@"%@红包服务", [RPRedpacketSetting shareInstance].redpacketOrgName];
    [self.tableView reloadData];
}

- (void)LoadretryView {
    rpWeakSelf;
    RedpacketErrorView * retryViw = [RedpacketErrorView new];
    self.retryViw = retryViw;
    [retryViw setButtonClickBlock:^{
        [weakSelf removebindingAliauth:NO];
    }];
    [self.view addSubview:self.retryViw];
    self.retryViw.frame = self.view.bounds;
}

- (void)addCloseBarButtonItem {
    if (self.navigationController.viewControllers.count == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [button setTitleColor:[RedpacketColorStore rp_textcolorYellow] forState:UIControlStateNormal];
        [button setTitle:@"关闭" forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(closeBarButtonSender) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return section?(self.isSend?self.dataArray.count:(self.dataArray.count?:1)):1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return indexPath.section?58.0f:(self.isSend?282:(self.username.length?344:373));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section) {
        if (self.dataArray.count) {
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }else {
            return [tableView dequeueReusableCellWithIdentifier:@"RPReceiotsInAlipayEmptyTableViewCell"];
        }
    }else {
        RPReceiotsInAlipayHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:@"RPReceiotsInAlipayHeaderView"];
        if (!cell) {
            cell = [[RPReceiotsInAlipayHeaderView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RPReceiotsInAlipayHeaderView"];
        }
        cell.isSend = self.isSend;
        cell.delegate = self;
        cell.incomeHeaderDic = self.responseData;
        cell.username = self.username;
        return cell;
    }
}

- (void)requestRedpacketGetDetailReplacer{}

- (void)doAlipayAuth {
    static RPAlipayAuth *staticAuth = nil;
    staticAuth = [RPAlipayAuth new];
    rpWeakSelf;
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    [staticAuth doAlipayAuth:^(BOOL isSuccess, NSString *error) {
        staticAuth = nil;
        [weakSelf.view rp_removeHudInManaual];
        if (isSuccess) {
            [[[UIAlertView alloc] initWithTitle:@"提示"
                                       message:@"已成功绑定支付宝账号，以后红包收到的钱会自动入账到此支付宝账号。"
                                      delegate:nil
                             cancelButtonTitle:@"我知道了"
                             otherButtonTitles:nil] show];
            [weakSelf removebindingAliauth:NO];
            
        }else {
            [weakSelf.view rp_showHudErrorView:error];
        }
    }];
}

- (void)removeBinding {
    [self removebindingAliauth:YES];
}

@end

