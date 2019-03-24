/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCStatusDefine.h
//  Created by Heq.Shinoda on 14-4-21.

#import <Foundation/Foundation.h>

#ifndef __RCStatusDefine
#define __RCStatusDefine

#pragma mark - 错误码相关

#pragma mark RCConnectErrorCode - 建立连接返回的错误码
/*!
 建立连接返回的错误码

 @discussion
 开发者仅需要关注以下几种连接错误码，其余错误码SDK均会进行自动重连，开发者无须处理。
 RC_CONN_ID_REJECT, RC_CONN_TOKEN_INCORRECT, RC_CONN_NOT_AUTHRORIZED,
 RC_CONN_PACKAGE_NAME_INVALID, RC_CONN_APP_BLOCKED_OR_DELETED,
 RC_CONN_USER_BLOCKED,
 RC_DISCONN_KICK, RC_CLIENT_NOT_INIT, RC_INVALID_PARAMETER, RC_INVALID_ARGUMENT
 */
typedef NS_ENUM(NSInteger, RCConnectErrorCode) {

    /*!
     连接已被释放

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_NET_CHANNEL_INVALID = 30001,

    /*!
     连接不可用

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_NET_UNAVAILABLE = 30002,

    /*!
     导航HTTP发送失败

     @discussion 如果是偶尔出现此错误，SDK会做好自动重连，开发者无须处理。如果一直是这个错误，应该是您没有设置好ATS。
     ATS默认只使用HTTPS协议，当HTTP协议被禁止时SDK会一直30004错误。您可以在我们iOS开发文档中搜索到ATS设置。
     */
    RC_NAVI_REQUEST_FAIL = 30004,

    /*!
     导航HTTP请求失败

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_NAVI_RESPONSE_ERROR = 30007,

    /*!
     导航HTTP返回数据格式错误

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_NODE_NOT_FOUND = 30008,

    /*!
     创建Socket连接失败

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_SOCKET_NOT_CONNECTED = 30010,

    /*!
     Socket断开

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_SOCKET_DISCONNECTED = 30011,

    /*!
     PING失败

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_PING_SEND_FAIL = 30012,

    /*!
     PING超时

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_PONG_RECV_FAIL = 30013,

    /*!
     信令发送失败

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_MSG_SEND_FAIL = 30014,

    /*!
     连接过于频繁

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_CONN_OVERFREQUENCY = 30015,

    /*!
     连接ACK超时

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_CONN_ACK_TIMEOUT = 31000,

    /*!
     信令版本错误

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_CONN_PROTO_VERSION_ERROR = 31001,

    /*!
     AppKey错误

     @discussion 请检查您使用的AppKey是否正确。
     */
    RC_CONN_ID_REJECT = 31002,

    /*!
     服务器当前不可用（预留）

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_CONN_SERVER_UNAVAILABLE = 31003,

    /*!
     Token无效

     @discussion Token无效一般有以下两种原因。
     一是token错误，请您检查客户端初始化使用的AppKey和您服务器获取token使用的AppKey是否一致；
     二是token过期，是因为您在开发者后台设置了token过期时间，您需要请求您的服务器重新获取token并再次用新的token建立连接。
     */
    RC_CONN_TOKEN_INCORRECT = 31004,

    /*!
     AppKey与Token不匹配

     @discussion
     请检查您使用的AppKey与Token是否正确，是否匹配。一般有以下两种原因。
     一是token错误，请您检查客户端初始化使用的AppKey和您服务器获取token使用的AppKey是否一致；
     二是token过期，是因为您在开发者后台设置了token过期时间，您需要请求您的服务器重新获取token并再次用新的token建立连接。
     */
    RC_CONN_NOT_AUTHRORIZED = 31005,

    /*!
     连接重定向

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_CONN_REDIRECTED = 31006,

    /*!
     BundleID不正确

     @discussion 请检查您App的BundleID是否正确。
     */
    RC_CONN_PACKAGE_NAME_INVALID = 31007,

    /*!
     AppKey被封禁或已删除

     @discussion 请检查您使用的AppKey是否正确。
     */
    RC_CONN_APP_BLOCKED_OR_DELETED = 31008,

    /*!
     用户被封禁

     @discussion 请检查您使用的Token是否正确，以及对应的UserId是否被封禁。
     */
    RC_CONN_USER_BLOCKED = 31009,

    /*!
     当前用户在其他设备上登录，此设备被踢下线
     */
    RC_DISCONN_KICK = 31010,

    /*!
     重连过程中当前用户在其它设备上登录
     */
    RC_CONN_OTHER_DEVICE_LOGIN = 31023,
    
    /*!
     连接被拒绝

     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    RC_CONN_REFUSED = 32061,

    /*!
     SDK没有初始化

     @discussion 在使用SDK任何功能之前，必须先Init。
     */
    RC_CLIENT_NOT_INIT = 33001,

    /*!
     开发者接口调用时传入的参数错误

     @discussion 请检查接口调用时传入的参数类型和值。
     */
    RC_INVALID_PARAMETER = 33003,

    /*!
     Connection已经存在

     @discussion
     调用过connect之后，只有在token错误或者被踢下线或者用户logout的情况下才需要再次调用connect。SDK会自动重连，不需要应用多次调用connect来保证连接性。
     */
    RC_CONNECTION_EXIST = 34001,
    
    /*!
     开发者接口调用时传入的参数错误

     @discussion 请检查接口调用时传入的参数类型和值。
     */
    RC_INVALID_ARGUMENT = -1000
};

