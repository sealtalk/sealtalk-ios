//
//  AppDelegate.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "AppDelegate.h"
#import "AFHttpTool.h"
#import "MBProgressHUD.h"
#import "MobClick.h"
#import "RCDCommonDefine.h"
#import "RCDHttpTool.h"
#import "RCDLoginViewController.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDSettingServerUrlViewController.h"
#import "RCDSettingUserDefaults.h"
#import "RCDTestMessage.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "RCWKNotifier.h"
#import "RCWKRequestHandler.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"
#import <AudioToolbox/AudioToolbox.h>
#import <RongCallKit/RongCallKit.h>
#import <RongContactCard/RongContactCard.h>
#import <RongIMKit/RongIMKit.h>

#define RONGCLOUD_IM_APPKEY @"n19jmcy59f1q9" // online key

//#define RONGCLOUD_IM_APPKEY @"c9kqb3rdkbb8j" // pre key
//#define RONGCLOUD_IM_APPKEY @"e0x9wycfx7flq" // offline key

#define UMENG_APPKEY @"563755cbe0f55a5cb300139c"

#define LOG_EXPIRE_TIME -7 * 24 * 60 * 60

#define iPhone6                                                                                                        \
    ([UIScreen instancesRespondToSelector:@selector(currentMode)]                                                      \
         ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size)                          \
         : NO)
#define iPhone6Plus                                                                                                    \
    ([UIScreen instancesRespondToSelector:@selector(currentMode)]                                                      \
         ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)                         \
         : NO)

@interface AppDelegate () <RCWKAppInfoProvider>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    //重定向log到本地问题
    //在info.plist中打开Application supports iTunes file sharing
    //    if (![[[UIDevice currentDevice] model] isEqualToString:@"iPhone
    //    Simulator"]) {
            [self redirectNSlogToDocumentFolder];
    //    }
    //启动页停留1秒钟。
    [NSThread sleepForTimeInterval:1.0];

    //为了在启动页面不显示statusBar，所以在工程设置里面把statusBar隐藏了，在启动页面过后，显示statusBar。
    application.statusBarHidden = NO;

    [self umengTrack];
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

    BOOL debugMode = NO;
#if RCDPrivateCloudManualMode
    debugMode = YES;
