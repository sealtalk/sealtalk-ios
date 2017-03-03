//
//  MybankCellTableViewCell.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/6/3.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "MybankCellTableViewCell.h"
#import "RedpacketColorStore.h"


@implementation MybankCellTableViewCell
{
    UILabel *_onceMoneyLable, *_dayMoneyLable;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubViews];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)loadSubViews
{
    [self addSubview:self.backImageView];
    [self.backImageView addSubview:self.bankNameLable];
    [self.backImageView addSubview:self.bankTypeLable];
    [self.backImageView addSubview:self.cardTypeLable];
    [self.backImageView addSubview:self.bankNoLable];
}

- (void)addfooterViewWithOnceMoney:(NSString *)onceMoney withDayMoney:(NSString *)dayMoney;
{
    [self addSubview:self.footterView];
    _dayMoneyLable.text = [NSString stringWithFormat:@"%@元",dayMoney];
    _onceMoneyLable.text =[NSString stringWithFormat:@"%@元",onceMoney];
}

- (void)delFooterView
{
    [_footterView removeFromSuperview];
}

- (UIView *)footterView
{
    if (!_footterView) {
        _footterView = [[UIView alloc]initWithFrame:CGRectMake(0, 125, [UIScreen mainScreen].bounds.size.width, 160)];
        UILabel *onceLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 30, [UIScreen mainScreen].bounds.size.width, 13)];
        onceLable.text = @"单笔支付限额";
        onceLable.font = [UIFont systemFontOfSize:12.0];
        onceLable.textColor = [RedpacketColorStore rp_textColorBlack6];
        [_footterView addSubview:onceLable];
        
        _onceMoneyLable = [[UILabel alloc]initWithFrame:CGRectMake(0, onceLable.frame.origin.y, [UIScreen mainScreen].bounds.size.width - 15, 13)];
        _onceMoneyLable.textAlignment = NSTextAlignmentRight;
        _onceMoneyLable.font = [UIFont systemFontOfSize:12.0];
        _onceMoneyLable.textColor = [RedpacketColorStore rp_textColorBlack6];
        [_footterView addSubview:_onceMoneyLable];
        
        UIView *rimLine = [[UIView alloc]initWithFrame:CGRectMake(15, _onceMoneyLable.frame.origin.y + 13 + 8, [UIScreen mainScreen].bounds.size.width - 30, .5)];
        rimLine.backgroundColor = [RedpacketColorStore rp_textColorLightGray];
        [_footterView addSubview:rimLine];
        
        UILabel *dayLable = [[UILabel alloc]initWithFrame:CGRectMake(15, rimLine.frame.origin.y + .5 + 8, [UIScreen mainScreen].bounds.size.width, 13)];
        dayLable.text = @"单日支付限额";
        dayLable.font = [UIFont systemFontOfSize:12.0];
        dayLable.textColor = [RedpacketColorStore rp_textColorBlack6];
        [_footterView addSubview:dayLable];
        
        _dayMoneyLable = [[UILabel alloc]initWithFrame:CGRectMake(0, dayLable.frame.origin.y, [UIScreen mainScreen].bounds.size.width - 15, 13)];
//        dayMoneyLable.text = [NSString stringWithFormat:@"%@元",dayMoney];
        _dayMoneyLable.textAlignment = NSTextAlignmentRight;
        _dayMoneyLable.font = [UIFont systemFontOfSize:12.0];
        _dayMoneyLable.textColor = [RedpacketColorStore rp_textColorBlack6];
        [_footterView addSubview:_dayMoneyLable];
        
        UIButton *delBankcardBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, _dayMoneyLable.frame.origin.y + 13 + 30, [UIScreen mainScreen].bounds.size.width - 30, 44)];
        
        [delBankcardBtn setTitle:@"移除银行卡" forState:UIControlStateNormal];
        delBankcardBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [delBankcardBtn setTitleColor:[RedpacketColorStore rp_textColorRed] forState:UIControlStateNormal];
        [delBankcardBtn setTitleColor:[RedpacketColorStore rp_textColorGray] forState:UIControlStateHighlighted];
        delBankcardBtn.layer.cornerRadius = 5.0;
        delBankcardBtn.layer.borderWidth = .5;
        delBankcardBtn.layer.borderColor = [RedpacketColorStore rp_textColorLightGray].CGColor;
        delBankcardBtn.layer.masksToBounds = YES;
        [delBankcardBtn addTarget:self action:@selector(clickdelBankcardBtn) forControlEvents:UIControlEventTouchUpInside];
        [_footterView addSubview:delBankcardBtn];

    }
    return _footterView;
}

- (void)clickdelBankcardBtn
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定要解除这张银行卡吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        if (_selectionBlockDel) {
            _selectionBlockDel();
        }
    }
}

- (UIImageView *)backImageView
{
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width - 20,125)];
        _backImageView.layer.cornerRadius     = 5.0f;
        _backImageView.layer.masksToBounds    = YES;
    }
    return _backImageView;
}

- (UILabel *)bankNameLable
{
    if (!_bankNameLable) {
        _bankNameLable = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, [UIScreen mainScreen].bounds.size.width ,17)];
        _bankNameLable.textColor = [UIColor whiteColor];
        _bankNameLable.text = @"中国工商银行";
    }
    return _bankNameLable;
}

- (UILabel *)bankTypeLable
{
    if (!_bankTypeLable) {
        _bankTypeLable = [[UILabel alloc]initWithFrame:CGRectMake(20, 44, _backImageView.bounds.size.width, 13)];
        _bankTypeLable.textColor = [UIColor whiteColor];
        _bankTypeLable.text = @"借记卡";
        _bankTypeLable.font = [UIFont systemFontOfSize:13.0];
    }
    return _bankTypeLable;
}

- (UILabel *)cardTypeLable
{
    if (!_cardTypeLable) {
        _cardTypeLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 24, _backImageView.bounds.size.width - 20, 13)];
        _cardTypeLable.textAlignment = NSTextAlignmentRight;
        _cardTypeLable.text = @"支付卡";
        _cardTypeLable.textColor = [UIColor whiteColor];
        _cardTypeLable.alpha = .85;
        _cardTypeLable.font = [UIFont systemFontOfSize:13.0];
    }
    return _cardTypeLable;
}

- (UILabel *)bankNoLable
{
    if (!_bankNoLable) {
        _bankNoLable = [[UILabel alloc]initWithFrame:CGRectMake(20, 85, _backImageView.bounds.size.width, 20)];
        _bankNoLable.text = @"**** **** **** 7926";
        _bankNoLable.font = [UIFont systemFontOfSize:27];
        _bankNoLable.textColor = [UIColor whiteColor];
    }
    return _bankNoLable;
}
@end
