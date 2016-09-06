//
//  RCDGroupTableViewCell.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDGroupInfo;

@interface RCDGroupTableViewCell : UITableViewCell

/**
 *
 *  @return cell高度
 */
+ (CGFloat)cellHeight;

/**
 *  给控件填充数据
 *
 *  @param group 设置群组模型
 */
- (void)setModel:(RCDGroupInfo *)group;

@property(nonatomic, copy) NSString *groupID;

/**
 *  群组名称label
 */
@property(nonatomic, strong) UILabel *lblGroupName;

/**
 *  群组头像
 */
@property(nonatomic, strong) UIImageView *imvGroupPort;

/**
 *  群组id的label
 */
@property(nonatomic, strong) UILabel *lblGroupId;

@end