#endif
    // debugMode是为了动态切换导航server地址和文件server地址，公有云用户可以忽略
    if (debugMode) {
        //初始化融云SDK
        NSString *appKey = [RCDSettingUserDefaults getRCAppKey];
        if (appKey) {
            // debug模式初始化sdk
            [[RCIM sharedRCIM] initWithAppKey:appKey];
            NSString *navServer = [RCDSettingUserDefaults getRCNaviServer];
            NSString *fileUrlver = [RCDSettingUserDefaults getRCFileServer];
            //设置导航server和文件server地址
            [[RCIMClient sharedRCIMClient] setServerInfo:navServer fileServer:fileUrlver];
            RCDLoginViewController *settingVC = [[RCDLoginViewController alloc] init];
            RCDNavigationViewController *_navi =
                [[RCDNavigationViewController alloc] initWithRootViewController:settingVC];
            self.window.rootViewController = _navi;
        } else {
            RCDSettingServerUrlViewController *settingVC = [[RCDSettingServerUrlViewController alloc] init];
            RCDNavigationViewController *_navi =
                [[RCDNavigationViewController alloc] initWithRootViewController:settingVC];
            self.window.rootViewController = _navi;
        }

    } else {

        //非debug模式初始化sdk
        [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
        [RCDSettingUserDefaults setRCAppKey:RONGCLOUD_IM_APPKEY];
    }

    /* RedPacket_FTR  */
    //需要在info.plist加上您的红包的scheme，注意一定不能与其它应用重复
    //设置扩展Module的Url Scheme。
    [[RCIM sharedRCIM] setScheme:@"rongCloudRedPacket" forExtensionModule:@"JrmfPacketManager"];

    // 注册自定义测试消息
    [[RCIM sharedRCIM] registerMessageType:[RCDTestMessage class]];

    //设置会话列表头像和会话页面头像

    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];

    [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    //    [RCIM sharedRCIM].portraitImageViewCornerRadius = 10;
    //开启用户信息和群组信息的持久化
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    //设置用户信息源和群组信息源
    [RCIM sharedRCIM].userInfoDataSource = RCDDataSource;
    [RCIM sharedRCIM].groupInfoDataSource = RCDDataSource;
    //设置名片消息功能中联系人信息源和群组信息源
    [RCContactCardKit shareInstance].contactsDataSource = RCDDataSource;
    [RCContactCardKit shareInstance].groupDataSource = RCDDataSource;

    //设置群组内用户信息源。如果不使用群名片功能，可以不设置
    //  [RCIM sharedRCIM].groupUserInfoDataSource = RCDDataSource;
    //  [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
    //设置接收消息代理
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    //    [RCIM sharedRCIM].globalMessagePortraitSize = CGSizeMake(46, 46);
    //开启输入状态监听
    [RCIM sharedRCIM].enableTypingStatus = YES;

    //开启发送已读回执
    [RCIM sharedRCIM].enabledReadReceiptConversationTypeList =
        @[ @(ConversationType_PRIVATE), @(ConversationType_DISCUSSION), @(ConversationType_GROUP) ];

    //开启多端未读状态同步
    [RCIM sharedRCIM].enableSyncReadStatus = YES;

    //设置显示未注册的消息
    //如：新版本增加了某种自定义消息，但是老版本不能识别，开发者可以在旧版本中预先自定义这种未识别的消息的显示
    [RCIM sharedRCIM].showUnkownMessage = YES;
    [RCIM sharedRCIM].showUnkownMessageNotificaiton = YES;

    //群成员数据源
    [RCIM sharedRCIM].groupMemberDataSource = RCDDataSource;

    //开启消息@功能（只支持群聊和讨论组, App需要实现群成员数据源groupMemberDataSource）
    [RCIM sharedRCIM].enableMessageMentioned = YES;

    //开启消息撤回功能
    [RCIM sharedRCIM].enableMessageRecall = YES;

    //  设置头像为圆形
    //  [RCIM sharedRCIM].globalMessageAvatarStyle = RC_USER_AVATAR_CYCLE;
    //  [RCIM sharedRCIM].globalConversationAvatarStyle = RC_USER_AVATAR_CYCLE;
    //   设置优先使用WebView打开URL
    //  [RCIM sharedRCIM].embeddedWebViewPreferred = YES;

    //  设置通话视频分辨率
    //  [[RCCallClient sharedRCCallClient] setVideoProfile:RC_VIDEO_PROFILE_480P];

    //设置Log级别，开发阶段打印详细log
    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Info;

    //登录
    NSString *token = [DEFAULTS objectForKey:@"userToken"];
    NSString *userId = [DEFAULTS objectForKey:@"userId"];
    NSString *userName = [DEFAULTS objectForKey:@"userName"];
    NSString *password = [DEFAULTS objectForKey:@"userPwd"];
    NSString *userNickName = [DEFAULTS objectForKey:@"userNickName"];
    NSString *userPortraitUri = [DEFAULTS objectForKey:@"userPortraitUri"];

    if (token.length && userId.length && password.length) {
        RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
        RCDNavigationViewController *rootNavi =
            [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
        self.window.rootViewController = rootNavi;
        [self insertSharedMessageIfNeed];
        RCUserInfo *_currentUserInfo =
            [[RCUserInfo alloc] initWithUserId:userId name:userNickName portrait:userPortraitUri];
        [RCIM sharedRCIM].currentUserInfo = _currentUserInfo;
        [[RCIM sharedRCIM] connectWithToken:token
            success:^(NSString *userId) {
                [AFHttpTool
                    loginWithPhone:userName
                          password:password
                            region:@"86"
                           success:^(id response) {
                               if ([response[@"code"] intValue] == 200) {
                                   [RCDHTTPTOOL
                                       getUserInfoByUserID:userId
                                                completion:^(RCUserInfo *user) {
                                                    [DEFAULTS setObject:user.portraitUri forKey:@"userPortraitUri"];
                                                    [DEFAULTS setObject:user.name forKey:@"userNickName"];
                                                    [DEFAULTS synchronize];
                                                    [RCIMClient sharedRCIMClient].currentUserInfo = user;
                                                }];
                                   //登录demoserver成功之后才能调demo 的接口
                                   [RCDDataSource syncGroups];
                                   [RCDDataSource syncFriendList:userId
                                                        complete:^(NSMutableArray *result){
                                                        }];
                               }
                           }
                           failure:^(NSError *err){
                           }];
            }
            error:^(RCConnectErrorCode status) {
                [RCDDataSource syncGroups];
                NSLog(@"connect error %ld", (long)status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
                    RCDNavigationViewController *rootNavi =
                        [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
                    self.window.rootViewController = rootNavi;
                });
            }
            tokenIncorrect:^{
                [AFHttpTool loginWithPhone:userName
                                  password:password
                                    region:@"86"
                                   success:^(id response) {
                                       if ([response[@"code"] intValue] == 200) {
                                           NSString *newToken = response[@"result"][@"token"];
                                           NSString *newUserId = response[@"result"][@"id"];
                                           [[RCIM sharedRCIM] connectWithToken:newToken
                                               success:^(NSString *userId) {
                                                   [self loginSuccess:userName
                                                               userId:newUserId
                                                                token:newToken
                                                             password:password];
                                               }
                                               error:^(RCConnectErrorCode status) {
                                                   [self gotoLoginViewAndDisplayReasonInfo:@"登录失效，请重新登录。"];
                                               }
                                               tokenIncorrect:^{
                                                   [self gotoLoginViewAndDisplayReasonInfo:@"无法连接到服务器"];
                                                   NSLog(@"Token无效");
                                               }];
                                       } else {
                                           [self gotoLoginViewAndDisplayReasonInfo:@"手机号或密码错误"];
                                       }
                                   }
                                   failure:^(NSError *err){

                                   }];
            }];

    } else {
        RCDLoginViewController *vc = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:vc];

        self.window.rootViewController = _navi;
    }

    /**
     * 推送处理1
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

    //统一导航条样式
    UIFont *font = [UIFont systemFontOfSize:19.f];
    NSDictionary *textAttributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"0099ff" alpha:1.0f]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:RCKitDispatchMessageNotification
                                               object:nil];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1.5, 0)
                                                         forBarMetrics:UIBarMetricsDefault];
    UIImage *tmpImage = [UIImage imageNamed:@"back"];

    CGSize newSize = CGSizeMake(12, 20);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [tmpImage drawInRect:CGRectMake(2, -2, newSize.width, newSize.height)];
    UIImage *backButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
    if (IOS_FSystenVersion >= 8.0) {
        [UINavigationBar appearance].translucent = NO;
    }

    //    NSArray *groups = [self getAllGroupInfo];
    //    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:groups];
    //    NSArray *loadedContents = [NSKeyedUnarchiver
    //                               unarchiveObjectWithData:data];
    //    NSLog(@"loadedContents size is %d", loadedContents.count);
    return YES;
}

/**
 * 推送处理2
 */
//注册用户通知设置
- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]
        stringByReplacingOccurrencesOfString:@">"
                                  withString:@""] stringByReplacingOccurrencesOfString:@" "
                                                                            withString:@""];

    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

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

