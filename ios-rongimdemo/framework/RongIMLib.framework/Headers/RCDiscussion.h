/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCDiscussion.h
//  Created by Heq.Shinoda on 14-6-23.

#ifndef __RCDiscussion
#define __RCDiscussion

#import <Foundation/Foundation.h>

/*!
 讨论组类
 */
@interface RCDiscussion : NSObject

/*!
 讨论组ID
 */
@property(nonatomic, copy) NSString *discussionId;

/*!
 讨论组名称
 */
@property(nonatomic, copy) NSString *discussionName;

/*!
 讨论组的创建者的用户ID
 */
@property(nonatomic, copy) NSString *creatorId;

/*!
 讨论组成员的用户ID列表
 */
@property(nonatomic, strong) NSArray *memberIdList;

/*!
 讨论组是否开放加人权限

 @discussion 是否允许非创建者添加用户，0表示允许，1表示不允许，默认值为0。
 */
@property(nonatomic, assign) int inviteStatus;

/*!
 讨论组的会话类型（已废弃，请勿使用）

 @warning **已废弃，请勿使用。**
 */
@property(nonatomic, assign) __deprecated_msg("已废弃，请勿使用。") int conversationType;

/*!
 讨论组是否允许消息提醒（已废弃，请勿使用）

 @warning **已废弃，请勿使用。**
 */
@property(nonatomic, assign) __deprecated_msg("已废弃，请勿使用。") int pushMessageNotificationStatus;

/*!
 讨论组初始化方法

 @param discussionId                    讨论组ID
 @param discussionName                  讨论组名称
 @param creatorId                       创建者的用户ID
 @param conversationType                会话类型
 @param memberIdList                    讨论组成员的用户ID列表
 @param inviteStatus                    是否开放加人权限
 @param pushMessageNotificationStatus   是否允许消息提醒
 @return                                讨论组对象
 */
- (instancetype)initWithDiscussionId:(NSString *)discussionId
                      discussionName:(NSString *)discussionName
                           creatorId:(NSString *)creatorId
                    conversationType:(int)conversationType
                        memberIdList:(NSArray *)memberIdList
                        inviteStatus:(int)inviteStatus
               msgNotificationStatus:(int)pushMessageNotificationStatus;

@end
#endif
