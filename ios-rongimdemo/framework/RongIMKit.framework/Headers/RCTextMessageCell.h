//
//  RCTextMessageCell.h
//  RongIMKit
//
//  Created by xugang on 15/2/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCAttributedLabel.h"
#import "RCMessageCell.h"

#define Text_Message_Font_Size 16

/*!
 文本消息Cell
 */
@interface RCTextMessageCell : RCMessageCell <RCAttributedLabelDelegate>

/*!
 显示消息内容的Label
 */
@property(strong, nonatomic) RCAttributedLabel *textLabel;

/*!
 消息的背景View
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*!
 设置当前消息Cell的数据模型

 @param model 消息Cell的数据模型
 */
- (void)setDataModel:(RCMessageModel *)model;

@end
