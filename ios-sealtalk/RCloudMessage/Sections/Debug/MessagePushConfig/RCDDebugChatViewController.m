//
//  RCDDebugChatViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2020/12/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugChatViewController.h"

@interface RCConversationViewController ()
- (void)reloadRecalledMessage:(long)recalledMsgId;
@end

@interface RCDDebugChatViewController ()

@end

@implementation RCDDebugChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)sendMessage:(RCMessageContent *)messageContent pushContent:(NSString *)pushContent {
    
    RCMessagePushConfig *pushConfig = [self getPushConfig];
    RCMessageConfig *config = [self getConfig];
    if (self.targetId == nil) {
        return;
    }
    messageContent = [self willSendMessage:messageContent];
    if (messageContent == nil) {
        return;
    }
    RCMessage *message = [[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:MessageDirection_SEND messageId:0 content:messageContent];
    message.messagePushConfig = pushConfig;
    message.messageConfig = config;
    
    if ([messageContent isKindOfClass:[RCMediaMessageContent class]]) {
        [[RCIM sharedRCIM] sendMediaMessage:message pushContent:pushContent pushData:nil progress:nil successBlock:nil errorBlock:nil cancel:nil];
    } else {
        [[RCIM sharedRCIM] sendMessage:message pushContent:pushContent pushData:nil successBlock:nil errorBlock:nil];
    }
}

- (void)recallMessage:(long)messageId {
    RCMessagePushConfig *pushConfig = [self getPushConfig];
    RCMessageConfig *config = [self getConfig];
    RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:messageId];
    msg.messagePushConfig = pushConfig;
    msg.messageConfig = config;
    if (msg.messageDirection != MessageDirection_SEND && msg.sentStatus != SentStatus_SENT) {
        NSLog(@"错误，只有发送成功的消息才能撤回！！！");
        return;
    }
    
    [[RCIMClient sharedRCIMClient] recallMessage:msg
                                     pushContent:nil
                                         success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadRecalledMessage:messageId];
        });
    }
                                           error:^(RCErrorCode errorcode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [RCAlertView showAlertController:nil message:RCLocalizedString(@"MessageRecallFailed") cancelTitle:RCLocalizedString(@"OK") inViewController:self];
        });
    }];
}

- (RCMessagePushConfig *)getPushConfig {
    RCMessagePushConfig *pushConfig = [[RCMessagePushConfig alloc] init];
    pushConfig.disablePushTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-disablePushTitle"] boolValue];
    pushConfig.pushTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-title"];
    pushConfig.pushContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-content"];
    pushConfig.pushData = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-data"];
    pushConfig.forceShowDetailContent = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-forceShowDetailContent"] boolValue];
    pushConfig.templateId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-templateId"];
    
    pushConfig.iOSConfig.threadId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-threadId"];
    pushConfig.iOSConfig.apnsCollapseId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-apnsCollapseId"];
    
    pushConfig.androidConfig.notificationId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-id"];
    pushConfig.androidConfig.channelIdMi = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-mi"];
    pushConfig.androidConfig.channelIdHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw"];
    pushConfig.androidConfig.channelIdOPPO = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-oppo"];
    pushConfig.androidConfig.typeVivo = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-vivo"];
    return pushConfig;
}

- (RCMessageConfig *)getConfig {
    RCMessageConfig *config = [[RCMessageConfig alloc] init];
    config.disableNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:@"config-disableNotification"] boolValue];
    return config;
}

@end
