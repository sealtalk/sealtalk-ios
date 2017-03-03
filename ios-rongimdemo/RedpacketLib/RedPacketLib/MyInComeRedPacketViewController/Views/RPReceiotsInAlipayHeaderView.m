//
//  RPReceiotsInAlipayHeaderView.m
//  RedpacketLib
//
//  Created by 都基鹏 on 2016/12/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPReceiotsInAlipayHeaderView.h"
#import "UIView+YZHExtension.h"
#import "RPLayout.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketTool.h"
#import "UIButton+RPAction.h"

@interface RPReceiotsInAlipayHeaderViewButton : UIButton
@end
@implementation RPReceiotsInAlipayHeaderViewButton
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setTitleColor:[RedpacketColorStore rp_textColorRed] forState:UIControlStateNormal];
        [self setTitleColor:[RedpacketColorStore colorWithHexString:@"0xd24f44" alpha:0.4] forState:UIControlStateHighlighted];
        [self.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.layer setCornerRadius:20];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderWidth:0.5];
        [self.layer setBorderColor:[RedpacketColorStore rp_textColorRed].CGColor];
    }
    return self;
}
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        [self.layer setBorderColor:[RedpacketColorStore colorWithHexString:@"0xd24f44" alpha:0.4].CGColor];
    }else{
        [self.layer setBorderColor:[RedpacketColorStore rp_textColorRed].CGColor];
    }
}

@end

@interface RPReceiotsInAlipayHeaderView()<UIActionSheetDelegate>

@property (nonatomic,weak)UIButton * describeLable;
@property (nonatomic,weak)UIButton * bindingButton;
@property (nonatomic,weak)UIButton * removeBindingButton;
@property (nonatomic,weak)UIView * lineView;
@property (nonatomic,weak)UIView * gapView;
@property (nonatomic,weak)UIImageView * arrowView;

@end

@implementation RPReceiotsInAlipayHeaderView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    [self.headImageView rpm_updateConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(30);
    }];
    
    self.bindingButton = [self rp_addsubview:[RPReceiotsInAlipayHeaderViewButton class]];
    [self.bindingButton addTarget:self action:@selector(doAlipayAuth) forControlEvents:UIControlEventTouchUpInside];
    [self.bindingButton setTitle:@"绑定支付宝" forState:UIControlStateNormal];
    [self.bindingButton rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.moneyLable.rpm_bottom).offset(20);
        make.centerX.equalTo(self);
        make.width.offset(156);
        make.height.offset(40);
    }];
    
    self.describeLable = [self rp_addsubview:[UIButton class]];
    [self.describeLable setTitleColor:[RedpacketColorStore rp_textColorGray] forState:UIControlStateNormal];
    self.describeLable.titleLabel.font = [UIFont systemFontOfSize:13];
    self.describeLable.titleLabel.numberOfLines = 2;
    self.describeLable.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.describeLable rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.height.offset(13);
    }];
    
    self.removeBindingButton = [self rp_addsubview:[UIButton class]];
    [self.removeBindingButton addTarget:self action:@selector(removeBinding) forControlEvents:UIControlEventTouchUpInside];
    [self.removeBindingButton setTitleColor:[RedpacketColorStore rp_colorWithHEX:0x35b7f3] forState:UIControlStateNormal];
    self.removeBindingButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.removeBindingButton.hidden = YES;
    self.removeBindingButton.rp_hitTestEdgeInsets = UIEdgeInsetsMake(-40, -150, -40, -150);
    [self.removeBindingButton rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.describeLable.rpm_bottom).offset(11);
        make.centerX.equalTo(self);
        make.height.offset(13);
    }];
    
    self.arrowView = [self rp_addsubview:[UIImageView class]];
    self.arrowView.image = rpRedpacketBundleImage(@"redpacket_bluearrow");
    [self.arrowView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.left.equalTo(self.removeBindingButton.rpm_right).offset(2);
        make.centerY.equalTo(self.removeBindingButton);
        make.height.offset(14);
        make.width.offset(8);
    }];
    
    
    self.lineView = [self rp_addsubview:[UIView class]];
    self.lineView.backgroundColor = [RedpacketColorStore rp_lineColorLightGray];
    [self.lineView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-80);
        make.left.and.right.equalTo(self);
        make.height.offset(RP_(@(0.5)).floatValue);
    }];
    
    self.gapView = [self rp_addsubview:[UIView class]];
    self.gapView.backgroundColor = [RedpacketColorStore rp_lineColorLightGray];
    [self.gapView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.width.offset(0.5);
        make.centerX.equalTo(self);
        make.top.equalTo(self.lineView).offset(10);
        make.bottom.equalTo(self.rpm_bottom).offset(-10);
    }];
    
    
    [self.receiveDescribeLable rpm_updateConstraints:^(RPConstraintMaker *make) {
        make.height.offset(13);
    }];
    
    [self.receiveNumbersLable rpm_updateConstraints:^(RPConstraintMaker *make) {
        make.height.offset(34);
    }];
    
    [self.bestLuckyDescibeLable rpm_updateConstraints:^(RPConstraintMaker *make) {
        make.height.offset(13);
    }];
    [self.bestLuckyNumbersLable rpm_updateConstraints:^(RPConstraintMaker *make) {
        make.height.offset(34);
    }];
    
    
    return self;
}

