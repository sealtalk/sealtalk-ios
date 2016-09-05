//
//  SettingsController.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@interface SettingsController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceSwitch *sound;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *quit;
@end