- (void)onlineConfigCallBack:(NSNotification *)note {

    NSLog(@"online config has fininshed and note = %@", note.userInfo);
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

    //  //震动
    //  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //  AudioServicesPlaySystemSound(1007);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];
    if (status != ConnectionStatus_SignUp) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
            @(ConversationType_PRIVATE), @(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE),
            @(ConversationType_PUBLICSERVICE), @(ConversationType_GROUP)
        ]];
        application.applicationIconBadgeNumber = unreadMsgCount;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
    //  int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
    //    @(ConversationType_PRIVATE),
    //    @(ConversationType_DISCUSSION),
    //    @(ConversationType_APPSERVICE),
    //    @(ConversationType_PUBLICSERVICE),
    //    @(ConversationType_GROUP)
    //  ]];
    //  application.applicationIconBadgeNumber = unreadMsgCount;

    // 登陆状态下为消息分享保存会话信息
    if([RCIMClient sharedRCIMClient].getConnectionStatus == ConnectionStatus_Connected){
       [self saveConversationInfoForMessageShare];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
    if ([[RCIMClient sharedRCIMClient] getConnectionStatus] == ConnectionStatus_Connected) {
        // 插入分享消息
        [self insertSharedMessageIfNeed];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

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
            //      long long sendTime = [[sharedInfo objectForKey:@"sharedTime"] longLongValue];
            //      RCMessage *message = [[RCIMClient sharedRCIMClient] insertOutgoingMessage:[[sharedInfo
            //      objectForKey:@"conversationType"] intValue] targetId:[sharedInfo objectForKey:@"targetId"]
            //      sentStatus:SentStatus_SENT content:richMsg sentTime:sendTime];
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
                RCUserInfo *user = [[RCIM sharedRCIM] getUserInfoCache:conversation.targetId];
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
    [shareUserDefaults setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserCookies"] forKey:@"Cookie"];
    [shareUserDefaults synchronize];
}

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

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    NSNumber *left = [notification.userInfo objectForKey:@"left"];
    if ([RCIMClient sharedRCIMClient].sdkRunningMode == RCSDKRunningMode_Background && 0 == left.integerValue) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
            @(ConversationType_PRIVATE), @(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE),
            @(ConversationType_PUBLICSERVICE), @(ConversationType_GROUP)
        ]];
        dispatch_async(dispatch_get_main_queue(),^{
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
#pragma mark - RCWKAppInfoProvider
- (NSString *)getAppName {
    return @"融云";
}

- (NSString *)getAppGroups {
    return @"group.cn.rongcloud.im.WKShare";
}

- (NSArray *)getAllUserInfo {
    return [RCDDataSource getAllUserInfo:^{
        [[RCWKNotifier sharedWKNotifier] notifyWatchKitUserInfoChanged];
    }];
}
- (NSArray *)getAllGroupInfo {
    return [RCDDataSource getAllGroupInfo:^{
        [[RCWKNotifier sharedWKNotifier] notifyWatchKitGroupChanged];
    }];
}
- (NSArray *)getAllFriends {
    return [RCDDataSource getAllFriends:^{
        [[RCWKNotifier sharedWKNotifier] notifyWatchKitFriendChanged];
    }];
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
    NSString *token = [DEFAULTS stringForKey:@"userToken"];
    if (token.length) {
        return YES;
    } else {
        return NO;
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您的帐号在别的设备上登录，"
                                                                @"您被迫下线！"
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil, nil];
        [alert show];
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = _navi;
    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        [AFHttpTool getTokenSuccess:^(id response) {
            NSString *token = response[@"result"][@"token"];
            [[RCIM sharedRCIM] connectWithToken:token
                success:^(NSString *userId) {

                }
                error:^(RCConnectErrorCode status) {

                }
                tokenIncorrect:^{

                }];
        }
                            failure:^(NSError *err){

                            }];
    } else if (status == ConnectionStatus_DISCONN_EXCEPTION) {
        [[RCIMClient sharedRCIMClient] disconnect];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您的帐号被封禁"
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil, nil];
        [alert show];
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
    if ([[message.content.class getObjectName] isEqualToString:@"RCJrmf:RpOpendMsg"]) {
    return YES;
    }
    return NO;
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    if ([message.content isMemberOfClass:[RCInformationNotificationMessage class]]) {
        RCInformationNotificationMessage *msg = (RCInformationNotificationMessage *)message.content;
        // NSString *str = [NSString stringWithFormat:@"%@",msg.message];
        if ([msg.message rangeOfString:@"你已添加了"].location != NSNotFound) {
            [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                                 complete:^(NSMutableArray *friends){
                                 }];
        }
    } else if ([message.content isMemberOfClass:[RCContactNotificationMessage class]]) {
        RCContactNotificationMessage *msg = (RCContactNotificationMessage *)message.content;
        if ([msg.operation isEqualToString:ContactNotificationMessage_ContactOperationAcceptResponse]) {
            [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                                 complete:^(NSMutableArray *friends){
                                 }];
        }
    } else if ([message.content isMemberOfClass:[RCGroupNotificationMessage class]]) {
        RCGroupNotificationMessage *msg = (RCGroupNotificationMessage *)message.content;
        if ([msg.operation isEqualToString:@"Dismiss"] &&
            [msg.operatorUserId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            [[RCIMClient sharedRCIMClient]clearRemoteHistoryMessages:ConversationType_GROUP
                                                            targetId:message.targetId
                                                          recordTime:message.sentTime
                                                             success:^{
                                                                 [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_GROUP targetId:message.targetId];
                                                             }
                                                               error:nil
             ];
            [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP targetId:message.targetId];
        } else if ([msg.operation isEqualToString:@"Quit"] || [msg.operation isEqualToString:@"Add"] ||
                   [msg.operation isEqualToString:@"Kicked"] || [msg.operation isEqualToString:@"Rename"]) {
            if (![msg.operation isEqualToString:@"Rename"]) {
                [RCDHTTPTOOL getGroupMembersWithGroupId:message.targetId
                                                  Block:^(NSMutableArray *result) {
                                                      [[RCDataBaseManager shareInstance]
                                                          insertGroupMemberToDB:result
                                                                        groupId:message.targetId
                                                                       complete:^(BOOL results){

                                                                       }];
                                                  }];
            }
            [RCDHTTPTOOL getGroupByID:message.targetId
                    successCompletion:^(RCDGroupInfo *group) {
                        [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                        [[RCIM sharedRCIM] refreshGroupInfoCache:group withGroupId:group.groupId];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdeteGroupInfo"
                                                                            object:message.targetId];
                    }];
        }
    }
}

/* RedPacket_FTR  */
//如果您使用了红包等融云的第三方扩展，请实现下面两个openURL方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    if ([[RCIM sharedRCIM] openExtensionModuleUrl:url]) {
        return YES;
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
    if ([[RCIM sharedRCIM] openExtensionModuleUrl:url]) {
        return YES;
    }
    return YES;
}

//设置群组通知消息没有提示音
- (BOOL)onRCIMCustomAlertSound:(RCMessage *)message {
    //当应用处于前台运行，收到消息不会有提示音。
    //  if ([message.content isMemberOfClass:[RCGroupNotificationMessage class]]) {
    return YES;
    //  }
    //  return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKitDispatchMessageNotification object:nil];
}

- (void)umengTrack {
    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setLogEnabled:YES]; // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString *
                                              //类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy)REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App
    //   Store"渠道

    [MobClick updateOnlineConfig]; //在线参数配置

    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onlineConfigCallBack:)
                                                 name:UMOnlineConfigDidFinishedNotification
                                               object:nil];
}

