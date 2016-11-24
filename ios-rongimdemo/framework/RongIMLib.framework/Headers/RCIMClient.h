/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RongIMClient.h
//  Created by xugang on 14/12/23.

#ifndef __RongIMClient
#define __RongIMClient
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RCChatRoomInfo.h"
#import "RCConversation.h"
#import "RCCustomerServiceConfig.h"
#import "RCCustomerServiceInfo.h"
#import "RCDiscussion.h"
#import "RCMessage.h"
#import "RCPublicServiceProfile.h"
#import "RCStatusDefine.h"
#import "RCUploadImageStatusListener.h"
#import "RCUploadMediaStatusListener.h"
#import "RCUserInfo.h"
#import "RCWatchKitStatusDelegate.h"
#import "RCCustomerServiceGroupItem.h"
#import "RCUserOnlineStatusInfo.h"
#import "RCSearchConversationResult.h"

#pragma mark - 消息接收监听器

/*!
 IMlib消息接收的监听器

 @discussion
 设置IMLib的消息接收监听器请参考RCIMClient的setReceiveMessageDelegate:object:方法。

 @warning 如果您使用IMlib，可以设置并实现此Delegate监听消息接收；
 如果您使用IMKit，请使用RCIM中的RCIMReceiveMessageDelegate监听消息接收，而不要使用此监听器，否则会导致IMKit中无法自动更新UI！
 */
@protocol RCIMClientReceiveMessageDelegate <NSObject>

/*!
 接收消息的回调方法

 @param message     当前接收到的消息
 @param nLeft       还剩余的未接收的消息数，left>=0
 @param object      消息监听设置的key值

 @discussion 如果您设置了IMlib消息监听之后，SDK在接收到消息时候会执行此方法。
 其中，left为还剩余的、还未接收的消息数量。比如刚上线一口气收到多条消息时，通过此方法，您可以获取到每条消息，left会依次递减直到0。
 您可以根据left数量来优化您的App体验和性能，比如收到大量消息时等待left为0再刷新UI。
 object为您在设置消息接收监听时的key值。
 */
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object;

@optional
/*!
 消息被撤回的回调方法
 
 @param messageId 被撤回的消息ID
 
 @discussion 被撤回的消息会变更为RCRecallNotificationMessage，App需要在UI上刷新这条消息。
 */
- (void)onMessageRecalled:(long)messageId;

/*!
 请求消息已读回执（收到需要阅读时发送回执的请求，收到此请求后在会话页面已经展示该 messageUId 对应的消息或者调用 getHistoryMessages 获取消息的时候，包含此 messageUId 的消息，需要调用
 sendMessageReadReceiptResponse 接口发送消息阅读回执）
 
 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 */
- (void)onMessageReceiptRequest:(RCConversationType)conversationType targetId:(NSString *)targetId messageUId:(NSString *)messageUId;

/*!
 消息已读回执响应（收到阅读回执响应，可以按照 messageUId 更新消息的阅读数）
 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 @param userIdList 已读userId列表
 */
- (void)onMessageReceiptResponse:(RCConversationType)conversationType targetId:(NSString *)targetId messageUId:(NSString *)messageUId readerList:(NSMutableDictionary *)userIdList;

@end

#pragma mark - 连接状态监听器

/*!
 IMLib连接状态的的监听器

 @discussion
 设置IMLib的连接状态监听器，请参考RCIMClient的setRCConnectionStatusChangeDelegate:方法。

 @warning 如果您使用IMLib，可以设置并实现此Delegate监听连接状态变化；
 如果您使用IMKit，请使用RCIM中的RCIMConnectionStatusDelegate监听消息接收，而不要使用此监听器，否则会导致IMKit中无法自动更新UI！
 */
@protocol RCConnectionStatusChangeDelegate <NSObject>

/*!
 IMLib连接状态的的监听器

 @param status  SDK与融云服务器的连接状态

 @discussion 如果您设置了IMLib消息监听之后，当SDK与融云服务器的连接状态发生变化时，会回调此方法。
 */
- (void)onConnectionStatusChanged:(RCConnectionStatus)status;

@end

#pragma mark - 输入状态监听器

/*!
 IMLib输入状态的的监听器

 @discussion 设置IMLib的输入状态监听器，请参考RCIMClient的setRCTypingStatusDelegate:方法。

 @warning 如果您使用IMLib，可以设置并实现此Delegate监听消息接收；如果您使用IMKit，请直接设置RCIM中的enableSendComposingStatus，而不要使用此监听器，否则会导致IMKit中无法自动更新UI！
 */
@protocol RCTypingStatusDelegate <NSObject>

/*!
 用户输入状态变化的回调

 @param conversationType        会话类型
 @param targetId                会话目标ID
 @param userTypingStatusList 正在输入的RCUserTypingStatus列表（nil标示当前没有用户正在输入）

 @discussion 当客户端收到用户输入状态的变化时，会回调此接口，通知发生变化的会话以及当前正在输入的RCUserTypingStatus列表。

 @warning 目前仅支持单聊。
 */
- (void)onTypingStatusChanged:(RCConversationType)conversationType
                     targetId:(NSString *)targetId
                       status:(NSArray *)userTypingStatusList;

@end

#pragma mark - 日志监听器
/*!
 IMLib日志的监听器
 
 @discussion
 设置IMLib日志的监听器，请参考RCIMClient的setRCLogInfoDelegate:方法。
 
 @discussion 您可以通过logLevel来控制日志的级别。
 */
@protocol RCLogInfoDelegate <NSObject>

/*!
 IMLib日志的回调
 
 @param logInfo 日志信息
 */
- (void)didOccurLog:(NSString *)logInfo;

@end

#pragma mark - IMLib核心类

/*!
 融云IMLib核心类

 @discussion 您需要通过sharedRCIMClient方法，获取单例对象。
 */
@interface RCIMClient : NSObject

/*!
 获取融云通讯能力库IMLib的核心类单例

 @return 融云通讯能力库IMLib的核心类单例

 @discussion 您可以通过此方法，获取IMLib的单例，访问对象中的属性和方法.
 */
+ (instancetype)sharedRCIMClient;

#pragma mark - SDK初始化

/*!
 初始化融云SDK

 @param appKey  从融云开发者平台创建应用后获取到的App Key

 @discussion
 您在使用融云SDK所有功能(包括显示SDK中或者继承于SDK的View)之前，您必须先调用此方法初始化SDK。
 在App整个生命周期中，您只需要执行一次初始化。

 @warning 如果您使用IMLib，请使用此方法初始化SDK；
 如果您使用IMKit，请使用RCIM中的initWithAppKey:方法初始化，而不要使用此方法。

 @warning **已废弃，请勿使用。**
 升级说明:从2.4.1版本开始，为了兼容Swift的风格与便于使用，将此方法升级为initWithAppKey:方法，方法的功能和使用均不变。**
 */
- (void)init:(NSString *)appKey __deprecated_msg("已废弃，请勿使用。");

/*!
 初始化融云SDK

 @param appKey  从融云开发者平台创建应用后获取到的App Key

 @discussion
 您在使用融云SDK所有功能（包括显示SDK中或者继承于SDK的View）之前，您必须先调用此方法初始化SDK。
 在App整个生命周期中，您只需要执行一次初始化。

 **升级说明:**
 **从2.4.1版本开始，为了兼容Swift的风格与便于使用，将原有的init:方法升级为此方法，方法的功能和使用均不变。**

 @warning 如果您使用IMLib，请使用此方法初始化SDK；
 如果您使用IMKit，请使用RCIM中的同名方法初始化，而不要使用此方法。
 */
- (void)initWithAppKey:(NSString *)appKey;

/*!
 设置deviceToken，用于远程推送

 @param deviceToken     从系统获取到的设备号deviceToken(需要去掉空格和尖括号)

 @discussion
 deviceToken是系统提供的，从苹果服务器获取的，用于APNs远程推送必须使用的设备唯一值。
 您需要将-application:didRegisterForRemoteNotificationsWithDeviceToken:获取到的deviceToken，转为NSString类型，并去掉其中的空格和尖括号，作为参数传入此方法。

 如:

    - (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
        NSString *token = [deviceToken description];
        token = [token stringByReplacingOccurrencesOfString:@"<"
 withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@">"
 withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@" "
 withString:@""];
        [[RCIMClient sharedRCIMClient] setDeviceToken:token];
    }

 */
- (void)setDeviceToken:(NSString *)deviceToken;

#pragma mark - 设置导航服务器和上传文件服务器(仅限独立数据中心使用，使用前必须先联系商务开通)

/*!
 设置导航服务器和上传文件服务器信息

 @param naviServer     导航服务器地址，具体的格式参考下面的说明
 @param fileServer     文件服务器地址，具体的格式参考下面的说明
 @return               是否设置成功

 @warning 仅限独立数据中心使用，使用前必须先联系商务开通。
 @discussion
 naviServer必须为有效的服务器地址，fileServer如果想使用默认的，可以传nil。
 naviServer和fileServer的格式说明：
 1、如果使用https，则设置为https://cn.xxx.com:port或https://cn.xxx.com格式，其中域名部分也可以是IP，如果不指定端口，将默认使用443端口。
 2、如果使用http，则设置为cn.xxx.com:port或cn.xxx.com格式，其中域名部分也可以是IP，如果不指定端口，将默认使用80端口。
 */
- (BOOL)setServerInfo:(NSString *)naviServer fileServer:(NSString *)fileServer;

#pragma mark - 连接与断开服务器

