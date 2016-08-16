//
//  ConversationListController.m
//  RongIMDemo
//
//  Created by litao on 17/3/25.
//  Copyright (c) 2017年 RongCloud. All rights reserved.
//

#import "ConversationListController.h"
#import <RongIMLib/RongIMLib.h>
#import "ConversationRowController.h"
#import "RCAppQueryHelper.h"
#import "RCAppInfoModel.h"
#import "RCWKNotificationCenter.h"
#import "RCWKUtility.h"
#import <RongIMLib/RongIMLib.h>

@interface ConversationListController () <RCWKNotificationObserver>
@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (strong, nonatomic)NSArray *conversations;
@property (nonatomic)BOOL needLoadAtWillActivity;
@end

@implementation ConversationListController
- (void)loadContactFromApp
{
    if (![RCAppInfoModel sharedModel].contacts.count) {
        [RCAppQueryHelper queryParentAppContacts:^(NSArray *contacts) {
            NSLog(@"contact loaded");
            [RCAppInfoModel sharedModel].contacts = contacts;
            [RCAppQueryHelper queryParentAppGroupInfos:^(NSArray *groups) {
                [RCAppInfoModel sharedModel].groups = groups;
                [self updateTable];
            }];
        }];

    }
}

- (void)setConversations:(NSArray *)conversations
{
    if (conversations) {
        _conversations = conversations;
        [self updateTable];
    }
}

- (void)loadDataFromApp
{
    NSArray *conversationTypes = @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)];
    [RCAppQueryHelper queryParentAppConversationListByType:conversationTypes reply:^(NSArray *conversationList) {
        if (conversationList) {
            self.conversations = conversationList;
            [self updateTable];
        } else {
            NSLog(@"failure get data from app");
        }
    }];
}

