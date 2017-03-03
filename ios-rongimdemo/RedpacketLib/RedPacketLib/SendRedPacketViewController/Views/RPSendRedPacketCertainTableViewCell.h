//
//  RPSendRedPacketCertainTableViewCell.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPBaseTableViewCell.h"
#import "RPSendRedPacketBaseTableViewCellProtocol.h"

@interface RPSendRedPacketCertainTableViewCell : RPBaseTableViewCell
@property (nonatomic,weak)id<RPSendRedPacketBaseTableViewCellProtocol> RPCellDelagete;
@end
