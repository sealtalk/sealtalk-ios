//
//  RPAdvertisementDetailView.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//
#import "RPAdvertisementDetailView.h"
#import "UIImageView+YZHWebCache.h"
#import "RPAdvertisementDetailModel.h"
#import "RedpacketColorStore.h"
#import "RedpacketDataRequester.h"
#import "RPRedpacketTool.h"
#import "UIAlertView+YZHAlert.h"

typedef NS_ENUM(NSInteger,RedpacketAdvertisementActionType) {
    RedpacketAdvertisementReceive = 0 , //领取红包事件
    RedpacketAdvertisementAction      , //点击进入广告页
    RedpacketAdvertisementShare       , //点击分享
};

@interface RPAdvertisementActionbView : UIView <UIAlertViewDelegate>

@property (nonatomic,strong)UILabel * titleLable;
@property (nonatomic,strong)UILabel * subTitleLable;
@property (nonatomic,strong)UILabel * moneyLable;
@property (nonatomic,strong)UIButton * sendButton;
@property (nonatomic,strong)UIButton * shareButton;
@property (nonatomic,strong)RPAdvertisementDetailModel * detailModel;
@property (nonatomic,strong)NSArray * subTitleLableConstraintArray;
@property (nonatomic,weak)id<RPAdvertisementDetailViewDelegate> rpDelegate;
@property (nonatomic,assign)BOOL showAlertView;
@property (nonatomic,strong)NSMutableArray * sendConstraintArray;
@property (nonatomic,strong)UIAlertView * alert;

@end

@implementation RPAdvertisementActionbView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.showAlertView = NO;
        self.sendConstraintArray = [NSMutableArray array];
        
        self.titleLable = [UILabel new];
        [self addSubview:self.titleLable];
        self.titleLable.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLable.textAlignment = NSTextAlignmentCenter;
        self.titleLable.numberOfLines = 1;
        [self.titleLable setFont:[UIFont systemFontOfSize:15]];
        NSLayoutConstraint * titleLableTopConstraint = [NSLayoutConstraint constraintWithItem:self.titleLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:48];
        NSLayoutConstraint * titleLableLeftConstraint = [NSLayoutConstraint constraintWithItem:self.titleLable attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint * titleLableRightConstraint = [NSLayoutConstraint constraintWithItem:self.titleLable attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self addConstraints:@[titleLableTopConstraint,titleLableLeftConstraint,titleLableRightConstraint]];
        
        self.subTitleLable = [UILabel new];
        [self addSubview:self.subTitleLable];
        self.subTitleLable.translatesAutoresizingMaskIntoConstraints = NO;
        self.subTitleLable.textAlignment = NSTextAlignmentCenter;
        NSLayoutConstraint * subTitleLableLeftConstraint = [NSLayoutConstraint constraintWithItem:self.subTitleLable attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:32];
        NSLayoutConstraint * subTitleLableRightConstraint = [NSLayoutConstraint constraintWithItem:self.subTitleLable attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-32];
        [self addConstraints:@[subTitleLableLeftConstraint,subTitleLableRightConstraint]];
        
        self.moneyLable = [UILabel new];
        self.moneyLable.textAlignment = NSTextAlignmentCenter;
        self.moneyLable.textColor = [RedpacketColorStore rp_textColorRed];
        self.moneyLable.translatesAutoresizingMaskIntoConstraints = NO;
        self.moneyLable.numberOfLines = 1;
        [self.moneyLable setFont:[UIFont systemFontOfSize:49]];
        [self addSubview:self.moneyLable];
        NSLayoutConstraint * moneyLableTopConstraint = [NSLayoutConstraint constraintWithItem:self.moneyLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:104];
        NSLayoutConstraint * moneyLableLeftConstraint = [NSLayoutConstraint constraintWithItem:self.moneyLable attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:32];
        NSLayoutConstraint * moneyLableRightConstraint = [NSLayoutConstraint constraintWithItem:self.moneyLable attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-32];
        [self addConstraints:@[moneyLableTopConstraint,moneyLableLeftConstraint,moneyLableRightConstraint]];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.sendButton];
        self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(redpacketDidClick) forControlEvents:UIControlEventTouchUpInside];
        self.sendButton.clipsToBounds = YES;
        self.sendButton.layer.cornerRadius = 7;
        NSLayoutConstraint * sendButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:32];
        NSLayoutConstraint * sendButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-22];
        NSLayoutConstraint * sendButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
        [self addConstraints:@[sendButtonLeftConstraint,sendButtonBottomConstraint,sendButtonHeightConstraint]];
        
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shareButton setTitle:@"分享给好友" forState:UIControlStateNormal];
        [self addSubview:self.shareButton];
        self.shareButton.clipsToBounds = YES;
        self.shareButton.layer.cornerRadius = 7;
        self.shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [self.shareButton setBackgroundColor:[UIColor colorWithRed:210/255.0 green:79/255.0 blue:68/255.0 alpha:1]];
        [self.shareButton setImage:rpRedpacketBundleImage(@"adverisement_share") forState:UIControlStateNormal];
        NSLayoutConstraint * shareButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.shareButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.sendButton attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint * shareButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:self.shareButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:10];
        NSLayoutConstraint * shareButtonRightConstraint = [NSLayoutConstraint constraintWithItem:self.shareButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-32];
        NSLayoutConstraint * shareButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.shareButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.sendButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        [self addConstraints:@[shareButtonBottomConstraint,shareButtonLeftConstraint,shareButtonRightConstraint,shareButtonHeightConstraint]];
    }
    return self;
}

