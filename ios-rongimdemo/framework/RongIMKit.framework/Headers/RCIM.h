//
//  RCIM.h
//  RongIMKit
//
//  Created by xugang on 15/1/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import "RCThemeDefine.h"

/*!
 @const 收到消息的Notification
 
 @discussion 接收到消息后，SDK会分发此通知。
 
 Notification的object为RCMessage消息对象。
 userInfo为NSDictionary对象，其中key值为@"left"，value为还剩余未接收的消息数的NSNumber对象。
 
 与RCIMReceiveMessageDelegate的区别:
 RCKitDispatchMessageNotification只要注册都可以收到通知；RCIMReceiveMessageDelegate需要设置监听，并同时只能存在一个监听。
 */
FOUNDATION_EXPORT NSString *const RCKitDispatchMessageNotification;

/*!
 @const 消息被撤回的Notification
 
 @discussion 消息被撤回后，SDK会分发此通知。
 
 Notification的object为NSNumber的messageId。
 
 与RCIMReceiveMessageDelegate的区别:
 RCKitDispatchRecallMessageNotification只要注册都可以收到通知；RCIMReceiveMessageDelegate需要设置监听，并同时只能存在一个监听。
 */
FOUNDATION_EXPORT NSString *const RCKitDispatchRecallMessageNotification;

/*!
 @const 收到已读回执的Notification
 
 @discussion 收到消息已读回执之后 IMLib 更新消息状态之后，IMKit会分发此通知。
 
 Notification的object为nil，userInfo为NSDictionary对象，
 其中key值分别为@"cType"、@"tId"、@"messageTime",
 对应的value为会话类型的NSNumber对象、会话的targetId、已阅读的最后一条消息的sendTime。
 如：
 NSNumber *ctype = [notification.userInfo objectForKey:@"cType"];
 NSNumber *time = [notification.userInfo objectForKey:@"messageTime"];
 NSString *targetId = [notification.userInfo objectForKey:@"tId"];
 NSString *fromUserId = [notification.userInfo objectForKey:@"fId"];
 
 收到这个消息之后可以更新这个会话中messageTime以前的消息UI为已读（底层数据库消息状态已经改为已读）。
 
 @warning  **已废弃，请勿使用。**
 升级说明：如果您之前使用了此通知，可以直接替换为RCLibDispatchReadReceiptNotification通知，行为和内容完全一致。
 */
FOUNDATION_EXPORT NSString *const RCKitDispatchReadReceiptNotification __deprecated_msg("已废弃，请使用RCLibDispatchReadReceiptNotification通知。");

/*!
 @const 连接状态变化的Notification
 
 @discussion SDK连接状态发生变化时，SDK会分发此通知。
 
 Notification的object为NSNumber对象，对应于RCConnectionStatus的值。
 
 与RCIMConnectionStatusDelegate的区别:
 RCKitDispatchConnectionStatusChangedNotification只要注册都可以收到通知；RCIMConnectionStatusDelegate需要设置监听，同时只能存在一个监听。
 */
FOUNDATION_EXPORT NSString *const RCKitDispatchConnectionStatusChangedNotification;

/**
 *  收到消息已读回执的响应
 通知的 object 中携带信息如下： @{@"targetId":targetId,
 @"conversationType":@(conversationType),
 @"messageUId": messageUId,
 @"readCount":@(count)};
 */
FOUNDATION_EXPORT NSString *const RCKitDispatchMessageReceiptResponseNotification;

/**
 *  收到消息已读回执的请求
 通知的 object 中携带信息如下： @{@"targetId":targetId,
 @"conversationType":@(conversationType),
 @"messageUId": messageUId};
 */
FOUNDATION_EXPORT NSString *const RCKitDispatchMessageReceiptRequestNotification;

#pragma mark - 用户信息提供者、群组信息提供者、群名片信息提供者

/*!
 用户信息提供者
 
 @discussion SDK需要通过您实现的用户信息提供者，获取用户信息并显示。
 */
@protocol RCIMUserInfoDataSource <NSObject>

/*!
 获取用户信息
 
 @param userId      用户ID
 @param completion  获取用户信息完成之后需要执行的Block [userInfo:该用户ID对应的用户信息]
 
 @discussion SDK通过此方法获取用户信息并显示，请在completion中返回该用户ID对应的用户信息。
 在您设置了用户信息提供者之后，SDK在需要显示用户信息的时候，会调用此方法，向您请求用户信息用于显示。
 */
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion;

@end

