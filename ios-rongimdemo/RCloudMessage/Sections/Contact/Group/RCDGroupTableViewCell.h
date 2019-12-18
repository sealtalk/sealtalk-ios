//
//  RCDGroupTableViewCell.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
@class RCDGroupInfo;

@interface RCDGroupTableViewCell : RCDTableViewCell

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

@end
