//
//  AppDelegate.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "AFHttpTool.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "MobClick.h"
#import "RCDCommonDefine.h"
#import "RCDHttpTool.h"
#import "RCDLoginViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDTestMessage.h"
#import "RCDataBaseManager.h"
#import "RCWKNotifier.h"
#import "RCWKRequestHandler.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"
#import <AudioToolbox/AudioToolbox.h>
#import <RongCallKit/RongCallKit.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDNavigationViewController.h"

//#define RONGCLOUD_IM_APPKEY @"e0x9wycfx7flq" //offline key
#define RONGCLOUD_IM_APPKEY @"n19jmcy59f1q9" // online key

#define UMENG_APPKEY @"563755cbe0f55a5cb300139c"

#define iPhone6                                                                \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
       ? CGSizeEqualToSize(CGSizeMake(750, 1334),                              \
                           [[UIScreen mainScreen] currentMode].size)           \
       : NO)
#define iPhone6Plus                                                            \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
       ? CGSizeEqualToSize(CGSizeMake(1242, 2208),                             \
                           [[UIScreen mainScreen] currentMode].size)           \
       : NO)

@interface AppDelegate () <RCWKAppInfoProvider>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  //重定向log到本地问题
  //在info.plist中打开Application supports iTunes file sharing
  //    if (![[[UIDevice currentDevice] model] isEqualToString:@"iPhone
  //    Simulator"]) {
          [self redirectNSlogToDocumentFolder];
  //    }
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

  BOOL debugMode = [[NSUserDefaults standardUserDefaults]
      boolForKey:@"rongcloud appkey debug"];
  // debugMode是为了切换appkey测试用的，请应用忽略关于debugMode的信息，这里直接调用init。
  if (!debugMode) {

    //初始化融云SDK
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];

  }

  // 注册自定义测试消息
  [[RCIM sharedRCIM] registerMessageType:[RCDTestMessage class]];

  //设置会话列表头像和会话界面头像

  [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
  
  [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
  //    [RCIM sharedRCIM].portraitImageViewCornerRadius = 10;
  //开启用户信息和群组信息的持久化
  [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
  //设置用户信息源和群组信息源
  [RCIM sharedRCIM].userInfoDataSource = RCDDataSource;
  [RCIM sharedRCIM].groupInfoDataSource = RCDDataSource;

  //设置群组内用户信息源。如果不使用群名片功能，可以不设置
  //  [RCIM sharedRCIM].groupUserInfoDataSource = RCDDataSource;
  //  [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
  //设置接收消息代理
  [RCIM sharedRCIM].receiveMessageDelegate = self;
  //    [RCIM sharedRCIM].globalMessagePortraitSize = CGSizeMake(46, 46);
  //开启输入状态监听
  [RCIM sharedRCIM].enableTypingStatus = YES;
  //开启发送已读回执（只支持单聊）
  [RCIM sharedRCIM].enableReadReceipt = YES;
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
  
  
  //    //设置头像为圆形
  //    [RCIM sharedRCIM].globalMessageAvatarStyle = RC_USER_AVATAR_CYCLE;
  //    [RCIM sharedRCIM].globalConversationAvatarStyle = RC_USER_AVATAR_CYCLE;

  //通话设置群组成员列表提供者
  [RCCall sharedRCCall].groupMemberDataSource = RCDDataSource;

  //登录
  NSString *token = [DEFAULTS objectForKey:@"userToken"];
  NSString *userId = [DEFAULTS objectForKey:@"userId"];
  NSString *userName = [DEFAULTS objectForKey:@"userName"];
  NSString *password = [DEFAULTS objectForKey:@"userPwd"];
  NSString *userNickName = [DEFAULTS objectForKey:@"userNickName"];
  NSString *userPortraitUri = [DEFAULTS objectForKey:@"userPortraitUri"];

  if (token.length && userId.length && password.length && !debugMode) {
    RCUserInfo *_currentUserInfo =
        [[RCUserInfo alloc] initWithUserId:userId
                                      name:userNickName
                                  portrait:userPortraitUri];
    [RCIM sharedRCIM].currentUserInfo = _currentUserInfo;
    [[RCIM sharedRCIM] connectWithToken:token
        success:^(NSString *userId) {
          [AFHttpTool loginWithPhone:userName
              password:password
              region:@"86"
              success:^(id response) {
                if ([response[@"code"] intValue] == 200) {
                  [RCDHTTPTOOL
                      getUserInfoByUserID:userId
                               completion:^(RCUserInfo *user) {
                                 [DEFAULTS setObject:user.portraitUri
                                              forKey:@"userPortraitUri"];
                                 [DEFAULTS setObject:user.name
                                              forKey:@"userNickName"];
                                 [DEFAULTS synchronize];
                                 [RCIMClient sharedRCIMClient].currentUserInfo =
                                     user;
                               }];
                  //登陆demoserver成功之后才能调demo 的接口
                  [RCDDataSource syncGroups];
                  [RCDDataSource syncFriendList:userId
                                       complete:^(NSMutableArray *result){
                                       }];
                }
              }
              failure:^(NSError *err){
              }];
          //设置当前的用户信息

          //同步群组
          //调用connectWithToken时数据库会同步打开，不用再等到block返回之后再访问数据库，因此不需要这里刷新
          //这里仅保证之前已经成功登陆过，如果第一次登陆必须等block
          //返回之后才操作数据
          //          dispatch_async(dispatch_get_main_queue(), ^{
          //            UIStoryboard *storyboard =
          //                [UIStoryboard storyboardWithName:@"Main"
          //                bundle:nil];
          //            UINavigationController *rootNavi = [storyboard
          //                instantiateViewControllerWithIdentifier:@"rootNavi"];
          //            self.window.rootViewController = rootNavi;
          //          });
        }
        error:^(RCConnectErrorCode status) {
          RCUserInfo *_currentUserInfo =
              [[RCUserInfo alloc] initWithUserId:userId
                                            name:userName
                                        portrait:nil];
          [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
          [RCDDataSource syncGroups];
          NSLog(@"connect error %ld", (long)status);
          dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard =
                [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            RCDNavigationViewController *rootNavi = [storyboard
                instantiateViewControllerWithIdentifier:@"rootNavi"];
            self.window.rootViewController = rootNavi;
          });
        }
        tokenIncorrect:^{
          dispatch_async(dispatch_get_main_queue(), ^{
            RCDLoginViewController *loginVC =
                [[RCDLoginViewController alloc] init];
            RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc]
                                                  initWithRootViewController:loginVC];
            self.window.rootViewController = _navi;
            UIAlertView *alertView =
                [[UIAlertView alloc] initWithTitle:nil
                                           message:@"Token已过期，请重新登录"
                                          delegate:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil, nil];
            ;
            [alertView show];
          });
        }];

  } else {
    RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
    // [loginVC defaultLogin];
    // RCDLoginViewController* loginVC = [storyboard
    // instantiateViewControllerWithIdentifier:@"loginVC"];
    RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc]
                                          initWithRootViewController:loginVC];
    self.window.rootViewController = _navi;
  }

  /**
   * 推送处理1
   */
  if ([application
          respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    //注册推送, 用于iOS8以及iOS8之后的系统
    UIUserNotificationSettings *settings = [UIUserNotificationSettings
        settingsForTypes:(UIUserNotificationTypeBadge |
                          UIUserNotificationTypeSound |
                          UIUserNotificationTypeAlert)
              categories:nil];
    [application registerUserNotificationSettings:settings];
  } else {
    //注册推送，用于iOS8之前的系统
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
                                       UIRemoteNotificationTypeAlert |
                                       UIRemoteNotificationTypeSound;
    [application registerForRemoteNotificationTypes:myTypes];
  }
  /**
   * 统计推送打开率1
   */
  [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];
  /**
   * 获取融云推送服务扩展字段1
   */
  NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient]
      getPushExtraFromLaunchOptions:launchOptions];
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
  NSDictionary *textAttributes = @{
    NSFontAttributeName : font,
    NSForegroundColorAttributeName : [UIColor whiteColor]
  };
  [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UINavigationBar appearance]
      setBarTintColor:[UIColor colorWithHexString:@"0195ff" alpha:1.0f]];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(didReceiveMessageNotification:)
             name:RCKitDispatchMessageNotification
           object:nil];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1.5, 0)  forBarMetrics:UIBarMetricsDefault];
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
    didRegisterUserNotificationSettings:
        (UIUserNotificationSettings *)notificationSettings {
  // register to receive notifications
  [application registerForRemoteNotifications];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSString *token =
      [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                             withString:@""]
          stringByReplacingOccurrencesOfString:@">"
                                    withString:@""]
          stringByReplacingOccurrencesOfString:@" "
                                    withString:@""];

  [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
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
- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
  /**
   * 统计推送打开率2
   */
  [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
  /**
   * 获取融云推送服务扩展字段2
   */
  NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient]
      getPushExtraFromRemoteNotification:userInfo];
  if (pushServiceData) {
    NSLog(@"该远程推送包含来自融云的推送服务");
    for (id key in [pushServiceData allKeys]) {
      NSLog(@"key = %@, value = %@", key, pushServiceData[key]);
    }
  } else {
    NSLog(@"该远程推送不包含来自融云的推送服务");
  }
}

