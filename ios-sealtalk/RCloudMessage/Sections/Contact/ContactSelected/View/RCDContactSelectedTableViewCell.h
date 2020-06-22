//
//  RCDContactSelectedTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
@class RCDFriendInfo;

@interface RCDContactSelectedTableViewCell : RCDTableViewCell

/**
 *  获取cell的高度
 *
 */
+ (CGFloat)cellHeight;

- (void)setModel:(RCDFriendInfo *)user;

@property (nonatomic, strong) NSString *groupId;

/**
 *  选中图片
 */
@property (nonatomic, strong) UIImageView *selectedImageView;

/**
 *  头像图片
 */
@property (nonatomic, strong) UIImageView *portraitImageView;

/**
 *  昵称
 */
@property (nonatomic, strong) UILabel *nicknameLabel;

@end
