//
//  RCConversationViewController.h
//  RongIMKit
//
//  Created by xugang on 15/1/22.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef __RCConversationViewController
#define __RCConversationViewController
#import <UIKit/UIKit.h>
#import "RCBaseViewController.h"
#import "RCPluginBoardView.h"
#import "RCChatSessionInputBarControl.h"
#import "RCEmojiBoardView.h"
#import "RCThemeDefine.h"
#import "RCMessageBaseCell.h"
#import "RCMessageModel.h"

///输入栏扩展输入的唯一标示
#define PLUGIN_BOARD_ITEM_ALBUM_TAG      1001
#define PLUGIN_BOARD_ITEM_CAMERA_TAG     1002
#define PLUGIN_BOARD_ITEM_LOCATION_TAG   1003
#define PLUGIN_BOARD_ITEM_VOIP_TAG       1004
#define PLUGIN_BOARD_ITEM_VIDEO_VOIP_TAG 1005


typedef NS_ENUM(NSUInteger, RCCustomerServiceStatus) {
    /*!
     无客服服务
     */
    RCCustomerService_NoService,
    /*!
     人工客服服务
     */
    RCCustomerService_HumanService,
    /*!
     机器人客服服务
     */
    RCCustomerService_RobotService
};
/*!
 聊天界面类
 */
@interface RCConversationViewController: RCBaseViewController
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIScrollViewDelegate>

#pragma mark - 初始化

/*!
 初始化聊天界面
 
 @param conversationType 会话类型
 @param targetId         目标会话ID
 
 @return 聊天界面对象
 */
- (id)initWithConversationType:(RCConversationType)conversationType
                      targetId:(NSString *)targetId;

#pragma mark - 会话属性

/*!
 当前会话的会话类型
 */
@property(nonatomic) RCConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 当前的用户名称（已废弃，请勿使用）
 
 @warning **已废弃，请勿使用。**
 */
@property(nonatomic, strong) __deprecated_msg("已废弃，请勿使用。") NSString *userName;

#pragma mark - 聊天界面属性

/*!
 聊天内容的消息Cell数据模型的数据源
 
 @discussion 数据源中存放的元素为消息Cell的数据模型，即RCMessageModel对象。
 */
@property(nonatomic, strong) NSMutableArray *conversationDataRepository;

/*!
 聊天界面的CollectionView
 */
@property(nonatomic, strong) UICollectionView *conversationMessageCollectionView;

/*!
 聊天界面的CollectionView Layout
 */
@property(nonatomic, strong) UICollectionViewFlowLayout *customFlowLayout;

#pragma mark - 未读消息数

#pragma mark 导航栏返回按钮中的未读消息数提示
/*!
 需要统计未读数的会话类型数组（在导航栏的返回按钮中显示）
 
 @discussion 此属性表明在导航栏的返回按钮中需要统计显示哪部分的会话类型的未读数。
 (需要将RCConversationType转为NSNumber构建Array)
 */
@property(nonatomic, strong) NSArray *displayConversationTypeArray;

/*!
 更新导航栏返回按钮中显示的未读消息数
 
 @discussion 如果您重写此方法，需要注意调用super。
 */
- (void)notifyUpdateUnreadMessageCount;

#pragma mark 右上角的未读消息数提示
/*!
 当收到的消息超过一个屏幕时，进入会话之后，是否在右上角提示上方存在的未读消息数
 
 @discussion 默认值为NO。
 开启该提示功能之后，当一个会话收到大量消息时（操作一个屏幕能显示的内容），
 进入该会话后，会在右上角提示用户上方存在的未读消息数，用户点击该提醒按钮，会跳转到最开始的未读消息。
 */
@property(nonatomic, assign) BOOL enableUnreadMessageIcon;

/*!
 右上角提示的未读消息数
 
 @discussion 右上角未读消息数支持的最大值是150。
 */
@property(nonatomic, assign) NSInteger unReadMessage;

/*!
 右上角未读消息数提示的Label
 */
@property(nonatomic,strong) UILabel *unReadMessageLabel;

/*!
 右上角未读消息数提示的按钮
 */
@property(nonatomic, strong) UIButton *unReadButton;

