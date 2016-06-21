//
//  RCDSelectPersonTableViewCell.m
//  RCloudMessage
//
//  Created by Liv on 15/3/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDSelectPersonTableViewCell.h"

@implementation RCDSelectPersonTableViewCell

-(void)awakeFromNib
{
    self.ivAva.clipsToBounds = YES;
    self.ivAva.layer.cornerRadius = 8.f;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _ivSelected.image = [UIImage imageNamed:@"select"];
    }else{
        _ivSelected.image = [UIImage imageNamed:@"unselect"];
    }
}

@end
