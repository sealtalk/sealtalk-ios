//
//  DiscussionNotificationRow.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import <WatchKit/WatchKit.h>

@interface DiscussionNotificationRow : NSObject
- (void)setMessage:(RCMessage *)message;
- (void)rowSelected:(RCMessage *)message;
@property(weak, nonatomic) IBOutlet WKInterfaceLabel *notifationLabel;
@end
