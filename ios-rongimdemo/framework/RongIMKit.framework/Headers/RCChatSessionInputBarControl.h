//
//  RCChatSessionInputBarControl.h
//  RongExtensionKit
//
//  Created by xugang on 15/2/12.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>
#import "RCTextView.h"
#import "RCEmojiBoardView.h"
#import "RCPluginBoardView.h"

#define RC_ChatSessionInputBar_Height 50.f
///输入栏扩展输入的唯一标示
#define INPUT_MENTIONED_SELECT_TAG       1000
#define PLUGIN_BOARD_ITEM_ALBUM_TAG      1001
#define PLUGIN_BOARD_ITEM_CAMERA_TAG     1002
#define PLUGIN_BOARD_ITEM_LOCATION_TAG   1003
#define PLUGIN_BOARD_ITEM_VOIP_TAG       1101
#define PLUGIN_BOARD_ITEM_VIDEO_VOIP_TAG 1102
#define PLUGIN_BOARD_ITEM_FILE_TAG       1006
#define PLUGIN_BOARD_ITEM_EVA_TAG        1103


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
 输入工具栏的数据源
 */
@protocol RCChatSessionInputBarControlDataSource;

/*!
 输入工具栏
 */
@interface RCChatSessionInputBarControl : UIView

/*!
 当前的会话类型
 */
@property(nonatomic, assign) RCConversationType conversationType;

/*!
 当前的会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 输入工具栏的点击回调监听
 */
@property(weak, nonatomic) id<RCChatSessionInputBarControlDelegate> delegate;

/*!
 输入工具栏的点击回调监听
 */
@property(weak, nonatomic) id<RCChatSessionInputBarControlDataSource> dataSource;

/*!
 公众服务菜单的容器View
 
 @warning  **已废弃，请勿使用。**
 升级说明：如果您之前使用了此属性，可以直接替换为containerView属性，行为和实现完全一致。
 */
@property(weak, nonatomic) UIView *clientView __deprecated_msg("已废弃，请勿使用。");

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
 所处的会话页面View
 */
@property(assign, nonatomic, readonly) UIView *containerView;

/*!
 当前的输入状态
 */
@property(nonatomic) KBottomBarStatus currentBottomBarStatus;
/*!
 所处的会话页面View
 
 @warning  **已废弃，请勿使用。**
 升级说明：如果您之前使用了此属性，可以直接替换为contextView属性，行为和实现完全一致。
 */
@property(assign, nonatomic, readonly) UIView *contextView
__deprecated_msg("已废弃，请勿使用。");

/*!
 Frame现在的Y坐标
 */
@property(assign, nonatomic) float currentPositionY
__deprecated_msg("已废弃，请勿使用。");

/*!
 Frame之前的Y坐标
 */
@property(assign, nonatomic) float originalPositionY
__deprecated_msg("已废弃，请勿使用。");

/*!
 文本输入框的高度
 */
@property(assign, nonatomic) float inputTextview_height
__deprecated_msg("已废弃，请勿使用。");

/*!
 公众服务账号菜单
 */
@property(strong, nonatomic) RCPublicServiceMenu *publicServiceMenu;

/*!
 输入扩展功能板View
 */
@property(nonatomic, strong) RCPluginBoardView *pluginBoardView;

/*!
 表情View
 */
@property(nonatomic, strong) RCEmojiBoardView *emojiBoardView;

/*!
 草稿
 */
@property(nonatomic, strong) NSString *draft;

/*!
 @提醒信息
 */
@property(nonatomic, strong, readonly) RCMentionedInfo *mentionedInfo;

/*!
 是否允许@功能
 */
@property(nonatomic, assign) BOOL isMentionedEnabled;

/*!
 初始化输入工具栏
 
 @param frame            显示的Frame
 @param containerView    所处的会话页面View
 @param controlType      菜单类型
 @param controlStyle     显示布局
 @param defaultInputType 默认的输入模式
 
 @return 输入工具栏对象
 */
- (instancetype)initWithFrame:(CGRect)frame
            withContainerView:(UIView *)containerView
                  controlType:(RCChatSessionInputBarControlType)controlType
                 controlStyle:(RCChatSessionInputBarControlStyle)controlStyle
             defaultInputType:(RCChatSessionInputBarInputType)defaultInputType;

/*!
 设置输入工具栏的样式
 
 @param type  菜单类型
 @param style 显示布局
 
 @discussion 您可以在会话页面RCConversationViewController的viewDidLoad之后设置，改变输入工具栏的样式。
 */
- (void)setInputBarType:(RCChatSessionInputBarControlType)type
                  style:(RCChatSessionInputBarControlStyle)style;

/*!
 销毁公众账号弹出的菜单
 */
- (void)dismissPublicServiceMenuPopupView;

/*!
 撤销录音
 */
- (void)cancelVoiceRecord;

/*!
 结束录音
 */
- (void)endVoiceRecord;

/*!
 View即将显示的回调
 */
- (void)containerViewWillAppear;

/*!
 View已经显示的回调
 */
- (void)containerViewDidAppear;

/*!
 View即将隐藏的回调
 */
- (void)containerViewWillDisappear;
/*!
 设置输入框的输入状态
 
 @param status          输入框状态
 @param animated        是否使用动画效果
 
 @discussion 如果需要设置，请在输入框执行containerViewWillAppear之后（即会话页面viewWillAppear之后）。
 */
