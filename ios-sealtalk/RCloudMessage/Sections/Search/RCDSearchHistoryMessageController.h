//
//  RCDSearchHistoryMessageController.h
//  RCloudMessage
//
//  Created by 张改红 on 16/10/13.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RCDTableViewController.h"
@interface RCDSearchHistoryMessageController : RCDTableViewController
/*!
 当前会话的会话类型
 */
@property (nonatomic, assign) RCConversationType conversationType;

/*!
 目标会话ID
 */
@property (nonatomic, strong) NSString *targetId;
@end
