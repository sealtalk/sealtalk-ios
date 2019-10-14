//
//  RCDQuicklySendView.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDQuicklySendView : UIView

@property (nonatomic, strong) UIImage *image;

+ (instancetype)quicklSendViewWithFrame:(CGRect)frame image:(UIImage *)image;

- (void)show;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
