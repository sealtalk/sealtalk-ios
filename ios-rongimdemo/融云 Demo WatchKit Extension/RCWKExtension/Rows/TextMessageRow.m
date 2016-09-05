//
//  TextMessageRow.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "TextMessageRow.h"

@implementation TextMessageRow
- (void)setMessage:(RCMessage *)message {
  [super setMessage:message];
  RCTextMessage *txtMsg = (RCTextMessage *)message.content;
  [self.contentLabel setText:txtMsg.content];
}
@end
