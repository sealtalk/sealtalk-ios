//  RCWKNotificationCenter.m
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCWKNotificationCenter.h"
#import "RCWKAPPCommonDefine.h"
#import "RCAppSharedUserDefault.h"

static void RCAppNotificationCallback(CFNotificationCenterRef center,
                                      void *observer, CFStringRef name,
                                      const void *object,
                                      CFDictionaryRef userInfo)

{
  NSString *notifyName = (__bridge NSString *)name;
  [[RCWKNotificationCenter defaultCenter] notifyEvent:notifyName];
}

@interface RCWKNotificationCenter ()
@property(strong, nonatomic) NSMutableDictionary *observers;
@end

@implementation RCWKNotificationCenter
+ (instancetype)defaultCenter {
  static RCWKNotificationCenter *pDefaultCenter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (pDefaultCenter == nil) {
      pDefaultCenter = [[RCWKNotificationCenter alloc] init];
    }
  });
  return pDefaultCenter;
}

- (NSMutableDictionary *)observers {
  if (!_observers) {
    _observers = [[NSMutableDictionary alloc] init];
  }
  return _observers;
}

- (void)addMessageChangeObserver:(id<RCWKNotificationObserver>)observer {
  [self addOtherObserver:observer event:RC_MESSAGE_CHANGED_EVENT];
}

- (void)removeMessageChangeObserver:(id<RCWKNotificationObserver>)observer {
  [self removeOtherObserver:observer event:RC_MESSAGE_CHANGED_EVENT];
}

- (void)addUserInfoChangeObserver:(id<RCWKNotificationObserver>)observer {
  [self addOtherObserver:observer event:RC_USER_INFO_CHANGED_EVENT];
}

- (void)removeUserInfoChangeObserver:(id<RCWKNotificationObserver>)observer {
  [self removeOtherObserver:observer event:RC_USER_INFO_CHANGED_EVENT];
}

- (void)addGroupInfoChangeObserver:(id<RCWKNotificationObserver>)observer {
    [self addOtherObserver:observer event:RC_GROUP_INFO_CHANGED_EVENT];
}

- (void)removeGroupInfoChangeObserver:(id<RCWKNotificationObserver>)observer {
    [self removeOtherObserver:observer event:RC_GROUP_INFO_CHANGED_EVENT];
}
- (void)addFriendChangeObserver:(id<RCWKNotificationObserver>)observer {
    [self addOtherObserver:observer event:RC_FRIEND_CHANGED_EVENT];
}

- (void)removeFriendChangeObserver:(id<RCWKNotificationObserver>)observer {
    [self removeOtherObserver:observer event:RC_FRIEND_CHANGED_EVENT];
}
- (void)addLoadImageObserver:(id<RCWKNotificationObserver>)observer {
  [self addOtherObserver:observer event:RC_LOAD_IMAGE_DONE_EVENT];
}

- (void)removeLoadIMageObserver:(id<RCWKNotificationObserver>)observer {
  [self removeOtherObserver:observer event:RC_LOAD_IMAGE_DONE_EVENT];
}

- (void)addConnectionStatusObserver:(id<RCWKNotificationObserver>)observer {
  [self addOtherObserver:observer event:RC_CONNECTION_STATUS_CHANGED_EVENT];
}

- (void)removeConnectionStatusObserver:(id<RCWKNotificationObserver>)observer {
  [self removeOtherObserver:observer event:RC_CONNECTION_STATUS_CHANGED_EVENT];
}

- (void)addOtherObserver:(id<RCWKNotificationObserver>)observer
                   event:(NSString *)event {
  NSMutableArray *array = self.observers[event];

  if (!array || ![array count]) {
    array = [[NSMutableArray alloc] init];
    [array addObject:observer];
    [self.observers setValue:array forKey:event];
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(), NULL,
        RCAppNotificationCallback, (__bridge CFStringRef)event, NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
  } else {
    if ([array containsObject:observer]) {
      return;
    } else {
      [array addObject:observer];
    }
  }
}
- (void)removeOtherObserver:(id<RCWKNotificationObserver>)observer
                      event:(NSString *)event {
  NSMutableArray *array = self.observers[event];

  if (array) {
    [array removeObject:observer];
    if (![array count]) {
      CFNotificationCenterRemoveObserver(
          CFNotificationCenterGetDarwinNotifyCenter(), NULL,
          (__bridge CFStringRef)event, NULL);
    }
  }
}

- (void)notifyEvent:(NSString *)event {
  NSMutableArray *observers = self.observers[event];
  for (id<RCWKNotificationObserver> observer in observers) {
    if ([event isEqualToString:RC_MESSAGE_CHANGED_EVENT]) {
      [observer onMessageChangedEvent];
    } else if ([event isEqualToString:RC_USER_INFO_CHANGED_EVENT]) {
      [observer onUserInfoChangedEvent];
    } else if ([event isEqualToString:RC_GROUP_INFO_CHANGED_EVENT]) {
        [observer onGroupInfoChangedEvent];
    } else if ([event isEqualToString:RC_FRIEND_CHANGED_EVENT]) {
        [observer onFriendChangedEvent];
    } else if ([event isEqualToString:RC_LOAD_IMAGE_DONE_EVENT]) {
      NSString *userID = [RCAppSharedUserDefault
          getSharedDefaultObjectForKey:WK_APP_SHARED_DEFAULT_LAST_LOADED_IMAGE];
      [observer onLoadImageDoneEvent:userID];
    } else if ([event isEqualToString:RC_CONNECTION_STATUS_CHANGED_EVENT]) {
      [observer onConnectionStatusChangedEvent];
    } else {
      [observer onOtherEvent:event];
    }
  }
}

@end
