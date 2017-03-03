//
//  RPRedpacketDetailHeaderView.m
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/10/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketDetailHeaderView.h"
#import "RPLayout.h"
#import "UIView+YZHExtension.h"
#import "RedpacketColorStore.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketTool.h"
#import "NSDictionary+YZHExtern.h"

@interface RPRedpacketDetailHeaderView ()

@property (nonatomic) UIImageView *headImageView;
@property (nonatomic) UILabel *detailLable;
@property (nonatomic) UIImageView *detailImageView;
@property (nonatomic) UILabel *greetingLable;
@property (nonatomic) UILabel *moneyLable;
@property (nonatomic) UILabel *noticeLable;

@end

@implementation RPRedpacketDetailHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    UIImageView *backImageView = [self rp_addsubview:[UIImageView class]];
    
    
    [backImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(0);
        make.left.equalTo(self.rpm_left).offset(0);
        make.right.equalTo(self.rpm_right).offset(0);
        make.height.offset(63);
    }];
    
    [backImageView setImage:rpRedpacketBundleImage(@"redpacket_RPRedpacketDetailHeaderView_header")];

    [self.headImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.centerY.equalTo(backImageView.rpm_bottom).offset(0);
        make.centerX.equalTo(self.rpm_centerX).offset(0);
        make.height.offset(57);
        make.width.offset(57);
    }];
    
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 28.5;
    
    [self.detailLable rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.headImageView.rpm_bottom).offset(10);
        make.centerX.equalTo(self.rpm_centerX).offset(-10);
    }];
    
    [self.detailImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.left.equalTo(self.detailLable.rpm_right).offset(2);
        make.centerY.equalTo(self.detailLable.rpm_centerY).offset(0);
    }];
    
    [self.greetingLable rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.detailLable.rpm_bottom).offset(5);
        make.left.equalTo(self.rpm_left).offset(15);
        make.right.equalTo(self.rpm_right).offset(-15);
    }];
}

- (void)setMessageModel:(RedpacketMessageModel *)messageModel
{
    _messageModel = messageModel;
   
    [self.headImageView rp_setImageWithURL:rpURL(messageModel.redpacketSender.userAvatar) placeholderImage:rpRedpacketBundleImage(@"redpacket_header")];
    self.detailLable.text = [NSString stringWithFormat:@"%@的红包",messageModel.redpacketSender.userNickname];
    self.greetingLable.text = messageModel.redpacket.redpacketGreeting;
    
    if ([messageModel.myAmount floatValue] > 0.009) {
        self.rp_height = 275;
        [self.moneyLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.headImageView.rpm_bottom).offset(76);
            make.left.equalTo(self.rpm_left).offset(0);
            make.width.equalTo(self.rpm_width).offset(0);
        }];
    
        [self.noticeLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.moneyLable.rpm_bottom).offset(15);
            make.left.equalTo(self.rpm_left).offset(0);
            make.width.equalTo(self.rpm_width).offset(0);
        }];
        self.moneyLable.text = [NSString stringWithFormat:@"￥%@",messageModel.myAmount];
    }else
    {
        self.rp_height = 185;
    }
    
    if (messageModel.redpacketType == RedpacketTypeRand) {
        self.detailImageView.hidden = NO;
        [self.detailImageView setImage:rpRedpacketBundleImage(@"redPackert_luckCard")];
    }else if (messageModel.redpacketType == RedpacketTypeMember){
        self.detailImageView.hidden = NO;
        [self.detailImageView setImage:rpRedpacketBundleImage(@"redPackert_toSomebody")];
    }else
    {
        self.detailImageView.hidden = YES;
    }
}

- (UIImageView *)headImageView
{
    if (!_headImageView) {
        _headImageView = [self rp_addsubview:[UIImageView class]];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImageView;
}

- (UILabel *)detailLable
{
    if (!_detailLable) {
        _detailLable = [self rp_addsubview:[UILabel class]];
        _detailLable.textColor = [RedpacketColorStore rp_textColorBlack];
        _detailLable.font = [UIFont systemFontOfSize:15];
        _detailLable.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLable;
}

- (UIImageView *)detailImageView
{
    if (!_detailImageView) {
        _detailImageView = [self rp_addsubview:[UIImageView class]];
        
    }
    return _detailImageView;
}

- (UILabel *)greetingLable
{
    if (!_greetingLable) {
        _greetingLable = [self rp_addsubview:[UILabel class]];
        _greetingLable.font = [UIFont systemFontOfSize:12.0f];
        _greetingLable.textColor = [RedpacketColorStore rp_textColorGray];
        _greetingLable.textAlignment = NSTextAlignmentCenter;
        _greetingLable.numberOfLines = 0;
        
    }
    return _greetingLable;
}

- (UILabel *)moneyLable
{
    if (!_moneyLable) {
        _moneyLable = [self rp_addsubview:[UILabel class]];
        _moneyLable.font = [UIFont systemFontOfSize:45.0f];
        _moneyLable.textColor = [RedpacketColorStore rp_textColorBlack];
        _moneyLable.textAlignment = NSTextAlignmentCenter;
    }
    return _moneyLable;
}

- (UILabel *)noticeLable
{
    if (!_noticeLable) {
        _noticeLable = [self rp_addsubview:[UILabel class]];
        _noticeLable.font = [UIFont systemFontOfSize:12];
        _noticeLable.textColor = [RedpacketColorStore rp_textColorGray];
        _noticeLable.textAlignment = NSTextAlignmentCenter;
        NSString *prompt = @"已存入零钱，可用于发红包或提现";
        
#ifdef AliAuthPay
        
        prompt = @"已入账至绑定的支付宝账户";
        
#endif
        
        _noticeLable.text = prompt;
    }
    return _noticeLable;
}

@end
