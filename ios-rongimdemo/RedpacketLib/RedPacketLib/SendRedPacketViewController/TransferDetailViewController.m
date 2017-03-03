//
//  TransferDetailViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/8/25.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "TransferDetailViewController.h"
#import "RedpacketColorStore.h"
#import "ChangePurseViewController.h"

@interface TransferDetailViewController ()

@end

@implementation TransferDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLable.text = @"转账详情";
    self.cuttingLineHidden = YES;
    self.view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    [self loadSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.barStyle       = UIBarStyleDefault;
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:@"关闭" rightButtonTitle:@""];
}

- (void)clickButtonLeft
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadSubViews
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.rp_width * .5 - 61 * .5, 50, 62, 62)];
    [imageView setImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redPacket_transferSucessful"]];
    [self.view addSubview:imageView];
    
    UILabel *successLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.rp_bottom + 14, self.view.rp_width, 16)];
    successLabel.text = @"交易成功";
    successLabel.font = [UIFont systemFontOfSize:16];
    successLabel.textAlignment = NSTextAlignmentCenter;
    successLabel.textColor = [RedpacketColorStore rp_textColorBlack];
    [self.view addSubview:successLabel];
    
    UILabel *moneyLable = [[UILabel alloc]initWithFrame:CGRectMake(0, successLabel.rp_bottom + 18, self.view.rp_width, 37)];
    if (self.model.isRedacketSender) {
        moneyLable.text = [NSString stringWithFormat:@"-%@",self.model.redpacket.redpacketMoney];
    }else
    {
        moneyLable.text = [NSString stringWithFormat:@"+%@",self.model.redpacket.redpacketMoney];
    }
    moneyLable.font = [UIFont systemFontOfSize:37];
    moneyLable.textAlignment = NSTextAlignmentCenter;
    moneyLable.textColor = [RedpacketColorStore rp_textColorBlack];
    [self.view addSubview:moneyLable];
    
    UILabel *noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, moneyLable.rp_bottom + 18, self.view.rp_width *.5, 14)];
    NSString *prompt = @"已存入零钱，可用于发红包或提现";
    
#ifdef AliAuthPay
    
    prompt = @"已入账至绑定的支付宝账户";
    
#endif
    noticeLabel.text = prompt;
    noticeLabel.textAlignment = NSTextAlignmentRight;
    noticeLabel.textColor = [RedpacketColorStore rp_textColorGray];
    noticeLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:noticeLabel];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(noticeLabel.rp_right - 2, noticeLabel.rp_top,67, 14)];
    [btn setTitle:@"查看零钱" forState:UIControlStateNormal];
    [btn setTitleColor:[RedpacketColorStore rp_blueButtonNormalColor] forState:UIControlStateNormal];
    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:self action:@selector(clickViewBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    if (self.model.isRedacketSender) {
        noticeLabel.alpha = 0;
        btn.alpha = 0;
    }else
    {
        noticeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraints:@[
                                    [NSLayoutConstraint constraintWithItem:noticeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:moneyLable.rp_bottom + 18],
                                    [NSLayoutConstraint constraintWithItem:noticeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:14],
                                    [NSLayoutConstraint constraintWithItem:noticeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:.5 constant:0],
                                    [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:noticeLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                    [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:noticeLabel attribute:NSLayoutAttributeRight multiplier:1 constant:0]
                                    ]
         ];
        
    }
    
    UILabel *bottomLable = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.rp_bottom - 100, self.view.rp_width, 12)];
    bottomLable.text = [NSString stringWithFormat:@"转账时间：%@",self.model.redpacket.tranferTime];
    bottomLable.font = [UIFont systemFontOfSize:12.0];
    bottomLable.textColor = [RedpacketColorStore rp_textColorGray];
    bottomLable.textAlignment  = NSTextAlignmentCenter;
    [self.view addSubview:bottomLable];
}

- (void)clickViewBtn
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    ChangePurseViewController *changeViewctr = [[ChangePurseViewController alloc] init];
    [self.navigationController pushViewController:changeViewctr animated:YES];
}

@end
