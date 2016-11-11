//
//  RongIMKitExtensionModule.h
//  RongIMKit
//
//  Created by 岑裕 on 16/7/2.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCExtensionModule.h"
#import "RCMessageModel.h"
#import "RCExtensionMessageCellInfo.h"

/*!
 RongCloud IM扩展模块协议
 */
@protocol RongIMKitExtensionModule <RCExtensionModule>

@optional

#pragma mark - Cell
/*!
 获取会话界面的cell信息。
 
 @param conversationType  会话类型
 @param targetId          targetId
 
 @return cell信息列表。
 
 @discussion 当进入到会话界面时，SDK需要了解扩展模块的消息对应的MessageCell和reuseIdentifier。
 */
- (NSArray<RCExtensionMessageCellInfo *> *)getMessageCellInfoList:(RCConversationType)conversationType
                                                         targetId:(NSString *)targetId;

/*!
 点击MessageCell的处理
 
 @param messageModel   被点击MessageCell的model
 */
- (void)didTapMessageCell:(RCMessageModel *)messageModel;
@end
