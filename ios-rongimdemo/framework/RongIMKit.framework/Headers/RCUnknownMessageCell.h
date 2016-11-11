//
//  RCUnknownMessageCell.h
//  RongIMKit
//
//  Created by xugang on 3/31/15.
//  Copyright (c) 2015 RongCloud. All rights reserved.
//

#import "RCMessageBaseCell.h"

/*!
 未知消息Cell
 */
@interface RCUnknownMessageCell : RCMessageBaseCell

/*!
 提示的Label
 */
@property(strong, nonatomic) RCTipLabel *messageLabel;

/*!
 设置当前消息Cell的数据模型
 
 @param model 消息Cell的数据模型
 */
- (void)setDataModel:(RCMessageModel *)model;

@end
