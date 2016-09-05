//
//  RCWKUtility.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@interface RCWKUtility : NSObject
+ (NSString *)formatDiscussionNotificationMessageContent:
    (RCDiscussionNotificationMessage *)discussionNotification;
@end
