//
//  RCDFriendInvitationTableViewController.h
//  RCloudMessage
//
//  Created by litao on 15/7/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import <UIKit/UIKit.h>

@interface RCDFriendInvitationTableViewController : UITableViewController
/**
 *  targetId
 */
@property(nonatomic, strong) NSString *targetId;
/**
 *  targetName
 */
@property(nonatomic, strong) NSString *userName;
/**
 *  conversationType
 */
@property(nonatomic) RCConversationType conversationType;
/**
 * model
 */
@property(strong, nonatomic) RCConversationModel *conversation;
@end
