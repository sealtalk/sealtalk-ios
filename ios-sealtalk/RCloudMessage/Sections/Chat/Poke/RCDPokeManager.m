//
//  RCDPokeManager.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPokeManager.h"
#import "RCDPokeMessage.h"
#import "RCDPokeRemindController.h"
#import "RCDUserInfoManager.h"
@interface RCDPokeManager ()
@property (nonatomic, assign) BOOL isBackground;
@property (nonatomic, strong) RCMessage *bgFirstMessage; //后台收到的第一条消息，产品需求：用户不在 App
                                                         //内（关闭App、后台运行中、关机等），不显示该通知，需要在打开
                                                         //App 的第一时间收到
@end
@implementation RCDPokeManager
+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillTerminate)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)appDidEnterBackground {
    self.isBackground = YES;
}

- (void)appWillEnterForeground {
    self.isBackground = NO;
    //进入前台时检查后台模式是否收到戳一下消息
    if (self.bgFirstMessage) {
        [self persentPokeRemindVC:self.bgFirstMessage];
        self.bgFirstMessage = nil;
    }
}

- (void)appWillTerminate {
    self.isBackground = YES;
}

- (void)persentPokeRemindVC:(RCMessage *)message {
    if (!self.isBackground && !self.isShowPokeVC) {
        RCDPokeRemindController *pokeRemindVC = [[RCDPokeRemindController alloc] init];
        pokeRemindVC.message = message;
        [[UIApplication sharedApplication].keyWindow addSubview:pokeRemindVC.view];
    }
    if (!self.isShowPokeVC && self.isBackground && !self.bgFirstMessage) {
        self.bgFirstMessage = message;
    }
}

- (BOOL)isHoldReceivePokeManager:(RCMessage *)message {
    if ([message.content isKindOfClass:[RCDPokeMessage class]]) {
        if (![self.currentConversation.targetId isEqualToString:message.targetId] &&
            self.currentConversation.conversationType != message.conversationType &&
            message.messageDirection == MessageDirection_RECEIVE && [RCDUserInfoManager getReceivePokeMessageStatus]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self persentPokeRemindVC:message];
            });
        }
        return YES;
    }
    return NO;
}

- (void)saveSendPokeTime:(RCConversationType)type targetId:(NSString *)targetId {
    [[NSUserDefaults standardUserDefaults]
        setValue:@(CFAbsoluteTimeGetCurrent())
          forKey:[NSString stringWithFormat:@"%ld%@%@", type, targetId, [RCIM sharedRCIM].currentUserInfo.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getLastSendPokeTimeInterval:(RCConversationType)type targetId:(NSString *)targetId {
    CFAbsoluteTime lastTime = [[[NSUserDefaults standardUserDefaults]
        objectForKey:[NSString stringWithFormat:@"%ld%@%@", type, targetId, [RCIM sharedRCIM].currentUserInfo.userId]]
        longLongValue];
    NSTimeInterval linkTime = (CFAbsoluteTimeGetCurrent() - lastTime);
    return (NSInteger)linkTime;
}
@end
