//
//  RPRedpacketPreView.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketPreView.h"
#import "RPLayout.h"
#import "RedpacketColorStore.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketTool.h"
#import "UIView+YZHExtension.h"
#import "RPNormalRedpacketPreView.h"
#import "RPMemberRedpacketPreView.h"
#import "RPSendAmountRedpacketPreView.h"
#import "RPReceiveAmountRedpacketPreView.h"
#import "RPRedpacketSetting.h"
#import "UIButton+RPAction.h"

@implementation RPRedpacketPreView

+ (instancetype)preViewWithBoxStatusType:(RedpacketBoxStatusType)boxStatusType {
    return [[self alloc] initWithRedpacketBoxStatusType:boxStatusType];
}
- (instancetype)initWithRedpacketBoxStatusType:(RedpacketBoxStatusType)boxStatusType {
    
    switch (boxStatusType) {
        case RedpacketBoxStatusTypeAvgRobbed:
        case RedpacketBoxStatusTypeRandRobbing:
        case RedpacketBoxStatusTypeRobbing:
        case RedpacketBoxStatusTypePoint:
        case RedpacketBoxStatusTypeAvgRobbing:
        case RedpacketBoxStatusTypeOverdue: {
            self = [[RPNormalRedpacketPreView alloc] init];
            break;
        }
        case RedpacketBoxStatusTypeMember: {
            self = [[RPMemberRedpacketPreView alloc]init];
            break;
        }
        case RedpacketBoxStatusTypeSendAmount: {
            self = [[RPSendAmountRedpacketPreView alloc]init];
            break;
        }
        case RedpacketBoxStatusTypeReceiveAmount: {
            self = [[RPReceiveAmountRedpacketPreView alloc]init];
            break;
        }
        default:{
            self = [[RPNormalRedpacketPreView alloc] init];
            break;
        }
    }
    
    if (self) {
        self.boxStatusType = boxStatusType;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.backgroundImageView = [self rp_addsubview:[UIImageView class]];
        NSString *urlstr = [RPRedpacketSetting shareInstance].redpacketBackImageURL;
        if (urlstr.length > 0) {
            [self.backgroundImageView rp_setImageWithURL:[NSURL URLWithString:urlstr]
                                        placeholderImage:rpRedpacketBundleImage(@"redpacket_background")];
        }else {
            [self.backgroundImageView setImage:rpRedpacketBundleImage(@"redpacket_background")];
        }
        [self.backgroundImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.avatarImageView = [self rp_addsubview:[UIImageView class]];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.avatarImageView.layer.cornerRadius = RP_(@(60),@(78),@(78)).floatValue / 2.0f;
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.borderWidth = 5.0;
        self.avatarImageView.layer.borderColor = [RedpacketColorStore rp_textcolorYellow].CGColor;
        [self.avatarImageView setImage:rpRedpacketBundleImage(@"redpacket_header")];
        [self.avatarImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.rpm_top).offset(RP_(@(52),@(66),@(66)).floatValue);
            make.centerX.equalTo(self);
            make.size.sizeOffset(CGSizeMake(RP_(@(60),@(78),@(78)).floatValue,RP_(@(60),@(78),@(78)).floatValue));
        }];
        
        self.closeButton = [self rp_addsubview:[UIButton class]];
        [self.closeButton setImage:rpRedpacketBundleImage(@"payView_close_high") forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        self.closeButton.rp_hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -40, -40);
        [self.closeButton rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.rpm_top).offset(14);
            make.left.equalTo(self).offset(14);
            make.size.sizeOffset(CGSizeMake(18,18));
        }];
        
        
        self.submitButton = [self rp_addsubview:[UIButton class]];
        self.submitButton.layer.cornerRadius = RP_(@(16),@(20),@(20)).floatValue;
        self.submitButton.layer.masksToBounds = YES;
        self.submitButton.layer.borderWidth = 0.5;
        self.submitButton.layer.borderColor = [RedpacketColorStore rp_textcolorYellow].CGColor;
        [self.submitButton setBackgroundColor:[RedpacketColorStore rp_textcolorYellow]];
        [self.submitButton setTitleColor:[RedpacketColorStore rp_textColorRed] forState:UIControlStateNormal];
        [self.submitButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.submitButton setTitle:@"拆红包" forState:UIControlStateNormal];
        [self.submitButton rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.left.equalTo(self).offset(78);
            make.right.equalTo(self).offset(-78);
            make.centerX.equalTo(self);
            make.height.offset(RP_(@(32),@(44),@(44)).floatValue);
            make.bottom.equalTo(self).offset(RP_(@(-24),@(-30),@(-30)).floatValue);
        }];
    }
    return self;
}

- (void)setMessageModel:(RedpacketMessageModel *)messageModel {
    if (_messageModel != messageModel) {
        _messageModel = messageModel;
        NSURL *headerUrl = [NSURL URLWithString:messageModel.redpacketSender.userAvatar];
        [self.avatarImageView rp_setImageWithURL:headerUrl placeholderImage:rpRedpacketBundleImage(@"redpacket_header")];
        self.avatarImageView.backgroundColor = [RedpacketColorStore rp_headBackGroundColor];
    }
}

- (void)closeAction:(id)sender {
    if (self.closeButtonBlock) {
        self.closeButtonBlock(self);
    }
}

- (void)submitAction:(id)sender {
    self.submitButtonBlock(self.boxStatusType,self);
}

@end
