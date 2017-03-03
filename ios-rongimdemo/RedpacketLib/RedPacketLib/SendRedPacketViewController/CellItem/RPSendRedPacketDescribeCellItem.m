//
//  RPSendRedPacketDescribeCellItem.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketDescribeCellItem.h"
#import "RPSendRedPacketDescribeTableViewCell.h"


@implementation RPSendRedPacketDescribeCellItem
- (Class)cellClass{
    return [RPSendRedPacketDescribeTableViewCell class];
}
- (UITableViewCellSelectionStyle)cellSelectionStyle{
    return UITableViewCellSelectionStyleNone;
}
- (CGFloat)cellHeight{
    return 64;
}
@end
