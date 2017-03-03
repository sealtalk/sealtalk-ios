//
//  RedpacketTypeMemberHandle.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/12.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketTypeMemberHandle.h"

@implementation RedpacketTypeMemberHandle
- (void)getRedpacketDetail {
    [super getRedpacketDetail];
    rpWeakSelf;
    BOOL isReceive = [weakSelf.messageModel.myAmount floatValue] > 0.009;
    
    switch (weakSelf.messageModel.redpacketStatusType) {
            
        case RedpacketStatusTypeCanGrab:
        case RedpacketStatusTypeGrabFinish: {
            // 判断自己是否抢过
            if (weakSelf.messageModel.isRedacketSender)
            {
                [weakSelf showRedPacketDetailViewController:weakSelf.messageModel arguments:nil];
                
            }else if (isReceive)
            {
                [weakSelf showRedPacketDetailViewController:weakSelf.messageModel arguments:nil];
            }else
            {
                [weakSelf setingPacketViewWith:weakSelf.messageModel boxStatusType:RedpacketBoxStatusTypeMember closeButtonBlock:^(RPRedpacketPreView *packetView){
                    [weakSelf removeRedPacketView];
                } submitButtonBlock:^(RedpacketBoxStatusType boxStatusType, RPRedpacketPreView *packetView) {
                    if ([weakSelf.messageModel.redpacketReceiver.userId isEqualToString: weakSelf.messageModel.currentUser.userId]) {
                        [weakSelf.delegate sendGrabRedpacketRequest:weakSelf.messageModel];
                    }
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
