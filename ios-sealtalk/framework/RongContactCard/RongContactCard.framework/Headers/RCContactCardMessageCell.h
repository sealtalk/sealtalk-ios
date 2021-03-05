//
//  RCContactCardMessageCell.h
//  RongContactCard
//
//  Created by Sin on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#if __has_include(<RongIMKit/RongIMKit.h>)
#import <RongIMKit/RongIMKit.h>
#else
#import "RongIMKit.h"
#endif

/**
 *  名片消息cell
 */
@interface RCContactCardMessageCell : RCMessageCell

/**
 *  昵称label
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 *  头像
 */
@property (nonatomic, strong) RCloudImageView *portraitView;

// size of cell
+ (CGSize)sizeOfMessageCell;
@end