- (void)setDetailModel:(RPAdvertisementDetailModel *)detailModel {
    _detailModel = detailModel;
    if (![detailModel isKindOfClass:[RPAdvertisementDetailModel class]]) return;
    [self.titleLable setText:[NSString stringWithFormat:@"%@的红包",detailModel.name]];
    [self.subTitleLable setText:detailModel.title];
    [self.sendButton setEnabled:YES];
    [self updateConstraintsIfNeeded];
    [self updateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    UIImage * sendButtonBackgroundColorImage = [RedpacketColorStore rp_createImageWithColor:[UIColor colorWithRed:210/255.0 green:79/255.0 blue:68/255.0 alpha:1]];
    
    switch (self.detailModel.rpState) {
        case RedpacketStatusTypeCanGrab: {
            self.sendButton.enabled = YES;
            [self.sendButton setTitle:@"点击领取" forState:UIControlStateNormal];
            [self configSubTitleLableLayout:YES];
            [self.moneyLable setText:@""];
            self.moneyLable.hidden = YES;
            break;
        }
        case RedpacketStatusTypeGrabFinish:
            if (self.detailModel.myAmount.floatValue > 0) {
                self.moneyLable.hidden = NO;
                [self.moneyLable setText:[NSString stringWithFormat:@"¥%@",self.detailModel.myAmount]];
                [self configSubTitleLableLayout:!self.detailModel.shareURL.length];
                if (self.detailModel.landingPage.length > 0) {
                    self.sendButton.enabled = YES;
                    [self.sendButton setTitle:@"去看看" forState:UIControlStateNormal];
                }else{
                    self.sendButton.enabled = NO;
                    [self.sendButton setTitle:@"已领取" forState:UIControlStateNormal];
                    sendButtonBackgroundColorImage = [RedpacketColorStore rp_createImageWithColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
                    [self.sendButton setImage:rpRedpacketBundleImage(@"adverisement_receive") forState:UIControlStateNormal];
                }
                
            }else {
                self.sendButton.enabled = NO;
                [self.sendButton setTitle:@"手慢了，红包派完了" forState:UIControlStateNormal];
                sendButtonBackgroundColorImage = [RedpacketColorStore rp_createImageWithColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
                self.moneyLable.hidden = YES;
                [self configSubTitleLableLayout:YES];
            }
            break;
        case RedpacketStatusTypeOutDate:
            self.sendButton.enabled = NO;
            [self.sendButton setTitle:@"来晚了，红包已过期" forState:UIControlStateNormal];
            sendButtonBackgroundColorImage = [RedpacketColorStore rp_createImageWithColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
            [self.moneyLable setText:@""];
            self.moneyLable.hidden = YES;
            [self configSubTitleLableLayout:YES];
            break;
        default:
            self.sendButton.enabled = NO;
            [self.sendButton setTitle:@"已过期" forState:UIControlStateNormal];
            sendButtonBackgroundColorImage = [RedpacketColorStore rp_createImageWithColor:[UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1]];
            [self.moneyLable setText:@""];
            self.moneyLable.hidden = YES;
            [self configSubTitleLableLayout:YES];
            break;
    }
    [self.sendButton setBackgroundImage:sendButtonBackgroundColorImage forState:UIControlStateNormal];
}

- (void)configSubTitleLableLayout:(BOOL)flag {
    if (self.subTitleLableConstraintArray) {
        [self removeConstraints:self.subTitleLableConstraintArray];
    }
    if (self.sendConstraintArray) {
        [self removeConstraints:self.sendConstraintArray];
    }
    NSLayoutConstraint * subTitleLableTopConstraint = [NSLayoutConstraint constraintWithItem:self.subTitleLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:self.moneyLable.hidden?104:74];
    self.subTitleLableConstraintArray = [NSArray arrayWithObjects:subTitleLableTopConstraint, nil];
    [self addConstraints:self.subTitleLableConstraintArray];
    
    self.subTitleLable.textColor = self.moneyLable.hidden?[RedpacketColorStore rp_textColorRed]: [RedpacketColorStore rp_textColorGray];
    self.subTitleLable.numberOfLines = self.moneyLable.hidden?2:1;
    [self.subTitleLable setFont:[UIFont systemFontOfSize:self.moneyLable.hidden?24:12]];
    self.shareButton.hidden = flag;
    
    NSLayoutConstraint * sendButtonRightConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:flag?NSLayoutAttributeRight:NSLayoutAttributeCenterX multiplier:1 constant:flag?-32:-10];
    self.sendConstraintArray = [[NSArray arrayWithObjects:sendButtonRightConstraint, nil] mutableCopy];
    [self addConstraints:self.sendConstraintArray];

}

- (void)redpacketDidClick {
    
    switch (self.detailModel.rpState) {
        case RedpacketStatusTypeCanGrab:{
            if ([self.rpDelegate respondsToSelector:@selector(getRedpacket)]) {
                self.showAlertView = YES;
                [self.rpDelegate getRedpacket];
            }
            
            if ([self.rpDelegate respondsToSelector:@selector(advertisementRedPacketAction:)]) {
                NSMutableDictionary * args = self.detailModel.shareDictionary.mutableCopy;
                [args setObject:@(RedpacketAdvertisementReceive) forKey:@"actionType"];
                [self.rpDelegate advertisementRedPacketAction:args];
            }
            break;
        }
        case RedpacketStatusTypeGrabFinish:
            if (self.detailModel.landingPage.length > 0) {
                [[RedpacketDataRequester alloc]analysisADDataWithADName:@"rp.hb.ad.click_ad" andADID:self.detailModel.rpID];
                
                if ([self.rpDelegate respondsToSelector:@selector(advertisementRedPacketAction:)]) {
                    NSMutableDictionary * args = self.detailModel.shareDictionary.mutableCopy;
                    [args setObject:@(RedpacketAdvertisementAction) forKey:@"actionType"];
                    [self.rpDelegate advertisementRedPacketAction:args];
                }
            }
            break;
        default:
            break;
    }
}

- (void)shareAction {
    
    if (!self.alert && (self.detailModel.shareMessage.length || self.detailModel.shareURL.length)) {
        self.alert = [[UIAlertView alloc]initWithTitle:@"" message:self.detailModel.shareMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"分享", nil];
        [self.alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    rpWeakSelf;
    if (buttonIndex) {
        if ([weakSelf.rpDelegate respondsToSelector:@selector(advertisementRedPacketAction:)]) {
            NSMutableDictionary * args = weakSelf.detailModel.shareDictionary.mutableCopy;
            [args setObject:@(RedpacketAdvertisementShare) forKey:@"actionType"];
            [weakSelf.rpDelegate advertisementRedPacketAction:args];
        }
    }
    weakSelf.alert = nil;
    
}

@end


@interface RPAdvertisementDetailView()

@property (nonatomic,strong)UIImageView * bannerImageView;
@property (nonatomic,strong)UIImageView * iconImageView;
@property (nonatomic,strong)UILabel * describeLable;
@property (nonatomic,strong)RPAdvertisementActionbView * actionView;

@end

@implementation RPAdvertisementDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.bounces = NO;
        self.bannerImageView = [UIImageView new];
        self.bannerImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.bannerImageView];
        self.bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bannerImageView.clipsToBounds = YES;
        
        self.actionView = [RPAdvertisementActionbView new];
        self.actionView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        self.actionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.actionView];
        
        self.iconImageView = [UIImageView new];
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.iconImageView];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImageView.clipsToBounds = YES;
        self.iconImageView.layer.cornerRadius = 37;
        
        self.describeLable = [UILabel new];
        self.describeLable.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.describeLable];
        self.describeLable.font = [UIFont systemFontOfSize:12];
        self.describeLable.textColor = [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1];
        self.describeLable.textAlignment = NSTextAlignmentCenter;
        
        NSLayoutConstraint * bannerImageViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.bannerImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint * bannerImageViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bannerImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint * bannerImageViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.bannerImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint * bannerImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bannerImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[UIScreen mainScreen].bounds.size.width];
        NSLayoutConstraint * bannerImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.bannerImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:290];
        [self addConstraints:@[bannerImageViewTopConstraint,bannerImageViewLeftConstraint,bannerImageViewRightConstraint,bannerImageViewWidthConstraint,bannerImageViewHeightConstraint]];
        
        
        NSLayoutConstraint * actionViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.actionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bannerImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:-14];
        NSLayoutConstraint * actionViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.actionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:15];
        NSLayoutConstraint * actionViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.actionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-15];
        NSLayoutConstraint * actionViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.actionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:254];
        [self addConstraints:@[actionViewTopConstraint,actionViewLeftConstraint,actionViewRightConstraint,actionViewHeightConstraint]];
        
        
        NSLayoutConstraint * describeLableLeftConstraint = [NSLayoutConstraint constraintWithItem:self.describeLable attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint * describeLableRightConstraint = [NSLayoutConstraint constraintWithItem:self.describeLable attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint * describeLableTopConstraint = [NSLayoutConstraint constraintWithItem:self.describeLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.actionView attribute:NSLayoutAttributeBottom multiplier:1 constant:48];
        NSLayoutConstraint * describeLableBottomConstraint = [NSLayoutConstraint constraintWithItem:self.describeLable attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-14];
        [self addConstraints:@[describeLableLeftConstraint,describeLableRightConstraint,describeLableTopConstraint,describeLableBottomConstraint]];
        
        NSLayoutConstraint * iconImageViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint * iconImageViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.actionView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint * iconImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:74];
        NSLayoutConstraint * iconImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:74];
        [self addConstraints:@[iconImageViewCenterXConstraint,iconImageViewCenterYConstraint,iconImageViewWidthConstraint,iconImageViewHeightConstraint]];
        
    }
    return self;
}

