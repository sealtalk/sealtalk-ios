//
//  RCDGroupTableViewCell.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDGroupTableViewCell.h"
#import "RCDGroupInfo.h"
#import "RCDHttpTool.h"
#import <RongIMKit/RongIMKit.h>
@implementation RCDGroupTableViewCell

- (void)awakeFromNib {
  // Initialization code
  _imvGroupPort.layer.masksToBounds = YES;
  _imvGroupPort.layer.cornerRadius = 2.f;
}

- (void)setIsJoin:(BOOL)isJoin {
  if (isJoin) {
    [_btJoin setImage:[UIImage imageNamed:@"chat"]
             forState:UIControlStateNormal];
    [_btJoin setImage:[UIImage imageNamed:@"chat_hover"]
             forState:UIControlStateHighlighted];
  } else {
    [_btJoin setImage:[UIImage imageNamed:@"join"]
             forState:UIControlStateNormal];
    [_btJoin setImage:[UIImage imageNamed:@"join_hover"]
             forState:UIControlStateHighlighted];
  }

  _isJoin = isJoin;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
