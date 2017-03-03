//
//  UIView+Animation.h
//  HTAlertView
//
//  Created by Mr.Yang on 13-12-6.
//  Copyright (c) 2013年 MoonLightCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PopAnchor) {
    PopAnchorTop        = 1,
    PopAnchorBottom     = 1 << 1,
    PopAnchorLeft       = 1 << 2,
    PopAnchorRight      = 1 << 3,
    PopAnchorCenterX    = 1 << 4,
    PopAnchorCenterY    = 1 << 5
};

@interface UIView (YZHAnimation)

- (void)rp_popupSubView:(UIView *)view atPosition:(PopAnchor)position;

/**
 *  缩小至消失
 */
- (void)rp_shrinkDispaerWithDelegate:(id)delegate;

/**
 *  缩小
    @param 代理
 */
- (void)rp_shrinkDispaerWithCompletionBlock:(void (^) (void))animationStop1;

/**
 *  果冻效果弹出
 @param 代理
 */
- (void)rp_popOutWithDelegate:(id)delegate;

/**
 *  闪烁
 */
- (void)rp_glintAnimation;

/**
 *  左右晃动
 */
- (void)rp_shakeAnimation;

/**
 *  左右摇摆
 */
- (void)rp_shockAnimation;

/**
 *  放大
 */
- (void)rp_scaleAnimation;

/**
 *  雷达波图
 *
 *  @param count  数量
 */
- (void)rp_radar:(NSInteger)count;


@end
