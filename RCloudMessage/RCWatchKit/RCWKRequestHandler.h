//
//  RCWKRequestHandler.h
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import "RCWKAppInfoProvider.h"

@interface RCWKRequestHandler : NSObject
- (instancetype)initHelperWithUserInfo:(NSDictionary *)userInfo
                              provider:(id<RCWKAppInfoProvider>)provider
                                 reply:(void (^)(NSDictionary *))reply;
- (BOOL)handleWatchKitRequest;
@end
