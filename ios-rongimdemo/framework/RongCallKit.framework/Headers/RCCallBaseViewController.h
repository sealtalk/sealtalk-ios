//
//  RCCallBaseViewController.h
//  RongCallKit
//
//  Created by 岑裕 on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongCallLib/RongCallLib.h>
#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>

/*!
 通话的ViewController基类

 @discussion
 单人音视频通话RCCallSingleCallViewController、多人音频通话RCCallAudioMultiCallViewController、多人视频通话RCCallVideoMultiCallViewController均继承此类。
 */
@interface RCCallBaseViewController : UIViewController <RCCallSessionDelegate>

/*!
 会话类型
 */
@property(nonatomic, assign, readonly) RCConversationType conversationType;

/*!
 会话目标ID
 */
@property(nonatomic, strong, readonly) NSString *targetId;

/*!
 媒体类型
 */
@property(nonatomic, assign, readonly) RCCallMediaType mediaType;

/*!
 通话实体
 */
@property(nonatomic, strong, readonly) RCCallSession *callSession;

/*!
 背景View
 */
@property(nonatomic, strong) UIView *backgroundView;

/*!
 蒙层View
 */
@property(nonatomic, strong) UIVisualEffectView *blurView;

/*!
 最小化Button
 */
@property(nonatomic, strong) UIButton *minimizeButton;

/*!
 加人Button
 */
@property(nonatomic, strong) UIButton *inviteUserButton;

/*!
 通话时长Label
 */
@property(nonatomic, strong) UILabel *timeLabel;

/*!
 提示Label
 */
@property(nonatomic, strong) UILabel *tipsLabel;

/*!
 静音Button
 */
@property(nonatomic, strong) UIButton *muteButton;

/*!
 扬声器Button
 */
@property(nonatomic, strong) UIButton *speakerButton;

/*!
 接听Button
 */
@property(nonatomic, strong) UIButton *acceptButton;

/*!
 挂断Button
 */
@property(nonatomic, strong) UIButton *hangupButton;

/*!
 关闭摄像头的Button
 */
@property(nonatomic, strong) UIButton *cameraCloseButton;

/*!
 切换前后摄像头的Button
 */
@property(nonatomic, strong) UIButton *cameraSwitchButton;

/*!
 + Button
 */
@property (nonatomic, strong) UIButton *addButton;

/*!
 举手Button
 */
@property (nonatomic, strong) UIButton *handUpButton;

/*!
 白板Button
 */
@property (nonatomic, strong) UIButton *whiteBoardButton;

/*!
 信号强度ImageView
 */
@property (nonatomic, strong) UIImageView *signalImageView;

#pragma mark - 回调
/*!
 通话即将接通
 */
- (void)callWillConnect;

/*!
 通话即将挂断
 */
- (void)callWillDisconnect;

/*!
 即将显示提示

 @param warning 需要显示提示的错误码

 @return 是否显示提示
 */
- (BOOL)tipsWillShow:(RCCallErrorCode)warning;

/*!
 点击最小化Button的回调
 */
- (void)didTapMinimizeButton;

/*!
 点击加人Button的回调
 */
- (void)didTapInviteUserButton;

/*!
 点击接听Button的回调
 */
- (void)didTapAcceptButton;

/*!
 点击挂断Button的回调
 */
- (void)didTapHangupButton;

/*!
 点击扬声器Button的回调
 */
- (void)didTapSpeakerButton;

/*!
 点击静音Button的回调
 */
- (void)didTapMuteButton;

/*!
 点击开启、关闭摄像头Button的回调
 */
- (void)didTapCameraCloseButton;

/*!
 点击切换前后摄像头Button的回调
 */
- (void)didTapCameraSwitchButton;

/*!
 重新Layout布局

 @param isMultiCall      是否多方通话
 @param mediaType        通话媒体类型
 @param callStatus       通话状态

 @discussion 如果您需要重写并调整UI的布局，应该先调用super。
 */
- (void)resetLayout:(BOOL)isMultiCall mediaType:(RCCallMediaType)mediaType callStatus:(RCCallStatus)callStatus;

- (void)inviteUserButtonClicked;

- (void)whiteBoardButtonClicked;

- (void)hangupButtonClicked;

#pragma mark - 初始化
/*!
 初始化呼入的ViewController

 @param callSession 呼入的通话实体

 @return ViewController
 */
- (instancetype)initWithIncomingCall:(RCCallSession *)callSession;

/*!
 初始化ViewController并发起通话

 @param conversationType 会话类型
 @param targetId         会话目标ID
 @param mediaType        通话媒体类型
 @param userIdList       邀请的用户ID列表

 @return ViewController
 */
- (instancetype)initWithOutgoingCall:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                           mediaType:(RCCallMediaType)mediaType
                          userIdList:(NSArray *)userIdList;

/*!
 初始化已经接通的ViewController

 @param callSession 已经接通的通话实体

 @return ViewController
 */
- (instancetype)initWithActiveCall:(RCCallSession *)callSession;

@end
