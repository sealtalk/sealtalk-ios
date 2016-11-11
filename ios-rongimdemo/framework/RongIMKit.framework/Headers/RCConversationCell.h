//
//  RCConversationCell.h
//  RongIMKit
//
//  Created by xugang on 15/1/24.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCConversationBaseCell.h"
#import "RCMessageBubbleTipView.h"
#import "RCThemeDefine.h"
#import <UIKit/UIKit.h>

#define CONVERSATION_ITEM_HEIGHT 65.0f
@protocol RCConversationCellDelegate;
@class RCloudImageView;

/*!
 会话Cell类
 */
@interface RCConversationCell : RCConversationBaseCell

/*!
 会话Cell的点击监听器
 */
@property(nonatomic, weak) id<RCConversationCellDelegate> delegate;

/*!
 Cell的头像背景View
 */
@property(nonatomic, strong) UIView *headerImageViewBackgroundView;

/*!
 Cell头像View
 */
@property(nonatomic, strong) RCloudImageView *headerImageView;

/*!
 会话的标题
 */
@property(nonatomic, strong) UILabel *conversationTitle;

/*!
 显示最后一条内容的Label
 */
@property(nonatomic, strong) UILabel *messageContentLabel;

/*!
 显示最后一条消息发送时间的Label
 */
@property(nonatomic, strong) UILabel *messageCreatedTimeLabel;

/*!
 头像右上角未读消息提示的View
 */
@property(nonatomic, strong) RCMessageBubbleTipView *bubbleTipView;

/*!
 会话免打扰状态显示的View
 */
@property(nonatomic, strong) UIImageView *conversationStatusImageView;

/*!
 Cell中显示的头像形状

 @discussion 默认值为当前IMKit的全局设置值（RCIM中的globalConversationAvatarStyle）。
 */
@property(nonatomic, assign) RCUserAvatarStyle portraitStyle;

/*!
 是否进行新消息提醒

 @discussion 此属性默认会根据会话设置的提醒状态进行设置。
 */
@property(nonatomic, assign) BOOL enableNotification;

/*!
 会话中有未读消息时，是否在头像右上角的bubbleTipView中显示数字

 @discussion 默认值为YES。
 您可以在RCConversationListViewController的willDisplayConversationTableCell:atIndexPath:回调中进行设置。
 */
@property(nonatomic, assign) BOOL isShowNotificationNumber;

/*!
 是否在群组和讨论组会话Cell中隐藏发送者的名称 
 */
@property(nonatomic, assign) BOOL hideSenderName;

/*!
 非置顶的Cell的背景颜色
 */
@property(nonatomic, strong) UIColor *cellBackgroundColor;

/*!
 置顶Cell的背景颜色
 */
@property(nonatomic, strong) UIColor *topCellBackgroundColor;

/*!
 显示最后一台消息发送状态
 */
@property(nonatomic, strong) UIImageView *lastSendMessageStatusView;

/*!
 设置Cell中显示的头像形状

 @param portraitStyle 头像形状

 @discussion 此设置仅当前会话Cell有效。
 */
- (void)setHeaderImagePortraitStyle:(RCUserAvatarStyle)portraitStyle;

/*!
 设置当前会话Cell的数据模型

 @param model 会话Cell的数据模型
 */
- (void)setDataModel:(RCConversationModel *)model;

@end

/*!
 会话Cell的点击监听器
 */
@protocol RCConversationCellDelegate <NSObject>

/*!
 点击Cell头像的回调

 @param model 会话Cell的数据模型
 */
- (void)didTapCellPortrait:(RCConversationModel *)model;

/*!
 长按Cell头像的回调

 @param model 会话Cell的数据模型
 */
- (void)didLongPressCellPortrait:(RCConversationModel *)model;

@end
