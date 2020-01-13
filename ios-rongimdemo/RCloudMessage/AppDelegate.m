//
//  AppDelegate.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "AppDelegate.h"
#import "RCDCommonDefine.h"
#import "RCDLoginViewController.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDTestMessage.h"
#import "RCDUtilities.h"
#import "RCWKNotifier.h"
#import "RCWKRequestHandler.h"
#import "UIColor+RCColor.h"
#import "RCDBuglyManager.h"
#import "RCDLoginManager.h"
#import "RCDCountry.h"
#import "RCDCommonString.h"
#import "RCDUserInfoManager.h"
#import "RCDGroupManager.h"
#import "RCDGroupNotificationMessage.h"
#import "RCDGroupNoticeUpdateMessage.h"
#import "RCDContactNotificationMessage.h"
#import "RCDChatNotificationMessage.h"
#import "RCDWeChatManager.h"
#import "RCDChatManager.h"
#import "RCDIMService.h"

#define RONGCLOUD_IM_APPKEY @"n19jmcy59f1q9" // online key
#import "RCDPokeMessage.h"
#import "RCDPokeManager.h"
#import "RCDClearMessage.h"
//#define RONGCLOUD_IM_APPKEY @"c9kqb3rdkbb8j" // pre key
//#define RONGCLOUD_IM_APPKEY @"e0x9wycfx7flq" // offline key

#define RONGCLOUD_STATUS_SERVER @""
#define BUGLY_APPID @""
#define LOG_EXPIRE_TIME -7 * 24 * 60 * 60

#define WECHAT_APPID @"wxe3d4d4ec21b00104"

@interface AppDelegate () <RCWKAppInfoProvider>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [self configSealTalkWithApp:application andOptions:launchOptions];
    [self configRongIM];
    [self configWeChatShare];
    [self loginAndEnterMainPage];
    return YES;
}