#pragma mark RCErrorCode - 具体业务错误码
/*!
 具体业务错误码
 */
typedef NS_ENUM(NSInteger, RCErrorCode) {
    /*!
     未知错误（预留）
     */
    ERRORCODE_UNKNOWN = -1,

    /*!
     已被对方加入黑名单
     */
    REJECTED_BY_BLACKLIST = 405,

    /*!
     超时
     */
    ERRORCODE_TIMEOUT = 5004,

    /*!
     发送消息频率过高，1秒钟最多只允许发送5条消息
     */
    SEND_MSG_FREQUENCY_OVERRUN = 20604,

    /*!
     不在该讨论组中
     */
    NOT_IN_DISCUSSION = 21406,

    /*!
     不在该群组中
     */
    NOT_IN_GROUP = 22406,

    /*!
     在群组中已被禁言
     */
    FORBIDDEN_IN_GROUP = 22408,

    /*!
     不在该聊天室中
     */
    NOT_IN_CHATROOM = 23406,

    /*!
     在该聊天室中已被禁言
     */
    FORBIDDEN_IN_CHATROOM = 23408,

    /*!
     已被踢出并禁止加入聊天室
     */
    KICKED_FROM_CHATROOM = 23409,

    /*!
     聊天室不存在
     */
    RC_CHATROOM_NOT_EXIST = 23410,

    /*!
     聊天室成员超限
     */
    RC_CHATROOM_IS_FULL = 23411,

    /*!
     聊天室接口参数无效
     */
    RC_PARAMETER_INVALID_CHATROOM = 23412,

    /*!
     聊天室云存储业务未开通
     */
    RC_ROAMING_SERVICE_UNAVAILABLE_CHATROOM = 23414,

    /*!
     当前连接不可用（连接已经被释放）
     */
    RC_CHANNEL_INVALID = 30001,

    /*!
     当前连接不可用
     */
    RC_NETWORK_UNAVAILABLE = 30002,

    /*!
     消息响应超时
     */
    RC_MSG_RESPONSE_TIMEOUT = 30003,

    /*!
     SDK没有初始化

     @discussion 在使用SDK任何功能之前，必须先Init。
     */
    CLIENT_NOT_INIT = 33001,

    /*!
     数据库错误

     @discussion 请检查您使用的Token和userId是否正确。
     */
    DATABASE_ERROR = 33002,

    /*!
     开发者接口调用时传入的参数错误

     @discussion 请检查接口调用时传入的参数类型和值。
     */
    INVALID_PARAMETER = 33003,

    /*!
     历史消息云存储业务未开通
     */
    MSG_ROAMING_SERVICE_UNAVAILABLE = 33007,

    /*!
     无效的公众号。(由会话类型和Id所标识的公众号会话是无效的)
     */
    INVALID_PUBLIC_NUMBER = 29201,
    /*!
      消息大小超限，消息体（序列化成json格式之后的内容）最大128k bytes。
     */
    RC_MSG_SIZE_OUT_OF_LIMIT = 30016,

    /*!
    撤回消息参数无效。
    */
    RC_RECALLMESSAGE_PARAMETER_INVALID = 25101,
    /*!
    push设置参数无效。
    */
    RC_PUSHSETTING_PARAMETER_INVALID = 26001,
    /*!
    操作被禁止。
    */
    RC_OPERATION_BLOCKED = 20605,

    /*!
    操作不支持。
    */
    RC_OPERATION_NOT_SUPPORT = 20606,

    /*!
     发送的消息中包含敏感词 （发送方发送失败，接收方不会收到消息）
     */
    RC_MSG_BLOCKED_SENSITIVE_WORD = 21501,

    /*!
     消息中敏感词已经被替换 （接收方可以收到被替换之后的消息）
     */
    RC_MSG_REPLACED_SENSITIVE_WORD = 21502,
    
    /*!
     小视频消息超限
     */
    RC_SIGHT_MSG_DURATION_LIMIT_EXCEED = 34002,

};

