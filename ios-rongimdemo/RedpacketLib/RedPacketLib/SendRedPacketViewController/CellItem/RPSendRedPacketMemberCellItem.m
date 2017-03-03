//
//  RPSendRedPacketMemberCellItem.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketMemberCellItem.h"
#import "RPSendRedPacketMemberTableViewCell.h"

@implementation RPSendRedPacketMemberCellItem
- (Class)cellClass{
    return [RPSendRedPacketMemberTableViewCell class];
}
- (UITableViewCellSelectionStyle)cellSelectionStyle{
    return UITableViewCellSelectionStyleNone;
}
- (CGFloat)cellHeight{
    return 60;
}
@end
