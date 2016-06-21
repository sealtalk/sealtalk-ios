//
//  RCChatSessionInputBarControl.h
//  RongIMKit
//
//  Created by xugang on 15/2/12.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef __RCChatSessionInputBarControl
#define __RCChatSessionInputBarControl
#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>
#import "RCTextView.h"

#define Height_ChatSessionInputBar 50.0f

/*!
 输入工具栏的显示布局
 */
typedef NS_ENUM(NSInteger, RCChatSessionInputBarControlStyle) {
    /*!
     切换-输入框-扩展
     */
    RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION = 0,
    /*!
     扩展-输入框-切换
     */
    RC_CHAT_INPUT_BAR_STYLE_EXTENTION_CONTAINER_SWITCH = 1,
    /*!
     输入框-切换-扩展
     */
    RC_CHAT_INPUT_BAR_STYLE_CONTAINER_SWITCH_EXTENTION = 2,
    /*!
     输入框-扩展-切换
     */
    RC_CHAT_INPUT_BAR_STYLE_CONTAINER_EXTENTION_SWITCH = 3,
    /*!
     切换-输入框
     */
    RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER = 4,
    /*!
     输入框-切换
     */
    RC_CHAT_INPUT_BAR_STYLE_CONTAINER_SWITCH = 5,
    /*!
     扩展-输入框
     */
    RC_CHAT_INPUT_BAR_STYLE_EXTENTION_CONTAINER = 6,
    /*!
     输入框-扩展
     */
    RC_CHAT_INPUT_BAR_STYLE_CONTAINER_EXTENTION = 7,
    /*!
     输入框
     */
    RC_CHAT_INPUT_BAR_STYLE_CONTAINER = 8,
};

/*!
 输入工具栏的菜单类型
 */
typedef NS_ENUM(NSInteger, RCChatSessionInputBarControlType) {
    /*!
     默认类型，非公众服务
     */
    RCChatSessionInputBarControlDefaultType = 0,
    /*!
     公众服务
     */
    RCChatSessionInputBarControlPubType = 1,
    
    /*!
     客服机器人
     */
    RCChatSessionInputBarControlCSRobotType = 2,
    
    /*!
     客服机器人
     */
    RCChatSessionInputBarControlNoAvailableType = 3
};

/*!
 输入工具栏的输入模式
 */
typedef NS_ENUM(NSInteger, RCChatSessionInputBarInputType) {
    /*!
     文本输入模式
     */
    RCChatSessionInputBarInputText = 0,
    /*!
     语音输入模式
     */
    RCChatSessionInputBarInputVoice = 1,
    /*!
     扩展输入模式
     */
    RCChatSessionInputBarInputExtention = 2
};

/*!
 输入工具栏的输入模式
 */
typedef NS_ENUM(NSInteger, KBottomBarStatus) {
    /*!
     初始状态
     */
    KBottomBarDefaultStatus = 0,
    /*!
     文本输入状态
     */
    KBottomBarKeyboardStatus,
    /*!
     功能板输入模式
     */
    KBottomBarPluginStatus,
    /*!
     表情输入模式
     */
    KBottomBarEmojiStatus,
    /*!
     语音消息输入模式
     */
    KBottomBarRecordStatus
};

/*!
 输入工具栏的点击监听器
 */
@protocol RCChatSessionInputBarControlDelegate;

/*!
 输入工具栏
 */
@interface RCChatSessionInputBarControl : UIView

/*!
 输入工具栏的点击回调监听
 */
@property(weak, nonatomic) id<RCChatSessionInputBarControlDelegate> delegate;

/*!
 公众服务菜单的容器View
 */
@property(weak, nonatomic) UIView *clientView;

/*!
 公众服务菜单切换的按钮
 */
@property(strong, nonatomic) UIButton *pubSwitchButton;

/*!
 客服机器人转人工切换的按钮
 */
@property(strong, nonatomic) UIButton *robotSwitchButton;

/*!
 容器View
 */
@property(strong, nonatomic) UIView *inputContainerView;

/*!
 公众服务菜单的容器View
 */
@property(strong, nonatomic) UIView *menuContainerView;

/*!
 语音与文本输入切换的按钮
 */
@property(strong, nonatomic) UIButton *switchButton;

