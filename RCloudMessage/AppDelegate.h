//
//  AppDelegate.h
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, RCIMConnectionStatusDelegate,RCIMReceiveMessageDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

