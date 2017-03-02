//
//  RCMessageCell.h
//  RongIMKit
//
//  Created by xugang on 15/1/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageBaseCell.h"
#import "RCThemeDefine.h"
#import "RCMessageCellNotificationModel.h"
#import "RCMessageCellDelegate.h"
#import "RCContentView.h"

//#define PORTRAIT_WIDTH 45
//#define PORTRAIT_HEIGHT 45
#define HeadAndContentSpacing 6

@class RCloudImageView;

/*!
 展示的消息Cell类
 
 @discussion 需要展示用户信息和内容的消息Cell可以继承此类，
 如：RCTextMessageCell、RCImageMessageCell、RCLocationMessageCell、RCVoiceMessageCell、RCRichContentMessageCell等。
 如果您需要显示自定义消息，可以继承此类。
 */
@interface RCMessageCell : RCMessageBaseCell

/*!
消息发送者的用户头像
*/
@property(nonatomic, strong) RCloudImageView *portraitImageView;

/*!
 消息发送者的用户名称
 */
@property(nonatomic, strong) UILabel *nicknameLabel;

/*!
 消息内容的View
 */
@property(nonatomic, strong) RCContentView *messageContentView;

/*!
 显示发送状态的View
 
 @discussion 其中包含messageFailedStatusView子View。
 */
@property(nonatomic, strong) UIView *statusContentView;

/*!
 显示发送失败状态的View
 */
@property(nonatomic, strong) UIButton *messageFailedStatusView;

/*!
 消息发送指示View
 */
@property(nonatomic, strong) UIActivityIndicatorView *messageActivityIndicatorView;

/*!
 消息内容的View的宽度
 */
@property(nonatomic, readonly) CGFloat messageContentViewWidth;

/*!
 显示的用户头像形状
 */
@property(nonatomic, assign, setter=setPortraitStyle:) RCUserAvatarStyle portraitStyle;

/*!
 是否显示用户名称
 */
@property(nonatomic, readonly) BOOL isDisplayNickname;

/*!
 显示消息已阅读状态的View
 */
@property(nonatomic, strong) UIView *messageHasReadStatusView;

/*!
 显示是否消息回执的Button
 
 @discussion 仅在群组和讨论组中显示
 */
@property(nonatomic, strong) UIButton *receiptView;

/*!
 消息阅读人数的Label
 
 @discussion 仅在群组和讨论组中显示
 */
@property(nonatomic, strong) UILabel *receiptCountLabel;

/*!
 显示群是否消息回执的Button
 
 @warning 如果您使用了该属性，可以迁移到receiptView，完全一致。
 */
@property(nonatomic, strong) UIButton *groupAndDiscussionReceiptView __deprecated_msg("已废弃，请勿使用。");

/*!
 消息阅读人数的Label
 
 @warning 如果您使用了该属性，可以迁移到receiptCountLabel，完全一致。
 */
@property(nonatomic, strong) UILabel *groupAndDiscussionReceiptCountView __deprecated_msg("已废弃，请勿使用。");

/*!
 显示消息发送成功状态的View
 */
@property(nonatomic, strong) UIView *messageSendSuccessStatusView;

/*!
 设置当前消息Cell的数据模型
 
 @param model 消息Cell的数据模型
 */
- (void)setDataModel:(RCMessageModel *)model;

/*!
 更新消息发送状态
 
 @param model 消息Cell的数据模型
 */
- (void)updateStatusContentView:(RCMessageModel *)model;

@end