- (void)configRongIM {
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    if (RONGCLOUD_STATUS_SERVER.length > 0) {
        [[RCIMClient sharedRCIMClient] setStatisticServer:RONGCLOUD_STATUS_SERVER];
    }
    [DEFAULTS setObject:RONGCLOUD_IM_APPKEY forKey:RCDAppKeyKey];

    // 注册自定义测试消息
    [[RCIM sharedRCIM] registerMessageType:[RCDTestMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDGroupNotificationMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDGroupNoticeUpdateMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDContactNotificationMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDChatNotificationMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDPokeMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RCDClearMessage class]];

    [RCIMClient sharedRCIMClient].voiceMsgType = RCVoiceMessageTypeHighQuality;

    //设置会话列表头像和会话页面头像
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    [RCIM sharedRCIM].userInfoDataSource = RCDDataSource;
    [RCIM sharedRCIM].groupUserInfoDataSource = RCDDataSource;
    [RCIM sharedRCIM].groupInfoDataSource = RCDDataSource;
    [RCIM sharedRCIM].groupMemberDataSource = RCDDataSource;
    [RCContactCardKit shareInstance].contactsDataSource = RCDDataSource;
    [RCContactCardKit shareInstance].groupDataSource = RCDDataSource;
    [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    [RCIM sharedRCIM].globalNavigationBarTintColor = RCDDYCOLOR(0xffffff, 0xA8A8A8);
    [RCIM sharedRCIM].enableTypingStatus = YES;
    [RCIM sharedRCIM].enableSyncReadStatus = YES;
    [RCIM sharedRCIM].showUnkownMessage = YES;
    [RCIM sharedRCIM].showUnkownMessageNotificaiton = YES;
    [RCIM sharedRCIM].enableMessageMentioned = YES;
    [RCIM sharedRCIM].enableMessageRecall = YES;
    [RCIM sharedRCIM].isMediaSelectorContainVideo = YES;
    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Info;
    [RCIM sharedRCIM].enableSendCombineMessage = YES;
    [RCIM sharedRCIM].enableBurnMessage = YES;
    [RCIM sharedRCIM].enableDarkMode = YES;
    [RCIM sharedRCIM].reeditDuration = 60;
    //  设置头像为圆形
    //  [RCIM sharedRCIM].globalMessageAvatarStyle = RC_USER_AVATAR_CYCLE;
    //  [RCIM sharedRCIM].globalConversationAvatarStyle = RC_USER_AVATAR_CYCLE;
    //   设置优先使用WebView打开URL
    //  [RCIM sharedRCIM].embeddedWebViewPreferred = YES;
}

- (void)configWeChatShare {
    [RCDWeChatManager registerApp:WECHAT_APPID];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

    return [[RCDWeChatManager sharedManager] handleOpenURL:url];
}

- (void)configSealTalkWithApp:(UIApplication *)application andOptions:(NSDictionary *)launchOptions {
    [self saveCountryInfoIfNeed];
#ifndef DEBUG
    [self redirectNSlogToDocumentFolder];
#endif
    [NSThread sleepForTimeInterval:1.0];
    application.statusBarHidden = NO;
    if (BUGLY_APPID.length > 0) {
        [RCDBuglyManager startWithAppId:BUGLY_APPID];
    }
    [self setNavigationBarAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:RCKitDispatchMessageNotification
                                               object:nil];

    /**
     * 推送处理 1
     */
    [self registerRemoteNotification:application];

    /**
     * 统计推送，并获取融云推送服务扩展字段
     */
    [self recordLaunchOptions:launchOptions];
}

- (void)loginAndEnterMainPage {
    NSString *token = [DEFAULTS objectForKey:RCDIMTokenKey];
    NSString *userId = [DEFAULTS objectForKey:RCDUserIdKey];
    NSString *userName = [DEFAULTS objectForKey:RCDUserNameKey];
    NSString *password = [DEFAULTS objectForKey:RCDUserPasswordKey];
    NSString *userNickName = [DEFAULTS objectForKey:RCDUserNickNameKey];
    NSString *userPortraitUri = [DEFAULTS objectForKey:RCDUserPortraitUriKey];
    RCDCountry *currentCountry = [[RCDCountry alloc] initWithDict:[DEFAULTS objectForKey:RCDCurrentCountryKey]];
    NSString *regionCode = @"86";
    if (currentCountry.phoneCode.length > 0) {
        regionCode = currentCountry.phoneCode;
    }
    if (token.length && userId.length && password.length) {
        [RCDLoginManager openDB:userId];
        RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
        RCDNavigationViewController *rootNavi =
            [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
        self.window.rootViewController = rootNavi;

        [self insertSharedMessageIfNeed];

        RCUserInfo *_currentUserInfo =
            [[RCUserInfo alloc] initWithUserId:userId name:userNickName portrait:userPortraitUri];
        [RCIM sharedRCIM].currentUserInfo = _currentUserInfo;
        [[RCDIMService sharedService] connectWithToken:token
            dbOpened:^(RCDBErrorCode code) {
                NSLog(@"RCDBOpened %@", code ? @"failed" : @"success");
            }
            success:^(NSString *userId) {
                [self loginAppServer:userName password:password region:regionCode userId:userId];
            }
            error:^(RCConnectErrorCode status) {
                NSLog(@"connect error %ld", (long)status);
                [self loginAppServer:userName password:password region:regionCode userId:userId];
            }
            tokenIncorrect:^{
                [self refreshIMTokenAndReconnect:userName password:password region:regionCode];
            }];

    } else {
        RCDLoginViewController *vc = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:vc];
        self.window.rootViewController = _navi;
    }
}

- (void)loginAppServer:(NSString *)userName
              password:(NSString *)password
                region:(NSString *)regionCode
                userId:(NSString *)userId {
    [RCDLoginManager loginWithPhone:userName
        password:password
        region:regionCode
        success:^(NSString *_Nonnull token, NSString *_Nonnull userId) {
            [self saveLoginData:userName userId:userId token:token password:password];
        }
        error:^(RCDLoginErrorCode errorCode){

        }];
}

- (void)refreshIMTokenAndReconnect:(NSString *)userName password:(NSString *)password region:(NSString *)regionCode {
    [RCDLoginManager loginWithPhone:userName
        password:password
        region:regionCode
        success:^(NSString *_Nonnull newToken, NSString *_Nonnull newUserId) {
            [[RCDIMService sharedService] connectWithToken:newToken
                dbOpened:^(RCDBErrorCode code) {
                    NSLog(@"RCDBOpened %@", code ? @"failed" : @"success");
                }
                success:^(NSString *userId) {
                    [self saveLoginData:userName userId:newUserId token:newToken password:password];
                }
                error:^(RCConnectErrorCode status) {
                    [self gotoLoginViewAndDisplayReasonInfo:RCDLocalizedString(@"Login_is_invalid_please_login_again")];
                }
                tokenIncorrect:^{
                    [self gotoLoginViewAndDisplayReasonInfo:@"无法连接到服务器"];
                    NSLog(@"Token无效");
                }];
        }
        error:^(RCDLoginErrorCode errorCode) {
            if (errorCode == RCDLoginErrorCodeWrongPassword) {
                [self gotoLoginViewAndDisplayReasonInfo:@"手机号或密码错误"];
            }
        }];
}

/**
 * 推送处理2
 */
//注册用户通知设置
- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    /*
     设置 deviceToken（已兼容 iOS 13），推荐使用，需升级 SDK 版本至 2.9.25
     不需要开发者对 deviceToken 进行处理，可直接传入。
     */
    [[RCIMClient sharedRCIMClient] setDeviceTokenData:deviceToken];
}

