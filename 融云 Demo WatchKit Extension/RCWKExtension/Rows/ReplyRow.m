//
//  ReplyRow.m
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "ReplyRow.h"

@implementation ReplyRow
- (IBAction)replyVoice {
  [self.controller replyVoice];
}

- (IBAction)replyText {
  [self.controller replyText];
}
@end
