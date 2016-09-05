/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCWKNotifier.h
//  Created by litao on 15/4/7.

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@interface RCWKNotifier : NSObject <RCWatchKitStatusDelegate>
+ (instancetype)sharedWKNotifier;
@property(nonatomic, getter=isWatchAttached) BOOL watchAttached;
// for App use
- (void)notifyWatchKitEvent:(NSString *)appEvent;
- (void)notifyWatchKitUserInfoChanged;
- (void)notifyWatchKitGroupChanged;
- (void)notifyWatchKitFriendChanged;
- (void)notifyWatchKitLoadImageDone:(NSString *)userID;

@end