// 推送处理 3（如不升级 SDK，需要按照下面代码进行处理）
/*
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    NSString *token = [self getHexStringForData:deviceToken];
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

// Data 转换成 NSString（NSData ——> NSString）
- (NSString *)getHexStringForData:(NSData *)data {
    NSUInteger len = [data length];
    char *chars = (char *)[data bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i ++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    }
    return hexString;
}
*/

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if TARGET_IPHONE_SIMULATOR
// 模拟器不能使用远程推送
#else
    // 请检查App的APNs的权限设置，更多内容可以参考文档
    // http://www.rongcloud.cn/docs/ios_push.html。
    NSLog(@"获取DeviceToken失败！！！");
    NSLog(@"ERROR：%@", error);
#endif
}

/**
 * 推送处理4
 * userInfo内容请参考官网文档
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    /**
     * 统计推送打开率2
     */
    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
    /**
     * 获取融云推送服务扩展字段2
     */
    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromRemoteNotification:userInfo];
    if (pushServiceData) {
        NSLog(@"该远程推送包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"key = %@, value = %@", key, pushServiceData[key]);
        }
    } else {
        NSLog(@"该远程推送不包含来自融云的推送服务");
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    /**
     * 统计推送打开率3
     */
    [[RCIMClient sharedRCIMClient] recordLocalNotificationEvent:notification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];
    if (status != ConnectionStatus_SignUp) {
        int unreadMsgCount = [RCDUtilities getTotalUnreadCount];
        application.applicationIconBadgeNumber = unreadMsgCount;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 登陆状态下为消息分享保存会话信息
    if ([RCIMClient sharedRCIMClient].getConnectionStatus == ConnectionStatus_Connected) {
        [self saveConversationInfoForMessageShare];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([[RCIMClient sharedRCIMClient] getConnectionStatus] == ConnectionStatus_Connected) {
        // 插入分享消息
        [self insertSharedMessageIfNeed];
    }
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    NSNumber *left = [notification.userInfo objectForKey:@"left"];
    if ([RCIMClient sharedRCIMClient].sdkRunningMode == RCSDKRunningMode_Background && 0 == left.integerValue) {
        int unreadMsgCount = [RCDUtilities getTotalUnreadCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadMsgCount;
        });
    }
}

- (void)application:(UIApplication *)application
    handleWatchKitExtensionRequest:(NSDictionary *)userInfo
                             reply:(void (^)(NSDictionary *))reply {
    RCWKRequestHandler *handler =
        [[RCWKRequestHandler alloc] initHelperWithUserInfo:userInfo provider:self reply:reply];
    if (![handler handleWatchKitRequest]) {
        // can not handled!
        // app should handle it here
        NSLog(@"not handled the request: %@", userInfo);
    }
}

#pragma mark - RCIMConnectionStatusDelegate

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        [self showAlert:RCDLocalizedString(@"alert")
                   message:RCDLocalizedString(@"accout_kicked")
            cancelBtnTitle:RCDLocalizedString(@"i_know")];
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = _navi;
    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        [RCDLoginManager getToken:^(BOOL success, NSString *_Nonnull token, NSString *_Nonnull userId) {
            if (success) {
                [[RCDIMService sharedService] connectWithToken:token
                    dbOpened:^(RCDBErrorCode code) {
                        NSLog(@"RCDBOpened %@", code ? @"failed" : @"success");
                    }
                    success:^(NSString *userId) {

                    }
                    error:^(RCConnectErrorCode status) {

                    }
                    tokenIncorrect:^{

                    }];
            }
        }];
    } else if (status == ConnectionStatus_DISCONN_EXCEPTION) {
        [self showAlert:RCDLocalizedString(@"alert")
                   message:RCDLocalizedString(@"Your_account_has_been_banned")
            cancelBtnTitle:RCDLocalizedString(@"i_know")];
        [[RCIMClient sharedRCIMClient] disconnect];
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = _navi;
    }
}

