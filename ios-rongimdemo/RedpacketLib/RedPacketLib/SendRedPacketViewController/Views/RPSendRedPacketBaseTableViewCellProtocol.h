//
//  RPSendRedPacketBaseTableViewCellProtocol.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPBaseTableViewCell.h"

@protocol RPSendRedPacketBaseTableViewCellProtocol <RPBaseTableViewCellProtocol>
/**
 *  修改红包个数
 */
- (void)didChangePacketCount;
/**
 *  修改红包金额
 */
- (void)didChangePacketInputMoney;
/**
 *  修改红包玩法
 */
- (void)didChangePacketPlayType;
/**
 *  提交红包
 */
- (void)didSendRedPacket;
@end
