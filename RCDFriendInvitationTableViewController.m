//
//  RCDFriendInvitationTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/7/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDFriendInvitationTableViewController.h"
#import "RCDFriendInvitationTableViewCell.h"

@interface RCDFriendInvitationTableViewController ()
@property (nonatomic, strong)NSMutableArray *messageArray;
@end

@implementation RCDFriendInvitationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.messageArray = [[[RCIMClient sharedRCIMClient] getLatestMessages:self.conversationType
                                            targetId:self.targetId
                                               count:30] mutableCopy];
    
    __block RCDFriendInvitationTableViewController *weakSelf = self;
    [self.messageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RCMessage *message = obj;
        if (![message.content isKindOfClass:[RCContactNotificationMessage class]]) {
            [weakSelf.messageArray removeObject:obj];
        } else if (![((RCContactNotificationMessage *)message.content).operation isEqualToString:ContactNotificationMessage_ContactOperationRequest]) {
            [weakSelf.messageArray removeObject:obj];
        }
    }];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        RCMessage *message = self.messageArray[indexPath.row];
        
        if ([[RCIMClient sharedRCIMClient] deleteMessages:@[[NSNumber numberWithLong:message.messageId]]]) {
            
            [self.messageArray removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                               withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            NSLog(@"删除失败，请重试");
        }
        
        if (0 == self.messageArray.count) {
            
            // 删除会话列表
            [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_SYSTEM targetId:self.targetId];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDFriendInvitationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rCDFriendInvitationTableViewCellIdentifier" forIndexPath:indexPath];
    
    [cell setModel:self.messageArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

@end