- (void)doAlipayAuth {
    if ([self.delegate respondsToSelector:@selector(doAlipayAuth)]) {
        [self.delegate doAlipayAuth];
    }
}

- (void)removeBinding {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"解绑支付宝"
                                  otherButtonTitles:nil,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if ([self.delegate respondsToSelector:@selector(removeBinding)]) {
            [self.delegate removeBinding];
        }
    }
}

- (void)setIsSend:(BOOL)isSend {
    [super setIsSend:isSend];
    self.lineView.hidden = isSend;
    self.gapView.hidden = isSend;
    self.describeLable.hidden = isSend;
    self.removeBindingButton.hidden = isSend;
    self.arrowView.hidden = isSend;
    self.bindingButton.hidden = isSend;
    [self updateConstraintsIfNeeded];
}

- (void)setUsername:(NSString *)username {
    _username = username;
    if (self.isSend) return;
    if (_username && username.length) {
        self.bindingButton.hidden = YES;
        [self.describeLable setTitle:@"红包会自动入账到支付宝账号" forState:UIControlStateNormal];
        self.removeBindingButton.hidden = NO;
        [self.removeBindingButton setTitle:username forState:UIControlStateNormal];
        [self.describeLable rpm_updateConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.moneyLable.rpm_bottom).offset(24);
        }];
    }else {
        self.bindingButton.hidden = NO;
        self.removeBindingButton.hidden = YES;
        [self.describeLable setTitle:@"绑定后，收到的红包会自动入账到支付宝账号" forState:UIControlStateNormal];
        [self.describeLable rpm_updateConstraints:^(RPConstraintMaker *make) {
            make.top.equalTo(self.moneyLable.rpm_bottom).offset(76);
        }];
    }
    self.arrowView.hidden = self.removeBindingButton.hidden;
    [self updateFocusIfNeeded];
}

- (void)setIncomeHeaderDic:(NSDictionary *)incomeHeaderDic
{
    [super setIncomeHeaderDic:incomeHeaderDic];
    NSString *money = [incomeHeaderDic objectForKey:@"TotalAmount"];
    if (!money) return;
    if (money.length) {
        self.bestLuckyNumbersLable.textColor = [RedpacketColorStore rp_textColorBlack6];
        self.receiveNumbersLable.textColor = [RedpacketColorStore rp_textColorBlack6];
    }else {
        self.bestLuckyNumbersLable.textColor = [RedpacketColorStore rp_textColorGray];
        self.receiveNumbersLable.textColor = [RedpacketColorStore rp_textColorGray];
    }
}
@end
