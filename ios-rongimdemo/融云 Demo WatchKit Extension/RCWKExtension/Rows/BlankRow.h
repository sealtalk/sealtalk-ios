//
//  BlankRow.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/29.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlankRow : NSObject
- (void)setMessage:(RCMessage *)message;
- (void)rowSelected:(RCMessage *)message;
@end