/*!
 录制语音消息的按钮
 */
@property(strong, nonatomic) UIButton *recordButton;

/*!
 文本输入框
 */
@property(strong, nonatomic) RCTextView *inputTextView;

/*!
 表情的按钮
 */
@property(strong, nonatomic) UIButton *emojiButton;

/*!
 扩展输入的按钮
 */
@property(strong, nonatomic) UIButton *additionalButton;

/*!
 所处的聊天界面View
 */
@property(assign, nonatomic, readonly) UIView *contextView;

/*!
 Frame 起点X坐标
 */
@property(assign, nonatomic) float currentPositionY;

/*!
 Frame 起点Y坐标
 */
@property(assign, nonatomic) float originalPositionY;

/*!
 文本输入框的高度
 */
@property(assign, nonatomic) float inputTextview_height;

/*!
 公众服务账号菜单
 */
@property(strong, nonatomic) RCPublicServiceMenu *publicServiceMenu;

/*!
 初始化输入工具栏
 
 @param frame       显示的Frame
 @param contextView 所处的聊天界面View
 @param type        菜单类型
 @param style       显示布局
 @return            输入工具栏对象
 */
- (id)initWithFrame:(CGRect)frame
    withContextView:(UIView *)contextView
               type:(RCChatSessionInputBarControlType)type
              style:(RCChatSessionInputBarControlStyle)style;

/*!
 设置输入工具栏的样式
 
 @param type  菜单类型
 @param style 显示布局
 
 @discussion 您可以在聊天界面RCConversationViewController的viewDidLoad之后设置，改变输入工具栏的样式。
 */
- (void)setInputBarType:(RCChatSessionInputBarControlType)type style:(RCChatSessionInputBarControlStyle)style;

/**
 *  dismiss公众账号弹出菜单
 */
- (void)dismissPublicServiceMenuPopupView;
@end

/*!
 输入工具栏的点击监听器
 */
@protocol RCChatSessionInputBarControlDelegate <NSObject>

@optional

/*!
 键盘积即将显示的回调
 
 @param keyboardFrame 键盘最终需要显示的Frame
 */
- (void)keyboardWillShowWithFrame:(CGRect)keyboardFrame;

/*!
 键盘即将隐藏的回调
 */
- (void)keyboardWillHide;

/*!
 输入工具栏尺寸（高度）发生变化的回调
 
 @param frame 输入工具栏最终需要显示的Frame
 */
- (void)chatSessionInputBarControlContentSizeChanged:(CGRect)frame;

/*!
 点击键盘Return按钮的回调
 
 @param inputControl 当前输入工具栏
 @param text         当前输入框中国的文本内容
 */
- (void)didTouchKeyboardReturnKey:(RCChatSessionInputBarControl *)inputControl text:(NSString *)text;

/*!
 点击表情按钮的回调
 
 @param sender 表情按钮
 */
- (void)didTouchEmojiButton:(UIButton *)sender;

/*!
 点击扩展输入按钮的回调
 
 @param sender 扩展输入的按钮
 */
- (void)didTouchAddtionalButton:(UIButton *)sender;

/*!
 输入模式发生变化的回调
 
 @param switched 文本输入框最终是否隐藏
 */
- (void)didTouchSwitchButton:(BOOL)switched;

/*!
 点击公众服务的菜单切换按钮的回调
 
 @param switched 文本输入框最终是否隐藏
 */
- (void)didTouchPubSwitchButton:(BOOL)switched;

/*!
 点击客服机器人切换按钮的回调
 
 @param switched 文本输入框最终是否隐藏
 */
- (void)didTouchRobotSwitchButton:(BOOL)switched;
/*!
 点击录音按钮回调
 
 @param sender 录音按钮
 @param event  点击事件
 */
- (void)didTouchRecordButon:(UIButton *)sender event:(UIControlEvents)event;

/*!
 输入框中内容发生变化的回调
 
 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)inputTextView:(UITextView *)inputTextView
shouldChangeTextInRange:(NSRange)range
      replacementText:(NSString *)text;

/*!
 公众服务菜单的点击回调
 
 @param selectedMenuItem 点击的公众服务菜单项
 */
- (void)onPublicServiceMenuItemSelected:(RCPublicServiceMenuItem *)selectedMenuItem;

@end

#endif