- (void)application:(UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification {
  /**
   * 统计推送打开率3
   */
  [[RCIMClient sharedRCIMClient] recordLocalNotificationEvent:notification];

  //震动
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  AudioServicesPlaySystemSound(1007);
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
  int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
    @(ConversationType_PRIVATE),
    @(ConversationType_DISCUSSION),
    @(ConversationType_APPSERVICE),
    @(ConversationType_PUBLICSERVICE),
    @(ConversationType_GROUP)
  ]];
  application.applicationIconBadgeNumber = unreadMsgCount;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
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

- (void)redirectNSlogToDocumentFolder {
  NSLog(@"Log重定向到本地，如果您需要控制台Log，注释掉重定向逻辑即可。");
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *documentDirectory = [paths objectAtIndex:0];

  NSDate *currentDate = [NSDate date];
  NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
  [dateformatter setDateFormat:@"MMddHHmmss"];
  NSString *formattedDate = [dateformatter stringFromDate:currentDate];

  NSString *fileName = [NSString stringWithFormat:@"rc%@.log", formattedDate];
  NSString *logFilePath =
      [documentDirectory stringByAppendingPathComponent:fileName];

  freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+",
          stdout);
  freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+",
          stderr);
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
  NSNumber *left = [notification.userInfo objectForKey:@"left"];
  if ([RCIMClient sharedRCIMClient].sdkRunningMode == RCSDKRunningMode_Backgroud
      && 0 == left.integerValue) {
    RCMessage *message = notification.object;
    if (message.messageDirection == MessageDirection_RECEIVE && [[message.content class] persistentFlag] & MessagePersistent_ISCOUNTED) {
      int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
        @(ConversationType_PRIVATE),
        @(ConversationType_DISCUSSION),
        @(ConversationType_APPSERVICE),
        @(ConversationType_PUBLICSERVICE),
        @(ConversationType_GROUP)
      ]];
      [UIApplication sharedApplication].applicationIconBadgeNumber =
          unreadMsgCount;
    }
  }
}

