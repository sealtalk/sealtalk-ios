//
//  RCDContactSelectedTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDFriendInfo;

@interface RCDContactSelectedTableViewCell : UITableViewCell

/**
 *  获取cell的高度
 *
 */
+ (CGFloat)cellHeight;

- (void)setModel:(RCDFriendInfo *)user;

/**
 *  选中图片
 */
@property(nonatomic, strong) UIImageView *selectedImageView;

/**
 *  头像图片
 */
@property(nonatomic, strong) UIImageView *portraitImageView;

/**
 *  昵称
 */
@property(nonatomic, strong) UILabel *nicknameLabel;

@end
