//
//  ConversationRowController.h
//  RongIMDemo
//
//  Created by litao on 17/3/25.
//  Copyright (c) 2017年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WatchKit;

@interface ConversationRowController : NSObject
@property (weak, nonatomic) WKInterfaceImage *headIcon;
@property (weak, nonatomic) WKInterfaceLabel *name;
@property (weak, nonatomic) WKInterfaceLabel *lastMsg;
@property (weak, nonatomic) WKInterfaceLabel *dateLable;

@end
