//
//  RCEmojiBoardView.h
//  RongExtensionKit
//
//  Created by Heq.Shinoda on 14-5-29.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCEmoticonTabSource.h"
#import <RongIMLib/RongIMLib.h>
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
@interface RCEmojiBoardView : UIView <UIScrollViewDelegate>

/*!
 当前的会话类型
 */
@property(nonatomic, assign) RCConversationType conversationType;

/*!
 当前的会话ID
 */
@property(nonatomic, strong) NSString *targetId;

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
 表情区域的大小
 */
@property(nonatomic, assign, readonly) CGSize contentViewSize;

/**
 *  init
 *
 *  @param frame            frame
 *  @param delegate         实现RCEmojiViewDelegate的实体
 */
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<RCEmojiViewDelegate>)delegate;
/*!
 加载表情Label
 */
- (void)loadLabelView;

/*!
发送按钮是否可点击

 @param sender 发送者
 */
- (void)enableSendButton:(BOOL)sender;
/**
 *  添加表情包（普通开发者调用添加表情包）
 *
 *  @param viewDataSource 每页表情的数据源代理，当滑动需要加载表情页时会回调代理的方法，您需要返回表情页的view
 */
- (void)addEmojiTab:(id<RCEmoticonTabSource>)viewDataSource;
/**
 *  添加Extention表情包(用于第三方表情厂商添加表情包)
 *
 *  @param viewDataSource 每页表情的数据源代理，当滑动需要加载表情页时会回调代理的方法，您需要返回表情页的view
 */
- (void)addExtensionEmojiTab:(id<RCEmoticonTabSource>)viewDataSource;
/**
 *  表情页页码以及选中的页
 */
- (void)setCurrentIndex:(int)index withTotalPages:(int)totalPageNum;

/**
 *  重新加载通过扩展方式加载的表情包，（调用这个方法会回调RCExtensionModule 协议实现的扩展通过 addEmojiTab
 * 加入的表情包不会重写加载）
 */
- (void)reloadExtensionEmoticonTabSource;

@end
