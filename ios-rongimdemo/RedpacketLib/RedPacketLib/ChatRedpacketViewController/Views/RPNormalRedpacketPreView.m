//
//  RPNormalRedpacketPreView.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPNormalRedpacketPreView.h"
#import "RPLayout.h"
#import "RedpacketColorStore.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketTool.h"
#import "UIView+YZHExtension.h"

@implementation RPNormalRedpacketPreView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nameLable = [self rp_addsubview:[UILabel class]];
        self.nameLable.textColor = [UIColor whiteColor];
        self.nameLable.textAlignment = NSTextAlignmentCenter;
        self.nameLable.numberOfLines = 1;
        self.nameLable.font = [UIFont systemFontOfSize:15];
        [self.nameLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.rpm_bottom).offset(18);
            make.left.equalTo(self).offset(54);
            make.right.equalTo(self).offset(-54);
            make.height.offset(18);
            
        }];
        
        self.describeLable = [self rp_addsubview:[UILabel class]];
        self.describeLable.textColor = [UIColor whiteColor];
        self.describeLable.textAlignment = NSTextAlignmentCenter;
        self.describeLable.numberOfLines = 1;
        self.describeLable.font = [UIFont systemFontOfSize:15];
        [self.describeLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.nameLable.rpm_bottom).offset(7);
            make.left.equalTo(self).offset(24);
            make.right.equalTo(self).offset(-24);
            make.height.offset(18);
        }];
        
        self.luckButton = [self rp_addsubview:[UIButton class]];
        self.luckButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.luckButton setTitle:@"看看大家的手气>" forState:UIControlStateNormal];
        [self.luckButton setTitleColor:[RedpacketColorStore rp_textcolorYellow] forState:UIControlStateNormal];
        [self.luckButton addTarget:self action:@selector(luckAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.luckButton rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.bottom.equalTo(self.submitButton.rpm_top).offset(-16);
            make.centerX.equalTo(self);
            make.height.offset(18);
        }];
        
        self.promptingLabel = [self rp_addsubview:[UILabel class]];
        self.promptingLabel.textColor = [RedpacketColorStore rp_textcolorYellow];
        self.promptingLabel.textAlignment = NSTextAlignmentCenter;
        self.promptingLabel.numberOfLines = 2;
        self.promptingLabel.font = [UIFont systemFontOfSize:24];
        [self.promptingLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.describeLable.rpm_bottom);
            make.bottom.equalTo(self.luckButton.rpm_top);
            make.width.equalTo(self);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

- (void)luckAction:(id)sender {
    if (!self.submitButtonBlock) return;
    self.submitButtonBlock(sender==self.luckButton?RedpacketBoxStatusTypeOverdue:self.boxStatusType,self);
}

- (void)setMessageModel:(RedpacketMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    NSString * nikeName = messageModel.redpacketSender.userNickname;
    nikeName = nikeName.length > 18 ?[[nikeName substringToIndex:18] stringByAppendingString:@"..."]:nikeName;
    self.nameLable.text = nikeName;
    
}

- (void)setBoxStatusType:(RedpacketBoxStatusType)boxStatusType {
    [super setBoxStatusType:boxStatusType];
    
    //非拆红包状态界面
    self.promptingLabel.text = @"";
    self.describeLable.text = @"";
    switch (boxStatusType) {
        case RedpacketBoxStatusTypeOverdue:
            self.luckButton.hidden = YES;
            self.submitButton.hidden = YES;
            self.promptingLabel.text = @"超过1天未领取，红包已过期";
            break;
        case RedpacketBoxStatusTypeAvgRobbing:
            self.luckButton.hidden = YES;
            self.submitButton.hidden = YES;
            self.promptingLabel.text = @"手慢了，红包派完了";
            break;
        case RedpacketBoxStatusTypeAvgRobbed:
            self.luckButton.hidden = YES;
            self.submitButton.hidden = YES;
            self.promptingLabel.text = @"红包派发完毕";
            break;
        case RedpacketBoxStatusTypeRandRobbing:
            self.luckButton.hidden = NO;
            self.submitButton.hidden = YES;
            self.promptingLabel.text = @"手慢了，红包派完了";
            break;
        default: {
            NSString *greeting = self.messageModel.redpacket.redpacketGreeting;
            if (greeting.length > 22) {
                greeting = [greeting substringToIndex:22];
            }
            self.promptingLabel.text = greeting;
            self.submitButton.hidden = NO;
            self.luckButton.hidden = YES;
            
            if (self.messageModel.redpacketType == RedpacketTypeSingle) {
                self.describeLable.text = @"给你发了一个红包";
                
            }else if (self.messageModel.redpacketType == RedpacketTypeRand || self.messageModel.redpacketType == RedpacketTypeRandpri){
                if (self.messageModel.isRedacketSender) {
                    self.luckButton.hidden = NO;
                }
                self.describeLable.text = @"发了一个红包，金额随机";
                
            }else if (self.messageModel.redpacketType == RedpacketTypeAvg){
                self.describeLable.text = @"给你发了一个红包";
            }
            break;
        }
    }
}

@end