#pragma mark 右下角的未读消息数提示
/*!
 当前阅读区域的下方收到消息时，是否在聊天界面的右下角提示下方存在未读消息
 
 @discussion 默认值为NO。
 开启该提示功能之后，当聊天界面滑动到最下方时，此会话中收到消息会自动更新；
 当用户停留在上方某个区域阅读时，此会话收到消息时，会在右下角显示未读消息提示，而不会自动滚动到最下方，
 用户点击该提醒按钮，会滚动到最下方。
 */
@property(nonatomic, assign) BOOL enableNewComingMessageIcon;

/*!
 右下角未读消息数提示的Label
 */
@property(nonatomic, strong) UILabel *unReadNewMessageLabel;


#pragma mark - 输入工具栏

/*!
 聊天界面下方的输入工具栏
 */
@property(nonatomic, strong) RCChatSessionInputBarControl *chatSessionInputBarControl;

/*!
 输入框的默认输入模式
 
 @discussion 默认值为RCChatSessionInputBarInputText，即文本输入模式。
 */
@property(nonatomic) RCChatSessionInputBarInputType defaultInputType;

/*!
 输入扩展功能板View
 */
@property(nonatomic, strong) RCPluginBoardView *pluginBoardView;

/*!
 表情View
 */
@property(nonatomic, strong) RCEmojiBoardView *emojiBoardView;

/*!
 扩展功能板的点击回调
 
 @param pluginBoardView 输入扩展功能板View
 @param tag             输入扩展功能(Item)的唯一标示
 */
-(void)pluginBoardView:(RCPluginBoardView*)pluginBoardView
    clickedItemWithTag:(NSInteger)tag;

/*!
 输入框中内容发生变化的回调
 
 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range
      replacementText:(NSString *)text;

/*!
 设置输入框的输入状态
 
 @param inputBarStatus  输入框状态
 @param animated        是否使用动画效果
 */
-(void)setChatSessionInputBarStatus:(KBottomBarStatus)inputBarStatus animated:(BOOL)animated;

#pragma mark - 显示设置

/*!
 设置在聊天界面中显示的头像形状，矩形或者圆形（全局有效）
 
 @param avatarStyle 显示的头像形状
 
 @discussion 默认值为矩形，即RC_USER_AVATAR_RECTANGLE。
 请在viewDidLoad之前设置，此设置在SDK中全局有效。
 */
- (void)setMessageAvatarStyle:(RCUserAvatarStyle)avatarStyle;

/*!
 设置聊天界面中显示的头像大小（全局有效），高度必须大于或者等于36
 
 @param size 显示的头像形状
 
 @discussion 默认值为46*46。
 请在viewDidLoad之前设置，此设置在SDK中全局有效。
 */
- (void)setMessagePortraitSize:(CGSize)size;

/*!
 收到的消息是否显示发送者的名字
 
 @discussion 默认值为YES。
 您可以针对群聊、聊天室、单聊等不同场景，自己定制是否显示发送方的名字。
 */
@property(nonatomic) BOOL displayUserNameInCell;

/*!
 设置进入聊天室需要获取的历史消息数量（仅在当前会话为聊天室时生效）
 
 @discussion 此属性需要在viewDidLoad之前进行设置。
 -1表示不获取任何历史消息，0表示不特殊设置而使用SDK默认的设置（默认为获取10条），0<messageCount<=50为具体获取的消息数量,最大值为50。
 */
@property(nonatomic, assign) int defaultHistoryMessageCountOfChatRoom;

#pragma mark - 界面操作

/*!
 滚动到列表最下方
 
 @param animated 是否开启动画效果
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/*!
 返回前一个页面的方法
 
 @param sender 事件发起者
 
 @discussion 其中包含了一些聊天界面退出的清理工作，如退出讨论组等。
 如果您重写此方法，请注意调用super。
 */
- (void)leftBarButtonItemPressed:(id)sender;

#pragma mark - 消息操作

#pragma mark 发送消息
/*!
 发送消息(除图片消息外的所有消息)
 
 @param messageContent 消息的内容
 @param pushContent    接收方离线时需要显示的远程推送内容
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent来定义推送内容，否则将不会进行远程推送。
 
 如果您需要设置发送的pushData，可以使用RCIM的发送消息接口。
 */
