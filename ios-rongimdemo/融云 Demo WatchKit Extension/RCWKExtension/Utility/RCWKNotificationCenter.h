//
//  RCWKNotificationCenter.h
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RCWKNotificationObserver
@optional
- (void)onMessageChangedEvent;
- (void)onUserInfoChangedEvent;
- (void)onGroupInfoChangedEvent;
- (void)onFriendChangedEvent;
- (void)onLoadImageDoneEvent:(NSString *)userID;
- (void)onConnectionStatusChangedEvent;
- (void)onOtherEvent:(NSString *)event;
@end

@interface RCWKNotificationCenter : NSObject
// for watch kit use
+ (instancetype)defaultCenter;

- (void)addMessageChangeObserver:(id<RCWKNotificationObserver>)observer;
- (void)removeMessageChangeObserver:(id<RCWKNotificationObserver>)observer;
- (void)addUserInfoChangeObserver:(id<RCWKNotificationObserver>)observer;
- (void)removeUserInfoChangeObserver:(id<RCWKNotificationObserver>)observer;
- (void)addGroupInfoChangeObserver:(id<RCWKNotificationObserver>)observer;
- (void)removeGroupInfoChangeObserver:(id<RCWKNotificationObserver>)observer;
- (void)addFriendChangeObserver:(id<RCWKNotificationObserver>)observer;
- (void)removeFriendChangeObserver:(id<RCWKNotificationObserver>)observer;
- (void)addLoadImageObserver:(id<RCWKNotificationObserver>)observer;
- (void)removeLoadIMageObserver:(id<RCWKNotificationObserver>)observer;
- (void)addConnectionStatusObserver:(id<RCWKNotificationObserver>)observer;
- (void)removeConnectionStatusObserver:(id<RCWKNotificationObserver>)observer;

- (void)addOtherObserver:(id<RCWKNotificationObserver>)observer
                   event:(NSString *)event;
- (void)removeOtherObserver:(id<RCWKNotificationObserver>)observer
                      event:(NSString *)event;

// for internal use, never call it.
- (void)notifyEvent:(NSString *)event;
@end