#pragma mark - 连接状态

#pragma mark RCConnectionStatus - 网络连接状态码
/*!
 网络连接状态码

 @discussion 开发者仅需要关注以下几种连接状态，其余状态SDK均会进行自动重连。
 ConnectionStatus_Connected, ConnectionStatus_Connecting,
 ConnectionStatus_Unconnected,
 ConnectionStatus_SignUp, ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT,
 ConnectionStatus_TOKEN_INCORRECT
 */
typedef NS_ENUM(NSInteger, RCConnectionStatus) {
    /*!
     未知状态

     @discussion 建立连接中出现异常的临时状态，SDK会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_UNKNOWN = -1,

    /*!
     连接成功
     */
    ConnectionStatus_Connected = 0,

    /*!
     当前设备网络不可用

     @discussion 建立连接的临时状态，SDK会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_NETWORK_UNAVAILABLE = 1,

    /*!
     当前设备切换到飞行模式

     @discussion 建立连接的临时状态，SDK会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_AIRPLANE_MODE = 2,

    /*!
     当前设备切换到 2G（GPRS、EDGE）低速网络

     @discussion 建立连接的临时状态，SDK会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_Cellular_2G = 3,

    /*!
     当前设备切换到 3G 或 4G 高速网络

     @discussion 建立连接的临时状态，SDK会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_Cellular_3G_4G = 4,

    /*!
     当前设备切换到 WIFI 网络

     @discussion 建立连接的临时状态，SDK会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_WIFI = 5,

    /*!
     当前用户在其他设备上登录，此设备被踢下线
     */
    ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT = 6,

    /*!
     当前用户在 Web 端登录

     @discussion 建立连接的临时状态，SDK会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_LOGIN_ON_WEB = 7,

    /*!
     服务器异常

     @discussion 建立连接的临时状态，SDK会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_SERVER_INVALID = 8,

    /*!
     连接验证异常

     @discussion 建立连接的临时状态，SDK会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_VALIDATE_INVALID = 9,

    /*!
     连接中
     */
    ConnectionStatus_Connecting = 10,

    /*!
     连接失败或未连接
     */
    ConnectionStatus_Unconnected = 11,

    /*!
     已注销
     */
    ConnectionStatus_SignUp = 12,

    /*!
     Token无效

     @discussion
     Token无效一般有两种原因。一是token错误，请您检查客户端初始化使用的AppKey和您服务器获取token使用的AppKey是否一致；二是token过期，是因为您在开发者后台设置了token过期时间，您需要请求您的服务器重新获取token并再次用新的token建立连接。
     */
    ConnectionStatus_TOKEN_INCORRECT = 31004,

    /*!
     与服务器的连接已断开,用户被封禁
     */
    ConnectionStatus_DISCONN_EXCEPTION = 31011
};

#pragma mark RCNetworkStatus - 当前所处的网络
/*!
 当前所处的网络
 */