/*!
 与融云服务器建立连接

 @param token                   从您服务器端获取的token(用户身份令牌)
 @param successBlock            连接建立成功的回调
 [userId:当前连接成功所用的用户ID]
 @param errorBlock              连接建立失败的回调 [status:连接失败的错误码]
 @param tokenIncorrectBlock     token错误或者过期的回调

 @discussion 在App整个生命周期，您只需要调用一次此方法与融云服务器建立连接。
 之后无论是网络出现异常或者App有前后台的切换等，SDK都会负责自动重连。
 除非您已经手动将连接断开，否则您不需要自己再手动重连。

 tokenIncorrectBlock有两种情况：
 一是token错误，请您检查客户端初始化使用的AppKey和您服务器获取token使用的AppKey是否一致；
 二是token过期，是因为您在开发者后台设置了token过期时间，您需要请求您的服务器重新获取token并再次用新的token建立连接。

 @warning 如果您使用IMLib，请使用此方法建立与融云服务器的连接；
 如果您使用IMKit，请使用RCIM中的同名方法建立与融云服务器的连接，而不要使用此方法。

 在tokenIncorrectBlock的情况下，您需要请求您的服务器重新获取token并建立连接，但是注意避免无限循环，以免影响App用户体验。

 此方法的回调并非为原调用线程，您如果需要进行UI操作，请注意切换到主线程。
 */
- (void)connectWithToken:(NSString *)token
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode status))errorBlock
          tokenIncorrect:(void (^)())tokenIncorrectBlock;

///*!
// 重新建立与服务器的连接
//
// @param successBlock 重新连接成功的回调
// @param errorBlock   重新连接失败的回调
//
// @warning 升级说明：从2.2.3版本开始，删除此方法。
// SDK在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性，不需要App手动进行重连操作。
// */
//- (void)reconnect:(void (^)(NSString *userId))successBlock
//            error:(void (^)(RCConnectErrorCode status))errorBlock;

/*!
 断开与融云服务器的连接

 @param isReceivePush   App在断开连接之后，是否还接收远程推送

 @discussion
 因为SDK在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 所以除非您的App逻辑需要登出，否则一般不需要调用此方法进行手动断开。

 @warning 如果您使用IMLib，请使用此方法断开与融云服务器的连接；
 如果您使用IMKit，请使用RCIM中的同名方法断开与融云服务器的连接，而不要使用此方法。

 isReceivePush指断开与融云服务器的连接之后，是否还接收远程推送。
 [[RCIMClient sharedRCIMClient] disconnect:YES]与[[RCIMClient sharedRCIMClient]
 disconnect]完全一致；
 [[RCIMClient sharedRCIMClient] disconnect:NO]与[[RCIMClient sharedRCIMClient]
 logout]完全一致。
 您只需要按照您的需求，使用disconnect:与disconnect以及logout三个接口其中一个即可。
 */
- (void)disconnect:(BOOL)isReceivePush;

/*!
 断开与融云服务器的连接，但仍然接收远程推送

 @discussion
 因为SDK在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 所以除非您的App逻辑需要登出，否则一般不需要调用此方法进行手动断开。

 @warning 如果您使用IMLib，请使用此方法断开与融云服务器的连接；
 如果您使用IMKit，请使用RCIM中的同名方法断开与融云服务器的连接，而不要使用此方法。

 [[RCIMClient sharedRCIMClient] disconnect:YES]与[[RCIMClient sharedRCIMClient]
 disconnect]完全一致；
 [[RCIMClient sharedRCIMClient] disconnect:NO]与[[RCIMClient sharedRCIMClient]
 logout]完全一致。
 您只需要按照您的需求，使用disconnect:与disconnect以及logout三个接口其中一个即可。
 */
- (void)disconnect;

/*!
 断开与融云服务器的连接，并不再接收远程推送

 @discussion
 因为SDK在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 所以除非您的App逻辑需要登出，否则一般不需要调用此方法进行手动断开。

 @warning 如果您使用IMKit，请使用此方法断开与融云服务器的连接；
 如果您使用IMLib，请使用RCIMClient中的同名方法断开与融云服务器的连接，而不要使用此方法。

 [[RCIMClient sharedRCIMClient] disconnect:YES]与[[RCIMClient sharedRCIMClient]
 disconnect]完全一致；
 [[RCIMClient sharedRCIMClient] disconnect:NO]与[[RCIMClient sharedRCIMClient]
 logout]完全一致。
 您只需要按照您的需求，使用disconnect:与disconnect以及logout三个接口其中一个即可。
 */
- (void)logout;

#pragma mark - 连接状态监听

/*!
 设置IMLib的连接状态监听器

 @param delegate    IMLib连接状态监听器

 @warning 如果您使用IMLib，可以设置并实现此Delegate监听连接状态变化；
 如果您使用IMKit，请使用RCIM中的connectionStatusDelegate监听连接状态变化，而不要使用此方法，否则会导致IMKit中无法自动更新UI！
 */
- (void)setRCConnectionStatusChangeDelegate:
    (id<RCConnectionStatusChangeDelegate>)delegate;

/*!
 获取当前SDK的连接状态

 @return 当前SDK的连接状态
 */
- (RCConnectionStatus)getConnectionStatus;

/*!
 获取当前的网络状态

 @return 当前的网路状态
 */
- (RCNetworkStatus)getCurrentNetworkStatus;

/*!
 SDK当前所处的运行状态
 */
@property(nonatomic, assign, readonly) RCSDKRunningMode sdkRunningMode;

#pragma mark - Apple Watch状态监听

/*!
 用于Apple Watch的IMLib事务监听器
 */
@property(nonatomic, strong) id<RCWatchKitStatusDelegate>
    watchKitStatusDelegate;

#pragma mark - 用户信息

/*!
 当前登录用户的用户信息

 @discussion 用于与融云服务器建立连接之后，设置当前用户的用户信息。

 @warning 如果传入的用户信息中的用户ID与当前登录的用户ID不匹配，则将会忽略。
 如果您使用IMLib，请使用此字段设置当前登录用户的用户信息；
 如果您使用IMKit，请使用RCIM中的currentUserInfo设置当前登录用户的用户信息，而不要使用此字段。
 */
@property(nonatomic, strong) RCUserInfo *currentUserInfo;

/*!
 从融云服务器获取用户信息（已废弃，请勿使用）

 @param userId                      用户ID
 @param successBlock                获取用户信息成功的回调
 [userInfo:获取到的用户信息]
 @param errorBlock                  获取用户信息失败的回调 [status:失败的错误码]

 @warning **已废弃，请勿使用。**
 */
- (void)getUserInfo:(NSString *)userId
            success:(void (^)(RCUserInfo *userInfo))successBlock
              error:(void (^)(RCErrorCode status))errorBlock
    __deprecated_msg("已废弃，请勿使用。");

#pragma mark - 消息接收与发送

/*!
 注册自定义的消息类型

 @param messageClass    自定义消息的类，该自定义消息需要继承于RCMessageContent

 @discussion
 如果您需要自定义消息，必须调用此方法注册该自定义消息的消息类型，否则SDK将无法识别和解析该类型消息。

 @warning 如果您使用IMLib，请使用此方法注册自定义的消息类型；
 如果您使用IMKit，请使用RCIM中的同名方法注册自定义的消息类型，而不要使用此方法。
 */
- (void)registerMessageType:(Class)messageClass;

#pragma mark 消息发送

/*!
 发送消息

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [nErrorCode:发送失败的错误码,
 messageId:消息的ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。

 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。

 如果您使用此方法发送图片消息，需要您自己实现图片的上传，构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为上传成功的URL地址，然后使用此方法发送。

 如果您使用此方法发送文件消息，需要您自己实现文件的上传，构建一个RCFileMessage对象，
 并将RCFileMessage中的fileUrl字段设置为上传成功的URL地址，然后使用此方法发送。
 
 @warning 如果您使用IMLib，可以使用此方法发送消息；
 如果您使用IMKit，请使用RCIM中的同名方法发送消息，否则不会自动更新UI。
 */
- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode,
                                     long messageId))errorBlock;


/*!
 发送媒体消息（图片消息或文本消息）
 
 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的ID]
 @param cancelBlock         用户取消了消息发送的回调 [messageId:消息的ID]
 @return                    发送的消息实体
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
 
 如果您需要上传图片到自己的服务器，需要构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为上传成功的URL地址，然后使用RCIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 
 如果您需要上传文件到自己的服务器，构建一个RCFileMessage对象，
 并将RCFileMessage中的fileUrl字段设置为上传成功的URL地址，然后使用RCIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 
 @warning 如果您使用IMLib，可以使用此方法发送媒体消息；
 如果您使用IMKit，请使用RCIM中的同名方法发送媒体消息，否则不会自动更新UI。
 */
- (RCMessage *)sendMediaMessage:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                        content:(RCMessageContent *)content
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                       progress:(void (^)(int progress, long messageId))progressBlock
                        success:(void (^)(long messageId))successBlock
                          error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
                         cancel:(void (^)(long messageId))cancelBlock;

/*!
 发送媒体消息(上传图片或文件等媒体信息到指定的服务器)
 
 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param uploadPrepareBlock  媒体文件上传进度更新的IMKit监听
 [uploadListener:当前的发送进度监听，SDK通过此监听更新IMKit UI]
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的ID]
 @param cancelBlock         用户取消了消息发送的回调 [messageId:消息的ID]
 @return                    发送的消息实体
 
 @discussion 此方法仅用于IMKit。
 如果您需要上传图片到自己的服务器并使用IMLib，构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为上传成功的URL地址，然后使用RCIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 
 如果您需要上传文件到自己的服务器并使用IMLib，构建一个RCFileMessage对象，
 并将RCFileMessage中的fileUrl字段设置为上传成功的URL地址，然后使用RCIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 */