- (BOOL)onRCIMCustomLocalNotification:(RCMessage *)message withSenderName:(NSString *)senderName {
    //群组通知不弹本地通知
    if ([message.content isKindOfClass:[RCGroupNotificationMessage class]]) {
        return YES;
    }
    return NO;
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    if (![RCDGroupManager isHoldGroupNotificationMessage:message] &&
        ![RCDChatManager isHoldChatNotificationMessage:message] &&
        ![[RCDPokeManager sharedInstance] isHoldReceivePokeManager:message]) {
        if ([message.content isMemberOfClass:[RCInformationNotificationMessage class]]) {
            RCInformationNotificationMessage *msg = (RCInformationNotificationMessage *)message.content;
            // NSString *str = [NSString stringWithFormat:@"%@",msg.message];
            if ([msg.message rangeOfString:@"你已添加了"].location != NSNotFound) {
                [RCDDataSource syncFriendList];
            }
        } else if ([message.content isMemberOfClass:[RCDContactNotificationMessage class]] ||
                   [message.content isMemberOfClass:[RCContactNotificationMessage class]]) {
            [RCDDataSource syncFriendList];
        }
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {

    if ([url.absoluteString containsString:@"wechat"] || [url.absoluteString containsString:@"weixin"]) {
        return [[RCDWeChatManager sharedManager] handleOpenURL:url];
    }

    if ([[RCIM sharedRCIM] openExtensionModuleUrl:url]) {
        return YES;
    } else if ([url.absoluteString containsString:@"sealtalk:"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RCDOpenQRCodeUrlNotification object:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([url.absoluteString containsString:@"wechat"] || [url.absoluteString containsString:@"weixin"]) {
        return [[RCDWeChatManager sharedManager] handleOpenURL:url];
    }

    if ([[RCIM sharedRCIM] openExtensionModuleUrl:url]) {
        return YES;
    }
    return YES;
}

- (BOOL)onRCIMCustomAlertSound:(RCMessage *)message {
    //设置群组通知消息没有提示音
    //    if ([message.content isMemberOfClass:[RCGroupNotificationMessage class]]) {
    //        return YES;
    //    }
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKitDispatchMessageNotification object:nil];
}

- (void)saveLoginData:(NSString *)userName
               userId:(NSString *)userId
                token:(NSString *)token
             password:(NSString *)password {
    //保存默认用户
    [DEFAULTS setObject:userName forKey:RCDUserNameKey];
    [DEFAULTS setObject:password forKey:RCDUserPasswordKey];
    [DEFAULTS setObject:token forKey:RCDIMTokenKey];
    [DEFAULTS setObject:userId forKey:RCDUserIdKey];
    [DEFAULTS synchronize];

    [RCDUserInfoManager
        getUserInfoFromServer:userId
                     complete:^(RCDUserInfo *userInfo) {
                         [RCDBuglyManager
                             setUserIdentifier:[NSString stringWithFormat:@"%@ - %@", userInfo.userId, userInfo.name]];
                         [RCIM sharedRCIM].currentUserInfo = userInfo;
                         [DEFAULTS setObject:userInfo.portraitUri forKey:RCDUserPortraitUriKey];
                         [DEFAULTS setObject:userInfo.name forKey:RCDUserNickNameKey];
                         [DEFAULTS setObject:userInfo.stAccount forKey:RCDSealTalkNumberKey];
                         [DEFAULTS setObject:userInfo.gender forKey:RCDUserGenderKey];
                         [DEFAULTS synchronize];
                     }];
    //同步群组
    [RCDDataSource syncAllData];
}

- (void)gotoLoginViewAndDisplayReasonInfo:(NSString *)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert:nil message:reason cancelBtnTitle:RCDLocalizedString(@"confirm")];
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = _navi;

    });
}
#pragma mark - ShareExtension
//插入分享消息
- (void)insertSharedMessageIfNeed {
    NSUserDefaults *shareUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cn.rongcloud.im.share"];

    NSArray *sharedMessages = [shareUserDefaults valueForKey:@"sharedMessages"];
    if (sharedMessages.count > 0) {
        for (NSDictionary *sharedInfo in sharedMessages) {
            RCRichContentMessage *richMsg = [[RCRichContentMessage alloc] init];
            richMsg.title = [sharedInfo objectForKey:@"title"];
            richMsg.digest = [sharedInfo objectForKey:@"content"];
            richMsg.url = [sharedInfo objectForKey:@"url"];
            richMsg.imageURL = [sharedInfo objectForKey:@"imageURL"];
            richMsg.extra = [sharedInfo objectForKey:@"extra"];
            RCMessage *message = [[RCIMClient sharedRCIMClient]
                insertOutgoingMessage:[[sharedInfo objectForKey:@"conversationType"] intValue]
                             targetId:[sharedInfo objectForKey:@"targetId"]
                           sentStatus:SentStatus_SENT
                              content:richMsg];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCDSharedMessageInsertSuccess" object:message];
        }
        [shareUserDefaults removeObjectForKey:@"sharedMessages"];
        [shareUserDefaults synchronize];
    }
}