typedef NS_ENUM(NSUInteger, RCNetworkStatus) {
    /*!
     当前网络不可用
     */
    RC_NotReachable = 0,

    /*!
     当前处于WiFi网络
     */
    RC_ReachableViaWiFi = 1,

    /*!
     移动网络
     */
    RC_ReachableViaWWAN = 2,

    //    /*!
    //     当前处于3G网络
    //     */
    //    RC_ReachableVia3G = 3,
    //
    //    /*!
    //     当前处于2G网络
    //     */
    //    RC_ReachableVia2G = 4
};

#pragma mark RCSDKRunningMode - SDK当前所处的状态
/*!
 SDK当前所处的状态
 */
typedef NS_ENUM(NSUInteger, RCSDKRunningMode) {
    /*!
     后台运行状态
     */
    RCSDKRunningMode_Background = 0,

    /*!
     前台运行状态
     */
    RCSDKRunningMode_Foreground = 1
};

#pragma mark - 会话相关

#pragma mark RCConversationType - 会话类型
/*!
 会话类型
 */
typedef NS_ENUM(NSUInteger, RCConversationType) {
    /*!
     单聊
     */
    ConversationType_PRIVATE = 1,

    /*!
     讨论组
     */
    ConversationType_DISCUSSION = 2,

    /*!
     群组
     */
    ConversationType_GROUP = 3,

    /*!
     聊天室
     */
    ConversationType_CHATROOM = 4,

    /*!
     客服
     */
    ConversationType_CUSTOMERSERVICE = 5,

    /*!
     系统会话
     */
    ConversationType_SYSTEM = 6,

    /*!
     应用内公众服务会话

     @discussion
     客服2.0使用应用内公众服务会话（ConversationType_APPSERVICE）的方式实现。
     即客服2.0会话是其中一个应用内公众服务会话，这种方式我们目前不推荐，请尽快升级到新客服，升级方法请参考官网的客服文档。
     */
    ConversationType_APPSERVICE = 7,

    /*!
     跨应用公众服务会话
     */
    ConversationType_PUBLICSERVICE = 8,

    /*!
     推送服务会话
     */
    ConversationType_PUSHSERVICE = 9,
    
    /*!
     加密会话（仅对部分私有云用户开放，公有云用户不适用）
     */
    ConversationType_Encrypted = 11,
    
    /**
     * RTC 会话
     */
    ConversationType_RTC = 12,
    
    /*!
     无效类型
     */
    ConversationType_INVALID
    
};

#pragma mark RCConversationNotificationStatus - 会话提醒状态
/*!
 会话提醒状态
 */
typedef NS_ENUM(NSUInteger, RCConversationNotificationStatus) {
    /*!
     免打扰
     */
    DO_NOT_DISTURB = 0,

    /*!
     新消息提醒
     */
    NOTIFY = 1,
};

#pragma mark RCReadReceiptMessageType - 消息回执
/*!
 已读状态消息类型
 */
typedef NS_ENUM(NSUInteger, RCReadReceiptMessageType) {
    /*!
     根据会话来更新未读消息状态
     */
    RC_ReadReceipt_Conversation = 1,
};

#pragma mark RCChatRoomMemberOrder - 聊天室成员排列顺序
/*!
 聊天室成员的排列顺序
 */
typedef NS_ENUM(NSUInteger, RCChatRoomMemberOrder) {
    /*!
     升序，返回最早加入的成员列表
     */
    RC_ChatRoom_Member_Asc = 1,

    /*!
     降序，返回最晚加入的成员列表
     */
    RC_ChatRoom_Member_Desc = 2,
};

#pragma mark - 消息相关

#pragma mark RCMessagePersistent - 消息的存储策略
/*!
 消息的存储策略
 */
typedef NS_ENUM(NSUInteger, RCMessagePersistent) {
    /*!
     在本地不存储，不计入未读数
     */
    MessagePersistent_NONE = 0,

    /*!
     在本地只存储，但不计入未读数
     */
    MessagePersistent_ISPERSISTED = 1,

    /*!
     在本地进行存储并计入未读数
     */
    MessagePersistent_ISCOUNTED = 3,

    /*!
     在本地不存储，不计入未读数，并且如果对方不在线，服务器会直接丢弃该消息，对方如果之后再上线也不会再收到此消息。

     @discussion 一般用于发送输入状态之类的消息，该类型消息的messageUId为nil。
     */
    MessagePersistent_STATUS = 16
};