- (RCMessage *)sendMediaMessage:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                        content:(RCMessageContent *)content
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                  uploadPrepare:(void (^)(RCUploadMediaStatusListener *uploadListener))uploadPrepareBlock
                       progress:(void (^)(int progress, long messageId))progressBlock
                        success:(void (^)(long messageId))successBlock
                          error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
                         cancel:(void (^)(long messageId))cancelBlock;

/*!
 取消发送中的媒体信息
 
 @param messageId           媒体消息的messageId
 
 @return YES表示取消成功，NO表示取消失败，即已经发送成功或者消息不存在。
 */
- (BOOL)cancelSendMediaMessage:(long)messageId;

/*!
 插入消息

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param senderUserId        消息发送者的用户ID
 @param sendStatus          发送状态
 @param content             消息的内容
 @return                    插入的消息实体

 @discussion 此方法不支持聊天室的会话类型。目前仅支持插入向外发送的消息，不支持插入接收的消息。

 @warning **已废弃，请勿使用。**
 升级说明：如果您之前使用了此接口，可以直接替换为insertOutgoingMessage:targetId:sentStatus:content:接口，行为和实现完全一致。
 */
- (RCMessage *)insertMessage:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                senderUserId:(NSString *)senderUserId
                  sendStatus:(RCSentStatus)sendStatus
                     content:(RCMessageContent *)content
__deprecated_msg("已废弃，请勿使用。");

/*!
 插入向外发送的消息
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param sentStatus          发送状态
 @param content             消息的内容
 @return                    插入的消息实体
 
 @discussion 此方法不支持聊天室的会话类型。
 */
- (RCMessage *)insertOutgoingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                          sentStatus:(RCSentStatus)sentStatus
                             content:(RCMessageContent *)content;

/*!
 插入向外发送的、指定时间的消息
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param sentStatus          发送状态
 @param content             消息的内容
 @param sentTime            消息发送的Unix时间戳，单位为毫秒
 @return                    插入的消息实体
 
 @discussion 此方法不支持聊天室的会话类型。如果sentTime<=0，则被忽略，会以插入时的时间为准。
 */
//- (RCMessage *)insertOutgoingMessage:(RCConversationType)conversationType
//                            targetId:(NSString *)targetId
//                          sentStatus:(RCSentStatus)sentStatus
//                             content:(RCMessageContent *)content
//                            sentTime:(long long)sentTime;

/*!
 下载消息内容中的媒体信息

 @param conversationType    消息的会话类型
 @param targetId            消息的目标会话ID
 @param mediaType           消息内容中的多媒体文件类型，目前仅支持图片
 @param mediaUrl            多媒体文件的网络URL
 @param progressBlock       消息下载进度更新的回调 [progress:当前的下载进度, 0
 <= progress <= 100]
 @param successBlock        下载成功的回调
 [mediaPath:下载成功后本地存放的文件路径]
 @param errorBlock          下载失败的回调[errorCode:下载失败的错误码]
 */
- (void)downloadMediaFile:(RCConversationType)conversationType
                 targetId:(NSString *)targetId
                mediaType:(RCMediaType)mediaType
                 mediaUrl:(NSString *)mediaUrl
                 progress:(void (^)(int progress))progressBlock
                  success:(void (^)(NSString *mediaPath))successBlock
                    error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 下载消息内容中的媒体信息
 
 @param messageId           媒体消息的messageId
 @param progressBlock       消息下载进度更新的回调 [progress:当前的下载进度, 0 <= progress <= 100]
 @param successBlock        下载成功的回调[mediaPath:下载成功后本地存放的文件路径]
 @param errorBlock          下载失败的回调[errorCode:下载失败的错误码]
 @param cancelBlock         用户取消了下载的回调
 */
- (void)downloadMediaMessage:(long)messageId
                    progress:(void (^)(int progress))progressBlock
                     success:(void (^)(NSString *mediaPath))successBlock
                       error:(void (^)(RCErrorCode errorCode))errorBlock
                      cancel:(void (^)())cancelBlock;

/*!
 取消下载中的媒体信息
 
 @param messageId 媒体消息的messageId
 
 @return YES表示取消成功，NO表示取消失败，即已经下载完成或者消息不存在。
 */
- (BOOL)cancelDownloadMediaMessage:(long)messageId;

///*!
// 发送状态消息
//
// @param conversationType    会话类型
// @param targetId            目标会话ID
// @param content             消息内容
// @param successBlock        发送消息成功的回调 [messageId:消息的ID]
// @param errorBlock          发送消息失败的回调 [nErrorCode:发送失败的错误码,
// messageId:消息的ID]
//
// @discussion 通过此方法发送的消息，根据接收方的状态进行投递。
// 如果接收方不在线，则不会收到远程推送，再上线也不会收到此消息。
//
// @warning **已废弃，请勿使用。**
// 升级说明：如果您之前使用了此接口，可以直接替换为sendMessage:targetId:content:pushContent:pushData:success:error:接口（pushContent和pushData传为nil），行为和实现完全一致。
// */
//- (RCMessage *)sendStatusMessage:(RCConversationType)conversationType
//                        targetId:(NSString *)targetId
//                         content:(RCMessageContent *)content
//                         success:(void (^)(long messageId))successBlock
//                           error:(void (^)(RCErrorCode nErrorCode,
//                                           long messageId))errorBlock
//    __deprecated_msg("已废弃，请勿使用。");

/*!
 发送消息

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          息发送失败的回调 [nErrorCode:发送失败的错误码,
 messageId:消息的ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。

 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。

 使此方法会将pushData设置为nil，如果需要设置pushData可以使用RCIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法。

 如果您使用此方法发送图片消息，需要您自己实现图片的上传，然后构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为最终上传的地址，使用此方法发送。

 如果您使用IMLib，可以使用此方法发送消息；
 如果您使用IMKit，请使用RCIM中的同名方法发送消息，否则不会自动更新UI。
 
 @warning  **已废弃，请勿使用。**
 升级说明：如果您之前使用了此接口，可以直接替换为sendMessage:targetId:content:pushContent:pushData:success:error:接口（pushData传为nil），行为和实现完全一致。
 */
- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode,
                                     long messageId))errorBlock
    __deprecated_msg("已废弃，请勿使用。");

/*!
 发送图片消息

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。

 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。

 使此方法会将pushData设置为nil，如果需要设置pushData可以使用RCIMClient的
 sendImageMessage:targetId:content:pushContent:pushData:progress:success:error:方法。

 如果您需要上传图片到自己的服务器并使用IMLib，构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为上传成功的URL地址，然后使用RCIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 如果您使用IMLib，可以使用此方法发送图片消息；
 如果您使用IMKit，请使用RCIM中的同名方法发送图片消息，否则不会自动更新UI。
 
 @warning **已废弃，请勿使用。**
 升级说明：如果您之前使用了此接口，可以直接替换为sendMediaMessage:targetId:content:pushContent:pushData:progress:success:error:cancel:接口（pushData传为nil），行为和实现完全一致。
 */
- (RCMessage *)
sendImageMessage:(RCConversationType)conversationType
        targetId:(NSString *)targetId
         content:(RCMessageContent *)content
     pushContent:(NSString *)pushContent
        progress:(void (^)(int progress, long messageId))progressBlock
         success:(void (^)(long messageId))successBlock
           error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
    __deprecated_msg("已废弃，请勿使用。");

/*!
 发送图片消息

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。

 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。

 如果您需要上传图片到自己的服务器，构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为上传成功的URL地址，然后使用RCIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 如果您使用IMLib，可以使用此方法发送图片消息；
 如果您使用IMKit，请使用RCIM中的同名方法发送图片消息，否则不会自动更新UI。

 @warning **已废弃，请勿使用。**
 升级说明：如果您之前使用了此接口，可以直接替换为sendMediaMessage:targetId:content:pushContent:pushData:progress:success:error:cancel:接口，行为和实现完全一致。
 */
- (RCMessage *)
sendImageMessage:(RCConversationType)conversationType
        targetId:(NSString *)targetId
         content:(RCMessageContent *)content
     pushContent:(NSString *)pushContent
        pushData:(NSString *)pushData
        progress:(void (^)(int progress, long messageId))progressBlock
         success:(void (^)(long messageId))successBlock
           error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
    __deprecated_msg("已废弃，请勿使用。");

/*!
 发送图片消息(上传图片到指定的服务器)

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param uploadPrepareBlock  图片上传进度更新的IMKit监听
 [uploadListener:当前的发送进度监听，SDK通过此监听更新IMKit UI]
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的ID]
 @return                    发送的消息实体

 @discussion 此方法仅用于IMKit。
 如果您需要上传图片到自己的服务器并使用IMLib，构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为上传成功的URL地址，然后使用RCIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 @warning **已废弃，请勿使用。**
 升级说明：如果您之前使用了此接口，可以直接替换为sendMediaMessage:targetId:content:pushContent:pushData:uploadPrepare:progress:success:error:cancel:接口，行为和实现完全一致。
 */
- (RCMessage *)
sendImageMessage:(RCConversationType)conversationType
        targetId:(NSString *)targetId
         content:(RCMessageContent *)content
     pushContent:(NSString *)pushContent
        pushData:(NSString *)pushData
   uploadPrepare:
       (void (^)(RCUploadImageStatusListener *uploadListener))uploadPrepareBlock
        progress:(void (^)(int progress, long messageId))progressBlock
         success:(void (^)(long messageId))successBlock
           error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
    __deprecated_msg("已废弃，请勿使用。");

