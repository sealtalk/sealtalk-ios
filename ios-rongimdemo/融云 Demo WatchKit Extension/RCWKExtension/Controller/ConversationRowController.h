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
@property (weak, nonatomic) IBOutlet WKInterfaceImage *headIcon;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *name;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *lastMsg;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *dateLable;

@end
