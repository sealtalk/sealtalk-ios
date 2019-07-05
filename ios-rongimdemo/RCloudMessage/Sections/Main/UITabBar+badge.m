//
//  UITabBar+badge.m
//  RCloudMessage
//
//  Created by Jue on 16/7/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "UITabBar+badge.h"
#define TabbarItemNums 4.0
#import "RCDTabBarBtn.h"
#import "UIColor+RCColor.h"
#import "RCDCommonDefine.h"

@implementation UITabBar (badge)

- (void)showBadgeOnItemIndex:(int)index {
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];

    //新建小红点
    UIView *badgeView = [[UIView alloc] init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 5.f;                                           //圆形
    badgeView.backgroundColor = [UIColor colorWithHexString:@"f43530" alpha:1.0]; //颜色：红色
    CGRect tabFrame = self.frame;

    //确定小红点的位置
    float percentX = (index + 0.5) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 10, 10); //圆形大小为10
    [self addSubview:badgeView];
}

- (void)showBadgeOnItemIndex:(int)index badgeValue:(int)badgeValue {
    /*
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

     RCDTabBarBtn *testBtn = [RCDTabBarBtn new];
     testBtn.tag = 888+index;
     testBtn.layer.cornerRadius = 9;
     testBtn.maxDistance = 20;
     [testBtn setTitle:@"99" forState:UIControlStateNormal];
     [testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [testBtn setBackgroundColor:[UIColor redColor]];
     if (badgeValue < 10) {
     testBtn.frame = CGRectMake(x, y, 18, 18);//圆形
     //badgeLabel.frame = CGRectMake(3, 3, 12, 12);
     //badgeLabel.text = [NSString stringWithFormat:@"%d",badgeValue];
     }
     if (badgeValue >= 10 && badgeValue < 100 ) {
     testBtn.frame = CGRectMake(x, y, 22, 18);//椭圆形
     //badgeLabel.frame = CGRectMake(1, 3, 20, 12);
     //badgeLabel.text = [NSString stringWithFormat:@"%d",badgeValue];
     }
     if (badgeValue >= 100) {
     testBtn.frame = CGRectMake(x, y, 26, 18);//椭圆形
     // badgeLabel.frame = CGRectMake(1, 0, 24, 10);
     //badgeLabel.text = @"...";
     }
     [self addSubview:testBtn];

     //[self addSubview:badgeView];
     */
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];

    //新建小红点
    CGRect tabFrame = self.frame;
    //确定小红点的位置
    float scale = 0.5;
    if (RCDIsIPad) {
        if (([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            scale = 0.55;
        } else {
            scale = 0.6;
        }
    }
    float percentX = (index + scale) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    if (badgeValue < 10) {
        [self initUnreadCountButton:CGRectMake(x, y, 18, 18) tag:888 + index badgeValue:badgeValue];
    }
    if (badgeValue >= 10 && badgeValue < 100) {
        [self initUnreadCountButton:CGRectMake(x, y, 22, 18) tag:888 + index badgeValue:badgeValue];
    }
    if (badgeValue >= 100) {
        RCDTabBarBtn *btn = [[RCDTabBarBtn alloc] initWithFrame:CGRectMake(x, y, 22, 18)];
        [btn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [self addSubview:btn];
        btn.tag = 888 + index;
        // btn.layer.cornerRadius = 9;//圆形
    }
}

//隐藏小红点
- (void)hideBadgeOnItemIndex:(int)index {
    //移除小红点
    [self removeBadgeOnItemIndex:index];
}

//移除小红点
- (void)removeBadgeOnItemIndex:(int)index {
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888 + index) {
            [((RCDTabBarBtn *)subView).shapeLayer removeFromSuperlayer];
            [subView removeFromSuperview];
        }
    }
}

- (void)initUnreadCountButton:(CGRect)frame tag:(NSUInteger)tag badgeValue:(int)badgeValue {
    RCDTabBarBtn *btn = [[RCDTabBarBtn alloc] initWithFrame:frame];
    [self addSubview:btn];
    btn.tag = tag;
    btn.layer.cornerRadius = 9; //圆形
    btn.unreadCount = [NSString stringWithFormat:@"%d", badgeValue];
}

@end
