//
//  RCDBuglyManager.h
//  SealTalk
//
//  Created by 孙浩 on 2019/3/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDBuglyManager : NSObject

/**
 初始化Bugly,使用默认BuglyConfig

 @param appId 注册Bugly分配的应用唯一标识
 */
+ (void)startWithAppId:(NSString *)appId;

/**
 设置用户标识

 @param userId 用户标识
 */
+ (void)setUserIdentifier:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
