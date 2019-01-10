/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCDiscussionNotification.h
//  Created by Heq.Shinoda on 14-6-26.

#import "RCMessageContent.h"

/*!
 讨论组通知消息的类型名
 */
#define RCDiscussionNotificationTypeIdentifier @"RC:DizNtf"

/*!
 讨论组通知的类型
 */
typedef NS_ENUM(NSInteger, RCDiscussionNotificationType) {
    /*!
     有成员加入讨论组的通知
     */
    RCInviteDiscussionNotification = 1,
    /*!
     有成员退出讨论组的通知
     */
    RCQuitDiscussionNotification,
    /*!
     讨论组名称发生变更的通知
     */
    RCRenameDiscussionTitleNotification,
    /*!
     有成员被踢出讨论组的通知
     */
    RCRemoveDiscussionMemberNotification,
    /*!
     讨论组加入权限的变更
     */
    RCSwichInvitationAccessNotification
};

/*!
 讨论组通知消息类

 @discussion 讨论组通知消息类，此消息会进行存储，但不计入未读消息数。
 */
@interface RCDiscussionNotificationMessage : RCMessageContent <NSCoding>

/*!
 讨论组通知的类型
 */
@property(nonatomic, assign) RCDiscussionNotificationType type;

/*!
 操作者的用户ID
 */
@property(nonatomic, copy) NSString *operatorId;

/*!
 讨论组通知的扩展信息
 */
@property(nonatomic, copy) NSString *extension;

/*!
 初始化讨论组通知消息

 @param type        讨论组通知的扩展信息
 @param operatorId  操作者的用户ID
 @param extension   讨论组通知的扩展信息
 @return            讨论组通知对象
 */
+ (instancetype)notificationWithType:(RCDiscussionNotificationType)type
operator:(NSString *)operatorId
                           extension:(NSString *)extension;

@end
