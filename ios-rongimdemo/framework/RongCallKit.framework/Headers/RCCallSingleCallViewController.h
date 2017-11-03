//
//  RCCallSingleCallViewController.h
//  RongCallKit
//
//  Created by 岑裕 on 16/3/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCCallBaseViewController.h"
@class RCloudImageView;

/*!
 单人音视频ViewController
 */
@interface RCCallSingleCallViewController : RCCallBaseViewController

/*!
 对端的头像View
 */
@property(nonatomic, strong) RCloudImageView *remotePortraitView;

/*!
 对端的名字Label
 */
@property(nonatomic, strong) UILabel *remoteNameLabel;

/*!
 用户状态的view
 */
@property(nonatomic, strong) UIImageView *statusView;

/*!
 全屏的视频View
 */
@property(nonatomic, strong) UIView *mainVideoView;

/*!
 通话接通后，界面右上角的视频View
 */
@property(nonatomic, strong) UIView *subVideoView;

#pragma mark - 初始化
/*!
 初始化呼入的单人音视频ViewController

 @param callSession 呼入的通话实体

 @return 单人音视频ViewController
 */
- (instancetype)initWithIncomingCall:(RCCallSession *)callSession;

/*!
 初始化单人音视频ViewController并发起通话

 @param targetId         会话ID
 @param mediaType        通话媒体类型

 @return 单人音视频ViewController
 */
- (instancetype)initWithOutgoingCall:(NSString *)targetId mediaType:(RCCallMediaType)mediaType;

/*!
 初始化已经接通的音视频ViewController

 @param callSession 已经接通的通话实体

 @return 单人音视频ViewController
 */
- (instancetype)initWithActiveCall:(RCCallSession *)callSession;

@end
