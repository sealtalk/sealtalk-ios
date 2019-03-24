//
//  RCCSStarView.m
//  RongSelfBuiltCustomerDemo
//
//  Created by 张改红 on 2016/12/6.
//  Copyright © 2016年 rongcloud. All rights reserved.
//

#import "RCDCSStarView.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDCommonDefine.h"
@interface RCDCSStarView ()
@property (nonatomic)int starValue; //0-4
@property (nonatomic, strong)NSArray *starButtonArray;
@property (nonatomic, strong) UILabel *starTitle;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, strong) UIImage *lightImage;
@end
@implementation RCDCSStarView
- (void)setSubviews{
  [self setDefaultStarIndex:5 starWidth:25.5 space:12];
}

- (void)setDefaultStarIndex:(NSInteger)index starWidth:(CGFloat)starWidth space:(CGFloat)space{
  self.defaultImage = [RCKitUtility imageNamed:(@"custom_service_evaluation_star")ofBundle:@"RongCloud.bundle"];
  self.lightImage = [RCKitUtility imageNamed:(@"custom_service_evaluation_star_hover")ofBundle:@"RongCloud.bundle"] ;
  [self setStarTitle];
  CGRect startFrame = self.frame;
  for (NSInteger j = 0; j < 5; j++) {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(j* (starWidth + space), 20, starWidth, self.frame.size.height-20)];
    
    btn.enabled = YES;
    btn.tag = j + 1;
    [btn addTarget:self action:@selector(starTapBtn:) forControlEvents:UIControlEventTouchUpInside];
    // 上左下右 星星居中
    [btn setImageEdgeInsets:UIEdgeInsetsMake((startFrame.size.height-20 - starWidth)/2, 0, (startFrame.size.height-20 - starWidth)/2, 0)];
    if (j < index) {
      [btn setImage:self.lightImage forState:UIControlStateNormal];
    } else {
      [btn setImage:self.defaultImage forState:UIControlStateNormal];
    }
    [self addSubview:btn];
    
    // self.width
    startFrame.size.width = (starWidth + space) * 5;
    self.frame = startFrame;
  }
}

- (void)starTapBtn:(UIButton *)btn{
  for (NSInteger i = 1; i <= 5; i++) {
    UIButton *starBtn = (UIButton *)[self viewWithTag:i];
    if (i <= btn.tag) {
      [starBtn setImage:self.lightImage forState:UIControlStateNormal];
    } else {
      [starBtn setImage:self.defaultImage forState:UIControlStateNormal];
    }
  }
  
  if (self.starDelegate && [self.starDelegate respondsToSelector:@selector(didSelectStar:)]) {
    [self.starDelegate didSelectStar:(int)btn.tag];
  }
}

- (void)setStarTitle{
  self.starTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
  self.starTitle.textColor = HEXCOLOR(0x3c4d65);
  self.starTitle.text = RCDLocalizedString(@"remark_customer");
  self.starTitle.font = [UIFont systemFontOfSize:16];
  self.starTitle.textAlignment = NSTextAlignmentCenter;
  [self addSubview:self.starTitle];
}
@end