/*!
 发送定向消息
 
 @param conversationType 发送消息的会话类型
 @param targetId         发送消息的目标会话ID
 @param userIdList       发送给的用户ID列表
 @param content          消息的内容
 @param pushContent      接收方离线时需要显示的远程推送内容
 @param pushData         接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock     消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock       消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的ID]
 
 @return 发送的消息实体
 
 @discussion 此方法用于在群组和讨论组中发送消息给其中的部分用户，其它用户不会收到这条消息。
 如果您使用IMLib，可以使用此方法发送定向消息；
 如果您使用IMKit，请使用RCIM中的同名方法发送定向消息，否则不会自动更新UI。
 
 @warning 此方法目前仅支持群组和讨论组。
 */
- (RCMessage *)sendDirectionalMessage:(RCConversationType)conversationType
                             targetId:(NSString *)targetId
                         toUserIdList:(NSArray *)userIdList
                              content:(RCMessageContent *)content
                          pushContent:(NSString *)pushContent
                             pushData:(NSString *)pushData
                              success:(void (^)(long messageId))successBlock
                                error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

#pragma mark 消息接收监听
/*!
 设置IMlib的消息接收监听器

 @param delegate    IMLib消息接收监听器
 @param userData    用户自定义的监听器Key值，可以为nil

 @discussion
 设置IMLib的消息接收监听器请参考RCIMClient的setReceiveMessageDelegate:object:方法。

 userData为您自定义的任意数据，SDK会在回调的onReceived:left:object:方法中传入作为object参数。
 您如果有设置多个监听，会只有最终的一个监听器起作用，您可以通过该userData值区分您设置的监听器。如果不需要直接设置为nil就可以。

 @warning 如果您使用IMlib，可以设置并实现此Delegate监听消息接收；
 如果您使用IMKit，请使用RCIM中的receiveMessageDelegate监听消息接收，而不要使用此方法，否则会导致IMKit中无法自动更新UI！
 */
- (void)setReceiveMessageDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate
                           object:(id)userData;

#pragma mark 消息阅读回执
/*!
 @const 收到已读回执的Notification

 @discussion 收到消息已读回执之后，IMLib会分发此通知。

 Notification的object为nil，userInfo为NSDictionary对象，
 其中key值分别为@"cType"、@"tId"、@"messageTime",
 对应的value为会话类型的NSNumber对象、会话的targetId、已阅读的最后一条消息的sendTime。
 如：
 NSNumber *ctype = [notification.userInfo objectForKey:@"cType"];
 NSNumber *time = [notification.userInfo objectForKey:@"messageTime"];
 NSString *targetId = [notification.userInfo objectForKey:@"tId"];
 NSString *fromUserId = [notification.userInfo objectForKey:@"fId"];
 
 收到这个消息之后可以更新这个会话中messageTime以前的消息UI为已读（底层数据库消息状态已经改为已读）。

 @warning 目前仅支持单聊。
 */
FOUNDATION_EXPORT NSString *const RCLibDispatchReadReceiptNotification;

/*!
 发送某个会话中消息阅读的回执

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param timestamp           该会话中已阅读的最后一条消息的发送时间戳
 @param successBlock        发送成功的回调
 @param errorBlock          发送失败的回调[nErrorCode: 失败的错误码]

 @discussion 此接口只支持单聊, 如果使用Lib 可以注册监听
 RCLibDispatchReadReceiptNotification 通知,使用kit 直接设置RCIM.h
 中的enabledReadReceiptConversationTypeList。

 @warning 目前仅支持单聊。
 */
- (void)sendReadReceiptMessage:(RCConversationType)conversationType
                      targetId:(NSString *)targetId
                          time:(long long)timestamp
                       success:(void (^)())successBlock
                         error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 请求消息阅读回执
 
 @param message      要求阅读回执的消息
 @param successBlock 请求成功的回调
 @param errorBlock   请求失败的回调[nErrorCode: 失败的错误码]
 
 @discussion 通过此接口，可以要求阅读了这条消息的用户发送阅读回执。
 */
- (void)sendReadReceiptRequest:(RCMessage *)message
                       success:(void (^)())successBlock
                         error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 发送阅读回执
 
 @param conversationType 会话类型
 @param targetId         会话ID
 @param messageList      已经阅读了的消息列表
 @param successBlock     发送成功的回调
 @param errorBlock       发送失败的回调[nErrorCode: 失败的错误码]
 
 @discussion 当用户阅读了需要阅读回执的消息，可以通过此接口发送阅读回执，消息的发送方即可直接知道那些人已经阅读。
 */
- (void)sendReadReceiptResponse:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                    messageList:(NSArray<RCMessage *> *)messageList
                        success:(void (^)())successBlock
                          error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 同步会话阅读状态
 
 @param conversationType 会话类型
 @param targetId         会话ID
 @param timestamp        已经阅读的最后一条消息的Unix时间戳(毫秒)
 @param successBlock     同步成功的回调
 @param errorBlock       同步失败的回调[nErrorCode: 失败的错误码]
 */
- (void)syncConversationReadStatus:(RCConversationType)conversationType
                          targetId:(NSString *)targetId
                              time:(long long)timestamp
                           success:(void (^)())successBlock
                             error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 撤回消息
 
 @param message      需要撤回的消息
 @param successBlock 撤回成功的回调 [messageId:撤回的消息ID，该消息已经变更为新的消息]
 @param errorBlock   撤回失败的回调 [errorCode:撤回失败错误码]
 */
- (void)recallMessage:(RCMessage *)message
              success:(void (^)(long messageId))successBlock
                error:(void(^)(RCErrorCode errorcode))errorBlock;

#pragma mark - 消息操作

/*!
 获取某个会话中指定数量的最新消息实体

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param count               需要获取的消息数量
 @return                    消息实体RCMessage对象列表

 @discussion
 此方法会获取该会话中指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 */
- (NSArray *)getLatestMessages:(RCConversationType)conversationType
                      targetId:(NSString *)targetId
                         count:(int)count;

/*!
 获取会话中，从指定消息之前、指定数量的最新消息实体

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param oldestMessageId     截止的消息ID
 @param count               需要获取的消息数量
 @return                    消息实体RCMessage对象列表

 @discussion
 此方法会获取该会话中，oldestMessageId之前的、指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含oldestMessageId对应那条消息，如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 如：
 oldestMessageId为10，count为2，会返回messageId为9和8的RCMessage对象列表。
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                oldestMessageId:(long)oldestMessageId
                          count:(int)count;

/*!
 获取会话中，从指定消息之前、指定数量的、指定消息类型的最新消息实体

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param objectName          消息内容的类型名
 @param oldestMessageId     截止的消息ID
 @param count               需要获取的消息数量
 @return                    消息实体RCMessage对象列表

 @discussion
 此方法会获取该会话中，oldestMessageId之前的、指定数量和消息类型的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含oldestMessageId对应的那条消息，如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 如：
 oldestMessageId为10，count为2，会返回messageId为9和8的RCMessage对象列表。
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                     objectName:(NSString *)objectName
                oldestMessageId:(long)oldestMessageId
                          count:(int)count;

/*!
 获取会话中，从指定消息之前、指定数量的、指定消息类型、可以向前或向后查找的最新消息实体

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param objectName          消息内容的类型名
 @param baseMessageId       当前的消息ID
 @param isForward           查询方向 true为向前，false为向后
 @param count               需要获取的消息数量
 @return                    消息实体RCMessage对象列表

 @discussion
 此方法会获取该会话中，baseMessageId之前或之后的、指定数量、消息类型和查询方向的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含baseMessageId对应的那条消息，如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                     objectName:(NSString *)objectName
                  baseMessageId:(long)baseMessageId
                      isForward:(BOOL)isForward
                          count:(int)count;

/*!
 在会话中搜索指定消息的前 beforeCount 数量和后 afterCount 数量的消息。返回的消息列表中会包含指定的消息。消息列表时间顺序从旧到新。
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param sentTime            消息的发送时间
 @param beforeCount         指定消息的前部分消息数量
 @param afterCount          指定消息的后部分消息数量
 @return                    消息实体RCMessage对象列表
 
 @discussion
 获取该会话的这条消息及这条消息前 beforeCount 条和后 afterCount 条消息,如前后消息不够则返回实际数量的消息。
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                       sentTime:(long long)sentTime
                    beforeCount:(int)beforeCount
                     afterCount:(int)afterCount;

/*!
 从服务器端获取之前的历史消息

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param recordTime          截止的消息发送时间戳，毫秒
 @param count               需要获取的消息数量， 0 < count <= 20
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]

 @discussion
 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
 例如，本地会话中有10条消息，您想拉取更多保存在服务器的消息的话，recordTime应传入最早的消息的发送时间戳，count传入1~20之间的数值。
 */
- (void)getRemoteHistoryMessages:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                      recordTime:(long long)recordTime
                           count:(int)count
                         success:(void (^)(NSArray *messages))successBlock
                           error:(void (^)(RCErrorCode status))errorBlock;

/*!
 从服务器端获取聊天室的历史消息
 @param targetId            聊天室ID
 @param recordTime          起始的消息发送时间戳，毫秒
 @param count               需要获取的消息数量， 0 < count <= 200
 @param order               拉取顺序，RC_Timestamp_Desc:倒序，RC_Timestamp_ASC:正序
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组, syncTime:下次拉取消息的时间戳]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]
 
 @discussion
 此方法从服务器端获取聊天室的历史消息，但是必须先开通聊天室消息云存储功能。
 指定开始时间,比如2016年9月1日10点(1472695200000), 默认是0(正序:从存储的第一条消息开始拉取,倒序:从存储的最后一条消息开始拉取)
 */
