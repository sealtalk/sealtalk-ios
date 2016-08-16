//
//  RCDContactSelectedTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactSelectedTableViewCell.h"

@implementation RCDContactSelectedTableViewCell

- (void)awakeFromNib {
  // Initialization code
}

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  if (selected) {
    _selectedImageView.image = [UIImage imageNamed:@"select"];
  } else {
    _selectedImageView.image = [UIImage imageNamed:@"unselect"];
  }
  // Configure the view for the selected state
}

@end