#pragma mark RCMessageDirection - 消息的方向
/*!
 消息的方向
 */
typedef NS_ENUM(NSUInteger, RCMessageDirection) {
    /*!
     发送
     */
    MessageDirection_SEND = 1,

    /*!
     接收
     */
    MessageDirection_RECEIVE = 2
};

#pragma mark RCSentStatus - 消息的发送状态
/*!
 消息的发送状态
 */
typedef NS_ENUM(NSUInteger, RCSentStatus) {
    /*!
     发送中
     */
    SentStatus_SENDING = 10,

    /*!
     发送失败
     */
    SentStatus_FAILED = 20,

    /*!
     已发送成功
     */
    SentStatus_SENT = 30,

    /*!
     对方已接收
     */
    SentStatus_RECEIVED = 40,

    /*!
     对方已阅读
     */
    SentStatus_READ = 50,

    /*!
     对方已销毁
     */
    SentStatus_DESTROYED = 60,

    /*!
     发送已取消
     */
    SentStatus_CANCELED = 70,
    
    /*!
     无效类型
     */
    SentStatus_INVALID
};

#pragma mark RCReceivedStatus - 消息的接收状态
/*!
 消息的接收状态
 */
typedef NS_ENUM(NSUInteger, RCReceivedStatus) {
    /*!
     未读
     */
    ReceivedStatus_UNREAD = 0,

    /*!
     已读
     */
    ReceivedStatus_READ = 1,

    /*!
     已听

     @discussion 仅用于语音消息
     */
    ReceivedStatus_LISTENED = 2,

    /*!
     已下载
     */
    ReceivedStatus_DOWNLOADED = 4,

    /*!
     该消息已经被其他登录的多端收取过。（即该消息已经被其他端收取过后。当前端才登录，并重新拉取了这条消息。客户可以通过这个状态更新UI，比如不再提示）。
     */
    ReceivedStatus_RETRIEVED = 8,

    /*!
     该消息是被多端同时收取的。（即其他端正同时登录，一条消息被同时发往多端。客户可以通过这个状态值更新自己的某些UI状态）。
     */
    ReceivedStatus_MULTIPLERECEIVE = 16,

};

#pragma mark RCMediaType - 消息内容中多媒体文件的类型
/*!
 消息内容中多媒体文件的类型
 */
typedef NS_ENUM(NSUInteger, RCMediaType) {
    /*!
     图片
     */
    MediaType_IMAGE = 1,

    /*!
     语音
     */
    MediaType_AUDIO = 2,

    /*!
     视频
     */
    MediaType_VIDEO = 3,

    /*!
     其他文件
     */
    MediaType_FILE = 4,
    
    /*!
     小视频
     */
    MediaType_SIGHT = 5
};

#pragma mark RCMediaType - 消息中@提醒的类型
/*!
 @提醒的类型
 */
typedef NS_ENUM(NSUInteger, RCMentionedType) {
    /*!
     @所有人
     */
    RC_Mentioned_All = 1,

    /*!
     @部分指定用户
     */
    RC_Mentioned_Users = 2,
};

/**
 语音消息采样率
 
 - RCSample_Rate_8000: 8KHz
 - RCSample_Rate_16000: 16KHz
 */
typedef NS_ENUM(NSInteger,RCSampleRate)
{
    RCSample_Rate_8000 = 1,         //8KHz
    RCSample_Rate_16000 = 2,        //16KHz
};

#pragma mark - 公众服务相关

#pragma mark RCPublicServiceType - 公众服务账号类型
/*!
 公众服务账号类型
 */
typedef NS_ENUM(NSUInteger, RCPublicServiceType) {
    /*!
     应用内公众服务账号
     */
    RC_APP_PUBLIC_SERVICE = 7,

    /*!
     跨应用公众服务账号
     */
    RC_PUBLIC_SERVICE = 8,
};

#pragma mark RCPublicServiceMenuItemType - 公众服务菜单类型
/*!
 公众服务菜单类型
 */
typedef NS_ENUM(NSUInteger, RCPublicServiceMenuItemType) {
    /*!
     包含子菜单的一组菜单
     */
    RC_PUBLIC_SERVICE_MENU_ITEM_GROUP = 0,

    /*!
     包含查看事件的菜单
     */
    RC_PUBLIC_SERVICE_MENU_ITEM_VIEW = 1,

    /*!
     包含点击事件的菜单
     */
    RC_PUBLIC_SERVICE_MENU_ITEM_CLICK = 2,
};