- (void)getRemoteChatroomHistoryMessages:(NSString *)targetId
                              recordTime:(long long)recordTime
                                   count:(int)count
                                   order:(RCTimestampOrder)order
                                 success:(void (^)(NSArray *messages, long long syncTime))successBlock
                                   error:(void (^)(RCErrorCode status))errorBlock;

/*!
 获取会话中@提醒自己的消息
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 
 @discussion
 此方法从本地获取被@提醒的消息(最多返回10条信息)
 @warning 使用 IMKit 注意在进入会话页面前调用，否则在进入会话清除未读数的接口 clearMessagesUnreadStatus: targetId:
 以及 设置消息接收状态接口 setMessageReceivedStatus:receivedStatus:会同步清除被提示信息状态。
 */
- (NSArray *)getUnreadMentionedMessages:(RCConversationType)conversationType
                               targetId:(NSString *)targetId;
/*!
 获取消息的发送时间（Unix时间戳、毫秒）

 @param messageId   消息ID
 @return            消息的发送时间（Unix时间戳、毫秒）
 */
- (long long)getMessageSendTime:(long)messageId;

/*!
 通过messageId获取消息实体

 @param messageId   消息ID（数据库索引唯一值）
 @return            通过消息ID获取到的消息实体，当获取失败的时候，会返回nil。
 */
- (RCMessage *)getMessage:(long)messageId;

/*!
 通过全局唯一ID获取消息实体

 @param messageUId   全局唯一ID（服务器消息唯一ID）
 @return 通过全局唯一ID获取到的消息实体，当获取失败的时候，会返回nil。
 */
- (RCMessage *)getMessageByUId:(NSString *)messageUId;

/*!
 删除消息

 @param messageIds  消息ID的列表
 @return            是否删除成功
 */
- (BOOL)deleteMessages:(NSArray *)messageIds;

/*!
 删除某个会话中的所有消息
 
 @param conversationType    会话类型，不支持聊天室
 @param targetId            目标会话ID
 @param successBlock        成功的回调
 @param errorBlock          失败的回调

 @discussion 此方法删除数据库中该会话的消息记录，同时会整理压缩数据库，减少占用空间
 */
- (void)deleteMessages:(RCConversationType)conversationType
              targetId:(NSString *)targetId
               success:(void (^)())successBlock
                 error:(void (^)(RCErrorCode status))errorBlock;

/*!
 删除某个会话中的所有消息

 @param conversationType    会话类型，不支持聊天室
 @param targetId            目标会话ID
 @return                    是否删除成功
 */
- (BOOL)clearMessages:(RCConversationType)conversationType
             targetId:(NSString *)targetId;

/*!
 设置消息的附加信息

 @param messageId   消息ID
 @param value       附加信息
 @return            是否设置成功
 */
- (BOOL)setMessageExtra:(long)messageId value:(NSString *)value;

/*!
 设置消息的接收状态

 @param messageId       消息ID
 @param receivedStatus  消息的接收状态
 @return                是否设置成功
 */
- (BOOL)setMessageReceivedStatus:(long)messageId
                  receivedStatus:(RCReceivedStatus)receivedStatus;

/*!
 设置消息的发送状态

 @param messageId       消息ID
 @param sentStatus      消息的发送状态
 @return                是否设置成功
 */
- (BOOL)setMessageSentStatus:(long)messageId
                  sentStatus:(RCSentStatus)sentStatus;

#pragma mark - 会话列表操作
/*!
 获取会话列表

 @param conversationTypeList 会话类型的数组(需要将RCConversationType转为NSNumber构建Array)
 @return                        会话RCConversation的列表

 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。
 */
- (NSArray *)getConversationList:(NSArray *)conversationTypeList;

/*!
 获取单个会话数据

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @return                    会话的对象
 */
- (RCConversation *)getConversation:(RCConversationType)conversationType
                           targetId:(NSString *)targetId;

/*!
 获取会话中的消息数量

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @return                    会话中的消息数量

 @discussion -1表示获取消息数量出错。
 */
- (int)getMessageCount:(RCConversationType)conversationType
              targetId:(NSString *)targetId;

/*!
 删除指定类型的会话

 @param conversationTypeList 会话类型的数组(需要将RCConversationType转为NSNumber构建Array)
 @return                        是否删除成功
 */
- (BOOL)clearConversations:(NSArray *)conversationTypeList;

/*!
 从本地存储中删除会话

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @return                    是否删除成功

 @discussion 此方法会从本地存储中删除该会话，但是不会删除会话中的消息。
 */
- (BOOL)removeConversation:(RCConversationType)conversationType
                  targetId:(NSString *)targetId;

/*!
 设置会话的置顶状态

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param isTop               是否置顶
 @return                    设置是否成功
 */
- (BOOL)setConversationToTop:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                       isTop:(BOOL)isTop;

#pragma mark 会话中的草稿操作
/*!
 获取会话中的草稿信息

 @param conversationType    会话类型
 @param targetId            会话目标ID
 @return                    该会话中的草稿
 */
- (NSString *)getTextMessageDraft:(RCConversationType)conversationType
                         targetId:(NSString *)targetId;

/*!
 保存草稿信息

 @param conversationType    会话类型
 @param targetId            会话目标ID
 @param content             草稿信息
 @return                    是否保存成功
 */
- (BOOL)saveTextMessageDraft:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                     content:(NSString *)content;

/*!
 删除会话中的草稿信息

 @param conversationType    会话类型
 @param targetId            会话目标ID
 @return                    是否删除成功
 */
- (BOOL)clearTextMessageDraft:(RCConversationType)conversationType
                     targetId:(NSString *)targetId;

#pragma mark 未读消息数

/*!
 获取所有的未读消息数

 @return    所有的未读消息数
 */
- (int)getTotalUnreadCount;

/*!
 获取某个会话内的未读消息数

 @param conversationType    会话类型
 @param targetId            会话目标ID
 @return                    该会话内的未读消息数
 */
- (int)getUnreadCount:(RCConversationType)conversationType
             targetId:(NSString *)targetId;

/*!
 获取某个类型的会话中所有的未读消息数

 @param conversationTypes   会话类型的数组
 @return                    该类型的会话中所有的未读消息数
 */
- (int)getUnreadCount:(NSArray *)conversationTypes;

/*!
 获取某个类型的会话中所有未读的被@的消息数
 
 @param conversationTypes   会话类型的数组
 @return                    该类型的会话中所有未读的被@的消息数
 */
- (int)getUnreadMentionedCount:(NSArray *)conversationTypes;

/*!
 清除某个会话中的未读消息数

 @param conversationType    会话类型，不支持聊天室
 @param targetId            目标会话ID
 @return                    是否清除成功
 */
- (BOOL)clearMessagesUnreadStatus:(RCConversationType)conversationType
                         targetId:(NSString *)targetId;

/*!
 清除某个会话中的未读消息数
 
 @param conversationType    会话类型，不支持聊天室
 @param targetId            目标会话ID
 @param timestamp           该会话已阅读的最后一条消息的发送时间戳
 @return                    是否清除成功
 */
- (BOOL)clearMessagesUnreadStatus:(RCConversationType)conversationType
                         targetId:(NSString *)targetId
                             time:(long long)timestamp;

#pragma mark 会话的消息提醒

/*!
 设置会话的消息提醒状态

 @param conversationType            会话类型
 @param targetId                    目标会话ID
 @param isBlocked                   是否屏蔽消息提醒
 @param successBlock                设置成功的回调
 [nStatus:会话设置的消息提醒状态]
 @param errorBlock                  设置失败的回调 [status:设置失败的错误码]

 @discussion
 如果您使用IMLib，此方法会屏蔽该会话的远程推送；如果您使用IMKit，此方法会屏蔽该会话的所有提醒（远程推送、本地通知、前台提示音）。
 */
- (void)
setConversationNotificationStatus:(RCConversationType)conversationType
                         targetId:(NSString *)targetId
                        isBlocked:(BOOL)isBlocked
                          success:(void (^)(RCConversationNotificationStatus
                                                nStatus))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

/*!
 查询会话的消息提醒状态

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param successBlock        查询成功的回调 [nStatus:会话设置的消息提醒状态]
 @param errorBlock          查询失败的回调 [status:设置失败的错误码]
 */
- (void)
getConversationNotificationStatus:(RCConversationType)conversationType
                         targetId:(NSString *)targetId
                          success:(void (^)(RCConversationNotificationStatus
                                                nStatus))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark 全局消息提醒

/*!
 全局屏蔽某个时间段的消息提醒

 @param startTime       开始屏蔽消息提醒的时间，格式为HH:MM:SS
 @param spanMins        需要屏蔽消息提醒的分钟数，0 < spanMins < 1440
 @param successBlock    屏蔽成功的回调
 @param errorBlock      屏蔽失败的回调 [status:屏蔽失败的错误码]

 @discussion 此方法设置的屏蔽时间会在每天该时间段时生效。
 如果您使用IMLib，此方法会屏蔽该会话在该时间段的远程推送；如果您使用IMKit，此方法会屏蔽该会话在该时间段的所有提醒（远程推送、本地通知、前台提示音）。
 */
- (void)setNotificationQuietHours:(NSString *)startTime
                         spanMins:(int)spanMins
                          success:(void (^)())successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

