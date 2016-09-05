//
//  RCNumberProgressView.h
//  RCIM
//
//  Created by xugang on 6/5/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 图片消息进度的View
 */
@interface RCImageMessageProgressView : UIView

/*!
 显示进度的Label
 */
@property(nonatomic, assign) UILabel *label;

/*!
 进度指示的View
 */
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;

/*!
 更新进度
 
 @param progress 进度值，0 <= progress <= 100
 */
- (void)updateProgress:(NSInteger)progress;

/*!
 开始播放动画
 */
- (void)startAnimating;

/*!
 停止播放动画
 */
- (void)stopAnimating;

@end
