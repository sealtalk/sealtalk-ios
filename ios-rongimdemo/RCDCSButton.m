//
//  RCDCSButton.m
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/6.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDCSButton.h"
#import "RCDCommonDefine.h"
@implementation RCDCSButton
- (instancetype)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
    [self setTitleColor:HEXCOLOR(0x939dab) forState:(UIControlStateNormal)];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = HEXCOLOR(0xb4bdcd).CGColor;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
  }
  return self;
}

- (void)setSelected:(BOOL)selected{
  if (selected) {
    self.backgroundColor = HEXCOLOR(0xe3eeff);
    self.layer.borderColor = HEXCOLOR(0x91bcff).CGColor;
    [self setTitleColor:HEXCOLOR(0x4d8df0) forState:(UIControlStateNormal)];
  }else{
    [self setTitleColor:HEXCOLOR(0x939dab) forState:(UIControlStateNormal)];
    self.layer.borderColor = HEXCOLOR(0xb4bdcd).CGColor;
    self.backgroundColor = HEXCOLOR(0xffffff);
  }
  super.selected = selected;
}
@end
