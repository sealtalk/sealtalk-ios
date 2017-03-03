//
//  RPSendRedPacketCertainCellItem.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketCertainCellItem.h"
#import "RPSendRedPacketCertainTableViewCell.h"

@implementation RPSendRedPacketCertainCellItem
- (Class)cellClass{
    return [RPSendRedPacketCertainTableViewCell class];
}
- (UITableViewCellSelectionStyle)cellSelectionStyle{
    return UITableViewCellSelectionStyleNone;
}
- (CGFloat)cellHeight{
    return 144;
}
@end
