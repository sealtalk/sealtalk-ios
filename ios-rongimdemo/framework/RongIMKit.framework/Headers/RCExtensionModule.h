//
//  RCExtensionModule.h
//  RongExtensionKit
//
//  Created by 岑裕 on 16/7/2.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCEmoticonTabSource.h"
#import "RCExtensionPluginItemInfo.h"
#import "RCChatSessionInputBarControl.h"
#import <RongIMLib/RongIMLib.h>

/*!
 RongCloud IM扩展模块协议
 */
@protocol RCExtensionModule <NSObject>

/*!
 生成一个扩展模块。
 */
+ (instancetype)loadRongExtensionModule;

@optional
#pragma mark - SDK status notify
/*!
 初始化融云SDK
 
 @param appkey   应用的融云Appkey
 */
- (void)initWithAppKey:(NSString *)appkey;

/*!
 连接融云IM服务
 
 @param userId   用户ID
 */
- (void)didConnect:(NSString *)userId;

/*!
 断开融云IM服务
 */
- (void)didDisconnect;

/*!
 销毁扩展模块
 */
- (void)destroyModule;

/*!
 处理收到的消息
 
 @param message  收到的消息
 */
- (void)onMessageReceived:(RCMessage *)message;

/*!
 处理收到消息响铃事件
 
 @param message  收到的消息
 
 @return         扩展模块处理的结果，YES为模块处理，SDK不会响铃。NO为模块未处理，SDK会默认处理。
 @discussion     当应用处在前台时，如果在新来消息的会话内，没有铃声和通知；如果不在该会话内会铃声提示。当应用处在后台时，新来消息会弹出本地通知
 */
- (BOOL)handleAlertForMessageReceived:(RCMessage *)message;

/*!
 处理收到消息通知事件
 
 @param message   收到的消息
 @param fromName  来源名字，如果message是单聊消息就是发送者的名字，如果是群组消息就是群组名，如果是讨论组消息就是讨论组名。
 @param userInfo  LocalNotification userInfo。如果扩展模块要弹本地通知，请一定带上userInfo。
 
 @return         扩展模块处理的结果，YES为模块处理，SDK不会弹出通知。NO为模块未处理，SDK会默认处理。
 @discussion     当应用处在前台时，如果在新来消息的会话内，没有铃声和通知；如果不在该会话内会铃声提示。当应用处在后台时，新来消息会弹出本地通知
 */
- (BOOL)handleNotificationForMessageReceived:(RCMessage *)message from:(NSString *)fromName userInfo:(NSDictionary *)userInfo;

#pragma mark - App URL
/*!
 设置扩展模块URL scheme。
 
 @param scheme      URL scheme
 */
- (void)setScheme:(NSString *)scheme;

/*!
 处理openUrl请求
 
 return   是否处理
 */
- (BOOL)onOpenUrl:(NSURL *)url;

#pragma mark - Input Bar
/*!
 获取会话界面的plugin board item信息。
 
 @param conversationType  会话类型
 @param targetId          targetId
 
 @return plugin board item信息列表。
 
 @discussion 当进入到会话界面时，SDK需要注册扩展面部区域的item。
 */
- (NSArray<RCExtensionPluginItemInfo *> *)getPluginBoardItemInfoList:(RCConversationType)conversationType
                                                    targetId:(NSString *)targetId;

/*!
 获取会话输入区的表情tab页

 @param conversationType  会话类型
 @param targetId          targetId

 @return 需要加载的表情tab页列表
 */
- (NSArray<id<RCEmoticonTabSource>> *)getEmoticonTabList:(RCConversationType)conversationType
                                                targetId:(NSString *)targetId;

/*!
 点击表情面板中的加号按钮的回调

 @param emojiView       表情面板
 @param addButton       加号按钮
 @param inputBarControl 表情面板所在的输入工具栏
 */
- (void)emoticonTab:(RCEmojiBoardView *)emojiView
  didTouchAddButton:(UIButton *)addButton
         inInputBar:(RCChatSessionInputBarControl *)inputBarControl;

/*!
 点击表情面板中的设置按钮的回调

 @param emojiView       表情面板
 @param settingButton   设置Button
 @param inputBarControl 表情面板所在的输入工具栏
 */
- (void)emoticonTab:(RCEmojiBoardView *)emojiView
    didTouchSettingButton:(UIButton *)settingButton
               inInputBar:(RCChatSessionInputBarControl *)inputBarControl;

/*!
 输入框内容发生变化的回调

 @param inputTextView   文本输入框
 @param inputBarControl 文本输入框所在的输入工具栏
 */
- (void)inputTextViewDidChange:(UITextView *)inputTextView
                    inInputBar:(RCChatSessionInputBarControl *)inputBarControl;

///*!
// 点击加号面板中按钮的回调
// 
// @param emojiView       加号面板
// @param addButton       加号中的每一项
// @param inputBarControl 面板所在的输入工具栏
// */
//- (void)pluginBoard:(RCPluginBoardView *)pluginBoardView
// clickedItemWithTag:(NSInteger)tag
//         inInputBar:(RCChatSessionInputBarControl *)inputBarControl;
@end
