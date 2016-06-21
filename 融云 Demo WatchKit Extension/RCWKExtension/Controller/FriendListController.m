//
//  FriendListController.m
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "FriendListController.h"
#import "RCAppQueryHelper.h"
#import "FriendRowController.h"
#import <RongIMLib/RongIMLib.h>
#import "RCWKNotificationCenter.h"
#import "RCAppInfoModel.h"

@interface FriendListController () <RCWKNotificationObserver>
@property (weak, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (strong, nonatomic)NSArray *contacts;
@end

@implementation FriendListController

- (void)loadFriendsFromApp
{
    [RCAppQueryHelper queryParentAppFriends:^(NSArray *contacts) {
        self.contacts = contacts;
    }];
}

- (void)setContacts:(NSArray *)contacts
{
    if (contacts) {
        _contacts = contacts;
        [self updateTable];
    }
}

- (instancetype)init {
    self = [super init];
    NSLog(@"conversationListController init");
    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        // Retrieve the data. This could be accessed from the iOS app via a shared container.
        [self loadFriendsFromApp];
    }
    
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [self setTitle:@"好友"];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [[RCWKNotificationCenter defaultCenter] addConnectionStatusObserver:self];
    [[RCWKNotificationCenter defaultCenter] addFriendChangeObserver:self];
    [RCAppQueryHelper requestParentAppNotification:YES];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [[RCWKNotificationCenter defaultCenter] removeConnectionStatusObserver:self];
    [[RCWKNotificationCenter defaultCenter] removeFriendChangeObserver:self];
    [RCAppQueryHelper requestParentAppNotification:NO];
}

- (void)onFriendChangedEvent
{
    [self loadFriendsFromApp];
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
    if ([size intValue]) {
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
    [self.tableView setNumberOfRows:self.contacts.count withRowType:@"friendRow"];
    [self.contacts enumerateObjectsUsingBlock:^(RCUserInfo *conversation, NSUInteger idx, BOOL *stop) {
        FriendRowController *row = [self.tableView rowControllerAtIndex:idx];
        if ([self isHeadIconCached:conversation.userId]) {
            [row.header setImageNamed:conversation.userId];
        } else {
            [row.header setImageNamed:@"header"];
        }
        [row.name setText:conversation.name];
        NSLog(@"row is %@", conversation.name);
    }];
}
- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    RCUserInfo *userinfo = self.contacts[rowIndex];
    RCConversation *conversation = [[RCConversation alloc] init];
    conversation.targetId = userinfo.userId;
    conversation.conversationTitle = userinfo.name;
    conversation.conversationType = ConversationType_PRIVATE;
    NSLog(@"target id is %@", userinfo.userId);
    [self pushControllerWithName:@"Conversation" context:conversation];
}
@end
