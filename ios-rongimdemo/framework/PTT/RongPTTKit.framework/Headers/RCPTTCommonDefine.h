//
//  RCPTTCommonDefine.h
//  RongPTTKit
//
//  Created by Sin on 16/12/27.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#ifndef RCPTTCommonDefine_h
#define RCPTTCommonDefine_h

#import <UIKit/UIKit.h>

// RCPTTStatusView状态需要发生改变的时候会post该通知
static NSString *RCPTTStatusViewStatusChangeNotification = @"RCPTTStatusViewStatusChangeNotification";

typedef NS_ENUM(NSUInteger, RCPTTStatus) { RCPTTStatusTalking };

#endif /* RCPTTCommonDefine_h */
