//
//  RCConversationCell.h
//  RongIMKit
//
//  Created by xugang on 15/1/24.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef __RCConversationTableCell
#define __RCConversationTableCell
#import <UIKit/UIKit.h>
#import "RCConversationBaseCell.h"
#import "RCMessageBubbleTipView.h"
#import "RCThemeDefine.h"

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
@property(weak, nonatomic) id<RCConversationCellDelegate> delegate;

/*!
 Cell的头像背景View
 */
@property(strong, nonatomic) UIView *headerImageViewBackgroundView;

/*!
 Cell头像View
 */
@property(strong, nonatomic) RCloudImageView *headerImageView;

/*!
 会话的标题
 */
@property(strong, nonatomic) UILabel *conversationTitle;

/*!
 显示最后一条内容的Label
 */
@property(strong, nonatomic) UILabel *messageContentLabel;

/*!
 显示最后一条消息发送时间的Label
 */
@property(strong, nonatomic) UILabel *messageCreatedTimeLabel;

/*!
 头像右上角未读消息提示的View
 */
@property(strong, nonatomic) RCMessageBubbleTipView *bubbleTipView;

/*!
 会话免打扰状态显示的View
 */
@property(strong, nonatomic) UIImageView *conversationStatusImageView;

/*!
 Cell中显示的头像形状
 
 @discussion 默认值为当前IMKit的全局设置值（RCIM中的globalConversationAvatarStyle）。
 */
@property(nonatomic) RCUserAvatarStyle portraitStyle;

/*!
 是否进行新消息提醒
 
 @discussion 此属性默认会根据会话设置的提醒状态进行设置。
 */
@property(nonatomic) BOOL enableNotification;

/*!
 会话中有未读消息时，是否在头像右上角的bubbleTipView中显示数字
 
 @discussion 默认值为YES。
 您可以在RCConversationListViewController的willDisplayConversationTableCell:atIndexPath:回调中进行设置。
 */
@property(nonatomic) BOOL isShowNotificationNumber;

/*!
 Cell的背景颜色
 */
@property(strong, nonatomic) UIColor *cellBackgroundColor;

/*!
 置顶Cell的背景颜色
 */
@property(strong, nonatomic) UIColor *topCellBackgroundColor;

/*!
 显示最后一台消息发送状态
 */
@property(strong, nonatomic) UIImageView *lastSendMessageStatusView;

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
#endif