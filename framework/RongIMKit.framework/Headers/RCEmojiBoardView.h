//
//  RCEmojiBoardView.h
//  RCIM
//
//  Created by Heq.Shinoda on 14-5-29.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCEmojiPageControl;
@class RCEmojiBoardView;

/*!
 表情输入的回调
 */
@protocol RCEmojiViewDelegate <NSObject>
@optional

/*!
 点击表情的回调
 
 @param emojiView 表情输入的View
 @param string    点击的表情对应的字符串编码
 */
- (void)didTouchEmojiView:(RCEmojiBoardView *)emojiView touchedEmoji:(NSString *)string;

/*!
 点击发送按钮的回调
 
 @param emojiView  表情输入的View
 @param sendButton 发送按钮
 */
- (void)didSendButtonEvent:(RCEmojiBoardView *)emojiView sendButton:(UIButton *)sendButton;

@end

/*!
 表情输入的View
 */
@interface RCEmojiBoardView : UIView <UIScrollViewDelegate> {
    /*!
     PageControl
     */
    RCEmojiPageControl *pageCtrl;
    
    /*!
     当前所在页的索引值
     */
    NSInteger currentIndex;
}

/*!
 表情背景的View
 */
@property(nonatomic, strong) UIScrollView *emojiBackgroundView;

/*!
 表情的Label(已废弃，请勿使用)
 
 @warning **已废弃，请勿使用。**
 */
@property(nonatomic, strong) __deprecated_msg("已废弃，请勿使用。") UILabel *emojiLabel;

/*!
 表情输入的回调
 */
@property(nonatomic, weak) id<RCEmojiViewDelegate> delegate;

/*!
 加载表情Label
 */
- (void)loadLabelView;

/*!
发送按钮是否可点击
 
 @param sender 发送者
 */
- (void)enableSendButton:(BOOL)sender;
@end
