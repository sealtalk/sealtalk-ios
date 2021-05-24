//
//  RCDDebugChatListController.m
//  SealTalk
//
//  Created by 张改红 on 2021/4/29.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugMsgShortageChatListController.h"
#import "RCDDebugMsgShortageChatController.h"

@interface RCDDebugMsgShortageChatListController ()

@end

@implementation RCDDebugMsgShortageChatListController
- (id)init {
    self = [super init];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[
            @(ConversationType_PRIVATE),
            @(ConversationType_APPSERVICE),
            @(ConversationType_PUBLICSERVICE),
            @(ConversationType_GROUP),
            @(ConversationType_SYSTEM)
        ]];
        //聚合会话类型
        [self setCollectionConversationType:@[ @(ConversationType_SYSTEM) ]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath{
    RCDDebugMsgShortageChatController *chatVC = [[RCDDebugMsgShortageChatController alloc] init];
    chatVC.conversationType = model.conversationType;
    chatVC.targetId = model.targetId;
    chatVC.title = model.conversationTitle;
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        chatVC.unReadMessage = model.unreadMessageCount;
        chatVC.enableNewComingMessageIcon = YES; //开启消息提醒
        chatVC.enableUnreadMessageIcon = YES;
        if (model.conversationType == ConversationType_SYSTEM) {
            chatVC.title = RCDLocalizedString(@"de_actionbar_sub_system");
        } else if (model.conversationType == ConversationType_PRIVATE) {
            chatVC.displayUserNameInCell = NO;
        }
    }
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
