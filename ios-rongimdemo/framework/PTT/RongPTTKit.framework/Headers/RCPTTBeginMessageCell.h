//
//  RCPTTBeginMessageCell.h
//  RongPTTKit
//
//  Created by Sin on 17/1/16.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import <RongPTTLib/RongPTTLib.h>

@interface RCPTTBeginMessageCell : RCMessageCell
/*!
 文本内容的Label
 */
@property(strong, nonatomic) UILabel *textLabel;

/*!
 背景View
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*!
 根据消息内容获取显示的尺寸

 @param message 消息内容

 @return 显示的View尺寸
 */
+ (CGSize)getBubbleBackgroundViewSize:(RCPTTBeginMessage *)message;
@end
