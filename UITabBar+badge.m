//
//  UITabBar+badge.m
//  RCloudMessage
//
//  Created by Jue on 16/7/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "UITabBar+badge.h"
#define TabbarItemNums 4.0
#import "UIColor+RCColor.h"

@implementation UITabBar (badge)

- (void)showBadgeOnItemIndex:(int)index{
  //移除之前的小红点
  [self removeBadgeOnItemIndex:index];
  
  //新建小红点
  UIView *badgeView = [[UIView alloc]init];
  badgeView.tag = 888+index;
  badgeView.layer.cornerRadius = 5.f;//圆形
  badgeView.backgroundColor = [UIColor colorWithHexString:@"f43530" alpha:1.0];//颜色：红色
  CGRect tabFrame = self.frame;
  
  //确定小红点的位置
  float percentX = (index +0.5) / TabbarItemNums;
  CGFloat x = ceilf(percentX * tabFrame.size.width);
  CGFloat y = ceilf(0.1 * tabFrame.size.height);
  badgeView.frame = CGRectMake(x, y, 10, 10);//圆形大小为10
  [self addSubview:badgeView];
}

- (void)showBadgeOnItemIndex:(int)index badgeValue:(int)badgeValue{
  //移除之前的小红点
  [self removeBadgeOnItemIndex:index];
  
  //新建小红点
  UIView *badgeView = [[UIView alloc]init];
  badgeView.tag = 888+index;
  badgeView.layer.cornerRadius = 9;//圆形
  badgeView.backgroundColor = [UIColor colorWithHexString:@"f43530" alpha:1.0];//颜色：红色
  CGRect tabFrame = self.frame;
  
  //新建Badge Label
  UILabel *badgeLabel = [[UILabel alloc] init];
  badgeLabel.font = [UIFont systemFontOfSize:12.f];
  badgeLabel.textColor = [UIColor whiteColor];
  badgeLabel.textAlignment = NSTextAlignmentCenter;
  [badgeView addSubview:badgeLabel];
  
  //确定小红点的位置
  float percentX = (index +0.55) / TabbarItemNums;
  CGFloat x = ceilf(percentX * tabFrame.size.width);
  CGFloat y = ceilf(0.1 * tabFrame.size.height);
  if (badgeValue < 10) {
    badgeView.frame = CGRectMake(x, y, 18, 18);//圆形
    badgeLabel.frame = CGRectMake(3, 3, 12, 12);
    badgeLabel.text = [NSString stringWithFormat:@"%d",badgeValue];
  }
  if (badgeValue >= 10 && badgeValue < 100 ) {
    badgeView.frame = CGRectMake(x, y, 22, 18);//椭圆形
    badgeLabel.frame = CGRectMake(1, 3, 20, 12);
    badgeLabel.text = [NSString stringWithFormat:@"%d",badgeValue];
  }
  if (badgeValue >= 100) {
    badgeView.frame = CGRectMake(x, y, 26, 18);//椭圆形
    badgeLabel.frame = CGRectMake(1, 0, 24, 10);
    badgeLabel.text = @"...";
  }
  
  [self addSubview:badgeView];
}

//隐藏小红点
- (void)hideBadgeOnItemIndex:(int)index{
  //移除小红点
  [self removeBadgeOnItemIndex:index];
}

//移除小红点
- (void)removeBadgeOnItemIndex:(int)index{
  //按照tag值进行移除
  for (UIView *subView in self.subviews) {
    if (subView.tag == 888+index) {
      [subView removeFromSuperview];
    }
  }
}

@end