- (void)sendMessage:(RCMessageContent *)messageContent
        pushContent:(NSString *)pushContent;

/*!
 发送图片消息
 
 @param imageMessage 消息的内容
 @param pushContent  接收方离线时需要显示的远程推送内容
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent来定义推送内容，否则将不会进行远程推送。
 
 如果您需要设置发送的pushData，可以使用RCIM的发送图片消息接口。
 */
- (void)sendImageMessage:(RCImageMessage *)imageMessage
             pushContent:(NSString *)pushContent;

/*!
 重新发送消息
 
 @param messageContent 消息的内容
 
 @discussion 发送消息失败，点击小红点时，会将本地存储的原消息实体删除，会回调此接口将消息内容重新发送。
 如果您需要重写此接口，请注意调用super。
 */
- (void)resendMessage:(RCMessageContent *)messageContent;

/*!
 发送图片消息(上传图片到App指定的服务器)
 
 @param imageMessage 消息的内容
 @param pushContent  接收方离线时需要显示的远程推送内容
 @param appUpload    是否上传到App指定的服务器
 
 @discussion 此方法用于上传图片到您自己的服务器，此时需要将appUpload设置为YES，并实现uploadImage:uploadListener:回调。
 需要您在该回调中上传图片，并通过uploadListener监听通知SDK同步显示上传进度。
 
 如果appUpload设置为NO，将会和普通图片消息的发送一致，上传到融云默认的服务器并发送。
 */
- (void)sendImageMessage:(RCImageMessage *)imageMessage
             pushContent:(NSString *)pushContent
               appUpload:(BOOL)appUpload;

/*!
 上传图片到App指定的服务器的回调
 
 @param message        图片消息的实体
 @param uploadListener SDK图片上传进度监听
 
 @discussion 如果您通过sendImageMessage:pushContent:appUpload:接口发送图片消息，则必须实现此回调。
 您需要在此回调中通过uploadListener将上传图片的进度和结果通知SDK，SDK会根据这些信息，自动更新UI。
 */
- (void)uploadImage:(RCMessage *)message
     uploadListener:(RCUploadImageStatusListener *)uploadListener;

#pragma mark 插入消息
/*!
 在聊天界面中插入一条消息
 
 @param message 消息实体
 
 @discussion 通过此方法插入一条消息，会将消息实体对应的内容Model插入数据源中，并更新UI。
 */
- (void)appendAndDisplayMessage:(RCMessage *)message;

#pragma mark 删除消息
/*!
 删除消息并更新UI
 
 @param model 消息Cell的数据模型
 */
- (void)deleteMessage:(RCMessageModel *)model;

#pragma mark - 消息操作的回调

/*!
 准备发送消息的回调
 
 @param messageCotent 消息内容
 
 @return 修改后的消息内容
 
 @discussion 此回调在消息准备向外发送时会回调，您可以在此回调中对消息内容进行过滤和修改等操作。
 如果此回调的返回值不为nil，SDK会对外发送返回的消息内容。
 */
- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageCotent;

/*!
 发送消息完成的回调
 
 @param stauts          发送状态，0表示成功，非0表示失败
 @param messageCotent   消息内容
 */
- (void)didSendMessage:(NSInteger)stauts
               content:(RCMessageContent *)messageCotent;

/*!
 即将在聊天界面插入消息的回调
 
 @param message 消息实体
 @return        修改后的消息实体
 
 @discussion 此回调在消息准备插入数据源的时候会回调，您可以在此回调中对消息进行过滤和修改操作。
 如果此回调的返回值不为nil，SDK会将返回消息实体对应的消息Cell数据模型插入数据源，并在聊天界面中显示。
 */
- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message;

/*!
 即将显示消息Cell的回调
 
 @param cell        消息Cell
 @param indexPath   该Cell对应的消息Cell数据模型在数据源中的索引值
 
 @discussion 您可以在此回调中修改Cell的显示和某些属性。
 */
- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell
                   atIndexPath:(NSIndexPath *)indexPath;