/*!
 群组信息提供者
 
 @discussion SDK需要通过您实现的群组信息提供者，获取群组信息并显示。
 */
@protocol RCIMGroupInfoDataSource <NSObject>

/*!
 获取群组信息
 
 @param groupId     群组ID
 @param completion  获取群组信息完成之后需要执行的Block [groupInfo:该群组ID对应的群组信息]
 
 @discussion SDK通过此方法获取用户信息并显示，请在completion的block中返回该用户ID对应的用户信息。
 在您设置了用户信息提供者之后，SDK在需要显示用户信息的时候，会调用此方法，向您请求用户信息用于显示。
 */
- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *groupInfo))completion;

@end

/*!
 群名片信息提供者
 
 @discussion 如果您使用了群名片功能，SDK需要通过您实现的群名片信息提供者，获取用户在群组中的名片信息并显示。
 */
@protocol RCIMGroupUserInfoDataSource <NSObject>

/*!
 获取用户在群组中的群名片信息
 
 @param userId          用户ID
 @param groupId         群组ID
 @param completion      获取群名片信息完成之后需要执行的Block [userInfo:该用户ID在群组中对应的群名片信息]
 
 @discussion 如果您使用了群名片功能，SDK需要通过您实现的群名片信息提供者，获取用户在群组中的名片信息并显示。
 */
- (void)getUserInfoWithUserId:(NSString *)userId
                      inGroup:(NSString *)groupId
                   completion:(void (^)(RCUserInfo *userInfo))completion;

@end

/*!
 群组成员列表提供者
 */
@protocol RCIMGroupMemberDataSource <NSObject>
@optional

/*!
 获取当前群组成员列表的回调（需要实现用户信息提供者 RCIMUserInfoDataSource）
 
 @param groupId     群ID
 @param resultBlock 获取成功 [userIdList:群成员ID列表]
 */
- (void)getAllMembersOfGroup:(NSString *)groupId
                      result:(void (^)(NSArray<NSString *> *userIdList))resultBlock;
@end


#pragma mark - 消息接收监听器

/*!
 IMKit消息接收的监听器
 
 @discussion 设置 IMKit 的消息接收监听器请参考 RCIM 的 receiveMessageDelegate 属性。
 
 @warning 如果您使用 IMKit，可以设置并实现此 Delegate 监听消息接收；
 如果您使用 IMLib，请使用 RCIMClient 中的 RCIMClientReceiveMessageDelegate 监听消息接收，而不要使用此监听器。
 */
@protocol RCIMReceiveMessageDelegate <NSObject>

/*!
 接收消息的回调方法
 
 @param message     当前接收到的消息
 @param left        还剩余的未接收的消息数，left>=0
 
 @discussion 如果您设置了IMKit消息监听之后，SDK在接收到消息时候会执行此方法（无论App处于前台或者后台）。
 其中，left为还剩余的、还未接收的消息数量。比如刚上线一口气收到多条消息时，通过此方法，您可以获取到每条消息，left会依次递减直到0。
 您可以根据left数量来优化您的App体验和性能，比如收到大量消息时等待left为0再刷新UI。
 */
- (void)onRCIMReceiveMessage:(RCMessage *)message
                        left:(int)left;

@optional

/*!
 当App处于后台时，接收到消息并弹出本地通知的回调方法
 
 @param message     接收到的消息
 @param senderName  消息发送者的用户名称
 @return            当返回值为NO时，SDK会弹出默认的本地通知提示；当返回值为YES时，SDK针对此消息不再弹本地通知提示
 
 @discussion 如果您设置了IMKit消息监听之后，当App处于后台，收到消息时弹出本地通知之前，会执行此方法。
 如果App没有实现此方法，SDK会弹出默认的本地通知提示。
 流程：
 SDK接收到消息 -> App处于后台状态 -> 通过用户/群组/群名片信息提供者获取消息的用户/群组/群名片信息
 -> 用户/群组信息为空 -> 不弹出本地通知
 -> 用户/群组信息存在 -> 回调此方法准备弹出本地通知 -> App实现并返回YES        -> SDK不再弹出此消息的本地通知
                                             -> App未实现此方法或者返回NO -> SDK弹出默认的本地通知提示
 
 
 您可以通过RCIM的disableMessageNotificaiton属性，关闭所有的本地通知(此时不再回调此接口)。
 
 @warning 如果App在后台想使用SDK默认的本地通知提醒，需要实现用户/群组/群名片信息提供者，并返回正确的用户信息或群组信息。
 参考RCIMUserInfoDataSource、RCIMGroupInfoDataSource与RCIMGroupUserInfoDataSource
 */
