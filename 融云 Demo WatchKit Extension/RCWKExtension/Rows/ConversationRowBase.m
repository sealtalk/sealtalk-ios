//
//  ConversationRowBase.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "ConversationRowBase.h"
#import "RCAppInfoModel.h"

@implementation ConversationRowBase
- (void)setMessage:(RCMessage *)message {
  UIImage *image;

  if (message.messageDirection == MessageDirection_RECEIVE) {
    NSString *userName =
        [RCAppInfoModel getUserInfoById:message.senderUserId].name;
    if (!userName) {
      userName = [NSString stringWithFormat:@"User(%@)", message.senderUserId];
    }
    [self.name setText:userName];
      if (![message.content isKindOfClass:[RCImageMessage class]] &&
          ![message.content isKindOfClass:[RCLocationMessage class]]) {
          image = [UIImage imageNamed:@"watchbubbleleft"];
      }
    
  } else {
      if (![message.content isKindOfClass:[RCImageMessage class]] &&
          ![message.content isKindOfClass:[RCLocationMessage class]]) {
          image = [UIImage imageNamed:@"watchbubbleright"];
      }

  }

  NSLog(@"image size is (%f, %f)", image.size.width, image.size.height);
  image = [image
      resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 + 3,
                                                   image.size.width / 2,
                                                   image.size.height / 2 + 3,
                                                   image.size.width / 2)];
  [self.bgGroup setBackgroundImage:image];

  if ([RCAppInfoModel isHeadIconCached:message.senderUserId]) {
    [self.header setImageNamed:message.senderUserId];
  } else {
    [self.header setImageNamed:@"watchd_efault_portrait"];
  }
}
- (void)rowSelected:(RCMessage *)message {
}
@end
