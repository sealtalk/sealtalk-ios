//
//  RCAppSharedUserDefault.m
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCAppSharedUserDefault.h"
#import "RCWKAPPCommonDefine.h"

@implementation RCAppSharedUserDefault
+ (id)getSharedDefaultObjectForKey:(NSString *)key {
  NSUserDefaults *shared =
      [[NSUserDefaults alloc] initWithSuiteName:@"group.rcdemo"];
  NSString *value = [shared valueForKey:key];
  return value;
}
@end