-(BOOL)onRCIMCustomLocalNotification:(RCMessage*)message
                      withSenderName:(NSString *)senderName;

/*!
 当App处于前台时，接收到消息并播放提示音的回调方法
 
 @param message 接收到的消息
 @return        当返回值为NO时，SDK会播放默认的提示音；当返回值为YES时，SDK针对此消息不再播放提示音
 
 @discussion 到消息时播放提示音之前，会执行此方法。
 如果App没有实现此方法，SDK会播放默认的提示音。
 流程：
 SDK接收到消息 -> App处于前台状态 -> 回调此方法准备播放提示音 -> App实现并返回YES        -> SDK针对此消息不再播放提示音
                                                      -> App未实现此方法或者返回NO -> SDK会播放默认的提示音
 
 您可以通过RCIM的disableMessageAlertSound属性，关闭所有前台消息的提示音(此时不再回调此接口)。
 */
-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message;

/*!
 消息被撤回的回调方法
 
 @param messageId 被撤回的消息ID
 
 @discussion 被撤回的消息会变更为RCRecallNotificationMessage，App需要在UI上刷新这条消息。
 */
- (void)onRCIMMessageRecalled:(long)messageId;

@end

#pragma mark - 连接状态监听器

/*!
 IMKit连接状态的的监听器
 
 @discussion 设置IMKit的连接状态监听器，请参考RCIM的connectionStatusDelegate属性。
 
 @warning 如果您使用IMKit，可以设置并实现此Delegate监听消息接收；
 如果您使用IMLib，请使用RCIMClient中的RCIMClientReceiveMessageDelegate监听消息接收，而不要使用此监听器。
 */
@protocol RCIMConnectionStatusDelegate <NSObject>

/*!
 IMKit连接状态的的监听器
 
 @param status  SDK与融云服务器的连接状态
 
 @discussion 如果您设置了IMKit消息监听之后，当SDK与融云服务器的连接状态发生变化时，会回调此方法。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status;

@end

#pragma mark - IMKit核心类

/*!
 融云IMKit核心类
 
 @discussion 您需要通过sharedRCIM方法，获取单例对象
 */
@interface RCIM : NSObject

/*!
 获取融云界面组件IMKit的核心类单例
 
 @return    融云界面组件IMKit的核心类单例
 
 @discussion 您可以通过此方法，获取IMKit的单例，访问对象中的属性和方法。
 */
+ (instancetype)sharedRCIM;

#pragma mark - SDK初始化

/*!
 初始化融云SDK
 
 @param appKey  从融云开发者平台创建应用后获取到的App Key
 
 @discussion 您在使用融云SDK所有功能（包括显示SDK中或者继承于SDK的View）之前，您必须先调用此方法初始化SDK。
 在App整个生命周期中，您只需要执行一次初始化。
 
 @warning 如果您使用IMKit，请使用此方法初始化SDK；
 如果您使用IMLib，请使用RCIMClient中的同名方法初始化，而不要使用此方法。
 */
- (void)initWithAppKey:(NSString *)appKey;

#pragma mark - 连接与断开服务器

/*!
 与融云服务器建立连接
 
 @param token                   从您服务器端获取的token(用户身份令牌)
 @param successBlock            连接建立成功的回调 [userId:当前连接成功所用的用户ID
 @param errorBlock              连接建立失败的回调 [status:连接失败的错误码]
 @param tokenIncorrectBlock     token错误或者过期的回调
 
 @discussion 在App整个生命周期，您只需要调用一次此方法与融云服务器建立连接。
 之后无论是网络出现异常或者App有前后台的切换等，SDK都会负责自动重连。
 除非您已经手动将连接断开，否则您不需要自己再手动重连。
 
 tokenIncorrectBlock有两种情况：
 一是token错误，请您检查客户端初始化使用的AppKey和您服务器获取token使用的AppKey是否一致；
 二是token过期，是因为您在开发者后台设置了token过期时间，您需要请求您的服务器重新获取token并再次用新的token建立连接。
 
 @warning 如果您使用IMKit，请使用此方法建立与融云服务器的连接；
 如果您使用IMLib，请使用RCIMClient中的同名方法建立与融云服务器的连接，而不要使用此方法。
 
 在tokenIncorrectBlock的情况下，您需要请求您的服务器重新获取token并建立连接，但是注意避免无限循环，以免影响App用户体验。
 
 此方法的回调并非为原调用线程，您如果需要进行UI操作，请注意切换到主线程。
 */
