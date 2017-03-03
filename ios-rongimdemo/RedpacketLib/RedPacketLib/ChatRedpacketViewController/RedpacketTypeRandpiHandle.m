//
//  RedpacketTypeRandpiHandle.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/12.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketTypeRandpiHandle.h"

@implementation RedpacketTypeRandpiHandle
- (void)getRedpacketDetail {
    
    [super getRedpacketDetail];
    rpWeakSelf;
    BOOL isReceive = [weakSelf.messageModel.myAmount floatValue] > 0.009;
    
    switch (weakSelf.messageModel.redpacketStatusType) {
            
        case RedpacketStatusTypeCanGrab: {
            if (weakSelf.messageModel.isRedacketSender || isReceive) {
                [weakSelf showRedPacketDetailViewController:weakSelf.messageModel arguments:nil];
            } else {
                [weakSelf setingPacketViewWith:weakSelf.messageModel boxStatusType:RedpacketBoxStatusTypeRobbing closeButtonBlock:^(RPRedpacketPreView *packetView) {
                    [weakSelf removeRedPacketView];
                } submitButtonBlock:^(RedpacketBoxStatusType boxStatusType, RPRedpacketPreView *packetView) {
                   // [weakSelf removeRedPacketView];
                    [weakSelf.delegate sendGrabRedpacketRequest:weakSelf.messageModel];
                }];
            }
            break;
        }
        case RedpacketStatusTypeGrabFinish: {
            if (weakSelf.messageModel.isRedacketSender || isReceive) {
                [weakSelf showRedPacketDetailViewController:weakSelf.messageModel arguments:nil];
            } else {
                [weakSelf setingPacketViewWith:weakSelf.messageModel boxStatusType:RedpacketBoxStatusTypeAvgRobbed closeButtonBlock:^(RPRedpacketPreView *packetView){
                    [weakSelf removeRedPacketView];
                } submitButtonBlock:nil];
            }
            break;
        }
        case RedpacketStatusTypeOutDate: {
            [weakSelf setingPacketViewWith:weakSelf.messageModel boxStatusType:RedpacketBoxStatusTypeOverdue closeButtonBlock:^(RPRedpacketPreView *packetView) {
                [weakSelf removeRedPacketView];
            } submitButtonBlock:nil];
            break;
        }
    }
}
@end
