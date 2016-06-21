//
//  ReplyRow.h
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversationController.h"
// controller identifier in interface.storyboard
#define REPLY_ROW_CONTROLLER_IDENTIFIER @"replyRow"

@interface ReplyRow : NSObject
@property(nonatomic, weak) ConversationController *controller;
@end
