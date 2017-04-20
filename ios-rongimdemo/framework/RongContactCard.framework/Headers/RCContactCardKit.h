//
//  RCContactCardKit.h
//  RongContactCard
//
//  Created by Jue on 2017/1/9.
//  Copyright © 2017年 ios-rongContactCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
#import "RCCCGroupInfo.h"
#import "RCCCUserInfo.h"

@protocol RCCCContactsDataSource <NSObject>
@required

/*!
 获取联系人列表的回调
 @param resultBlock 获取成功 [contactsInfoList:联系人信息列表]
 */
- (void)getAllContacts:(void (^)(NSArray<RCCCUserInfo *> *contactsInfoList))resultBlock;
@end

@protocol RCCCGroupDataSource <NSObject>
@required

/*!
 获取当前群组信息的回调
 
 @param groupId     群ID
 @param resultBlock 获取成功 [groupInfo:群组信息]
 */
- (void)getGroupInfoByGroupId:(NSString *)groupId
                      result:(void (^)(RCCCGroupInfo *groupInfo))resultBlock;
@end

@interface RCContactCardKit : NSObject

+ (RCContactCardKit *)shareInstance;

/*!
 联系人信息提供者
 
 @discussion 如果您使用了名片消息功能，SDK需要通过您实现本代理，获取联系人信息列表。
 */
@property(nonatomic, weak) id<RCCCContactsDataSource> contactsDataSource;

/*!
 群组信息提供者
 
 @discussion 如果您需要在群组中使用名片消息功能，SDK需要通过您实现本代理，展示群组信息。
 */
@property(nonatomic, weak) id<RCCCGroupDataSource> groupDataSource;

@end
