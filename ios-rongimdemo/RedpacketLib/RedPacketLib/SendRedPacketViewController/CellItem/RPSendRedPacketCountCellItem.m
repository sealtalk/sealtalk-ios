//
//  RPSendRedPacketChangeCellItem.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketCountCellItem.h"
#import "RPSendRedPacketCountTableViewCell.h"
@implementation RPSendRedPacketCountCellItem
- (Class)cellClass{
    return [RPSendRedPacketCountTableViewCell class];
}
- (UITableViewCellSelectionStyle)cellSelectionStyle{
    return UITableViewCellSelectionStyleNone;
}
- (CGFloat)cellHeight{
    return 70;
}
@end
