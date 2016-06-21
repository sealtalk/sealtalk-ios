//
//  RCAppInfoModel.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/16.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCAppInfoModel.h"
#import "RCWKNotificationCenter.h"
#import <WatchKit/WatchKit.h>

@interface RCAppInfoModel () <RCWKNotificationObserver>

@end

@implementation RCAppInfoModel
+ (instancetype)sharedModel {
  static RCAppInfoModel *pDefaultClient;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (pDefaultClient == nil) {
      pDefaultClient = [[RCAppInfoModel alloc] init];
      [[RCWKNotificationCenter defaultCenter]
          addLoadImageObserver:pDefaultClient];
    }
  });

  return pDefaultClient;
}
+ (RCUserInfo *)getUserInfoById:(NSString *)userId {
  for (RCUserInfo *info in [RCAppInfoModel sharedModel].contacts) {
    if ([info.userId isEqualToString:userId]) {
      return info;
    }
  }
  return nil;
}
+ (RCGroup *)getGroupInfoById:(NSString *)groupId {
    for (RCGroup *info in [RCAppInfoModel sharedModel].groups) {
        if ([info.groupId isEqualToString:groupId]) {
            return info;
        }
    }
    return nil;
}
- (void)onLoadImageDoneEvent:(NSString *)userID {
  if (!userID) {
    return;
  }
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *containerUrl =
      [fileManager containerURLForSecurityApplicationGroupIdentifier:
                       [RCAppInfoModel sharedModel].appGroups];
  containerUrl = [containerUrl URLByAppendingPathComponent:userID];
  NSData *data = [NSData dataWithContentsOfURL:containerUrl];
  UIImage *image = [UIImage imageWithData:data];
  [[WKInterfaceDevice currentDevice] addCachedImage:image name:userID];
}
+ (BOOL)isHeadIconCached:(NSString *)targetId {
  NSDictionary *cachedHeadIcons =
      [[WKInterfaceDevice currentDevice] cachedImages];
  NSNumber *size = cachedHeadIcons[targetId];
  if ([size intValue]) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerUrl =
        [fileManager containerURLForSecurityApplicationGroupIdentifier:
                         [RCAppInfoModel sharedModel].appGroups];
    containerUrl = [containerUrl URLByAppendingPathComponent:targetId];
    NSLog(@"the url is %@", containerUrl);
    return YES;
  } else {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerUrl =
        [fileManager containerURLForSecurityApplicationGroupIdentifier:
                         [RCAppInfoModel sharedModel].appGroups];
    containerUrl = [containerUrl URLByAppendingPathComponent:targetId];
    if ([fileManager fileExistsAtPath:[containerUrl path]]) {
      NSData *data = [NSData dataWithContentsOfURL:containerUrl];
      UIImage *image = [UIImage imageWithData:data];
      return [[WKInterfaceDevice currentDevice] addCachedImage:image
                                                          name:targetId];
    }
  }
  return NO;
}
@end