- (void)application:(UIApplication *)application
    handleWatchKitExtensionRequest:(NSDictionary *)userInfo
                             reply:(void (^)(NSDictionary *))reply {
  RCWKRequestHandler *handler =
      [[RCWKRequestHandler alloc] initHelperWithUserInfo:userInfo
                                                provider:self
                                                   reply:reply];
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
  [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:@"rongcloud://connect"]];
}
- (BOOL)getNewMessageNotificationSound {
  return ![RCIM sharedRCIM].disableMessageAlertSound;
}
- (void)setNewMessageNotificationSound:(BOOL)on {
  [RCIM sharedRCIM].disableMessageAlertSound = !on;
}
- (void)logout {
  [DEFAULTS removeObjectForKey:@"userName"];
  [DEFAULTS removeObjectForKey:@"userPwd"];
  [DEFAULTS removeObjectForKey:@"userToken"];
  [DEFAULTS removeObjectForKey:@"userCookie"];
  if (self.window.rootViewController != nil) {
    UIStoryboard *storyboard =
        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RCDLoginViewController *loginVC =
        [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
    RCDNavigationViewController *navi = [[RCDNavigationViewController alloc]
                                          initWithRootViewController:loginVC];
    self.window.rootViewController = navi;
  }
  [[RCIMClient sharedRCIMClient] disconnect:NO];
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
    UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:@"提示"
                  message:
                      @"您的帐号在别的设备上登录，"
                      @"您被迫下线！"
                 delegate:nil
        cancelButtonTitle:@"知道了"
        otherButtonTitles:nil, nil];
    [alert show];
    RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
    // [loginVC defaultLogin];
    // RCDLoginViewController* loginVC = [storyboard
    // instantiateViewControllerWithIdentifier:@"loginVC"];
    RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc]
                                          initWithRootViewController:loginVC];
    self.window.rootViewController = _navi;
  } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
    dispatch_async(dispatch_get_main_queue(), ^{
      RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
      UINavigationController *_navi =
          [[UINavigationController alloc] initWithRootViewController:loginVC];
      self.window.rootViewController = _navi;
      UIAlertView *alertView =
          [[UIAlertView alloc] initWithTitle:nil
                                     message:@"Token已过期，请重新登录"
                                    delegate:nil
                           cancelButtonTitle:@"确定"
                           otherButtonTitles:nil, nil];
      [alertView show];
    });
  }
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
  if ([message.content
          isMemberOfClass:[RCInformationNotificationMessage class]]) {
    RCInformationNotificationMessage *msg =
        (RCInformationNotificationMessage *)message.content;
    // NSString *str = [NSString stringWithFormat:@"%@",msg.message];
    if ([msg.message rangeOfString:@"你已添加了"].location != NSNotFound) {
      [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                           complete:^(NSMutableArray *friends){
                           }];
    }
  } else if ([message.content
                 isMemberOfClass:[RCContactNotificationMessage class]]) {
    RCContactNotificationMessage *msg =
        (RCContactNotificationMessage *)message.content;
    if ([msg.operation
            isEqualToString:
                ContactNotificationMessage_ContactOperationAcceptResponse]) {
      [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                           complete:^(NSMutableArray *friends){
                           }];
    }
  } else if ([message.content
                 isMemberOfClass:[RCGroupNotificationMessage class]]) {
    RCGroupNotificationMessage *msg =
        (RCGroupNotificationMessage *)message.content;
    if ([msg.operation isEqualToString:@"Dismiss"] &&
        [msg.operatorUserId
            isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
      [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_GROUP
                                          targetId:message.targetId];
      [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP
                                               targetId:message.targetId];
    } else if ([msg.operation isEqualToString:@"Rename"]) {
      [RCDHTTPTOOL getGroupByID:message.targetId
              successCompletion:^(RCDGroupInfo *group) {
                [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                [[RCIM sharedRCIM] refreshGroupInfoCache:group
                                             withGroupId:group.groupId];
              }];
    }
  }
}

//设置群组通知消息没有提示音
-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message
{
  if ([message.content isMemberOfClass:[RCGroupNotificationMessage class]]) {
    return YES;
  }
  return NO;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:RCKitDispatchMessageNotification
              object:nil];
}

- (void)umengTrack {
  //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
  [MobClick
      setLogEnabled:
          YES]; // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
  [MobClick
      setAppVersion:
          XcodeAppVersion]; //参数为NSString *
                            //类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
  //
  [MobClick startWithAppkey:UMENG_APPKEY
               reportPolicy:(ReportPolicy)REALTIME
                  channelId:nil];
  //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
  //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App
  //   Store"渠道

  [MobClick updateOnlineConfig]; //在线参数配置

  //    1.6.8之前的初始化方法
  //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(onlineConfigCallBack:)
             name:UMOnlineConfigDidFinishedNotification
           object:nil];
}

@end