- (void)connectWithToken:(NSString *)token
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode status))errorBlock
          tokenIncorrect:(void (^)())tokenIncorrectBlock;

/*!
 断开与融云服务器的连接
 
 @param isReceivePush   App在断开连接之后，是否还接收远程推送
 
 @discussion 因为SDK在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 所以除非您的App逻辑需要登出，否则一般不需要调用此方法进行手动断开。
 
 @warning 如果您使用IMKit，请使用此方法断开与融云服务器的连接；
 如果您使用IMLib，请使用RCIMClient中的同名方法断开与融云服务器的连接，而不要使用此方法。
 
 isReceivePush指断开与融云服务器的连接之后，是否还接收远程推送。
 [[RCIM sharedRCIM] disconnect:YES]与[[RCIM sharedRCIM] disconnect]完全一致；
 [[RCIM sharedRCIM] disconnect:NO]与[[RCIM sharedRCIM] logout]完全一致。
 您只需要按照您的需求，使用disconnect:与disconnect以及logout三个接口其中一个即可。
 */
- (void)disconnect:(BOOL)isReceivePush;

/*!
 断开与融云服务器的连接，但仍然接收远程推送
 
 @discussion 因为SDK在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 所以除非您的App逻辑需要登出，否则一般不需要调用此方法进行手动断开。
 
 @warning 如果您使用IMKit，请使用此方法断开与融云服务器的连接；
 如果您使用IMLib，请使用RCIMClient中的同名方法断开与融云服务器的连接，而不要使用此方法。
 
 [[RCIM sharedRCIM] disconnect:YES]与[[RCIM sharedRCIM] disconnect]完全一致；
 [[RCIM sharedRCIM] disconnect:NO]与[[RCIM sharedRCIM] logout]完全一致。
 您只需要按照您的需求，使用disconnect:与disconnect以及logout三个接口其中一个即可。
 */
- (void)disconnect;

/*!
 断开与融云服务器的连接，并不再接收远程推送
 
 @discussion 因为SDK在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 所以除非您的App逻辑需要登出，否则一般不需要调用此方法进行手动断开。
 
 @warning 如果您使用IMKit，请使用此方法断开与融云服务器的连接；
 如果您使用IMLib，请使用RCIMClient中的同名方法断开与融云服务器的连接，而不要使用此方法。
 
 [[RCIM sharedRCIM] disconnect:YES]与[[RCIM sharedRCIM] disconnect]完全一致；
 [[RCIM sharedRCIM] disconnect:NO]与[[RCIM sharedRCIM] logout]完全一致。
 您只需要按照您的需求，使用disconnect:与disconnect以及logout三个接口其中一个即可。
 */
- (void)logout;

#pragma mark 连接状态监听

/*!
 IMKit连接状态的监听器
 
 @warning 如果您使用IMKit，可以设置并实现此Delegate监听消息接收；
 如果您使用IMLib，请使用RCIMClient中的RCIMClientReceiveMessageDelegate监听消息接收，而不要使用此方法。
 */
@property(nonatomic, weak) id<RCIMConnectionStatusDelegate> connectionStatusDelegate;

/*!
 获取当前SDK的连接状态
 
 @return 当前SDK的连接状态
 */
- (RCConnectionStatus)getConnectionStatus;

#pragma mark - 消息接收与发送

/*!
 注册自定义的消息类型
 
 @param messageClass    自定义消息的类，该自定义消息需要继承于RCMessageContent
 
 @discussion 如果您需要自定义消息，必须调用此方法注册该自定义消息的消息类型，否则SDK将无法识别和解析该类型消息。
 
 @warning 如果您使用IMKit，请使用此方法注册自定义的消息类型；
 如果您使用IMLib，请使用RCIMClient中的同名方法注册自定义的消息类型，而不要使用此方法。
 */
- (void)registerMessageType:(Class)messageClass;

#pragma mark 消息发送
/*!
 发送消息(除图片消息、文件消息外的所有消息)，会自动更新UI
 
 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [nErrorCode:发送失败的错误码, messageId:消息的ID]
 @return                    发送的消息实体
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
 
 @warning 如果您使用IMKit，使用此方法发送消息SDK会自动更新UI；
 如果您使用IMLib，请使用RCIMClient中的同名方法发送消息，不会自动更新UI。
 */
- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 发送媒体文件消息，会自动更新UI
 
 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码, messageId:消息的ID]
 @param cancelBlock         用户取消了消息发送的回调 [messageId:消息的ID]
 @return                    发送的消息实体
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
 
 @warning 如果您使用IMKit，使用此方法发送媒体文件消息SDK会自动更新UI；
 如果您使用IMLib，请使用RCIMClient中的同名方法发送媒体文件消息，不会自动更新UI。
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
 取消发送中的媒体信息
 
 @param messageId           媒体消息的messageId
 
 @return YES表示取消成功，NO表示取消失败，即已经发送成功或者消息不存在。
 */
- (BOOL)cancelSendMediaMessage:(long)messageId;

/*!
 下载消息中的媒体文件
 
 @param messageId       消息ID
 @param progressBlock   下载进度更新的回调 [progress:当前的发送进度, 0 <= progress <= 100]
 @param successBlock    下载成功的回调 [mediaPath:下载完成后文件在本地的存储路径]
 @param errorBlock      下载失败的回调 [errorCode:下载失败的错误码]
 @param cancelBlock     下载取消的回调 
 
 @discussion 媒体消息仅限于图片消息和文件消息。
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

/*!
 发送图片消息，会自动更新UI
 
 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码, messageId:消息的ID]
 @return                    发送的消息实体
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
 
 如果您使用IMKit，使用此方法发送图片消息SDK会自动更新UI；
 如果您使用IMLib，请使用RCIMClient中的同名方法发送图片消息，不会自动更新UI。
 
 @warning  **已废弃，请勿使用。**
 升级说明：如果您之前使用了此接口，可以直接替换为sendMediaMessage:targetId:content:pushContent:pushData:success:error:cancel:接口，行为和实现完全一致。
 */
- (RCMessage *)sendImageMessage:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                        content:(RCMessageContent *)content
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                       progress:(void (^)(int progress, long messageId))progressBlock
                        success:(void (^)(long messageId))successBlock
                          error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
__deprecated_msg("已废弃，请使用sendMediaMessage函数。");

/*!
 发送定向消息，会自动更新UI
 
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
 如果您使用IMKit，使用此方法发送定向消息SDK会自动更新UI；
 如果您使用IMLib，请使用RCIMClient中的同名方法发送定向消息，不会自动更新UI。
 
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

/*!
 发起VoIP语音通话
 
 @param targetId    要发起语音通话的对方的用户ID
 
 @warning 旧版本VoIP接口，不再支持，请升级到最新VoIP版本。
 */
//- (void)startVoIPCallWithTargetId:(NSString *)targetId;

#pragma mark 消息接收监听
/*!
 IMKit消息接收的监听器
 
 @warning 如果您使用IMKit，可以设置并实现此Delegate监听消息接收；
 如果您使用IMLib，请使用RCIMClient中的RCIMClientReceiveMessageDelegate监听消息接收，而不要使用此方法。
 */
@property(nonatomic, weak) id<RCIMReceiveMessageDelegate> receiveMessageDelegate;

#pragma mark 消息通知提醒
/*!
 是否关闭所有的本地通知，默认值是NO
 
 @discussion 当App处于后台时，默认会弹出本地通知提示，您可以通过将此属性设置为YES，关闭所有的本地通知。
 */
@property(nonatomic, assign) BOOL disableMessageNotificaiton;

/*!
 是否关闭所有的前台消息提示音，默认值是NO
 
 @discussion 当App处于前台时，默认会播放消息提示音，您可以通过将此属性设置为YES，关闭所有的前台消息提示音。
 */
@property(nonatomic, assign) BOOL disableMessageAlertSound;

/*!
 是否开启发送输入状态，默认值是NO，开启之后在输入消息的时候对方可以看到正在输入的提示(目前只支持单聊)
 */
@property(nonatomic, assign) BOOL enableTypingStatus;

/*!
 是否开启已读回执功能，默认值是NO
 
 @discussion 开启后会在聊天页面消息显示之后会发送已读回执给对方。
 
 @warning **已废弃，请勿使用。**
 升级说明:请使用enabledReadReceiptConversationTypeList，设置开启回执的会话类型
 */
@property(nonatomic, assign) BOOL enableReadReceipt  __deprecated_msg("已废弃，请使用enabledReadReceiptConversationTypeList，设置开启回执的会话类型。");

/*!
 开启已读回执功能的会话类型，默认为空
 
 @discussion 这些会话类型的消息在聊天界面显示了之后会发送已读回执。目前仅支持单聊、群聊和讨论组。
 */
@property(nonatomic, copy) NSArray* enabledReadReceiptConversationTypeList;

