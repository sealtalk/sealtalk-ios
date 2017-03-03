//
//  RPSendRedPacketChangeCellItem.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketChangeCellItem.h"
#import "RPSendRedPacketChangeTableViewCell.h"
#import "RPSendRedPacketItem.h"

@implementation RPSendRedPacketChangeCellItem
- (Class)cellClass{
    return [RPSendRedPacketChangeTableViewCell class];
}
- (UITableViewCellSelectionStyle)cellSelectionStyle{
    return UITableViewCellSelectionStyleNone;
}

- (CGFloat)cellHeight{
    if (((RPSendRedPacketItem*)self.rawItem).redPacketType == RedpacketTypeSingle) {
        return 56;
    }
    return 82;
}
- (CGFloat)spaceViewHeight{
    if (((RPSendRedPacketItem*)self.rawItem).redPacketType == RedpacketTypeSingle) {
        return 12;
    }
    return 38;
}
@end
