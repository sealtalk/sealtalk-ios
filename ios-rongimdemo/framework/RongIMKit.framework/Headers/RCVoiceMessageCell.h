//
//  RCVoiceMessageCell.h
//  RongIMKit
//
//  Created by xugang on 15/2/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageCell.h"

#define kAudioBubbleMinWidth 70
#define kAudioBubbleMaxWidth 180
#define kBubbleBackgroundViewHeight 36

/*!
 语音消息播放停止的Notification
 */
UIKIT_EXTERN NSString *const kNotificationStopVoicePlayer;

/*!
 语音消息Cell
 */
@interface RCVoiceMessageCell : RCMessageCell

/*!
 消息的背景View
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*!
 语音播放的View
 */
@property(nonatomic, strong) UIImageView *playVoiceView;

/*!
 显示是否已播放的View
 */
@property(nonatomic, strong) UIImageView *voiceUnreadTagView;

/*!
 显示语音时长的Label
 */
@property(nonatomic, strong) UILabel *voiceDurationLabel;

/*!
 播放语音
 */
- (void)playVoice;

@end
