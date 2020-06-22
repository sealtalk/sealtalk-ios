//
//  RCDGroupInfo.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCGroup.h>
typedef NS_ENUM(NSInteger, RCDGroupMessageClearStatus) {
    RCDGroupMessageClearStatusClose = 0,
    RCDGroupMessageClearStatusBefore3d = 3,
    RCDGroupMessageClearStatusBefore7d = 7,
    RCDGroupMessageClearStatusBefore36h = 36,
    RCDGroupMessageClearStatusUnknown = -1, //获取失败
};

@interface RCDGroupInfo : RCGroup <NSCoding>
/** 人数 */
@property (nonatomic, strong) NSString *number;
/** 最大人数 */
@property (nonatomic, strong) NSString *maxNumber;
/** 群简介 */
@property (nonatomic, strong) NSString *introduce;

/** 创建者Id */
@property (nonatomic, strong) NSString *creatorId;
/** 是否解散 */
@property (nonatomic, assign) BOOL isDismiss;
/** 群禁言 */
@property (nonatomic, assign) BOOL mute;
/** 群认证，默认是NO */
@property (nonatomic, assign) BOOL needCertification;
/** 群成员保护，默认是NO */
@property (nonatomic, assign) BOOL memberProtection;

- (instancetype)initWithJson:(NSDictionary *)json;
@end
