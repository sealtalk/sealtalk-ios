//
//  DiscussionNotificationRow.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "DiscussionNotificationRow.h"
#import "RCWKUtility.h"

@implementation DiscussionNotificationRow
- (void)setMessage:(RCMessage *)message {
  RCDiscussionNotificationMessage *notification =
      (RCDiscussionNotificationMessage *)message.content;
  NSString *notifyString =
      [RCWKUtility formatDiscussionNotificationMessageContent:notification];
  [self.notifationLabel setText:notifyString];
}
- (void)rowSelected:(RCMessage *)message {
}
@end
