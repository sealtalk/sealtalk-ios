//
//  RCDRCIMDelegateImplementation.h
//  RongCloud
//  实现RCIM的数据源
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongContactCard/RongContactCard.h>
#import <RongCallKit/RongCallKit.h>

#define RCDDataSource [RCDRCIMDataSource sharedInstance]

/**
 *  此类写了一个provider的具体示例，开发者可以根据此类结构实现provider
 *  用户信息和群组信息都要通过回传id请求服务器获取，参考具体实现代码。
 */

@interface RCDRCIMDataSource
    : NSObject <RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMGroupUserInfoDataSource,
                RCCallGroupMemberDataSource, RCIMGroupMemberDataSource, RCCCContactsDataSource, RCCCGroupDataSource>

+ (RCDRCIMDataSource *)sharedInstance;

- (void)syncAllData;

/**
 *  从服务器同步好友列表
 */
- (void)syncFriendList;

@end
