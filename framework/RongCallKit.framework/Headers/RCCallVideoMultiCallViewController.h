//
//  RCCallVideoMultiCallViewController.h
//  RongCallKit
//
//  Created by litao on 16/3/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCCallBaseViewController.h"
@class RCloudImageView;

/*!
 多人视频ViewController
 */
@interface RCCallVideoMultiCallViewController : RCCallBaseViewController

/*!
 通话呼入时，最上方显示的邀请者头像View
 */
@property(nonatomic, strong) RCloudImageView *inviterPortraitView;

/*!
 通话呼入时，最上方显示的邀请者名字Label
 */
@property(nonatomic, strong) UILabel *inviterNameLabel;

/*!
 全屏的用户的名称Label
 */
@property(nonatomic, strong) UILabel *mainNameLabel;

/*!
 通话呼入时，用户列表说明的Label
 */
@property(nonatomic, strong) UILabel *userCollectionTitleLabel;

/*!
 用户视频列表的CollectionView
 */
@property(nonatomic, strong) UICollectionView *userCollectionView;

/*!
 用户视频列表CollectionView所使用的Layout

 @discussion
 默认使用的是RCVideoMultiCallUserCollectionLayout，您也可以自定义Layout。
 */
@property(nonatomic, strong) UICollectionViewLayout *userCollectionViewLayout;

#pragma mark - 初始化
/*!
 初始化呼入的多人视频ViewController

 @param callSession 呼入的通话实体

 @return 多人视频ViewController
 */
- (instancetype)initWithIncomingCall:(RCCallSession *)callSession;

/*!
 初始化多人视频ViewController并发起通话

 @param conversationType 会话类型
 @param targetId         会话目标ID
 @param userIdList       邀请的用户ID列表

 @return 多人视频ViewController
 */
- (instancetype)initWithOutgoingCall:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                          userIdList:(NSArray *)userIdList;

/*!
 初始化已经接通的多人音视频ViewController

 @param callSession 已经接通的通话实体

 @return 多人视频ViewController
 */
- (instancetype)initWithActiveCall:(RCCallSession *)callSession;

@end
