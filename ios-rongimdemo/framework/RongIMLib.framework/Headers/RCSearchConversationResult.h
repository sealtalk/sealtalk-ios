//
//  RCSearchConversationResult.h
//  RongIMLib
//
//  Created by 杜立召 on 16/9/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCConversation.h"

/*!
 搜索的会话结果
 */
@interface RCSearchConversationResult : NSObject

/*!
 会话
 */
@property(nonatomic, strong) RCConversation *conversation;

/*
 匹配的条数
 */
@property(nonatomic, assign) int matchCount;
@end
