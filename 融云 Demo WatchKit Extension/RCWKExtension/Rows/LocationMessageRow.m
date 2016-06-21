//
//  LocationMessageRow.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/29.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "LocationMessageRow.h"

@implementation LocationMessageRow
- (void)setMessage:(RCMessage *)message {
  [super setMessage:message];
  RCLocationMessage *locMsg = (RCLocationMessage *)message.content;
  [self.locationThumbnail setImage:locMsg.thumbnailImage];
}
@end
