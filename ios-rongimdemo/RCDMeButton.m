//
//  RCDMeButton.m
//  RCloudMessage
//
//  Created by Jue on 16/7/15.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMeButton.h"

@implementation RCDMeButton

-(instancetype) init
{
  if (self) {
    self = (RCDMeButton *)[UIButton buttonWithType:UIButtonTypeCustom];
    self.frame = CGRectMake(0, 6, 87, 23);
    UIImageView *backImg = [[UIImageView alloc]
                            initWithImage:[UIImage imageNamed:@"navigator_btn_back"]];
    backImg.frame = CGRectMake(-6, 4, 10, 17);
    [self addSubview:backImg];
    UILabel *backText =
    [[UILabel alloc] initWithFrame:CGRectMake(9,4, 85, 17)];
    backText.text = @"我";
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [self addSubview:backText];
  }
  return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
