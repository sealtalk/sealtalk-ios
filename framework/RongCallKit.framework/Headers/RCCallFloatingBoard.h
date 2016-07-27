//
//  RCCallFloatingBoard.h
//  RongCallKit
//
//  Created by litao on 16/3/15.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongCallLib/RongCallLib.h>
#import <RongIMLib/RongIMLib.h>

/*!
 最小化显示的悬浮窗
 */
@interface RCCallFloatingBoard : NSObject

/*!
 悬浮窗的Window
 */
@property(nonatomic, strong) UIWindow *window;

/*!
 音频通话最小化时的Button
 */
@property(nonatomic, strong) UIButton *floatingButton;

/*!
 视频通话最小化时的视频View
 */
@property(nonatomic, strong) UIView *videoView;

/*!
 当前的通话实体
 */
@property(nonatomic, strong) RCCallSession *callSession;

/*!
 开启悬浮窗

 @param callSession  通话实体
 @param touchedBlock 悬浮窗点击的Block
 */
+ (void)startCallFloatingBoard:(RCCallSession *)callSession
              withTouchedBlock:
                  (void (^)(RCCallSession *callSession))touchedBlock;

/*!
 关闭当前悬浮窗
 */
+ (void)stopCallFloatingBoard;

@end
