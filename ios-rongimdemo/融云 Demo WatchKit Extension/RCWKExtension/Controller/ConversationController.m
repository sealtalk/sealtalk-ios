//
//  ConversationController.m
//  RongIMDemo
//
//  Created by litao on 17/3/26.
//  Copyright (c) 2017年 RongCloud. All rights reserved.
//

#import "ConversationController.h"
#import "RCAppQueryHelper.h"
#import <RongIMLib/RongIMLib.h>
#import "ReplyRow.h"
#import "RCAppInfoModel.h"
#import "ConversationRowBase.h"
#import "RCWKNotificationCenter.h"

@interface ConversationController () <RCWKNotificationObserver>
@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (nonatomic, strong)NSMutableArray *contents; //of RCMessage
@property (nonatomic, strong)RCConversation *conversation;
@property (nonatomic)BOOL needLoadAtWillActivity;
@end

//controller identifier in interface.storyboard
#define SENT_TEXT_ROW_CONTROLLER_IDENTIFIER @"sentTextRow"
#define RECEIVED_TEXT_ROW_CONTROLLER_IDENTIFIER @"rcvdTextRow"
#define SENT_IMAGE_ROW_CONTROLLER_IDENTIFIER @"sentImageRow"
#define RECEIVED_IMAGE_ROW_CONTROLLER_IDENTIFIER @"rcvdImageRow"
#define SENT_LOCATION_ROW_CONTROLLER_IDENTIFIER @"sentLocationRow"
#define RECEIVED_LOCATION_ROW_CONTROLLER_IDENTIFIER @"rcvdLocationRow"
#define SENT_VOICE_ROW_CONTROLLER_IDENTIFIER @"sentVoiceRow"
#define RECEIVED_VOICE_ROW_CONTROLLER_IDENTIFIER @"rcvdVoiceRow"
#define SENT_UNKNOWN_MSG_ROW_CONTROLLER_IDENTIFIER @"sentUnknownMsgRow"
#define RECEIVED_UNKNOWN_MSG_ROW_CONTROLLER_IDENTIFIER @"rcvdUnknownMsgRow"
#define REPLY_ROW_CONTROLLER_IDENTIFIER @"replyRow"
#define BLANK_ROW_CONTROLLER_IDENTIFIER @"blankRow"
#define RECEIVED_DISCUSSION_NOTIFICATION_ROW_CONTROLLER_IDENTIFIER @"rcvdDiscussionNotificationRow"
@interface RCBlankContent : RCMessageContent
@end

@implementation RCBlankContent
@end

@implementation ConversationController
- (instancetype)init {
    self = [super init];
    NSLog(@"conversationController init");
    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        self.needLoadAtWillActivity = NO;

    }
    return self;
}

- (NSMutableArray *)contents
{
    if (!_contents) {
        _contents = [[NSMutableArray alloc] init];
    }
    return _contents;
}
- (void)replyText {
    NSArray* initialPhrases = @[@"好", @"呵呵", @"谢谢", @"再见",@"顶", @"现在忙，一会儿再聊"];
    NSLog(@"reply pressed!");
    [self presentTextInputControllerWithSuggestions:initialPhrases
                                   allowedInputMode:WKTextInputModeAllowAnimatedEmoji
                                         completion:^(NSArray *results) {
        NSLog(@"the input result is %@", results);
        if (results.count && [results[0] isKindOfClass:[NSString class]]) {
            [RCAppQueryHelper requestParentAppSendTxtMsg:self.conversation.targetId
                                                 type:self.conversation.conversationType
                                              content:results[0]
                                                reply:^(BOOL sendToLib) {
                if (sendToLib) {
                    [self loadDataFromApp];
                } else {
                    NSLog(@"Send to app failure");
                }
            }];
        }
    }];
}

- (void)replyVoice {
    [self presentControllerWithName:@"voice input controller" context:self.conversation];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    self.conversation = context;
    
    if (self.conversation.conversationType == ConversationType_PRIVATE) {
        NSString *userName = [RCAppInfoModel getUserInfoById:self.conversation.targetId].name;
        if (userName) {
            [self setTitle:userName];
        } else {
            [self setTitle:[NSString stringWithFormat:@"用户(%@)", self.conversation.targetId]];
        }
    } else {
        [self setTitle:self.conversation.conversationTitle];
    }

    
    // Retrieve the data. This could be accessed from the iOS app via a shared container.
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    [self.tableView insertRowsAtIndexes:indexSet withRowType:REPLY_ROW_CONTROLLER_IDENTIFIER];
    ReplyRow *replyRow = [self.tableView rowControllerAtIndex:0];
    replyRow.controller = self;
    [self loadDataFromApp];

}
- (void)loadDataFromApp
{
    [RCAppQueryHelper queryParentAppConversation:self.conversation.targetId type:self.conversation.conversationType olderMsgId:-1 count:6 reply:^(NSArray *messages) {
        if (messages) {
            if (self.contents.count == 0 && messages.count < 4) {
                NSMutableArray *modifiedMessages = [messages mutableCopy];
                RCMessage *blankMsg = [RCMessage new];
                blankMsg.content = [RCBlankContent new];
                blankMsg.messageId = -1;
                [modifiedMessages addObject:blankMsg];
                [self updateTable:modifiedMessages];
            } else {
                [self updateTable:messages];
            }
        } else {
            NSLog(@"failure get data from app");
        }
    }];
}
- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [[RCWKNotificationCenter defaultCenter] addConnectionStatusObserver:self];
    [[RCWKNotificationCenter defaultCenter] addMessageChangeObserver:self];
    [RCAppQueryHelper requestParentAppNotification:YES];
    if (self.needLoadAtWillActivity) {
        [self loadDataFromApp];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [[RCWKNotificationCenter defaultCenter] removeConnectionStatusObserver:self];
    [[RCWKNotificationCenter defaultCenter] removeMessageChangeObserver:self];
    [RCAppQueryHelper requestParentAppNotification:NO];
    self.needLoadAtWillActivity = YES;
}
- (void)onMessageChangedEvent
{
    [self loadDataFromApp];
}

