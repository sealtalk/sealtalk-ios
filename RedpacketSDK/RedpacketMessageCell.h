//
//  RedpacketMessageCell.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RedpacketMessage.h"

@interface RedpacketMessageCell : RCMessageCell
@property(strong, nonatomic) UILabel *greetingLabel;
@property(strong, nonatomic) UILabel *subLabel; // 显示 "查看红包"
@property(strong, nonatomic) UILabel *orgLabel;
@property(strong, nonatomic) UIImageView *iconView;
@property(strong, nonatomic) UIImageView *orgIconView;

@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*
 根据消息内容获取显示的尺寸
 
 @param message 消息内容
 
 @return 显示的View尺寸
 */
+ (CGSize)getBubbleBackgroundViewSize:(RedpacketMessage *)message;
@end
