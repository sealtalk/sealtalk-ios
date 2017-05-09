//
//  RCChatRoomInfo.h
//  RongIMLib
//
//  Created by 岑裕 on 16/1/11.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCStatusDefine.h"
#import <Foundation/Foundation.h>

/*!
 聊天室信息类
 */
@interface RCChatRoomInfo : NSObject

/*!
 聊天室ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 包含的成员信息类型
 */
@property(nonatomic, assign) RCChatRoomMemberOrder memberOrder;

/*!
 聊天室中的部分成员信息RCChatRoomMemberInfo列表

 @discussion
 如果成员类型为RC_ChatRoom_Member_Asc，则为最早加入的成员列表，按成员加入时间升序排列；
 如果成员类型为RC_ChatRoom_Member_Desc，则为最晚加入的成员列表，按成员加入时间降序排列。
 */
@property(nonatomic, strong) NSArray *memberInfoArray;

/*!
 当前聊天室的成员总数
 */
@property(nonatomic, assign) int totalMemberCount;

@end
