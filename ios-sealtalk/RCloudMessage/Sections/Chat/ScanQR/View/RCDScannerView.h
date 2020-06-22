//
//  RCDQRInfoHandle.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//
#import <UIKit/UIKit.h>
@protocol RCDScannerViewDelegate <NSObject>
- (void)didClickSelectImageButton;
@end

@interface RCDScannerView : UIView
@property (nonatomic, weak) id<RCDScannerViewDelegate> delegate;

/** 添加扫描线条动画 */
- (void)rcd_addScannerLineAnimation;

/** 暂停扫描线条动画 */
- (void)rcd_pauseScannerLineAnimation;

/** 添加指示器 */
- (void)rcd_addActivityIndicator;

/** 移除指示器 */
- (void)rcd_removeActivityIndicator;

- (CGFloat)scanner_x;
- (CGFloat)scanner_y;
- (CGFloat)scanner_width;

/**
 显示手电筒
 @param animated 是否附带动画
 */
- (void)rcd_showFlashlightWithAnimated:(BOOL)animated;

/**
 隐藏手电筒
 @param animated 是否附带动画
 */
- (void)rcd_hideFlashlightWithAnimated:(BOOL)animated;

/**
 设置手电筒开关
 @param on YES:开  NO:关
 */
- (void)rcd_setFlashlightOn:(BOOL)on;

/**
 获取手电筒当前开关状态
 @return YES:开  NO:关
 */
- (BOOL)rcd_flashlightOn;

@end
