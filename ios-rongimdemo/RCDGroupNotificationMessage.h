//
//  RCDGroupNotificationMessage.h
//  RCloudMessage
//
//  Created by Jue on 16/4/8.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 群组通知消息的类型名
 */
#define RCGroupNotificationTypeIdentifier @"RCD:GrpNtf"

/*!
 讨论组通知的类型
 */
typedef NS_ENUM(NSInteger, RCDGroupNotificationType) {
    /*!
     有成员加入群组的通知
     */
    RCDInviteGroupNotification = 1,
    /*!
     有成员退出群组的通知
     */
    RCDQuitGroupNotification,
    /*!
     群组名称发生变更的通知
     */
    RCDRenameGroupTitleNotification,
    /*!
     有成员被踢出群组的通知
     */
    RCDRemoveGroupMemberNotification,
};

@interface RCDGroupNotificationMessage : RCMessageContent

/*!
 群组通知的类型
 */
@property(nonatomic, assign) RCDGroupNotificationType type;

/*!
 操作者的用户ID
 */
@property(nonatomic, strong) NSString *operatorId;

/*!
 群组通知的扩展信息
 */
@property(nonatomic, strong) NSString *extension;

/*!
 初始化群组通知消息

 @param type        群组通知的扩展信息
 @param operatorId  操作者的用户ID
 @param extension   群组通知的扩展信息
 @return            群组通知对象
 */
+ (instancetype)notificationWithType:(RCDiscussionNotificationType)type
operator:(NSString *)operatorId
                           extension:(NSString *)extension;

@end
