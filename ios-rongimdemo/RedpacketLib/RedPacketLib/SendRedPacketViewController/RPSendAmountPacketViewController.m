//
//  RPSendAmountPacketViewController.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendAmountPacketViewController.h"
#import "RPSendAmountRedpacketPreView.h"
#import "RPLayout.h"
#import "RPRedpacketSendControl.h"
#import "YZHRedpacketBridge+Private.h"
#import "RPRedpacketSetting.h"


@interface RPSendAmountPacketViewController ()

@property (nonatomic,strong)RPRedpacketSendControl * payControl;

@end

@implementation RPSendAmountPacketViewController

- (void)dealloc
{
    [RPRedpacketSendControl releaseSendControl];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNetworking];
    self.view.backgroundColor = [RedpacketColorStore flashColorWithRed:0 green:0 blue:0 alpha:0.8];
    RPSendAmountRedpacketPreView * preView = (RPSendAmountRedpacketPreView *)[RPRedpacketPreView preViewWithBoxStatusType:RedpacketBoxStatusTypeSendAmount];
    [self.view addSubview:preView];
    [preView rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.sizeOffset(CGSizeMake(RP_SCREENWIDTH - 56, (RP_SCREENWIDTH - 56) * 418.0 / 320.0));
    }];
    
    rpWeakSelf;
    preView.convertActionBlock = ^(void) {
        if ([weakSelf.delegate respondsToSelector:@selector(convertRedpacketViewcontrollerFromViewController:)] && weakSelf.parentViewController) {
            [weakSelf.delegate convertRedpacketViewcontrollerFromViewController:weakSelf.parentViewController];
        }
        [weakSelf.view removeFromSuperview];
        [weakSelf removeFromParentViewController];
    };
    [preView setCloseButtonBlock:^(RPRedpacketPreView * packetView) {
        [RPRedpacketSendControl releaseSendControl];
        [weakSelf.view removeFromSuperview];
        [weakSelf removeFromParentViewController];
    }];
    [preView setSubmitButtonBlock:^(RedpacketBoxStatusType boxStatusType, RPRedpacketPreView * packetView) {
        
        RPRedpacketSendControl *control = [RPRedpacketSendControl currentControl];
        control.hostViewController = weakSelf.hostViewController;
        [control payMoney:packetView.messageModel.redpacket.redpacketMoney withMessageModel:packetView.messageModel inController:self andSuccessBlock:^(id object) {
           
            RedpacketMessageModel *redpacketModel = (RedpacketMessageModel *)object;
            
            if (weakSelf.sendRedPacketBlock) {
                weakSelf.sendRedPacketBlock(redpacketModel);
                [weakSelf.view removeFromSuperview];
                [weakSelf removeFromParentViewController];
            }
            
        }];
        
    }];
    
    RedpacketMessageModel *model = preView.messageModel;
    model.redpacketReceiver.userId = self.conversationInfo.userId;
    model.redpacketReceiver.userNickname = self.conversationInfo.userNickname;
    model.redpacketReceiver.userAvatar = self.conversationInfo.userAvatar;
    preView.messageModel = model;
    preView.receivernickName = (self.conversationInfo.userNickname.length > 0) ?self.conversationInfo.userNickname:self.conversationInfo.userId;
    [self.view rp_popupSubView:preView atPosition:PopAnchorCenterX | PopAnchorCenterY];
}

- (void)configViewStyle {}

- (void)configNetworking {
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken:^(NSInteger code, NSString *msg) {
        if (code == 0) {
            [weakSelf.view rp_removeHudInManaual];
            [RPRedpacketSetting asyncRequestRedpacketSettings:nil];
            [[RedpacketDataRequester requestSuccessBlock:nil andFaliureBlock:nil] analysisUserDataWithViewUrl:@"page.send_red_packet"];//用户行为统计
        }else {
            [weakSelf.view rp_showHudErrorView:msg];
        }
    }];
    
}

@end