//为消息分享保存会话信息
- (void)saveConversationInfoForMessageShare {
    NSArray *conversationList =
        [[RCIMClient sharedRCIMClient] getConversationList:@[ @(ConversationType_PRIVATE), @(ConversationType_GROUP) ]];

    NSMutableArray *conversationInfoList = [[NSMutableArray alloc] init];
    if (conversationList.count > 0) {
        for (RCConversation *conversation in conversationList) {
            NSMutableDictionary *conversationInfo = [NSMutableDictionary dictionary];
            [conversationInfo setValue:conversation.targetId forKey:@"targetId"];
            [conversationInfo setValue:@(conversation.conversationType) forKey:@"conversationType"];
            if (conversation.conversationType == ConversationType_PRIVATE) {
                RCUserInfo *user = [RCDUserInfoManager getUserInfo:conversation.targetId];
                [conversationInfo setValue:user.name forKey:@"name"];
                [conversationInfo setValue:user.portraitUri forKey:@"portraitUri"];
            } else if (conversation.conversationType == ConversationType_GROUP) {
                RCGroup *group = [[RCIM sharedRCIM] getGroupInfoCache:conversation.targetId];
                [conversationInfo setValue:group.groupName forKey:@"name"];
                [conversationInfo setValue:group.portraitUri forKey:@"portraitUri"];
            }
            [conversationInfoList addObject:conversationInfo];
        }
    }
    NSURL *sharedURL = [[NSFileManager defaultManager]
        containerURLForSecurityApplicationGroupIdentifier:@"group.cn.rongcloud.im.share"];
    NSURL *fileURL = [sharedURL URLByAppendingPathComponent:@"rongcloudShare.plist"];
    [conversationInfoList writeToURL:fileURL atomically:YES];

    NSUserDefaults *shareUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cn.rongcloud.im.share"];
    [shareUserDefaults setValue:[RCIM sharedRCIM].currentUserInfo.userId forKey:@"currentUserId"];
    [shareUserDefaults setValue:[DEFAULTS objectForKey:RCDUserCookiesKey] forKey:RCDCookieKey];
    [shareUserDefaults synchronize];
}

#pragma mark - RCWKAppInfoProvider
- (NSString *)getAppName {
    return @"融云";
}

- (NSString *)getAppGroups {
    return @"group.cn.rongcloud.im.WKShare";
}

- (NSArray *)getAllGroupInfo {
    return [RCDGroupManager getMyGroupList];
}

- (NSArray *)getAllFriends {
    return [RCDUserInfoManager getAllFriends];
}

- (void)openParentApp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"rongcloud://connect"]];
}

- (BOOL)getNewMessageNotificationSound {
    return ![RCIM sharedRCIM].disableMessageAlertSound;
}

- (void)setNewMessageNotificationSound:(BOOL)on {
    [RCIM sharedRCIM].disableMessageAlertSound = !on;
}

- (BOOL)getLoginStatus {
    NSString *token = [DEFAULTS stringForKey:RCDIMTokenKey];
    if (token.length) {
        return YES;
    } else {
        return NO;
    }
}

- (void)logout {
}

#pragma mark - private method
- (void)registerRemoteNotification:(UIApplication *)application {
    /**
     *  推送说明：
     *
     我们在知识库里还有推送调试页面加了很多说明，当遇到推送问题时可以去知识库里搜索还有查看推送测试页面的说明。
     *
     首先必须设置deviceToken，可以搜索本文件关键字“推送处理”。模拟器是无法获取devicetoken，也就没有推送功能。
     *
     当使用"开发／测试环境"的appkey测试推送时，必须用Development的证书打包，并且在后台上传"开发／测试环境"的推送证书，证书必须是development的。
     当使用"生产／线上环境"的appkey测试推送时，必须用Distribution的证书打包，并且在后台上传"生产／线上环境"的推送证书，证书必须是distribution的。
     */
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //注册推送, 用于iOS8以及iOS8之后的系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
            settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)
                  categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        //注册推送，用于iOS8之前的系统
        UIRemoteNotificationType myTypes =
            UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
}