/*!
 是否开启多端同步未读状态的功能，默认值是NO
 
 @discussion 开启之后，用户在其他端上阅读过的消息，当前客户端会清掉该消息的未读数。目前仅支持单聊、群聊、讨论组。
 */
@property(nonatomic, assign) BOOL enableSyncReadStatus;

/*!
 是否开启消息@提醒功能（只支持群聊和讨论组, App需要实现群成员数据源groupMemberDataSource），默认值是NO。
 */
@property(nonatomic, assign) BOOL enableMessageMentioned;

/*!
 是否开启消息撤回功能，默认值是NO。
 */
@property(nonatomic, assign) BOOL enableMessageRecall;

/*!
 消息可撤回的最大时间，单位是秒，默认值是120s。
 */
@property(nonatomic, assign) NSUInteger maxRecallDuration;

/*!
 是否在聊天界面和会话列表界面显示未注册的消息类型，默认值是NO
 
 @discussion App不断迭代开发，可能会在以后的新版本中不断增加某些自定义类型的消息，但是已经发布的老版本无法识别此类消息。
 针对这种情况，可以预先定义好未注册的消息的显示，以提升用户体验（如提示当前版本不支持，引导用户升级版本等）
 
 未注册的消息，可以通过RCConversationViewController中的rcUnkownConversationCollectionView:cellForItemAtIndexPath:和rcUnkownConversationCollectionView:layout:sizeForItemAtIndexPath:方法定制在聊天界面的显示。
 未注册的消息，可以通过修改unknown_message_cell_tip字符串资源定制在会话列表界面的显示。
 */
@property(nonatomic, assign) BOOL showUnkownMessage;

/*!
 未注册的消息类型是否显示本地通知，默认值是NO
 
 @discussion App不断迭代开发，可能会在以后的新版本中不断增加某些自定义类型的消息，但是已经发布的老版本无法识别此类消息。
 针对这种情况，可以预先定义好未注册的消息的显示，以提升用户体验（如提示当前版本不支持，引导用户升级版本等）
 
 未注册的消息，可以通过修改unknown_message_notification_tip字符串资源定制本地通知的显示。
 */
@property(nonatomic, assign) BOOL showUnkownMessageNotificaiton;

/*!
 语音消息的最大长度
 
 @discussion 默认值是60s，有效值为不小于5秒，不大于60秒
 */
@property(nonatomic, assign) NSUInteger maxVoiceDuration;


/*!
 APP是否独占音频
 
 @discussion 默认是NO,录音结束之后会调用AVAudioSession 的 setActive:NO ，
 恢复其他后台APP播放的声音，如果设置成YES,不会调用 setActive:NO，这样不会中断当前APP播放的声音
 (如果当前APP 正在播放音频，这时候如果调用SDK 的录音，可以设置这里为YES)
 */
@property(nonatomic, assign) BOOL isExclusiveSoundPlayer;

#pragma mark - 讨论组相关操作

/*!
 创建讨论组
 
 @param name            讨论组名称
 @param userIdList      用户ID的列表
 @param successBlock    创建讨论组成功的回调 [discussion:创建成功返回的讨论组对象]
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
 @param successBlock    讨论组加人成功的回调 [discussion:讨论组加人成功返回的讨论组对象]
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
 @param successBlock    讨论组踢人成功的回调 [discussion:讨论组踢人成功返回的讨论组对象]
 @param errorBlock      讨论组踢人失败的回调 [status:讨论组踢人失败的错误码]
 
 @discussion 如果当前登录用户不是此讨论组的创建者并且此讨论组没有开放加人权限，则会返回错误。
 
 @warning 不能使用此接口将自己移除，否则会返回错误。
 如果您需要退出该讨论组，可以使用-quitDiscussion:success:error:方法。
 */
- (void)removeMemberFromDiscussion:(NSString *)discussionId
                            userId:(NSString *)userId
                           success:(void (^)(RCDiscussion *discussion))successBlock
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
 @param errorBlock      获取讨论组信息失败的回调 [status:获取讨论组信息失败的错误码]
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
 
 @param discussionId    论组ID
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

#pragma mark - 用户信息、群组信息相关

/*!
 当前登录的用户的用户信息
 
 @discussion 与融云服务器建立连接之后，应该设置当前用户的用户信息，用于SDK显示和发送。
 
 @warning 如果传入的用户信息中的用户ID与当前登录的用户ID不匹配，则将会忽略。
 */
@property(nonatomic, strong) RCUserInfo *currentUserInfo;