-(void)updateStatus:(KBottomBarStatus)status animated:(BOOL)animated;

/*!
 重置到默认状态
 */
- (void)resetToDefaultStatus;

/*!
 内容区域大小发生变化。
 
 @discussion 当本view所在的view frame发生变化，需要重新计算本view的frame时，调用此方法
 */
- (void)containerViewSizeChanged;

/*!
 设置默认的输入框类型
 
 @param defaultInputType  默认输入框类型
 */
- (void)setDefaultInputType:(RCChatSessionInputBarInputType)defaultInputType;

/*!
 添加被@的用户
 
 @param userInfo    被@的用户信息
 */
- (void)addMentionedUser:(RCUserInfo *)userInfo;

/*!
 打开系统相册，选择图片
 
 @discussion 选择结果通过delegate返回
 */
- (void)openSystemAlbum;

/*!
 打开系统相机，拍摄图片
 
 @discussion 拍摄结果通过delegate返回
 */
- (void)openSystemCamera;

/*!
 打开地图picker，选择位置
 
 @discussion 选择结果通过delegate返回
 */
- (void)openLocationPicker;

/*!
 打开文件选择器，选择文件
 
 @discussion 选择结果通过delegate返回
 */
- (void)openFileSelector;

- (void)openDynamicFunction:(NSInteger)functionTag;

/*!
 更新输入框的Frame
 
 @warning  **已废弃，请勿使用。**
 */
- (void)refreshInputViewFrame
__deprecated_msg("已废弃，请勿使用。");

@end

/*!
 输入工具栏的点击监听器
 */
@protocol RCChatSessionInputBarControlDelegate <NSObject>

/*!
 显示ViewController
 
 @param viewController 需要显示的ViewController
 @param functionTag    功能标识
 */
- (void)presentViewController:(UIViewController *)viewController
                  functionTag:(NSInteger)functionTag;

@optional

/*!
 输入工具栏尺寸（高度）发生变化的回调
 
 @param chatInputBar 输入工具栏
 @param frame        输入工具栏最终需要显示的Frame
 */
- (void)chatInputBar:(RCChatSessionInputBarControl *)chatInputBar shouldChangeFrame:(CGRect)frame;

/*!
 点击键盘Return按钮的回调
 
 @param inputTextView 文本输入框
 */
- (void)inputTextViewDidTouchSendKey:(UITextView *)inputTextView;

/*!
 点击客服机器人切换按钮的回调
 */
- (void)robotSwitchButtonDidTouch;

/*!
 输入框中内容发生变化的回调
 
 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

/*!
 公众服务菜单的点击回调
 
 @param selectedMenuItem 点击的公众服务菜单项
 */
- (void)onPublicServiceMenuItemSelected:(RCPublicServiceMenuItem *)selectedMenuItem;

/*!
 点击扩展功能板中的扩展项的回调
 
 @param pluginBoardView 当前扩展功能板
 @param tag             点击的扩展项的唯一标示符
 */
-(void)pluginBoardView:(RCPluginBoardView*)pluginBoardView clickedItemWithTag:(NSInteger)tag;

/*!
 点击表情的回调
 
 @param emojiView    表情输入的View
 @param touchedEmoji 点击的表情对应的字符串编码
 */
- (void)emojiView:(RCEmojiBoardView *)emojiView didTouchedEmoji:(NSString *)touchedEmoji;

/*!
 点击发送按钮的回调
 
 @param emojiView  表情输入的View
 @param sendButton 发送按钮
 */
- (void)emojiView:(RCEmojiBoardView *)emojiView didTouchSendButton:(UIButton *)sendButton;

/*!
 开始录制语音消息
 */
- (void)recordDidBegin;

/*!
 结束录制语音消息
 */
- (void)recordDidEnd:(NSData *)recordData duration:(long)duration error:(NSError *)error;

/*!
  相机拍照图片
 
 @param image   相机拍摄，选择发送的图片
 */
- (void)imageDidCapture:(UIImage *)image;

/*!
 地理位置选择完成之后的回调
 @param location       位置的二维坐标
 @param locationName   位置的名称
 @param mapScreenShot  位置在地图中的缩略图
 */
- (void)locationDidSelect:(CLLocationCoordinate2D)location locationName:(NSString *)locationName mapScreenShot:(UIImage *)mapScreenShot;

/*!
 相册选择图片列表
 
 @param selectedImages   选中的图片
 @param full             用户是否要求原图
 */
- (void)imageDidSelect:(NSArray *)selectedImages fullImageRequired:(BOOL)full;

/*!
 选择文件列表
 
 @param filePathList   被选中的文件路径list
 */
- (void)fileDidSelect:(NSArray *)filePathList;

/*!
 输入工具栏状态变化时的回调
 
 @param bottomBarStatus 当前状态
 */
-(void)chatSessionInputBarStatusChanged:(KBottomBarStatus)bottomBarStatus;
@end


@protocol RCChatSessionInputBarControlDataSource<NSObject>

/*!
 获取待选择的用户ID列表
 
 @param completion  获取完成的回调
 @param functionTag 功能标识
 */
- (void)getSelectingUserIdList:(void (^)(NSArray<NSString *> *userIdList))completion functionTag:(NSInteger)functionTag;

/*!
 获取待选择的UserId的用户信息
 
 @param userId           用户ID
 @return 用户信息
 */
- (RCUserInfo *)getSelectingUserInfo:(NSString *)userId;

@end