/*!
 即将显示消息Cell的回调（已废弃，请勿使用）
 
 @param cell        消息Cell
 @param indexPath   该Cell对应的消息Cell数据模型在数据源中的索引值
 
 @discussion 您可以在此回调中修改Cell的显示和某些属性。
 此接口已废弃，您可以无缝使用willDisplayMessageCell:atIndexPath:代替，功能和使用完全一致。
 
 @warning **已废弃，请勿使用。**
 */
- (void)willDisplayConversationTableCell:(RCMessageBaseCell *)cell
                             atIndexPath:(NSIndexPath *)indexPath
__deprecated_msg("已废弃，请勿使用。");

#pragma mark - 自定义消息

/*!
 注册自定义消息的Cell
 
 @param cellClass   自定义消息的类，该自定义消息需要继承于RCMessageContent
 @param identifier  自定义消息Cell的唯一标示符
 
 @discussion 聊天界面在显示时需要通过identifier唯一标示来进行Cell重用，以提高性能。
 我们建议您在identifier中添加前缀，请勿使用"rc"前缀的字符串，以免与融云内置消息的Cell冲突。
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

/*!
 自定义消息Cell显示的回调
 
 @param collectionView  当前CollectionView
 @param indexPath       该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                自定义消息需要显示的Cell
 
 @discussion 自定义消息如果需要显示，则必须先通过RCIM的registerMessageType:注册该自定义消息类型，
 并在聊天界面中通过registerClass:forCellWithReuseIdentifier:注册该自定义消息的Cell，否则将此回调将不会被调用。
 */
- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView
                             cellForItemAtIndexPath:(NSIndexPath *)indexPath;

/*!
 自定义消息Cell显示的回调
 
 @param collectionView          当前CollectionView
 @param collectionViewLayout    当前CollectionView Layout
 @param indexPath               该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                        自定义消息Cell需要显示的高度
 
 @discussion 自定义消息如果需要显示，则必须先通过RCIM的registerMessageType:注册该自定义消息类型，
 并在聊天界面中通过registerClass:forCellWithReuseIdentifier:注册该自定义消息的Cell，否则将此回调将不会被调用。
 */
- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/*!
 未注册消息Cell显示的回调
 
 @param collectionView  当前CollectionView
 @param indexPath       该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                未注册消息需要显示的Cell
 
 @discussion 未注册消息的显示主要用于App未雨绸缪的新旧版本兼容，在使用此回调之前，需要将RCIM的showUnkownMessage设置为YES。
 比如，您App在新版本迭代中增加了某种自定义消息，当已经发布的旧版本不能识别，开发者可以在旧版本中预先定义好这些不能识别的消息的显示，
 如提示当前版本不支持，引导用户升级等。
 */
- (RCMessageBaseCell *)rcUnkownConversationCollectionView:(UICollectionView *)collectionView
                                   cellForItemAtIndexPath:(NSIndexPath *)indexPath;

/*!
 未注册消息Cell显示的回调
 
 @param collectionView          当前CollectionView
 @param collectionViewLayout    当前CollectionView Layout
 @param indexPath               该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                        未注册消息Cell需要显示的高度
 
 @discussion 未注册消息的显示主要用于App未雨绸缪的新旧版本兼容，在使用此回调之前，需要将RCIM的showUnkownMessage设置为YES。
 比如，您App在新版本迭代中增加了某种自定义消息，当已经发布的旧版本不能识别，开发者可以在旧版本中预先定义好这些不能识别的消息的显示，
 如提示当前版本不支持，引导用户升级等。
 */
- (CGSize)rcUnkownConversationCollectionView:(UICollectionView *)collectionView
                                      layout:(UICollectionViewLayout *)collectionViewLayout
                      sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - 点击事件回调

/*!
 点击Cell中的消息内容的回调
 
 @param model 消息Cell的数据模型
 
 @discussion SDK在此点击事件中，针对SDK中自带的图片、语音、位置等消息有默认的处理，如查看、播放等。
 您在重写此回调时，如果想保留SDK原有的功能，需要注意调用super。
 */
- (void)didTapMessageCell:(RCMessageModel *)model;

