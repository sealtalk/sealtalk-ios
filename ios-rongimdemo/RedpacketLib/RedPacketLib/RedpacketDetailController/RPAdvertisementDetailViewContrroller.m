//
//  RPDetailViewContrroller.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/7.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPAdvertisementDetailViewContrroller.h"
#import "RPRedpacketSetting.h"
#import "RPAdvertisementDetailView.h"
#import "RPAdvertisementDetailModel.h"
#import "YZHWebViewController.h"
#import "RPSoundPlayer.h"
#import "RedpacketErrorCode.h"

#ifdef AliAuthPay
#import "RPAlipayAuth.h"
#import "RPReceiptsInAlipayViewController.h"
#import "RPAliPayEmpower.h"
#endif

@interface RPAdvertisementDetailViewContrroller ()<RPAdvertisementDetailViewDelegate>

@property (nonatomic,weak)RPAdvertisementDetailView * detailView;

@end

@implementation RPAdvertisementDetailViewContrroller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLable.text = @"红包";
    self.cuttingLineHidden = YES;
    [self configViewStyle];
    
    RPAdvertisementDetailView * advertisementDetailView = [[RPAdvertisementDetailView alloc] initWithFrame:self.view.frame];
    advertisementDetailView.rpDelegate = self;
    [self.view addSubview:advertisementDetailView];
    self.detailView = advertisementDetailView;
    NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:advertisementDetailView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint * leftConstraint = [NSLayoutConstraint constraintWithItem:advertisementDetailView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint * rightConstraint = [NSLayoutConstraint constraintWithItem:advertisementDetailView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint * bottomConstraint = [NSLayoutConstraint constraintWithItem:advertisementDetailView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraints:@[topConstraint,leftConstraint,rightConstraint,bottomConstraint]];
    [self.detailView setDetailModel:self.adMessageModel];
}

- (void)configViewStyle {
    [super configViewStyle];
    
    [self setNavgationBarBackgroundColor:[RedpacketColorStore rp_textColorRed] titleColor:[RedpacketColorStore rp_textcolorYellow] leftButtonTitle:@"关闭" rightButtonTitle:nil];
    [self.navigationController.navigationBar insertSubview:[[UIImageView alloc] initWithImage:rp_imageWithColor([RedpacketColorStore rp_textColorRed])] atIndex:0];
    
    rpWeakSelf;
    [RPRedpacketSetting asyncRequestRedpacketSettings:^{
        weakSelf.subLable.text = [NSString stringWithFormat:@"%@红包服务", [RPRedpacketSetting shareInstance].redpacketOrgName];
    }];
}

- (void)getRedpacket {
    rpWeakSelf;
    [weakSelf.view rp_showHudWaitingView:YZHPromptTypeWating];
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *infoDic) {
        [weakSelf.view rp_removeHudInManaual];
        NSError * error;
        [weakSelf.adMessageModel mergeWithDictionary:infoDic error:&error];
        weakSelf.adMessageModel.rpState = RedpacketStatusTypeGrabFinish;
        if (!error) {
            [RPSoundPlayer playRedpacketOpenSound];
            [weakSelf.detailView setDetailModel:self.adMessageModel];
        }
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf.view rp_removeHudInManaual];
        if (code != RedpacketUnAliAuthed) {
            if (code == RedpacketHBCompleted) {
                weakSelf.adMessageModel.rpState = RedpacketStatusTypeGrabFinish;
                [weakSelf.detailView setDetailModel:self.adMessageModel];
            }else {
                [weakSelf.view rp_showHudErrorView:error];
            }
        }else {
#ifdef AliAuthPay
            [RPAliPayEmpower aliEmpowerSuccess:^{
                
            } failure:^(NSString *errorString) {
                [weakSelf.view rp_showHudErrorView:errorString];
            }];
#endif
        }
    }];
    
    [request requestGrabRedpacketResult:self.messageModel];
}

- (void)clickButtonLeft {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)advertisementRedPacketAction:(NSDictionary *)args {
    self.advertisementDetailAction(args);
}
@end

