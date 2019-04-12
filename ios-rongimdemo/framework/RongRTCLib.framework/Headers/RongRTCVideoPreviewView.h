//
//  RCVideoPreview.h
//  RongRTCLib
//
//  Created by zhaobingdong on 2018/12/17.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 视频填充模式
 */
typedef NS_ENUM(NSInteger, RCVideoFillMode) {
    /**
     自适应大小显示
     */
    RCVideoFillModeAspect ,
    /**
     填充显示
     */
    RCVideoFillModeAspectFill
};

NS_ASSUME_NONNULL_BEGIN

/**
 预览视频的 view
 */
@interface RongRTCVideoPreviewView : UIView

/**
 视频填充方式
 */
@property(nonatomic,assign) RCVideoFillMode fillMode;

@end

NS_ASSUME_NONNULL_END
