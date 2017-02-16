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
 获取会话页面的cell信息。
 
 @param conversationType  会话类型
 @param targetId          targetId
 
 @return cell信息列表。
 
 @discussion 当进入到会话页面时，SDK需要了解扩展模块的消息对应的MessageCell和reuseIdentifier。
 */
- (NSArray<RCExtensionMessageCellInfo *> *)getMessageCellInfoList:(RCConversationType)conversationType
                                                         targetId:(NSString *)targetId;

/*!
 点击MessageCell的处理
 
 @param messageModel   被点击MessageCell的model
 */
- (void)didTapMessageCell:(RCMessageModel *)messageModel;

/**
 会话页面 WillAppear 时会调用，可以自己修改 extensionView 的 frame 及内容
 
 @param conversationType 会话类型
 @param targetId         targetId
 @param extensionView    扩展view
 */
- (void)extensionViewWillAppear:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                  extensionView:(UIView *)extensionView;

/**
 会话页面 WillDisappear 时会调用（如果您的扩展模块里有其他需要改变会话页面的 extensionView,在收到这个方法之后就应该终止修改）
 
 @param conversationType 会话类型
 @param targetId         targetId
 */
- (void)extensionViewWillDisappear:(RCConversationType)conversationType
                          targetId:(NSString *)targetId;


/**
 会话页面即将被销毁，点击会话页面左上角的“返回”按钮会触发这个回调
 
 @param conversationType 会话类型
 @param targetId targetId
 */
- (void)containerViewWillDestroy:(RCConversationType)conversationType
                        targetId:(NSString *)targetId;

@end
