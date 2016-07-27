//
//  RCCallUserCallInfoModel.h
//  RongCallKit
//
//  Created by 岑裕 on 16/3/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongCallLib/RongCallLib.h>
#import <RongIMLib/RongIMLib.h>

/*!
 用户通话信息的数据模型类
 */
@interface RCCallUserCallInfoModel : NSObject

/*!
 用户ID
 */
@property(nonatomic, strong) NSString *userId;

/*!
 用户信息
 */
@property(nonatomic, strong) RCUserInfo *userInfo;

/*!
 用户的通话状态Profile
 */
@property(nonatomic, strong) RCCallUserProfile *profile;

@end
