//
//  RCDBuglyManager.m
//  SealTalk
//
//  Created by 孙浩 on 2019/3/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDBuglyManager.h"
#import <Bugly/Bugly.h>

@implementation RCDBuglyManager

+ (void)startWithAppId:(NSString *)appId {
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.reportLogLevel = BuglyLogLevelWarn;
    config.blockMonitorEnable = YES;
    config.blockMonitorTimeout = 2;
    config.unexpectedTerminatingDetectionEnable = YES;
    [Bugly startWithAppId:appId config:config];
}

+ (void)setUserIdentifier:(NSString *)userId {
    [Bugly setUserIdentifier:userId];
}

@end
