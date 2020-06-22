//
//  ImageMessageRow.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "ImageMessageRow.h"

@implementation ImageMessageRow
- (void)setMessage:(RCMessage *)message {
  [super setMessage:message];
  RCImageMessage *imgMsg = (RCImageMessage *)message.content;
  [self.imageView setImage:imgMsg.thumbnailImage];
}
@end
