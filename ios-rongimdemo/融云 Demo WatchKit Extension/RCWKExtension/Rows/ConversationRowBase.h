//
//  ConversationRowBase.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <RongIMLib/RongIMLib.h>

@interface ConversationRowBase : NSObject
@property(weak, nonatomic) IBOutlet WKInterfaceImage *header;
@property(weak, nonatomic) IBOutlet WKInterfaceGroup *bgGroup;
@property(weak, nonatomic) IBOutlet WKInterfaceLabel *name;
- (void)setMessage:(RCMessage *)message;
- (void)rowSelected:(RCMessage *)message;
@end
