//
//  RCDChatViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface RCDChatViewController : RCConversationViewController
@property(nonatomic, copy) NSString *groupName;
/**
 *  会话数据模型
 */
@property(strong, nonatomic) RCConversationModel *conversation;

@property BOOL needPopToRootView;
- (UIView *)loadEmoticonView:(NSString *)identify index:(int)index;
@end
