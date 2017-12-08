//
//  RCContactCardMessageCell.h
//  RongContactCard
//
//  Created by Sin on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
@class RCloudImageView;

/**
 *  名片消息cell
 */
@interface RCContactCardMessageCell : RCMessageCell

/**
 *  昵称label
 */
@property (nonatomic,strong) UILabel *nameLabel;

/**
 *  头像
 */
@property (nonatomic,strong) RCloudImageView *portraitView;

/*!
 消息的气泡背景View
 */
@property (nonatomic, strong) UIImageView *bubbleBackgroundView;

//size of cell
+ (CGSize)sizeOfMessageCell;
@end