- (void)recordLaunchOptions:(NSDictionary *)launchOptions {
    /**
     * 统计推送打开率1
     */
    [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];
    /**
     * 获取融云推送服务扩展字段1
     */
    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromLaunchOptions:launchOptions];
    if (pushServiceData) {
        NSLog(@"该启动事件包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"%@", pushServiceData[key]);
        }
    } else {
        NSLog(@"该启动事件不包含来自融云的推送服务");
    }
    //打印原始的远程推送内容
    NSDictionary *remoteNotificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationUserInfo) {
        NSLog(@"远程推送原始内容为 %@", remoteNotificationUserInfo);
    }
}

- (void)saveCountryInfoIfNeed {
    NSDictionary *dic = [DEFAULTS objectForKey:RCDCurrentCountryKey];
    RCDCountry *currentCountry;
    if (!dic) {
        currentCountry = [[RCDCountry alloc] initWithDict:@{
            @"region" : @"86",
            @"locale" : @{@"en" : @"China", @"zh" : @"中国"}
        }];
        [DEFAULTS setObject:[currentCountry getModelJson] forKey:RCDCurrentCountryKey];
    }
}

- (void)setNavigationBarAppearance {
    //统一导航条样式
    UIFont *font = [UIFont systemFontOfSize:19.f];
    NSDictionary *textAttributes =
        @{NSFontAttributeName : font, NSForegroundColorAttributeName : RCDDYCOLOR(0xffffff, 0xA8A8A8)};
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:RCDDYCOLOR(0xffffff, 0xA8A8A8)];
    [[UINavigationBar appearance] setBarTintColor:RCDDYCOLOR(0x0099ff, 0x000000)];

    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(2, 1)
                                                         forBarMetrics:UIBarMetricsDefault];
    UIImage *tmpImage = [UIImage imageNamed:@"navigator_btn_back"];
    CGSize newSize = CGSizeMake(10, 17);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [tmpImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *backButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
    if (IOS_FSystenVersion >= 8.0) {
        [UINavigationBar appearance].translucent = NO;
    }
}

//重定向 log 到本地文件
//在 info.plist 中打开 Application supports iTunes file sharing
- (void)redirectNSlogToDocumentFolder {
    NSLog(@"Log重定向到本地，如果您需要控制台Log，注释掉重定向逻辑即可。");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    [self removeExpireLogFiles:documentDirectory];

    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MMddHHmmss"];
    NSString *formattedDate = [dateformatter stringFromDate:currentDate];

    NSString *fileName = [NSString stringWithFormat:@"rc%@.log", formattedDate];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];

    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (void)removeExpireLogFiles:(NSString *)logPath {
    //删除超过时间的log文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:logPath error:nil]];
    NSDate *currentDate = [NSDate date];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSinceNow:LOG_EXPIRE_TIME];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *fileComp = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |
                          NSMinuteCalendarUnit | NSSecondCalendarUnit;
    fileComp = [calendar components:unitFlags fromDate:currentDate];
    for (NSString *fileName in fileList) {
        // rcMMddHHmmss.log length is 16
        if (fileName.length != 16) {
            continue;
        }
        if (![[fileName substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"rc"]) {
            continue;
        }
        int month = [[fileName substringWithRange:NSMakeRange(2, 2)] intValue];
        int date = [[fileName substringWithRange:NSMakeRange(4, 2)] intValue];
        if (month > 0) {
            [fileComp setMonth:month];
        } else {
            continue;
        }
        if (date > 0) {
            [fileComp setDay:date];
        } else {
            continue;
        }
        NSDate *fileDate = [calendar dateFromComponents:fileComp];

        if ([fileDate compare:currentDate] == NSOrderedDescending ||
            [fileDate compare:expireDate] == NSOrderedAscending) {
            [fileManager removeItemAtPath:[logPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

- (void)showAlert:(NSString *)title message:(NSString *)msg cancelBtnTitle:(NSString *)cBtnTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = self.window.rootViewController;
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:cBtnTitle style:UIAlertActionStyleDefault handler:nil]];
        [rootVC presentViewController:alertController animated:YES completion:nil];
    });
}
@end