/*!
 是否将用户信息和群组信息在本地持久化存储，默认值为NO
 
 @discussion 如果设置为NO，则SDK在需要显示用户信息时，会调用用户信息提供者获取用户信息并缓存到Cache，此Cache在App生命周期结束时会被移除，下次启动时会再次通过用户信息提供者获取信息。
 如果设置为YES，则会将获取到的用户信息持久化存储在本地，App下次启动时Cache会仍然有效。
 */
@property(nonatomic, assign) BOOL enablePersistentUserInfoCache;

/*!
 是否在发送的所有消息中携带当前登录的用户信息，默认值为NO
 
 @discussion 如果设置为YES，则会在每一条发送的消息中携带当前登录用户的用户信息。
 收到一条携带了用户信息的消息，SDK会将其信息加入用户信息的cache中并显示；
 若消息中不携带用户信息，则仍然会通过用户信息提供者获取用户信息进行显示。
 
 @warning 需要先设置当前登录用户的用户信息，参考RCIM的currentUserInfo。
 */
@property(nonatomic, assign) BOOL enableMessageAttachUserInfo;

#pragma mark 用户信息

/*!
 用户信息提供者
 
 @discussion SDK需要通过您实现的用户信息提供者，获取用户信息并显示。
 */
@property(nonatomic, weak) id<RCIMUserInfoDataSource> userInfoDataSource;

/*!
 更新SDK中的用户信息缓存
 
 @param userInfo     需要更新的用户信息
 @param userId       需要更新的用户ID
 
 @discussion 使用此方法，可以更新SDK缓存的用户信息。
 但是处于性能和使用场景权衡，SDK不会在当前View立即自动刷新（会在切换到其他View的时候再刷新该用户的显示信息）。
 如果您想立即刷新，您可以在会话列表或者聊天界面reload强制刷新。
 */
- (void)refreshUserInfoCache:(RCUserInfo *)userInfo
                  withUserId:(NSString *)userId;

/*!
 获取SDK中缓存的用户信息
 
 @param userId  用户ID
 @return        SDK中缓存的用户信息
 */
- (RCUserInfo *)getUserInfoCache:(NSString *)userId;

/*!
 清空SDK中所有的用户信息缓存
 
 @discussion 使用此方法，会清空SDK中所有的用户信息缓存。
 但是处于性能和使用场景权衡，SDK不会在当前View立即自动刷新（会在切换到其他View的时候再刷新所显示的用户信息）。
 如果您想立即刷新，您可以在会话列表或者聊天界面reload强制刷新。
 */
- (void)clearUserInfoCache;

#pragma mark 群组信息
/*!
 群组信息提供者
 
 @discussion SDK需要通过您实现的群组信息提供者，获取群组信息并显示。
 */
@property(nonatomic, weak) id<RCIMGroupInfoDataSource> groupInfoDataSource;

/*!
 更新SDK中的群组信息缓存
 
 @param groupInfo   需要更新的群组信息
 @param groupId     需要更新的群组ID
 
 @discussion 使用此方法，可以更新SDK缓存的群组信息。
 但是处于性能和使用场景权衡，SDK不会在当前View立即自动刷新（会在切换到其他View的时候再刷新该群组的显示信息）。
 如果您想立即刷新，您可以在会话列表或者聊天界面reload强制刷新。
 */
- (void)refreshGroupInfoCache:(RCGroup *)groupInfo
                  withGroupId:(NSString *)groupId;

/*!
 获取SDK中缓存的群组信息
 
 @param groupId     群组ID
 @return            SDK中缓存的群组信息
 */
- (RCGroup *)getGroupInfoCache:(NSString *)groupId;

/*!
 清空SDK中所有的群组信息缓存
 
 @discussion 使用此方法，会清空SDK中所有的群组信息缓存。
 但是处于性能和使用场景权衡，SDK不会在当前View立即自动刷新（会在切换到其他View的时候再刷新所显示的群组信息）。
 如果您想立即刷新，您可以在会话列表或者聊天界面reload强制刷新。
 */
- (void)clearGroupInfoCache;

#pragma mark 群名片信息（可选）

/*!
 群名片信息提供者
 
 @discussion 如果您使用了群名片功能，SDK需要通过您实现的群名片信息提供者，获取用户在群组中的名片信息并显示。
 */
@property(nonatomic, weak) id<RCIMGroupUserInfoDataSource> groupUserInfoDataSource;

/*!
 获取SDK中缓存的群名片信息
 
 @param userId      用户ID
 @param groupId     群组ID
 @return            群名片信息
 */
