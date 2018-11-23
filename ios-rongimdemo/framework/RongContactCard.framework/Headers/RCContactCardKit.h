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
 获取联系人列表的回调，当开发者使用默认的通讯录页面时，需要实现此回调来提供通讯录联系人列表
 
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


/*!
 弹出通讯录页面的回调
 
 @discussion 您可以通过代理提供一个UIViewController，在点击名片功能按钮时候，会弹出这个UIViewController。
  如果不提供此代理，会弹出默认的通讯录页面。
 */
@protocol RCCCContactViewControllerDelegate <NSObject>
@required

/**
 弹出通讯录页面的回调

 @param conversationType 点击名片按钮时所处会话的会话类型
 @param targetId 点击名片按钮时所处会话的会话id
 
 @discussion 
 您可以通过这个代理方法提供一个通讯录页面，在点击名片功能按钮时候，会回调此方法。
 如果您需要自定义通讯录页面，请在此回调中present自定义的通讯录页面。
 当用户选择某一个联系人之后，请根据点击时会话是单聊还是群组聊天，分别回调popupSendContactCardView:
 targetUserInfo:或者popupSendContactCardView:targetGroupInfo:来通知SDK，并自行dismiss通讯录页面。
 如果不提供此代理，会弹出默认的通讯录页面。
 */
- (void)needDisplayContactViewController:(RCConversationType)conversationType
                                targetId:(NSString *)targetId;

/**
 点击发送名片消息按钮的回调
 */
- (void)clickSendContactCardButton;

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


/*!
 弹出通讯录页面代理
 
 @discussion 如果您需要在点击名片按钮后弹出自己的通讯录页面，SDK需要通过您实现本代理，提供弹出的页面
 */
@property(nonatomic, weak) id<RCCCContactViewControllerDelegate> contactVCDelegate;

/**
 选中通讯录中的某个人，点击确定将名片发送到单聊会话的回调方法

 @param cardUserInfo 选中人的用户信息
 @param targetUserInfo 名片消息的目标会话的用户信息
 */
- (void)popupSendContactCardView:(RCCCUserInfo*)cardUserInfo
                  targetUserInfo:(RCCCUserInfo*)targetUserInfo;

/**
 选中通讯录中的某个人，点击确定将名片发送到群组会话的回调方法
 
 @param cardUserInfo 选中人的用户信息
 @param targetGroupInfo 名片消息的目标会话的群组信息
 */
- (void)popupSendContactCardView:(RCCCUserInfo*)cardUserInfo
                  targetGroupInfo:(RCCCGroupInfo*)targetGroupInfo;

@end
