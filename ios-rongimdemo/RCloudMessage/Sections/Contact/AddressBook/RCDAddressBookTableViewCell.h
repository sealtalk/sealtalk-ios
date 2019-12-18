//
//  RCDAddressBookTableViewCell.h
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
@class RCDFriendInfo;

@interface RCDAddressBookTableViewCell : RCDTableViewCell

@property (nonatomic, copy) void (^acceptBlock)(NSString *userId);

@property (nonatomic, copy) void (^ignoreBlock)(NSString *userId);

/**
 *  cell高度
 *
 */
+ (CGFloat)cellHeight;

/**
 *  设置模型
 *
 *  @param user 设置用户信息模型，填充控件的数据
 */
- (void)setModel:(RCDFriendInfo *)user;

@end
