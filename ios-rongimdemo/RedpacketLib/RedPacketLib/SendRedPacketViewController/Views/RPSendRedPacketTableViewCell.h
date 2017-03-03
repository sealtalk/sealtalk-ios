//
//  RPSendRedPacketTableViewCell.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPBaseTableViewCell.h"
#import "RPSendRedPacketBaseTableViewCellProtocol.h"

@interface RPSendRedPacketTableViewCell : RPBaseTableViewCell
@property (nonatomic,weak)UILabel * describeLable;
@property (nonatomic,weak)UILabel * unitsLable;
@property (nonatomic,weak)UIView * spaceView;
@property (nonatomic,weak)id<RPSendRedPacketBaseTableViewCellProtocol> RPCellDelagete;
- (CGFloat)spaceViewHeight;
@end
