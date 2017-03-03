//
//  RPReceiveAmountRedpacketPreView.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPReceiveAmountRedpacketPreView.h"
#import "RPLayout.h"
#import "RedpacketColorStore.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketTool.h"
#import "UIView+YZHExtension.h"

@interface RPReceiveAmountRedpacketPreView()

@property (nonatomic, strong) UILabel       *nameLable;
@property (nonatomic, strong) UILabel       *describeLable;
@property (nonatomic, strong) UILabel       *moneyLabel;
@property (nonatomic, strong) UILabel       *statusLabel;
@end

@implementation RPReceiveAmountRedpacketPreView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self.backgroundImageView setImage:rpRedpacketBundleImage(@"amount_bg")];
        self.nameLable = [self rp_addsubview:[UILabel class]];
        self.nameLable.font = [UIFont systemFontOfSize:13];
        self.nameLable.textAlignment = NSTextAlignmentCenter;
        self.nameLable.textColor = [UIColor whiteColor];
        self.nameLable.numberOfLines = 1;
        [self.nameLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.rpm_bottom).offset(RP_(@(10),@(13),@(13)).floatValue);
            make.centerX.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        
        self.describeLable = [self rp_addsubview:[UILabel class]];
        self.describeLable.font = [UIFont systemFontOfSize:RP_(@(16),@(22),@(22)).floatValue];
        self.describeLable.textAlignment = NSTextAlignmentCenter;
        self.describeLable.textColor = [RedpacketColorStore rp_textcolorYellow];
        self.describeLable.numberOfLines = 1;
        [self.describeLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.nameLable.rpm_bottom).offset(RP_(@(36),@(44),@(44)).floatValue);
            make.centerX.equalTo(self);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
        }];
        
        self.moneyLabel = [self rp_addsubview:[UILabel class]];
        self.moneyLabel.font = [UIFont systemFontOfSize:RP_(@(36),@(45),@(45)).floatValue];
        self.moneyLabel.textAlignment = NSTextAlignmentCenter;
        self.moneyLabel.textColor = [RedpacketColorStore rp_textcolorYellow];
        self.moneyLabel.numberOfLines = 1;
        [self.moneyLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.describeLable.rpm_bottom).offset(RP_(@(8),@(14),@(14)).floatValue);
            make.centerX.equalTo(self);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
        }];
        
        
        self.statusLabel = [self rp_addsubview:[UILabel class]];
        self.statusLabel.font = [UIFont systemFontOfSize:RP_(@(11),@(13),@(13)).floatValue];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.textColor = [RedpacketColorStore rp_textcolorYellow];
        self.statusLabel.numberOfLines = 1;
        [self.statusLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.moneyLabel.rpm_bottom).offset(RP_(@(12),@(18),@(18)).floatValue);
            make.centerX.equalTo(self);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
        }];
        self.submitButton.hidden = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}
- (void)setMessageModel:(RedpacketMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    
    self.nameLable.text = [NSString stringWithFormat:@"给 %@ 的红包",messageModel.redpacketReceiver.userNickname];
    self.describeLable.text = messageModel.redpacket.redpacketGreeting;
    self.moneyLabel.text = [NSString stringWithFormat:@"￥ %@",messageModel.redpacket.redpacketMoney];
    BOOL isSender = messageModel.isRedacketSender;
    
    NSString *prompt = @"成功领取，已存入零钱";
    
#ifdef AliAuthPay
    
    prompt = @"成功领取，已入账至绑定的支付宝账户";
    
#endif

    switch (messageModel.redpacketStatusType) {
        case RedpacketStatusTypeCanGrab:
            if (isSender) {
                self.statusLabel.text = @"等待对方领取";
            } else {
                self.statusLabel.text = prompt;
            }
            break;
        case RedpacketStatusTypeGrabFinish:
            if (isSender) {
                self.statusLabel.text = @"红包已被对方领取";
            } else {
                self.statusLabel.text = prompt;
            }
            break;
        case RedpacketStatusTypeOutDate:
            self.statusLabel.text = @"红包已过期";
            break;
        default:
            break;
    }

}
@end
