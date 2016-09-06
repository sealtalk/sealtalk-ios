//
//  RCMessageCellNotificationModel.h
//  RongIMKit
//
//  Created by xugang on 15/1/29.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef __RCMessageCellNotificationModel
#define __RCMessageCellNotificationModel
#import <UIKit/UIKit.h>

// 消息Cell需要更新的状态名
UIKIT_EXTERN NSString *const CONVERSATION_CELL_STATUS_SEND_BEGIN;
UIKIT_EXTERN NSString *const CONVERSATION_CELL_STATUS_SEND_FAILED;
UIKIT_EXTERN NSString *const CONVERSATION_CELL_STATUS_SEND_SUCCESS;
UIKIT_EXTERN NSString *const CONVERSATION_CELL_STATUS_SEND_PROGRESS;
UIKIT_EXTERN NSString *const CONVERSATION_CELL_DATA_IMAGE_KEY_UPDATE;
UIKIT_EXTERN NSString *const CONVERSATION_CELL_STATUS_SEND_HASREAD;

UIKIT_EXTERN NSString *const CONVERSATION_CELL_STATUS_SEND_READCOUNT;//已读数

#import <Foundation/Foundation.h>

/*!
 消息Cell状态更新通知的数据模型
 */
@interface RCMessageCellNotificationModel : NSObject

/*!
 消息ID
 */
@property(nonatomic) long messageId;

/*!
 更新的状态名
 */
@property(strong, nonatomic) NSString *actionName;

/*!
 进度
 */
@property(nonatomic) NSInteger progress;

@end
#endif