/*!
 长按Cell中的消息内容的回调
 
 @param model 消息Cell的数据模型
 @param view  长按区域的View
 
 @discussion SDK在此长按事件中，会默认展示菜单。
 您在重写此回调时，如果想保留SDK原有的功能，需要注意调用super。
 */
- (void)didLongTouchMessageCell:(RCMessageModel *)model
                         inView:(UIView *)view;

/*!
 点击Cell中URL的回调
 
 @param url   点击的URL
 @param model 消息Cell的数据模型
*/
- (void)didTapUrlInMessageCell:(NSString *)url
                         model:(RCMessageModel *)model;

/*!
 点击Cell中电话号码的回调
 
 @param phoneNumber 点击的电话号码
 @param model       消息Cell的数据模型
 */
- (void)didTapPhoneNumberInMessageCell:(NSString *)phoneNumber
                                 model:(RCMessageModel *)model;

/*!
 点击Cell中头像的回调
 
 @param userId  点击头像对应的用户ID
 */
- (void)didTapCellPortrait:(NSString *)userId;

/*!
 长按Cell中头像的回调
 
 @param userId  头像对应的用户ID
 */
- (void)didLongPressCellPortrait:(NSString *)userId;

#pragma mark - 语音消息、图片消息、位置消息显示与操作

/*!
 开始录制语音消息
 */
- (void)onBeginRecordEvent;

/*!
 结束录制语音消息
 */
- (void)onEndRecordEvent;

/*!
 是否开启语音消息连续播放
 
 @discussion 如果设置为YES，在点击播放语音消息时，会将下面所有未播放过的语音消息依次播放。
 */
@property(nonatomic, assign) BOOL enableContinuousReadUnreadVoice;

/*!
 查看图片消息中的图片
 
 @param model   消息Cell的数据模型
 
 @discussion SDK在此方法中会默认调用RCImagePreviewController下载并展示图片。
 */
- (void)presentImagePreviewController:(RCMessageModel *)model;

/*!
 发送新拍照的图片完成之后，是否将图片在本地另行存储。
 
 @discussion 如果设置为YES，您需要在saveNewPhotoToLocalSystemAfterSendingSuccess:回调中自行保存。
 */
@property(nonatomic, assign) BOOL enableSaveNewPhotoToLocalSystem;

/*!
 发送新拍照的图片完成之后，将图片在本地另行存储的回调
 
 @param newImage    图片
 
 @discussion 您可以在此回调中按照您的需求，将图片另行保存或执行其他操作。
 */
- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage;

/*!
 查看位置信息的位置详情
 
 @param locationMessageContent  点击的位置消息
 
 @discussion SDK在此方法中会默认调用RCLocationViewController在地图中展示位置。
 */
- (void)presentLocationViewController:(RCLocationMessage *)locationMessageContent;

#pragma mark - 客服
/*!
 用户的详细信息，此数据用于上传用户信息到客服后台，数据的nickName和portraitUrl必须填写。
 */
@property (nonatomic, strong)RCCustomerServiceInfo *csInfo;
/*!
 评价客服服务,然后离开当前VC的。此方法有可能在离开客服会话界面触发，也可能是客服在后台推送评价触发，也可能用户点击机器人知识库评价触发。应用可以重写此方法来自定义客服评价界面。应用不要直接调用此方法。
 
 @param serviceStatus  当前的服务类型。
 @param commentId      评论ID。当是用户主动离开客服会话时，这个id是null；当客服在后台推送评价请求时，这个id是对话id；当用户点击机器人应答评价时，这个是机器人知识库id。
 @param isQuit         评价完成后是否离开
 
 @discussion sdk会在需要评价时调用此函数。如需自定义评价界面，请根据demo的RCDCustomerServiceViewController中的示例来重写此函数。
 */
- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus commentId:(NSString *)commentId quitAfterComment:(BOOL)isQuit;

/*!
 离开客服界面
 
 @discussion 调用此方法离开客服VC。
 */
- (void)customerServiceLeftCurrentViewController;

/*!
 客服服务模式变化
 
 @param newMode  新的客服服务模式。
 */
- (void)onCustomerServiceModeChanged:(RCCSModeType)newMode;
@end
#endif