#pragma mark RCSearchType - 公众服务查找匹配方式
/*!
 公众服务查找匹配方式
 */
typedef NS_ENUM(NSUInteger, RCSearchType) {
    /*!
     精确匹配
     */
    RC_SEARCH_TYPE_EXACT = 0,

    /*!
     模糊匹配
     */
    RC_SEARCH_TYPE_FUZZY = 1,
    /*!
     无效类型
     */
    RCSearchType_INVALID
};

/*!
 客服服务方式
 */
typedef NS_ENUM(NSUInteger, RCCSModeType) {
    /*!
     无客服服务
     */
    RC_CS_NoService = 0,

    /*!
     机器人服务
     */
    RC_CS_RobotOnly = 1,

    /*!
     人工服务
     */
    RC_CS_HumanOnly = 2,

    /*!
     机器人优先服务
     */
    RC_CS_RobotFirst = 3,
};

/*!
 客服评价时机
 */
typedef NS_ENUM(NSUInteger, RCCSEvaEntryPoint) {
    /*!
     离开客服评价
     */
    RCCSEvaLeave = 0,

    /*!
     在扩展中展示客户主动评价按钮，离开客服不评价
     */
    RCCSEvaExtention = 1,

    /*!
     无评价入口
     */
    RCCSEvaNone = 2,

    /*!
     坐席结束会话评价
     */
    RCCSEvaCSEnd = 3,
};

/*!
 客服留言类型
 */
typedef NS_ENUM(NSUInteger, RCCSLMType) {
    /*!
     本地Native页面留言
     */
    RCCSLMNative = 0,

    /*!
     web页面留言
     */
    RCCSLMWeb = 1,
};

/*!
 客服问题解决状态
 */
typedef NS_ENUM(NSUInteger, RCCSResolveStatus) {
    /*!
     未解决
     */
    RCCSUnresolved = 0,

    /*!
     已解决
     */
    RCCSResolved = 1,

    /*!
     解决中
     */
    RCCSResolving = 2,
};

/*!
 客服评价类型
 */
typedef NS_ENUM(NSUInteger, RCCSEvaType) {
    /*!
     人工机器人分开评价
     */
    RCCSEvaSeparately = 0,

    /*!
     人工机器人统一评价
     */
    EVA_UNIFIED = 1,
};

#pragma mark RCLogLevel - 日志级别
/*!
 日志级别
 */
typedef NS_ENUM(NSUInteger, RCLogLevel) {
    /*!
     *  只输出错误的日志
     */
    RC_Log_Level_Error = 1,

    /*!
     *  输出错误和警告的日志
     */
    RC_Log_Level_Warn = 2,

    /*!
     *  输出错误、警告和一般的日志
     */
    RC_Log_Level_Info = 3,
};

#pragma mark RCTimestampOrder - 历史消息查询顺序
/*!
 日志级别
 */
typedef NS_ENUM(NSUInteger, RCTimestampOrder) {
    /*!
     *  降序, 按照时间戳从大到小
     */
    RC_Timestamp_Desc = 0,

    /*!
     *  升序, 按照时间戳从小到大
     */
    RC_Timestamp_Asc = 1,
};

#pragma mark RCPlatform - 在线平台
/*!
 在线平台
 */
typedef NS_ENUM(NSUInteger, RCPlatform) {
    /*!
     其它平台
     */
    RCPlatform_Other = 0,

    /*!
     iOS
     */
    RCPlatform_iOS = 1,

    /*!
     Android
     */
    RCPlatform_Android = 2,

    /*!
     Web
     */
    RCPlatform_Web = 3,

    /*!
     PC
     */
    RCPlatform_PC = 4
};

#pragma mark RCPushLauguageType - push 语言设置
/*!
 push 语言设置
 */
typedef NS_ENUM(NSUInteger, RCPushLauguage) {
    /*!
     英文
     */
    RCPushLauguage_EN_US = 1,
    /*!
     中文
     */
    RCPushLauguage_ZH_CN
};

#endif
