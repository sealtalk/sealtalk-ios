//
//  RPSendAmountRedpacketPreView.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendAmountRedpacketPreView.h"
#import "RPLayout.h"
#import "RedpacketColorStore.h"
#import "UIImageView+YZHWebCache.h"
#import "RPRedpacketTool.h"
#import "UIView+YZHExtension.h"
#import "RPRedpacketSetting.h"

static NSInteger randNumber = 0;

@interface RPSendAmountRedpacketPreView()

@property (nonatomic, strong) UILabel       *nameLable;
@property (nonatomic, strong) UILabel       *describeLable;
@property (nonatomic, strong) UIButton      *luckButton;
@property (nonatomic, strong) UIButton      *convertButton;
@property (nonatomic, strong) UILabel       *moneyLabel;
@property (nonatomic, strong) NSArray       *cacheArray;
@property (nonatomic, assign) NSInteger     luckIndex;
@end

@implementation RPSendAmountRedpacketPreView
@synthesize messageModel = _messageModel;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.backgroundImageView setImage:rpRedpacketBundleImage(@"amount_bg")];
        self.convertButton = [self rp_addsubview:[UIButton class]];
        [self.convertButton setTitleColor:[RedpacketColorStore colorWithHexString:@"#9B3A32" alpha:1] forState:UIControlStateNormal];
        self.convertButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.convertButton setTitle:@"切换至普通红包" forState:UIControlStateNormal];
        [self.convertButton addTarget:self action:@selector(convertAtcion:) forControlEvents:UIControlEventTouchUpInside];
        [self.convertButton rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.centerY.equalTo(self.closeButton);
            make.right.equalTo(self.rpm_right).offset(-14);
        }];
        
        self.nameLable = [self rp_addsubview:[UILabel class]];
        self.nameLable.font = [UIFont systemFontOfSize:15];
        self.nameLable.textAlignment = NSTextAlignmentCenter;
        self.nameLable.textColor = [UIColor whiteColor];
        self.nameLable.numberOfLines = 1;
        [self.nameLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.rpm_bottom).offset(RP_(@(14),@(16),@(16)).floatValue);
            make.centerX.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        
        self.luckButton = [self rp_addsubview:[UIButton class]];
        [self.luckButton addTarget:self action:@selector(luck) forControlEvents:UIControlEventTouchUpInside];
        [self.luckButton setImage:rpRedpacketBundleImage(@"amount_change") forState:UIControlStateNormal];
        [self.luckButton setTitle:@"切换金额" forState:UIControlStateNormal];
        [self.luckButton setTitleColor:[RedpacketColorStore rp_textcolorYellow] forState:UIControlStateNormal];
        [self.luckButton rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.bottom.equalTo(self.submitButton.rpm_top).offset(RP_(@(-32),@(-34),@(-44)).floatValue);
            make.centerX.equalTo(self);
            make.height.offset(16);
        }];
        
        self.moneyLabel = [self rp_addsubview:[UILabel class]];
        self.moneyLabel.numberOfLines = 1;
        self.moneyLabel.textColor = [RedpacketColorStore rp_textcolorYellow];
        self.moneyLabel.font = [UIFont systemFontOfSize:RP_(@(32),@(45),@(45)).floatValue];
        [self.moneyLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.bottom.equalTo(self.luckButton.rpm_top).offset(-RP_(@(12),@(14),@(16)).floatValue);
            make.centerX.equalTo(self);
        }];
        
        self.describeLable = [self rp_addsubview:[UILabel class]];
        self.describeLable.numberOfLines = 1;
        self.describeLable.font = [UIFont systemFontOfSize:22];
        self.describeLable.textColor = [RedpacketColorStore rp_textcolorYellow];
        [self.describeLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.bottom.equalTo(self.moneyLabel.rpm_top).offset(-RP_(@(6),@(8),@(14)).floatValue);
            make.centerX.equalTo(self);
        }];
        [self.submitButton setTitle:@"发红包" forState:UIControlStateNormal];
        
        self.cacheArray = [NSArray arrayWithObjects:
                           @{@"Greeting":@"好运长久",@"Amount":@(9.99)},
                           @{@"Greeting":@"愿一路都有好风景",@"Amount":@(6.66)},
                           @{@"Greeting":@"不许动",@"Amount":@(1.23)},
                           @{@"Greeting":@"地久天长",@"Amount":@(2.99)},
                           @{@"Greeting":@"花开富贵",@"Amount":@(2.88)},
                           @{@"Greeting":@"大步向幸福",@"Amount":@(1.21)},
                           @{@"Greeting":@"福星高照",@"Amount":@(0.68)},
                           @{@"Greeting":@"福星高照",@"Amount":@(6.68)},
                           @{@"Greeting":@"前程似锦",@"Amount":@(2.22)},
                           @{@"Greeting":@"爱你",@"Amount":@(5.20)},
                           @{@"Greeting":@"一定会遇到好事情",@"Amount":@(2.66)},
                           @{@"Greeting":@"八八大发",@"Amount":@(8.88)},
                           @{@"Greeting":@"八八大发",@"Amount":@(0.88)},
                           @{@"Greeting":@"所有愿望都实现",@"Amount":@(0.99)},
                           @{@"Greeting":@"不忙的时候记得找我",@"Amount":@(1.99)},
                           @{@"Greeting":@"就是任性",@"Amount":@(0.01)}, nil];
        NSArray * constGreetings = [RPRedpacketSetting shareInstance].constGreetings;
        if (constGreetings.count && [constGreetings isKindOfClass:[NSArray class]]) {
            self.cacheArray = constGreetings;
        }
        
        randNumber = 0;
        [self luck];
    }
    return self;
}

- (void)setReceivernickName:(NSString *)receivernickName {

    self.nameLable.text = [NSString stringWithFormat:@"给 %@ 的红包",receivernickName];
}

- (void)luck {
    while (randNumber == self.luckIndex) {
        randNumber = arc4random()%self.cacheArray.count;
    }
    self.luckIndex = randNumber;
    NSDictionary * info = self.cacheArray[randNumber];
    self.describeLable.text = info[@"Greeting"];
    self.moneyLabel.text = [NSString stringWithFormat:@"¥ %.2f",((NSNumber *)info[@"Amount"]).floatValue];
}

- (void)convertAtcion:(UIButton*)sender {
    if (self.convertActionBlock) {
        self.convertActionBlock();
    }
}

- (void)setMessageModel:(RedpacketMessageModel *)messageModel {
    [super setMessageModel:messageModel];
}

- (RedpacketMessageModel *)messageModel {
    if (_messageModel == nil) {
        _messageModel = [RedpacketMessageModel new];
    }
    
    NSDictionary * info = self.cacheArray[self.luckIndex];

    _messageModel.messageType = RedpacketMessageTypeRedpacket;
    _messageModel.redpacket.redpacketMoney = rpString(@"%.2f", ((NSNumber *)info[@"Amount"]).floatValue);
    _messageModel.redpacket.redpacketGreeting = info[@"Greeting"];
    _messageModel.redpacketSender = _messageModel.currentUser;
    _messageModel.redpacket.redpacketCount = 1;
    _messageModel.redpacketType = RedpacketTypeAmount;

    return _messageModel;
}

@end