- (instancetype)init {
    self = [super init];
    [RCAppQueryHelper requestParentAppOpen];
    NSLog(@"conversationListController init");
    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        // Retrieve the data. This could be accessed from the iOS app via a shared container.
        [self loadDataFromApp];
        self.needLoadAtWillActivity = NO;
    }
    
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [self setTitle:@"会话"];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [[RCWKNotificationCenter defaultCenter] addConnectionStatusObserver:self];
    [[RCWKNotificationCenter defaultCenter] addMessageChangeObserver:self];
    [[RCWKNotificationCenter defaultCenter] addUserInfoChangeObserver:self];
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
    [[RCWKNotificationCenter defaultCenter] removeUserInfoChangeObserver:self];
    [RCAppQueryHelper requestParentAppNotification:NO];
    self.needLoadAtWillActivity = YES;
}
- (void)onMessageChangedEvent
{
    [self loadDataFromApp];
}
- (void)onUserInfoChangedEvent
{
    [self loadContactFromApp];
}
- (void)onConnectionStatusChangedEvent
{
    [RCAppQueryHelper queryParentAppConnectionStatus:^(BOOL isConnected) {
        if (!isConnected) {
            [self popToRootController];
        }
    }];
}
- (BOOL)isHeadIconCached:(NSString *)targetId
{
    NSDictionary *cachedHeadIcons = [[WKInterfaceDevice currentDevice] cachedImages];
    NSNumber *size = cachedHeadIcons[targetId];
            NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerUrl = [fileManager containerURLForSecurityApplicationGroupIdentifier:[RCAppInfoModel sharedModel].appGroups];
    containerUrl = [containerUrl URLByAppendingPathComponent:targetId];
    NSLog(@"the url is %@", containerUrl);
    
    if ([size intValue]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *containerUrl = [fileManager containerURLForSecurityApplicationGroupIdentifier:[RCAppInfoModel sharedModel].appGroups];
        containerUrl = [containerUrl URLByAppendingPathComponent:targetId];
        NSLog(@"the url is %@", containerUrl);
        return YES;
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *containerUrl = [fileManager containerURLForSecurityApplicationGroupIdentifier:[RCAppInfoModel sharedModel].appGroups];
        containerUrl = [containerUrl URLByAppendingPathComponent:targetId];
        if ([fileManager fileExistsAtPath:[containerUrl path]]) {
            NSData *data = [NSData dataWithContentsOfURL:containerUrl];
            UIImage *image = [UIImage imageWithData:data];
            return [[WKInterfaceDevice currentDevice] addCachedImage:image name:targetId];
        }
    }
    return NO;
}
- (void)updateTable
{

    [self.tableView setNumberOfRows:self.conversations.count withRowType:@"default"];
    [self.conversations enumerateObjectsUsingBlock:^(RCConversation *conversation, NSUInteger idx, BOOL *stop){
        ConversationRowController *row = [self.tableView rowControllerAtIndex:idx];
        NSLog(@"targetID is %@", conversation.targetId);
        if (conversation.conversationType == ConversationType_PRIVATE ||
            conversation.conversationType == ConversationType_APPSERVICE ||
            conversation.conversationType == ConversationType_PUBLICSERVICE) {
            NSString *userName = [RCAppInfoModel getUserInfoById:conversation.targetId].name;
            if (!userName && conversation.conversationTitle) {
                userName = conversation.conversationTitle;
            }
            if (!userName || !userName.length) {
                userName = [NSString stringWithFormat:@"User(%@)", conversation.targetId];
            }
            [row.name setText:userName];
        } else if (conversation.conversationType == ConversationType_GROUP) {
            NSString *groupName = [RCAppInfoModel getGroupInfoById:conversation.targetId].groupName;
            if (!groupName && conversation.conversationTitle) {
                groupName = conversation.conversationTitle;
            }
            if (!groupName || !groupName.length) {
                groupName = [NSString stringWithFormat:@"Group(%@)", conversation.targetId];
                conversation.conversationTitle = groupName;
            }
            conversation.conversationTitle = groupName;
            [row.name setText:groupName];
            
        } else {
            [row.name setText:conversation.conversationTitle];
        }
        if (conversation.conversationType == ConversationType_PRIVATE ||
            conversation.conversationType == ConversationType_APPSERVICE ||
            conversation.conversationType == ConversationType_PUBLICSERVICE) {
            if ([self isHeadIconCached:conversation.targetId]) {
                [row.headIcon setImageNamed:conversation.targetId];
            } else {
                [row.headIcon setImageNamed:@"watchd_efault_portrait"];
                [RCAppQueryHelper requestParentAppCacheHeadIcon:conversation.conversationType targetId:conversation.targetId];
            }
        } else if (conversation.conversationType == ConversationType_DISCUSSION) {
            [row.headIcon setImageNamed:@"watch_default_discussion_portrait"];
        } else if (conversation.conversationType == ConversationType_GROUP) {
            [row.headIcon setImageNamed:@"watch_default_group_portrait"];
        } else {
            [row.headIcon setImageNamed:@"watchd_efault_portrait"];
        }
        
        if ([conversation.lastestMessage respondsToSelector:@selector(conversationDigest)]) {
            NSString *digest = [conversation.lastestMessage performSelector:@selector(conversationDigest)];
            [row.lastMsg setText:digest];
        } else if ([conversation.lastestMessage isKindOfClass:[RCTextMessage class]]) {
            RCTextMessage *textMsg = (RCTextMessage *)conversation.lastestMessage;
            [row.lastMsg setText:textMsg.content];
        } else if ([conversation.lastestMessage isKindOfClass:[RCImageMessage class]]) {
            [row.lastMsg setText:@"[图片]"];
        } else if ([conversation.lastestMessage isKindOfClass:[RCVoiceMessage class]]) {
            [row.lastMsg setText:@"[语音]"];
        } else if ([conversation.lastestMessage isKindOfClass:[RCLocationMessage class]]) {
            [row.lastMsg setText:@"[位置]"];
        } else if ([conversation.lastestMessage isKindOfClass:[RCDiscussionNotificationMessage class]]) {
            NSString *notifyString = [RCWKUtility formatDiscussionNotificationMessageContent:(RCDiscussionNotificationMessage *)conversation.lastestMessage];
            [row.lastMsg setText:notifyString];
        } else {
            [row.lastMsg setText:@"[不支持消息]"];
        }
    }];
}

+(NSString*)ConvertChatMessageTime:(long long)secs{
    NSString *timeText=nil;
    
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:secs/1000];
    
    //    DebugLog(@"messageDate==>%@",messageDate);
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM:dd"];
    
    NSString *strMsgDay = [formatter stringFromDate:messageDate];
    
    NSDate *now = [NSDate date];
    NSString* strToday = [formatter stringFromDate:now];
    NSDate *yesterday = [[NSDate alloc] initWithTimeIntervalSinceNow:-(24*60*60)];
    NSString *strYesterday = [formatter stringFromDate:yesterday];
    
    if ([strMsgDay isEqualToString:strToday]) {
        [formatter setDateFormat:@"HH':'mm"];
    }else if([strMsgDay isEqualToString:strYesterday]){
        [formatter setDateFormat:@"昨天"];
    }
    else
    {
        [formatter setDateFormat:@"MM-dd"];
    }
    timeText = [formatter stringFromDate:messageDate];
    
    return timeText;
}
- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    RCConversation *conversation = self.conversations[rowIndex];
    [self pushControllerWithName:@"Conversation" context:conversation];
}

@end