/*!
 删除已设置的全局时间段消息提醒屏蔽

 @param successBlock    删除屏蔽成功的回调
 @param errorBlock      删除屏蔽失败的回调 [status:失败的错误码]
 */
- (void)removeNotificationQuietHours:(void (^)())successBlock
                               error:(void (^)(RCErrorCode status))errorBlock;

/*!
 查询已设置的全局时间段消息提醒屏蔽

 @param successBlock    屏蔽成功的回调 [startTime:已设置的屏蔽开始时间,
 spansMin:已设置的屏蔽时间分钟数，0 < spansMin < 1440]
 @param errorBlock      查询失败的回调 [status:查询失败的错误码]
 */
- (void)getNotificationQuietHours:(void (^)(NSString *startTime,
                                            int spansMin))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

/*!
 全局屏蔽某个时间段的消息提醒

 @param startTime       开始屏蔽消息提醒的时间，格式为HH:MM:SS
 @param spanMins        需要屏蔽消息提醒的分钟数，0 < spanMins < 1440
 @param successBlock    屏蔽成功的回调
 @param errorBlock      屏蔽失败的回调 [status:屏蔽失败的错误码]

 @discussion 此方法设置的屏蔽时间会在每天该时间段时生效。
 如果您使用IMLib，此方法会屏蔽该会话在该时间段的远程推送；如果您使用IMKit，此方法会屏蔽该会话在该时间段的所有提醒（远程推送、本地通知、前台提示音）。

 @warning **已废弃，请勿使用。**
 升级说明：如果您之前使用了此接口，可以直接替换为setNotificationQuietHours:spanMins:success:error:接口，行为和实现完全一致。
 */
- (void)setConversationNotificationQuietHours:(NSString *)startTime
                                     spanMins:(int)spanMins
                                      success:(void (^)())successBlock
                                        error:(void (^)(RCErrorCode status))
                                                  errorBlock
    __deprecated_msg("已废弃，请勿使用。");

/*!
 删除已设置的全局时间段消息提醒屏蔽

 @param successBlock    删除屏蔽成功的回调
 @param errorBlock      删除屏蔽失败的回调 [status:失败的错误码]

 @warning **已废弃，请勿使用。**
 升级说明：如果您之前使用了此接口，可以直接替换为removeNotificationQuietHours:error:接口，行为和实现完全一致。
 */
- (void)removeConversationNotificationQuietHours:(void (^)())successBlock
                                           error:(void (^)(RCErrorCode status))
                                                     errorBlock
    __deprecated_msg("已废弃，请勿使用。");

#pragma mark - 输入状态提醒

/*!
 设置输入状态的监听器

 @param delegate IMLib输入状态的的监听器

 @warning 目前仅支持单聊。
 */
- (void)setRCTypingStatusDelegate:(id<RCTypingStatusDelegate>)delegate;

/*!
 向会话中发送正在输入的状态

 @param conversationType    会话类型
 @param targetId            会话目标ID
 @param objectName         正在输入的消息的类型名

 @discussion
 contentType为用户当前正在编辑的消息类型名，即RCMessageContent中getObjectName的返回值。
 如文本消息，应该传类型名"RC:TxtMsg"。

 @warning 目前仅支持单聊。
 */
- (void)sendTypingStatus:(RCConversationType)conversationType
                targetId:(NSString *)targetId
             contentType:(NSString *)objectName;

#pragma mark - 黑名单

/*!
 将某个用户加入黑名单

 @param userId          需要加入黑名单的用户ID
 @param successBlock    加入黑名单成功的回调
 @param errorBlock      加入黑名单失败的回调 [status:失败的错误码]
 */
- (void)addToBlacklist:(NSString *)userId
               success:(void (^)())successBlock
                 error:(void (^)(RCErrorCode status))errorBlock;

/*!
 将某个用户移出黑名单

 @param userId          需要移出黑名单的用户ID
 @param successBlock    移出黑名单成功的回调
 @param errorBlock      移出黑名单失败的回调[status:失败的错误码]
 */
- (void)removeFromBlacklist:(NSString *)userId
                    success:(void (^)())successBlock
                      error:(void (^)(RCErrorCode status))errorBlock;

/*!
 查询某个用户是否已经在黑名单中

 @param userId          需要查询的用户ID
 @param successBlock    查询成功的回调
 [bizStatus:该用户是否在黑名单中。0表示已经在黑名单中，101表示不在黑名单中]
 @param errorBlock      查询失败的回调 [status:失败的错误码]
 */
- (void)getBlacklistStatus:(NSString *)userId
                   success:(void (^)(int bizStatus))successBlock
                     error:(void (^)(RCErrorCode status))errorBlock;

/*!
 查询已经设置的黑名单列表

 @param successBlock    查询成功的回调
 [blockUserIds:已经设置的黑名单中的用户ID列表]
 @param errorBlock      查询失败的回调 [status:失败的错误码]
 */
- (void)getBlacklist:(void (^)(NSArray *blockUserIds))successBlock
               error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark - 讨论组操作

/*!
 创建讨论组

 @param name            讨论组名称
 @param userIdList      用户ID的列表
 @param successBlock    创建讨论组成功的回调
 [discussion:创建成功返回的讨论组对象]
 @param errorBlock      创建讨论组失败的回调 [status:创建失败的错误码]
 */
- (void)createDiscussion:(NSString *)name
              userIdList:(NSArray *)userIdList
                 success:(void (^)(RCDiscussion *discussion))successBlock
                   error:(void (^)(RCErrorCode status))errorBlock;

/*!
 讨论组加人，将用户加入讨论组

 @param discussionId    讨论组ID
 @param userIdList      需要加入的用户ID列表
 @param successBlock    讨论组加人成功的回调
 [discussion:讨论组加人成功返回的讨论组对象]
 @param errorBlock      讨论组加人失败的回调 [status:讨论组加人失败的错误码]

 @discussion 设置的讨论组名称长度不能超过40个字符，否则将会截断为前40个字符。
 */
- (void)addMemberToDiscussion:(NSString *)discussionId
                   userIdList:(NSArray *)userIdList
                      success:(void (^)(RCDiscussion *discussion))successBlock
                        error:(void (^)(RCErrorCode status))errorBlock;

/*!
 讨论组踢人，将用户移出讨论组

 @param discussionId    讨论组ID
 @param userId          需要移出的用户ID
 @param successBlock    讨论组踢人成功的回调
 [discussion:讨论组踢人成功返回的讨论组对象]
 @param errorBlock      讨论组踢人失败的回调 [status:讨论组踢人失败的错误码]

 @discussion
 如果当前登录用户不是此讨论组的创建者并且此讨论组没有开放加人权限，则会返回错误。

 @warning 不能使用此接口将自己移除，否则会返回错误。
 如果您需要退出该讨论组，可以使用-quitDiscussion:success:error:方法。
 */
- (void)removeMemberFromDiscussion:(NSString *)discussionId
                            userId:(NSString *)userId
                           success:
                               (void (^)(RCDiscussion *discussion))successBlock
                             error:(void (^)(RCErrorCode status))errorBlock;

/*!
 退出当前讨论组

 @param discussionId    讨论组ID
 @param successBlock    退出成功的回调 [discussion:退出成功返回的讨论组对象]
 @param errorBlock      退出失败的回调 [status:退出失败的错误码]
 */
- (void)quitDiscussion:(NSString *)discussionId
               success:(void (^)(RCDiscussion *discussion))successBlock
                 error:(void (^)(RCErrorCode status))errorBlock;

/*!
 获取讨论组的信息

 @param discussionId    需要获取信息的讨论组ID
 @param successBlock    获取讨论组信息成功的回调 [discussion:获取的讨论组信息]
 @param errorBlock      获取讨论组信息失败的回调
 [status:获取讨论组信息失败的错误码]
 */
- (void)getDiscussion:(NSString *)discussionId
              success:(void (^)(RCDiscussion *discussion))successBlock
                error:(void (^)(RCErrorCode status))errorBlock;

/*!
 设置讨论组名称

 @param discussionId            需要设置的讨论组ID
 @param discussionName          需要设置的讨论组名称，discussionName长度<=40
 @param successBlock            设置成功的回调
 @param errorBlock              设置失败的回调 [status:设置失败的错误码]

 @discussion 设置的讨论组名称长度不能超过40个字符，否则将会截断为前40个字符。
 */
- (void)setDiscussionName:(NSString *)discussionId
                     name:(NSString *)discussionName
                  success:(void (^)())successBlock
                    error:(void (^)(RCErrorCode status))errorBlock;

/*!
 设置讨论组是否开放加人权限

 @param discussionId    讨论组ID
 @param isOpen          是否开放加人权限
 @param successBlock    设置成功的回调
 @param errorBlock      设置失败的回调[status:设置失败的错误码]

 @discussion 讨论组默认开放加人权限，即所有成员都可以加人。
 如果关闭加人权限之后，只有讨论组的创建者有加人权限。
 */
- (void)setDiscussionInviteStatus:(NSString *)discussionId
                           isOpen:(BOOL)isOpen
                          success:(void (^)())successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark - 群组操作（已废弃，请勿使用）

/*!
 同步当前用户所在的群组列表信息(已废弃，建议您通过您的App Server进行群组操作)

 @param groupList               群组信息RCGroup的列表
 @param successBlock            同步成功的回调
 @param errorBlock              同步失败的回调 [status:同步失败的错误码]

 @discussion 此方法已废弃，建议您通过您的App Server进行群组操作。
 群组操作的流程，可以参考：http://support.rongcloud.cn/kb/MzY5

 @warning **已废弃，请勿使用。**
 */
