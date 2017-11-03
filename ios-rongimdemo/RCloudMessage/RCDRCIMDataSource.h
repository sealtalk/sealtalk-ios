//
//  RCDRCIMDelegateImplementation.h
//  RongCloud
//  实现RCIM的数据源
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongCallKit/RongCallKit.h>
#import <RongContactCard/RongContactCard.h>
#import <RongIMKit/RongIMKit.h>

#define RCDDataSource [RCDRCIMDataSource shareInstance]

/**
 *  此类写了一个provider的具体示例，开发者可以根据此类结构实现provider
 *  用户信息和群组信息都要通过回传id请求服务器获取，参考具体实现代码。
 */
@interface RCDRCIMDataSource
    : NSObject <RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMGroupUserInfoDataSource,
                RCCallGroupMemberDataSource, RCIMGroupMemberDataSource, RCCCContactsDataSource, RCCCGroupDataSource>

+ (RCDRCIMDataSource *)shareInstance;

/**
 *  同步自己的所属群组到融云服务器,修改群组信息后都需要调用同步
 */
- (void)syncGroups;

/**
 *  获取群中的成员列表
 */
- (void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray *userIdList))resultBlock;

/**
 *  从服务器同步好友列表
 */
- (void)syncFriendList:(NSString *)userId complete:(void (^)(NSMutableArray *friends))completion;
/*
 * 获取所有用户信息
 */
- (NSArray *)getAllUserInfo:(void (^)(void))completion;
/*
 * 获取所有群组信息
 */
- (NSArray *)getAllGroupInfo:(void (^)(void))completion;
/*
 * 获取所有好友信息
 */
- (NSArray *)getAllFriends:(void (^)(void))completion;

@end