- (void)onConnectionStatusChangedEvent
{
    [RCAppQueryHelper queryParentAppConnectionStatus:^(BOOL isConnected) {
        if (!isConnected) {
            [self popToRootController];
        }
    }];
}
/*

 */

- (NSString *)getRowType:(RCMessage *)message
{
    if ([message.content isKindOfClass:[RCTextMessage class]]) {
        if (message.messageDirection == MessageDirection_SEND) {
            return SENT_TEXT_ROW_CONTROLLER_IDENTIFIER;
        } else {
            return RECEIVED_TEXT_ROW_CONTROLLER_IDENTIFIER;
        }
    } else if ([message.content isKindOfClass:[RCImageMessage class]]) {
        if (message.messageDirection == MessageDirection_SEND) {
            return SENT_IMAGE_ROW_CONTROLLER_IDENTIFIER;
        } else {
            return RECEIVED_IMAGE_ROW_CONTROLLER_IDENTIFIER;
        }
    } else if ([message.content isKindOfClass:[RCLocationMessage class]]) {
        if (message.messageDirection == MessageDirection_SEND) {
            return SENT_LOCATION_ROW_CONTROLLER_IDENTIFIER;
        } else {
            return RECEIVED_LOCATION_ROW_CONTROLLER_IDENTIFIER;
        }
    } else if ([message.content isKindOfClass:[RCVoiceMessage class]]) {
        if (message.messageDirection == MessageDirection_SEND) {
            return SENT_VOICE_ROW_CONTROLLER_IDENTIFIER;
        } else {
            return RECEIVED_VOICE_ROW_CONTROLLER_IDENTIFIER;
        }
    } else if ([message.content isMemberOfClass:[RCBlankContent class]]) {
        return BLANK_ROW_CONTROLLER_IDENTIFIER;
    } else if ([message.content isKindOfClass:[RCDiscussionNotificationMessage class]]) {
        return RECEIVED_DISCUSSION_NOTIFICATION_ROW_CONTROLLER_IDENTIFIER;
    } else {
        if (message.messageDirection == MessageDirection_SEND) {
            return SENT_UNKNOWN_MSG_ROW_CONTROLLER_IDENTIFIER;
        } else {
            return RECEIVED_UNKNOWN_MSG_ROW_CONTROLLER_IDENTIFIER;
        }
    }

}
- (void)updateTable:(NSArray *)loadedContents
{
    int offset = (int)loadedContents.count;
    NSLog(@"loadedcontents size is %d", offset);
    if (self.contents.count > 0) {
        RCMessage *lastMsg = self.contents[0];
        for (int i = 0; i < loadedContents.count; i++) {
            RCMessage *loadMsg = loadedContents[i];
            if (lastMsg.messageId >= loadMsg.messageId) {
                offset = i;
                break;
            }
        }
    }

    NSLog(@"offset is %d", offset);
    int lastUpdateRows = (int)[self.tableView numberOfRows];
    if (lastUpdateRows > 0) {
        lastUpdateRows = lastUpdateRows - 1;
    }
    for (int i = 0; i < offset; i++) {
        RCMessage *message = loadedContents[offset - i - 1];
        NSInteger index = lastUpdateRows + i;
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:index];
        [self.contents insertObject:message atIndex:0];
        
        NSLog(@"self contents size is %ld", self.contents.count);
        
        NSString *identifier = [self getRowType:message];
        [self.tableView insertRowsAtIndexes:indexSet withRowType:identifier];
        ConversationRowBase *row = [self.tableView rowControllerAtIndex:index];
        [row setMessage:message];

    }

    if (offset > 0 && [self.tableView numberOfRows] > 0){
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(scrollToButtom) withObject:nil afterDelay:0.1f];
            });
        NSLog(@"try scroll to the last one");
    }
    NSLog(@"row number is %ld", (long)[self.tableView numberOfRows]);
}


- (void)scrollToButtom
{
    NSLog(@"scroll to row :%ld", [self.tableView numberOfRows] - 1);
    [self.tableView scrollToRowAtIndex:[self.tableView numberOfRows]-1];
}
- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    //self presentControllerWithName:<#(NSString *)#> context:<#(id)#>
    RCMessage *msg = self.contents[self.contents.count - rowIndex - 1];
    NSLog(@"msg object name is %@, index %ld", msg.objectName, rowIndex);
    if ([msg.content isKindOfClass:[RCVoiceMessage class]]) {
        ConversationRowBase *row = [self.tableView rowControllerAtIndex:rowIndex];
        [row rowSelected:msg];
    } else if ([msg.content isKindOfClass:[RCLocationMessage class]]) {
        RCLocationMessage *locationMsg = (RCLocationMessage *)msg.content;
        [self presentControllerWithName:@"location view" context:locationMsg];
    } else if ([msg.content isKindOfClass:[RCImageMessage class]]) {
        NSLog(@"pic pressed");
        RCImageMessage *imageMsg = (RCImageMessage *)msg.content;
        NSLog(@"image size is nil %d", imageMsg.originalImage == nil);
        [self presentControllerWithName:@"image view" context:msg];
    }
}
@end
