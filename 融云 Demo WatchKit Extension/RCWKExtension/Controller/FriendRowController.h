//
//  FriendRowController.h
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface FriendRowController : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceImage *header;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *name;

@end