- (void)setRpDelegate:(id<RPAdvertisementDetailViewDelegate>)rpDelegate {
    _rpDelegate = rpDelegate;
    self.actionView.rpDelegate = rpDelegate;
}

- (void)setDetailModel:(RPAdvertisementDetailModel *)detailModel{
    _detailModel = detailModel;
    if (![detailModel isKindOfClass:[RPAdvertisementDetailModel class]]) return;
    [self.iconImageView rp_setImageWithURL:[NSURL URLWithString:detailModel.logoURLString]];
    NSString *prompt = @"已存入零钱，可用于发红包或提现";
    
#ifdef AliAuthPay
    switch (detailModel.rpState) {
        case RedpacketStatusTypeCanGrab:
            prompt = @"收到的零钱入账至绑定的支付宝账户";
            break;
        case RedpacketStatusTypeGrabFinish:
            if (self.detailModel.myAmount.floatValue > 0) {
                prompt = @"已入账至绑定的支付宝账户";
            }else {
                prompt = @"";
            }
            
            break;
        default:
            break;
    }
#endif
    
    [self.describeLable setText:prompt];
    [self.actionView setDetailModel:detailModel];
    self.backgroundColor = [RedpacketColorStore colorWithHexString:detailModel.colorString alpha:1];
    [self.bannerImageView rp_setImageWithURL:[NSURL URLWithString:detailModel.bannerURLString] placeholderImage:nil completed:^(UIImage *image, NSError *error, YZHSDImageCacheType cacheType, NSURL *imageURL) {
        if (image && !error) {
            [[RedpacketDataRequester alloc]analysisADDataWithADName:@"rp.hb.ad.view_ad" andADID:detailModel.rpID];
        }
    }];
}

@end



