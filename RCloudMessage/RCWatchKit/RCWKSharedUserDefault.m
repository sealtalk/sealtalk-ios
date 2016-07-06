//
//  RCWKSharedUserDefault.m
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//
#import "RCWKAPPCommonDefine.h"
#import "RCWKAppInfoProvider.h"
#import "RCWKSharedUserDefault.h"
#import <UIKit/UIKit.h>

@implementation RCWKSharedUserDefault
+ (void)setSharedDefaultObject:(id)object forKey:(NSString *)key {
  id<RCWKAppInfoProvider> appInfoProvider =
      (id<RCWKAppInfoProvider>)[UIApplication sharedApplication].delegate;
  NSUserDefaults *shared =
      [[NSUserDefaults alloc] initWithSuiteName:[appInfoProvider getAppGroups]];
  [shared setObject:object forKey:key];
  [shared synchronize];
}
@end
