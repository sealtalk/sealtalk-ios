//
//  RCSightPlayerOverlay.h
//  RongExtensionKit
//
//  Created by birney on 2017/5/12.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol RCSightPlayerOverlay <NSObject>

/**
 底部播放按钮
 */
@property(nonatomic, strong, readonly) UIButton *playBtn;

/**
 左上角关闭按钮
 */
@property(nonatomic, strong, readonly) UIButton *closeBtn;

/**
 中心播放按钮
 */
@property(nonatomic, strong, readonly) UIButton *centerPlayBtn;


/**
 右上角扩展功能按钮
 */
@property(nonatomic, strong, readonly) UIButton* extraButton;
@end
NS_ASSUME_NONNULL_END
