//
//  RCDDebugChatListViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2020/12/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugChatListViewController.h"
#import "RCDDebugChatViewController.h"

@interface RCDDebugChatListViewController ()

@end

@implementation RCDDebugChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE ||
        conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        [self pushChatViewController:model];
    } else {
        [super onSelectedTableRow:conversationModelType conversationModel:model atIndexPath:indexPath];
    }
}

- (void)pushChatViewController:(RCConversationModel *)model {
    
    RCDDebugChatViewController *chatVC = [[RCDDebugChatViewController alloc] init];
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
