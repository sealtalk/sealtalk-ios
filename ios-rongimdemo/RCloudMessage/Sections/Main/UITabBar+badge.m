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
#import <objc/runtime.h>

#define RCDTabBarButtonTagFrom 888

@implementation UITabBar (badge)
- (void)bringBadgeToFrontOnItemIndex:(int)index {
    NSInteger tag = RCDTabBarButtonTagFrom + index;
    RCDTabBarBtn *badge = [self viewWithTag:tag];
    if (badge) {
        [badge removeFromSuperview];
        [self addSubview:badge];
    }
}

- (void)showBadgeOnItemIndex:(int)index {
    [self showBadgeOnItemIndex:index badgeValue:0];
}

- (void)showBadgeOnItemIndex:(int)index badgeValue:(int)badgeValue {
    [self showBadgeOnItemIndex:index badgeValue:badgeValue userInteractionEnabled:YES];
}

- (void)showBadgeOnItemIndex:(int)index badgeValue:(int)badgeValue userInteractionEnabled:(BOOL)enable {
    NSInteger itemsCount = self.items.count;
    NSInteger tag = RCDTabBarButtonTagFrom + index;
    RCDTabBarBtn *badge = [self viewWithTag:tag];
    CGRect decideFrame;
    CGRect tabFrame = self.frame;
    if (RCD_IS_IPHONEX) {
        tabFrame.size.height = 49.0 + 34.0;
    } else {
        tabFrame.size.height = 49.0;
    }
    float peRCDntX = (index + 0.51) / itemsCount;
    CGFloat x = ceilf(peRCDntX * tabFrame.size.width);
    if (index == 0) {
        x = x + 4;
    }
    CGFloat y = ceilf(0.07 * tabFrame.size.height);
    if (badgeValue > 0) {
        CGFloat width = 18;
        if (badgeValue >= 10 && badgeValue < 100) {
            width = 22;
        } else if (badgeValue >= 100 && badgeValue < 1000) {
            width = 30;
        }
        decideFrame = CGRectMake(x, y, width, 18);
    } else {
        decideFrame = CGRectMake(x, y, 10, 10);
    }
    if (!badge) {
        badge = [[RCDTabBarBtn alloc] initWithFrame:decideFrame];
        badge.tag = tag;
        [self addSubview:badge];
    }
    [badge setFrame:decideFrame];
    badge.layer.cornerRadius = badge.frame.size.height / 2;
    badge.hidden = NO;
    if (badgeValue) {
        badge.userInteractionEnabled = enable;
        if (badgeValue <= 99) {
            badge.unreadCount = [NSString stringWithFormat:@"%d", badgeValue];
        } else if (badgeValue > 99 && badgeValue < 1000) {
            badge.unreadCount = [NSString stringWithFormat:@"99+"];
        } else {
            badge.unreadCount = [NSString stringWithFormat:@"···"];
        }
    } else {
        badge.userInteractionEnabled = NO;
        badge.unreadCount = @"";
    }
}
- (void)deviceOrientationChange {
    if (RCDIsIPad) {
        NSInteger itemsCount = self.items.count;
        CGRect tabFrame = self.frame;
        for (NSInteger index = 0; index < itemsCount; index++) {
            RCDTabBarBtn *badge = [self viewWithTag:index + RCDTabBarButtonTagFrom];
            float peRCDntX = (index + 0.51) / itemsCount;
            CGFloat x = ceilf(peRCDntX * tabFrame.size.width);
            if (index == 0) {
                x = x + 4;
            }
            CGFloat y = ceilf(0.07 * tabFrame.size.height);
            CGRect frame = badge.frame;
            frame.origin.x = x;
            frame.origin.y = y;
            badge.frame = frame;
        }
    }
}
//隐藏小红点
- (void)hideBadgeOnItemIndex:(int)index {
    RCDTabBarBtn *badge = [self viewWithTag:RCDTabBarButtonTagFrom + index];
    badge.hidden = YES;
}

@end
