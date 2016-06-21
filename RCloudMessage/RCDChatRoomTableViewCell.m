//
//  RCDChatRoomTableViewCell.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/26.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDChatRoomTableViewCell.h"

@implementation RCDChatRoomTableViewCell

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.ivChatRoomPortrait.layer.cornerRadius     =   4;
        self.ivChatRoomPortrait.layer.masksToBounds    =   YES;
    }
    return self;
}

- (void)awakeFromNib {


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