- (void)syncGroups:(NSArray *)groupList
           success:(void (^)())successBlock
             error:(void (^)(RCErrorCode status))errorBlock
    __deprecated_msg("已废弃，请勿使用。");

/*!
 加入群组(已废弃，建议您通过您的App Server进行群组操作)

 @param groupId                 要加入的群组ID
 @param groupName               群组的名称
 @param successBlock            加入成功的回调
 @param errorBlock              加入失败的回调 [status:加入失败的错误码]

 @discussion 此方法已废弃，建议您通过您的App Server进行群组操作。
 群组操作的流程，可以参考：http://support.rongcloud.cn/kb/MzY5

 @warning **已废弃，请勿使用。**
 */
- (void)joinGroup:(NSString *)groupId
        groupName:(NSString *)groupName
          success:(void (^)())successBlock
            error:(void (^)(RCErrorCode status))errorBlock
    __deprecated_msg("已废弃，请勿使用。");

/*!
 退出群组(已废弃，建议您通过您的App Server进行群组操作)

 @param groupId                 要退出的群组ID
 @param successBlock            退出成功的回调
 @param errorBlock              退出失败的回调 [status:退出失败的错误码]

 @discussion 此方法已废弃，建议您通过您的App Server进行群组操作。
 群组操作的流程，可以参考：http://support.rongcloud.cn/kb/MzY5

 @warning **已废弃，请勿使用。**
 */
- (void)quitGroup:(NSString *)groupId
          success:(void (^)())successBlock
            error:(void (^)(RCErrorCode status))errorBlock
    __deprecated_msg("已废弃，请勿使用。");

#pragma mark - 聊天室操作

/*!
 加入聊天室（如果聊天室不存在则会创建）

 @param targetId                聊天室ID
 @param messageCount 进入聊天室时获取历史消息的数量，-1<=messageCount<=50
 @param successBlock            加入聊天室成功的回调
 @param errorBlock              加入聊天室失败的回调
 [status:加入聊天室失败的错误码]

 @discussion
 可以通过传入的messageCount设置加入聊天室成功之后，需要获取的历史消息数量。
 -1表示不获取任何历史消息，0表示不特殊设置而使用SDK默认的设置（默认为获取10条），0<messageCount<=50为具体获取的消息数量,最大值为50。
 */
- (void)joinChatRoom:(NSString *)targetId
        messageCount:(int)messageCount
             success:(void (^)())successBlock
               error:(void (^)(RCErrorCode status))errorBlock;

/*!
 加入已经存在的聊天室（如果不存在或超限会返回聊天室不存在错误23410 或 人数超限
 23411）

 @param targetId                聊天室ID
 @param messageCount 进入聊天室时获取历史消息的数量，-1<=messageCount<=50
 @param successBlock            加入聊天室成功的回调
 @param errorBlock              加入聊天室失败的回调
 [status:加入聊天室失败的错误码]

 @warning
 注意：使用Kit库的会话页面viewDidLoad会自动调用joinChatRoom加入聊天室（聊天室不存在会自动创建），
 如果您只想加入已存在的聊天室，需要在push到会话页面之前调用这个方法并且messageCount
 传-1，成功之后push到会话页面，失败需要您做相应提示处理

 @discussion
 可以通过传入的messageCount设置加入聊天室成功之后，需要获取的历史消息数量。
 -1表示不获取任何历史消息，0表示不特殊设置而使用SDK默认的设置（默认为获取10条），0<messageCount<=50为具体获取的消息数量,最大值为50。
 */
- (void)joinExistChatRoom:(NSString *)targetId
             messageCount:(int)messageCount
                  success:(void (^)())successBlock
                    error:(void (^)(RCErrorCode status))errorBlock;

/*!
 退出聊天室

 @param targetId                聊天室ID
 @param successBlock            退出聊天室成功的回调
 @param errorBlock              退出聊天室失败的回调
 [status:退出聊天室失败的错误码]
 */
- (void)quitChatRoom:(NSString *)targetId
             success:(void (^)())successBlock
               error:(void (^)(RCErrorCode status))errorBlock;

/*!
 获取聊天室的信息（包含部分成员信息和当前聊天室中的成员总数）

 @param targetId     聊天室ID
 @param count 需要获取的成员信息的数量（目前获取到的聊天室信息中仅包含不多于20人的成员信息，即0 <= count <= 20，传入0获取到的聊天室信息将或仅包含成员总数，不包含具体的成员列表）
 @param order        需要获取的成员列表的顺序（最早加入或是最晚加入的部分成员）
 @param successBlock 获取成功的回调 [chatRoomInfo:聊天室信息]
 @param errorBlock   获取失败的回调 [status:获取失败的错误码]

 @discussion 因为聊天室一般成员数量巨大，权衡效率和用户体验，目前返回的聊天室信息仅包含不多于20人的成员信息和当前成员总数。如果您使用RC_ChatRoom_Member_Asc升序方式查询，将返回最早加入的成员信息列表，按加入时间从旧到新排列；如果您使用RC_ChatRoom_Member_Desc降序方式查询，将返回最晚加入的成员信息列表，按加入时间从新到旧排列。
 */
- (void)getChatRoomInfo:(NSString *)targetId
                  count:(int)count
                  order:(RCChatRoomMemberOrder)order
                success:(void (^)(RCChatRoomInfo *chatRoomInfo))successBlock
                  error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark - 公众服务

/*!
 查找公众服务账号

 @param searchType                  查找匹配方式
 @param searchKey                   查找关键字
 @param successBlock                查找成功的回调
 [accounts:查找到的公众服务账号信息RCPublicServiceProfile的数组]
 @param errorBlock                  查找失败的回调 [status:失败的错误码]
 */
- (void)searchPublicService:(RCSearchType)searchType
                  searchKey:(NSString *)searchKey
                    success:(void (^)(NSArray *accounts))successBlock
                      error:(void (^)(RCErrorCode status))errorBlock;

/*!
 按类型查找公众服务账号

 @param publicServiceType           公众服务账号的类型
 @param searchType                  查找匹配方式
 @param searchKey                   查找关键字
 @param successBlock                查找成功的回调
 [accounts:查找到的公众服务账号信息RCPublicServiceProfile的数组]
 @param errorBlock                  查找失败的回调 [status:失败的错误码]
 */
- (void)searchPublicServiceByType:(RCPublicServiceType)publicServiceType
                       searchType:(RCSearchType)searchType
                        searchKey:(NSString *)searchKey
                          success:(void (^)(NSArray *accounts))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

/*!
 关注公众服务账号

 @param publicServiceType       公众服务账号的类型
 @param publicServiceId         公众服务的账号ID
 @param successBlock            关注成功的回调
 @param errorBlock              关注失败的回调 [status:失败的错误码]
 */
- (void)subscribePublicService:(RCPublicServiceType)publicServiceType
               publicServiceId:(NSString *)publicServiceId
                       success:(void (^)())successBlock
                         error:(void (^)(RCErrorCode status))errorBlock;

/*!
 取消关注公众服务账号

 @param publicServiceType       公众服务账号的类型
 @param publicServiceId         公众服务的账号ID
 @param successBlock            取消关注成功的回调
 @param errorBlock              取消关注失败的回调 [status:失败的错误码]
 */
- (void)unsubscribePublicService:(RCPublicServiceType)publicServiceType
                 publicServiceId:(NSString *)publicServiceId
                         success:(void (^)())successBlock
                           error:(void (^)(RCErrorCode status))errorBlock;

/*!
 查询已关注的公众服务账号

 @return 公众服务信息RCPublicServiceProfile列表
 */
- (NSArray *)getPublicServiceList;

/*!
 获取公众服务账号信息

 @param publicServiceType       公众服务账号的类型
 @param publicServiceId         公众服务的账号ID
 @return                        公众服务账号的信息

 @discussion 此方法会从本地缓存中获取公众服务账号信息
 */
- (RCPublicServiceProfile *)getPublicServiceProfile:
                                (RCPublicServiceType)publicServiceType
                                    publicServiceId:(NSString *)publicServiceId;

/*!
 获取公众服务账号信息

 @param targetId                        公众服务的账号ID
 @param type                            公众服务账号的类型
 @param onSuccess                       获取成功的回调
 [serviceProfile:获取到的公众账号信息]
 @param onError                         获取失败的回调 [error:失败的错误码]
 
 @discussion 此方法会从服务器获取公众服务账号信息
 */
- (void)getPublicServiceProfile:(NSString *)targetId
               conversationType:(RCConversationType)type
                      onSuccess:
                          (void (^)(RCPublicServiceProfile *serviceProfile))
                              onSuccess
                        onError:(void (^)(NSError *error))onError;

/*!
 获取公众服务使用的WebView Controller

 @param URLString   准备打开的URL
 @return            公众服务使用的WebView Controller
 
 @discussion 如果您选在用WebView打开URL连接，则您需要在App的Info.plist的NSAppTransportSecurity中增加NSAllowsArbitraryLoadsInWebContent和NSAllowsArbitraryLoads字段，并在苹果审核的时候提供额外的说明。
 更多内容可以参考：https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW55
 */
- (UIViewController *)getPublicServiceWebViewController:(NSString *)URLString;

#pragma mark - 推送业务数据统计

/*!
 统计App启动的事件

 @param launchOptions   App的启动附加信息

 @discussion 此方法用于统计融云推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在AppDelegate的-application:didFinishLaunchingWithOptions:中，
 调用此方法并将launchOptions传入即可。
 */
