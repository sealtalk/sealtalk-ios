//
//  RedpacketTypeRandHandle.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/12.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketTypeRandHandle.h"

@implementation RedpacketTypeRandHandle
- (void)getRedpacketDetail {
    
    [super getRedpacketDetail];
    rpWeakSelf;
    
    BOOL isReceive = [weakSelf.messageModel.myAmount floatValue] > 0.009;
    
    switch (weakSelf.messageModel.redpacketStatusType) {
            
        case RedpacketStatusTypeCanGrab: {
            
            if (isReceive) {
                [weakSelf showRedPacketDetailViewController:weakSelf.messageModel arguments:nil];
            } else {
                [weakSelf setingPacketViewWith:weakSelf.messageModel boxStatusType:RedpacketBoxStatusTypeRobbing closeButtonBlock:^(RPRedpacketPreView *packetView) {
                    [weakSelf removeRedPacketView];
                } submitButtonBlock:^(RedpacketBoxStatusType boxStatusType, RPRedpacketPreView *packetView) {
                    if (boxStatusType == RedpacketBoxStatusTypeOverdue) {
                        [weakSelf showRedPacketDetailViewController:weakSelf.messageModel arguments:nil];
                    }else {
                        //[weakSelf removeRedPacketView];
                        [weakSelf.delegate sendGrabRedpacketRequest:weakSelf.messageModel];
                    }

                }];
            }
            break;
        }
        case RedpacketStatusTypeGrabFinish: {
            if (isReceive) {
                [weakSelf showRedPacketDetailViewController:weakSelf.messageModel arguments:nil];
                
            } else {
                [weakSelf setingPacketViewWith:weakSelf.messageModel boxStatusType:RedpacketBoxStatusTypeRandRobbing closeButtonBlock:^(RPRedpacketPreView *packetView){
                    [weakSelf removeRedPacketView];
                } submitButtonBlock:^(RedpacketBoxStatusType boxStatusType, RPRedpacketPreView *packetView) {
                    //[weakSelf removeRedPacketView];
                    [weakSelf showRedPacketDetailViewController:weakSelf.messageModel arguments:nil];
                }];
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
