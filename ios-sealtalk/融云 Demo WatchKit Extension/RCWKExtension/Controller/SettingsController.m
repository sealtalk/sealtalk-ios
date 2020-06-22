//
//  SettingsController.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "SettingsController.h"
#import "RCAppQueryHelper.h"

@implementation SettingsController
- (instancetype)init {
  self = [super init];

  if (self) {
    [RCAppQueryHelper queryParentAppNewMsgSound:^(BOOL on) {
      [self.sound setOn:on];
    }];
  }
  return self;
}
- (IBAction)onSoundSwitch:(BOOL)value {
  [RCAppQueryHelper setParentAppNewMsgSound:value];
  [self.sound setOn:value];
}
- (IBAction)onLogoutButton {
  [RCAppQueryHelper requestParentAppLogout];
  [self popToRootController];
}

- (void)willActivate {
  [self setTitle:@"设置"];
}
@end
