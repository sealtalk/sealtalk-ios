//
//  RedpacketTypeAmountHandle.m
//  RedpacketLib
//
//  Created by 都基鹏 on 2016/11/4.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketTypeAmountHandle.h"

@implementation RedpacketTypeAmountHandle

- (void)getRedpacketDetail {
    [super getRedpacketDetail];
    rpWeakSelf;
    switch (weakSelf.messageModel.redpacketStatusType) {
            
        case RedpacketStatusTypeCanGrab: {
            if (weakSelf.messageModel.isRedacketSender) {
                [weakSelf setingPacketViewWith:weakSelf.messageModel boxStatusType:RedpacketBoxStatusTypeReceiveAmount closeButtonBlock:^(RPRedpacketPreView *packetView){
                    [weakSelf removeRedPacketView];
                } submitButtonBlock:nil];
            }else {
                [weakSelf.delegate sendGrabRedpacketRequest:weakSelf.messageModel];
            }
        }
            break;
        case RedpacketStatusTypeGrabFinish:
        case RedpacketStatusTypeOutDate: {
            [weakSelf setingPacketViewWith:weakSelf.messageModel boxStatusType:RedpacketBoxStatusTypeReceiveAmount closeButtonBlock:^(RPRedpacketPreView *packetView){
                [weakSelf removeRedPacketView];
            } submitButtonBlock:nil];
            break;
        }
    }
}

@end
