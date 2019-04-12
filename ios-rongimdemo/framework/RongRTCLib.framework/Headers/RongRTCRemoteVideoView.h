//
//  RCRemoteVideoView.h
//  RongRTCLib
//
//  Created by zhaobingdong on 2018/12/17.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RongRTCVideoPreviewView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 渲染远端视频的 view
 */
@interface RongRTCRemoteVideoView : RongRTCVideoPreviewView

/**
 是否隐藏视图
 
 @param isHidden 是否关闭
 */
- (void)hiddenVideoView:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