- (RCUserInfo *)getGroupUserInfoCache:(NSString *)userId
                          withGroupId:(NSString *)groupId;

/*!
 更新SDK中的群名片信息缓存
 
 @param userInfo     需要更新的用户信息
 @param userId       需要更新的用户ID
 @param groupId      需要更新群名片信息的群组ID
 
 @discussion 使用此方法，可以更新SDK缓存的群名片信息。
 但是处于性能和使用场景权衡，SDK不会在当前View立即自动刷新（会在切换到其他View的时候再刷新该群名片的显示信息）。
 如果您想立即刷新，您可以在会话列表或者聊天界面reload强制刷新。
 */
- (void)refreshGroupUserInfoCache:(RCUserInfo *)userInfo
                       withUserId:(NSString *)userId
                      withGroupId:(NSString *)groupId;

/*!
 清空SDK中所有的群名片信息缓存
 
 @discussion 使用此方法，会清空SDK中所有的群名片信息缓存。
 但是处于性能和使用场景权衡，SDK不会在当前View立即自动刷新（会在切换到其他View的时候再刷新所显示的群名片信息）。
 如果您想立即刷新，您可以在会话列表或者聊天界面reload强制刷新。
 */
- (void)clearGroupUserInfoCache;

#pragma mark 群成员信息提供者

/*!
 群成员信息提供者
 
 @discussion 如果您使用了@功能，SDK需要通过您实现的群用户成员提供者，获取群组中的用户列表。
 */
@property(nonatomic, weak) id<RCIMGroupMemberDataSource> groupMemberDataSource;

#pragma mark 头像显示

/*!
 SDK中全局的导航按钮字体颜色
 
 @discussion 默认值为[UIColor whiteColor]
 */
@property(nonatomic, strong) UIColor *globalNavigationBarTintColor;

/*!
 SDK会话列表界面中显示的头像形状，矩形或者圆形
 
 @discussion 默认值为矩形，即RC_USER_AVATAR_RECTANGLE
 */
@property(nonatomic) RCUserAvatarStyle globalConversationAvatarStyle;

/*!
 SDK会话列表界面中显示的头像大小，高度必须大于或者等于36
 
 @discussion 默认值为46*46
 */
@property(nonatomic) CGSize globalConversationPortraitSize;

/*!
 SDK聊天界面中显示的头像形状，矩形或者圆形
 
 @discussion 默认值为矩形，即RC_USER_AVATAR_RECTANGLE
 */
@property(nonatomic) RCUserAvatarStyle globalMessageAvatarStyle;

/*!
 SDK聊天界面中显示的头像大小
 
 @discussion 默认值为40*40
 */
@property(nonatomic) CGSize globalMessagePortraitSize;

/*!
 SDK会话列表界面和聊天界面的头像的圆角曲率半径
 
 @discussion 默认值为4，只有当头像形状设置为矩形时才会生效。
 参考RCIM的globalConversationAvatarStyle和globalMessageAvatarStyle。
 */
@property(nonatomic) CGFloat portraitImageViewCornerRadius;

#pragma mark - 网页展示模式
/*!
 点击Cell中的URL时，优先使用WebView还是SFSafariViewController打开。
 
 @discussion 默认为NO。
 如果设置为YES，将使用WebView打开URL链接，则您需要在App的Info.plist的NSAppTransportSecurity中增加NSAllowsArbitraryLoadsInWebContent和NSAllowsArbitraryLoads字段，并在苹果审核的时候提供额外的说明。
 如果设置为NO，将优先使用SFSafariViewController，在iOS 8及之前的系统中使用WebView，在审核的时候不需要提供额外说明。
 更多内容可以参考：https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW55
 */
@property(nonatomic, assign) BOOL embeddedWebViewPreferred;

#pragma mark - Extension module
/*!
 设置Extension Module的URL scheme。
 @param scheme      URL scheme
 @param moduleName  Extension module name
 
 @discussion 有些第三方扩展（比如红包）需要打开其他应用（比如使用支付宝进行支付），然后等待返回结果。因此首先要为第三方扩展设置一个URL scheme并加入到info.plist中，然后再告诉该扩展模块scheme。
 */
- (void)setScheme:(NSString *)scheme forExtensionModule:(NSString *)moduleName;

/*!
 第三方扩展处理openUrl
 
 @param url     url
 @return        YES处理，NO未处理。
 */
- (BOOL)openExtensionModuleUrl:(NSURL *)url;
@end