- (void)recordLaunchOptionsEvent:(NSDictionary *)launchOptions;

/*!
 统计本地通知的事件

 @param notification   本体通知的内容

 @discussion 此方法用于统计融云推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在AppDelegate的-application:didReceiveLocalNotification:中，
 调用此方法并将launchOptions传入即可。
 */
- (void)recordLocalNotificationEvent:(UILocalNotification *)notification;

/*!
 统计远程推送的事件

 @param userInfo    远程推送的内容

 @discussion 此方法用于统计融云推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在AppDelegate的-application:didReceiveRemoteNotification:中，
 调用此方法并将launchOptions传入即可。
 */
- (void)recordRemoteNotificationEvent:(NSDictionary *)userInfo;

/*!
 获取点击的启动事件中，融云推送服务的扩展字段

 @param launchOptions   App的启动附加信息
 @return 收到的融云推送服务的扩展字段，nil表示该启动事件不包含来自融云的推送服务

 @discussion 此方法仅用于获取融云推送服务的扩展字段。
 */
- (NSDictionary *)getPushExtraFromLaunchOptions:(NSDictionary *)launchOptions;

/*!
 获取点击的远程推送中，融云推送服务的扩展字段

 @param userInfo    远程推送的内容
 @return 收到的融云推送服务的扩展字段，nil表示该远程推送不包含来自融云的推送服务

 @discussion 此方法仅用于获取融云推送服务的扩展字段。
 */
- (NSDictionary *)getPushExtraFromRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - 工具类方法

/*!
 获取当前IMLib SDK的版本号

 @return 当前IMLib SDK的版本号，如: @"2.0.0"
 */
- (NSString *)getSDKVersion;

/*!
 将AMR格式的音频数据转化为WAV格式的音频数据

 @param data    AMR格式的音频数据，必须是AMR-NB的格式
 @return        WAV格式的音频数据
 */
- (NSData *)decodeAMRToWAVE:(NSData *)data;

/*!
 将WAV格式的音频数据转化为AMR格式的音频数据（8KHz采样）

 @param data            WAV格式的音频数据
 @param nChannels       声道数
 @param nBitsPerSample  采样位数（精度）
 @return                AMR-NB格式的音频数据

 @discussion
 此方法为工具类方法，您可以使用此方法将任意WAV音频转换为AMR-NB格式的音频。

 @warning
 如果您想和SDK自带的语音消息保持一致和互通，考虑到跨平台和传输的原因，SDK对于WAV音频有所限制.
 具体可以参考RCVoiceMessage中的音频参数说明(nChannels为1，nBitsPerSample为16)。
 */
- (NSData *)encodeWAVEToAMR:(NSData *)data
                    channel:(int)nChannels
             nBitsPerSample:(int)nBitsPerSample;

#pragma mark - 客服方法
/*!
 发起客服聊天

 @param kefuId       客服ID
 @param csInfo       客服信息
 @param successBlock            发起客服会话成功的回调
 @param errorBlock              发起客服会话失败的回调 [errorCode:失败的错误码 errMsg:错误信息]
 @param modeTypeBlock           客服模式变化
 @param pullEvaluationBlock     客服请求评价
 @param selectGroupBlock        客服分组选择
 @param quitBlock 客服被动结束。如果主动调用stopCustomerService，则不会调用到该block

 @discussion 有些客服提供商可能会主动邀请评价，有些不会，所以用lib开发客服需要注意对pullEvaluationBlock的处理。在pullEvaluationBlock里应该弹出评价。如果pullEvaluationBlock没有被调用到，需要在结束客服时（之前之后都可以）弹出评价框并评价。如果客服有分组，selectGroupBlock会被回调，此时必须让用户选择分组然后调用selectCustomerServiceGroup:withGroupId:。

 @warning 如果你使用IMKit，请不要使用此方法。RCConversationViewController默认已经做了处理。
 */
- (void)
startCustomerService:(NSString *)kefuId
                info:(RCCustomerServiceInfo *)csInfo
           onSuccess:(void (^)(RCCustomerServiceConfig *config))successBlock
             onError:(void (^)(int errorCode, NSString *errMsg))errorBlock
          onModeType:(void (^)(RCCSModeType mode))modeTypeBlock
    onPullEvaluation:(void (^)(NSString *dialogId))pullEvaluationBlock
       onSelectGroup:(void (^)(NSArray <RCCustomerServiceGroupItem*> *groupList))selectGroupBlock
              onQuit:(void (^)(NSString *quitMsg))quitBlock;


/*!
 结束客服聊天

 @param kefuId       客服ID

 @discussion 此方法依赖startCustomerService方法，只有调用成功以后才有效。
 @warning
 如果你使用IMKit，请不要使用此方法。RCConversationViewController默认已经做了处理。
 */
- (void)stopCustomerService:(NSString *)kefuId;

/*!
 选择客服分组模式
 
 @param kefuId       客服ID
 @param groupId       选择的客服分组id
 @discussion 此方法依赖startCustomerService方法，只有调用成功以后才有效。
 @warning
 如果你使用IMKit，请不要使用此方法。RCConversationViewController默认已经做了处理。
 */
- (void)selectCustomerServiceGroup:(NSString *)kefuId withGroupId:(NSString *)groupId;

/*!
 切换客服模式

 @param kefuId       客服ID

 @discussion
 此方法依赖startCustomerService方法，而且只有当前客服模式为机器人优先才可调用。
 @warning
 如果你使用IMKit，请不要使用此方法。RCConversationViewController默认已经做了处理。
 */
- (void)switchToHumanMode:(NSString *)kefuId;

/*!
 评价机器人客服，用于对单条机器人应答的评价。

 @param kefuId                客服ID
 @param knownledgeId          知识点ID
 @param isRobotResolved       是否解决问题
 @param suggest                客户建议

 @discussion 此方法依赖startCustomerService方法。可在客服结束之前或之后调用。
 @discussion
 有些客服服务商需要对机器人回答的词条进行评价，机器人回答的文本消息的extra带有{“robotEva”:”1”,
 “sid”:”xxx”}字段，当用户对这一条消息评价后调用本函数同步到服务器，knownledgedID为extra中的sid。若是离开会话评价，knownledgedID填nil

 @warning
 如果你使用IMKit，请不要使用此方法。RCConversationViewController默认已经做了处理。
 */
- (void)evaluateCustomerService:(NSString *)kefuId
                   knownledgeId:(NSString *)knownledgeId
                     robotValue:(BOOL)isRobotResolved
                        suggest:(NSString *)suggest;

/*!
 评价人工客服。

 @param kefuId                客服ID
 @param dialogId              对话ID，客服请求评价的对话ID
 @param value                 分数，取值范围1-5
 @param suggest               客户建议

 @discussion 此方法依赖startCustomerService方法。可在客服结束之前或之后调用。
 @discussion
 有些客服服务商会主动邀请评价，pullEvaluationBlock会被调用到，当评价完成后调用本函数同步到服务器，dialogId填pullEvaluationBlock返回的dialogId。若是离开会话触发的评价，dialogID为nil

 @warning
 如果你使用IMKit，请不要使用此方法。RCConversationViewController默认已经做了处理。
 */
- (void)evaluateCustomerService:(NSString *)kefuId
                       dialogId:(NSString *)dialogId
                     humanValue:(int)value
                        suggest:(NSString *)suggest;

#pragma mark - 搜索

/*!
 根据关键字搜索指定会话中的消息
 
 @param conversationType 会话类型
 @param targetId         会话ID
 @param keyword          关键字
 @param count            最大的查询数量
 @param startTime        查询记录的起始时间（传 0 表示不限时间）
 
 @return 匹配的消息列表
 */
- (NSArray <RCMessage *>*)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                                 keyword:(NSString *)keyword
                                   count:(int)count
                               startTime:(long long)startTime;

/*!
 根据关键字搜索会话
 
 @param conversationTypeList 需要搜索的会话类型列表
 @param objectNameList       需要搜索的消息类型名列表(即每个消息类方法getObjectName的返回值)
 @param keyword              关键字
 
 @return 匹配的会话搜索结果列表
 
 @discussion 目前，SDK内置的文本消息、文件消息、图文消息支持搜索。
 自定义的消息必须要实现RCMessageContent的getSearchableWords接口才能进行搜索。
 */
- (NSArray<RCSearchConversationResult *> *)searchConversations:
                                               (NSArray<NSNumber *> *)conversationTypeList
                                                   messageType:(NSArray<NSString *> *)objectNameList
                                                       keyword:(NSString *)keyword;

#pragma mark - 日志

/*!
 设置日志级别
 */
@property (nonatomic, assign) RCLogLevel logLevel;

/*!
 设置IMLib日志的监听器
 
 @param delegate IMLib日志的监听器

 @discussion 您可以通过logLevel来控制日志的级别。
 */
- (void)setRCLogInfoDelegate: (id<RCLogInfoDelegate>)delegate;

#pragma mark - File Storage

/*!
 文件消息下载路径
 
 @discussion 默认值为沙盒下的Documents/MyFile目录。您可以通过修改RCConfig.plist中的RelativePath来修改该路径。
 */
@property (nonatomic, strong, readonly) NSString *fileStoragePath;

#pragma mark - 第三方平台厂商接口
/*!
 获取Vendor token. 仅供融云第三方服务厂家使用。
 
 @param  successBlock 成功回调
 @param  errorBlock   失败回调
 */
- (void)getVendorToken:(void (^)(NSString *vendorToken))successBlock
                 error:(void (^)(RCErrorCode nErrorCode))errorBlock;


@end

#endif