- (void)loginSuccess:(NSString *)userName
              userId:(NSString *)userId
               token:(NSString *)token
            password:(NSString *)password {
    //保存默认用户
    [DEFAULTS setObject:userName forKey:@"userName"];
    [DEFAULTS setObject:password forKey:@"userPwd"];
    [DEFAULTS setObject:token forKey:@"userToken"];
    [DEFAULTS setObject:userId forKey:@"userId"];
    [DEFAULTS synchronize];
    //保存“发现”的信息
    [RCDHTTPTOOL getSquareInfoCompletion:^(NSMutableArray *result) {
        [DEFAULTS setObject:result forKey:@"SquareInfoList"];
        [DEFAULTS synchronize];
    }];

    [AFHttpTool getUserInfo:userId
                    success:^(id response) {
                        if ([response[@"code"] intValue] == 200) {
                            NSDictionary *result = response[@"result"];
                            NSString *nickname = result[@"nickname"];
                            NSString *portraitUri = result[@"portraitUri"];
                            RCUserInfo *user =
                                [[RCUserInfo alloc] initWithUserId:userId name:nickname portrait:portraitUri];
                            if (!user.portraitUri || user.portraitUri.length <= 0) {
                                user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                            }
                            [[RCDataBaseManager shareInstance] insertUserToDB:user];
                            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
                            [RCIM sharedRCIM].currentUserInfo = user;
                            [DEFAULTS setObject:user.portraitUri forKey:@"userPortraitUri"];
                            [DEFAULTS setObject:user.name forKey:@"userNickName"];
                            [DEFAULTS synchronize];
                        }
                    }
                    failure:^(NSError *err){

                    }];
    //同步群组
    [RCDDataSource syncGroups];
    [RCDDataSource syncFriendList:userId
                         complete:^(NSMutableArray *friends){
                         }];
    dispatch_async(dispatch_get_main_queue(), ^{
        RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
        RCDNavigationViewController *rootNavi =
            [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
        self.window.rootViewController = rootNavi;

    });
}

- (void)gotoLoginViewAndDisplayReasonInfo:(NSString *)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:reason
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        ;
        [alertView show];
        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = _navi;

    });
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

@end
