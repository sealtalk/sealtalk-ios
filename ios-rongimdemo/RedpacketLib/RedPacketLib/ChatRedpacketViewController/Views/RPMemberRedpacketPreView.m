//
//  RPMemberRedpacketPreView.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPMemberRedpacketPreView.h"
#import "RPLayout.h"
#import "RedpacketColorStore.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketTool.h"
#import "UIView+YZHExtension.h"

@implementation RPMemberRedpacketPreView

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self.avatarImageView setImage:rpRedpacketBundleImage(@"redpacket_RPMemberRedpacketPreView_logo")];
        
        self.receiveHeadImageView = [self rp_addsubview:[UIImageView class]];
        self.receiveHeadImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.receiveHeadImageView.layer.cornerRadius = RP_(@(54),@(70),@(70)).floatValue / 2.0f;
        self.receiveHeadImageView.layer.masksToBounds = YES;
        self.receiveHeadImageView.layer.borderWidth = 3.0;
        self.receiveHeadImageView.layer.borderColor = [RedpacketColorStore rp_textcolorYellow].CGColor;
        
        [self.receiveHeadImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.size.sizeOffset(CGSizeMake(RP_(@(54),@(70),@(70)).floatValue, RP_(@(54),@(70),@(70)).floatValue));
            make.top.equalTo(self).offset(RP_(@(130),@(170),@(170)).floatValue);
            
            make.left.equalTo(self.rpm_centerX).offset(-3);
        }];
        
        UIView *redBackLine = [self rp_addsubview:[UIView class]];
        redBackLine.backgroundColor = [RedpacketColorStore rp_textColorRed];
        redBackLine.layer.cornerRadius = RP_(@(60),@(76),@(76)).floatValue / 2.0f;
        redBackLine.layer.masksToBounds = YES;
        [redBackLine rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.receiveHeadImageView).offset(-3);
            make.right.equalTo(self.rpm_centerX).offset(3);
            make.width.equalTo(self.receiveHeadImageView.rpm_width).offset(6);
            make.height.equalTo(self.receiveHeadImageView.rpm_height).offset(6);
        }];

        
        self.senderHeadImageView = [redBackLine rp_addsubview:[UIImageView class]];
        self.senderHeadImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.senderHeadImageView.layer.cornerRadius = RP_(@(54),@(70),@(70)).floatValue / 2.0f;
        self.senderHeadImageView.layer.masksToBounds = YES;
        self.senderHeadImageView.layer.borderWidth = 3.0;
        self.senderHeadImageView.layer.borderColor = [RedpacketColorStore rp_textcolorYellow].CGColor;
        [self.senderHeadImageView rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.centerX.equalTo(redBackLine.rpm_centerX).offset(0);
            make.centerY.equalTo(redBackLine.rpm_centerY).offset(0);
            make.size.equalTo(self.receiveHeadImageView);
        }];
        

        self.senderNickNameLable = [self rp_addsubview:[UILabel class]];
        self.senderNickNameLable.font = [UIFont systemFontOfSize:15.0];
        self.senderNickNameLable.textColor = [UIColor whiteColor];
        self.senderNickNameLable.textAlignment = NSTextAlignmentCenter;
        [self.senderNickNameLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.receiveHeadImageView.rpm_bottom).offset(12);
            make.centerX.equalTo(self);
        }];
        
        self.describeLable = [self rp_addsubview:[UILabel class]];
        self.describeLable.font = [UIFont systemFontOfSize:15.0];
        self.describeLable.textAlignment = NSTextAlignmentCenter;
        self.describeLable.textColor = [RedpacketColorStore rp_textcolorYellow];
        self.describeLable.numberOfLines = 0;
        [self.describeLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.senderNickNameLable.rpm_bottom).offset(8);
            make.centerX.equalTo(self);
        }];
        
        self.greetingLable = [self rp_addsubview:[UILabel class]];
        self.greetingLable.numberOfLines = 0;
        self.greetingLable.text = @"恭喜发财恭喜发财恭喜发恭喜发财恭喜发财恭喜发";
        self.greetingLable.textAlignment = NSTextAlignmentCenter;
        self.greetingLable.font = [UIFont systemFontOfSize:24.0];
        self.greetingLable.textColor = [RedpacketColorStore rp_textcolorYellow];
        self.greetingLable.hidden = YES;
        [self.greetingLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.rpm_bottom).offset(30);
            make.width.offset(288);
            make.centerX.equalTo(self);
        }];
        
        self.moneyLable = [self rp_addsubview:[UILabel class]];
        self.moneyLable.textColor = [RedpacketColorStore rp_textcolorYellow];
        self.moneyLable.font = [UIFont systemFontOfSize:44];
        self.moneyLable.textAlignment = NSTextAlignmentCenter;
        self.moneyLable.hidden = YES;
        [self.moneyLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.greetingLable.rpm_bottom).offset(RP_(@(24),@(40),@(40)).floatValue);
            make.centerX.equalTo(self);
        }];
        
        [self.submitButton setBackgroundColor:[UIColor clearColor]];
        [self.submitButton setTitleColor:[RedpacketColorStore rp_textcolorYellow] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setMessageModel:(RedpacketMessageModel *)messageModel {
    if (messageModel.redpacketStatusType == RedpacketStatusTypeCanGrab)
    {
        if ([messageModel.currentUser.userId isEqualToString:messageModel.redpacketReceiver.userId]) {
            
            self.senderNickNameLable.text = [self nameStringWith:messageModel.redpacketSender.userNickname];
            self.describeLable.text = @"给你发了一个红包";
            self.describeLable.textColor = [UIColor whiteColor];
            [self.submitButton setTitle:@"拆红包" forState:UIControlStateNormal];
            
        }else
        {
            self.senderNickNameLable.text = [self nameStringWith:messageModel.redpacketSender.userNickname];
            
            NSString *string = [NSString stringWithFormat:@"给%@发了一个红包",[self nameStringWith:messageModel.redpacketReceiver.userNickname]];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,1)];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(string.length - 6,6)];
            [str addAttribute:NSForegroundColorAttributeName value:[RedpacketColorStore rp_textcolorYellow] range:NSMakeRange(1,string.length - 7)];
            self.describeLable.attributedText = str;
            if (str.length > 25) {
                [self.describeLable sizeToFit];
            }
            
            [self.submitButton setTitle:@"默默关掉" forState:UIControlStateNormal];
            [self.submitButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }else if (messageModel.redpacketStatusType == RedpacketStatusTypeGrabFinish)
    {
        self.senderNickNameLable.text = [self nameStringWith:messageModel.redpacketSender.userNickname];
        
        NSString *string = [NSString stringWithFormat:@"给%@发了一个红包",messageModel.redpacketReceiver.userNickname];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,1)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(string.length - 6,6)];
        [str addAttribute:NSForegroundColorAttributeName value:[RedpacketColorStore rp_textcolorYellow] range:NSMakeRange(1,string.length - 7)];
        self.describeLable.attributedText = str;
        
        [self.submitButton setTitle:@"偷看一下" forState:UIControlStateNormal];
        [self.submitButton addTarget:self action:@selector(glanceAction) forControlEvents:UIControlEventTouchUpInside];
    }else
    {
        self.submitButton.hidden = YES;
    }
    
    NSURL *receiveheaderUrl = [NSURL URLWithString:messageModel.redpacketReceiver.userAvatar];
    [self.receiveHeadImageView rp_setImageWithURL:receiveheaderUrl placeholderImage:rpRedpacketBundleImage(@"redpacket_header")];
    
    NSURL *sendheaderUrl = [NSURL URLWithString:messageModel.redpacketSender.userAvatar];
    [self.senderHeadImageView rp_setImageWithURL:sendheaderUrl placeholderImage:rpRedpacketBundleImage(@"redpacket_header")];
    
    self.greetingLable.text = messageModel.redpacket.redpacketGreeting;
    self.moneyLable.text = [NSString stringWithFormat: @"￥%@",messageModel.redpacket.redpacketMoney];
    
}

- (NSString *)nameStringWith:(NSString *)natureName {
    if (natureName.length > 18) {
        return [[natureName substringToIndex:18] stringByAppendingString:@"..."];
    }
    return natureName;
}

- (void)glanceAction {
    self.senderNickNameLable.hidden = YES;
    self.receiveHeadImageView.hidden = YES;
    self.senderHeadImageView.hidden = YES;
    self.describeLable.hidden = YES;
    self.greetingLable.hidden = NO;
    self.moneyLable.hidden = NO;
    [self.submitButton setTitle:@"默默关掉" forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
}
@end

