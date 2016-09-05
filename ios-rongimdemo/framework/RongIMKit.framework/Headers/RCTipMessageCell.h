//
//  RCTipMessageCell.h
//  RongIMKit
//
//  Created by xugang on 15/1/29.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageBaseCell.h"

/*!
 提示消息Cell
 */
@interface RCTipMessageCell : RCMessageBaseCell

/*!
 提示的Label
 */
@property(strong, nonatomic) RCTipLabel *tipMessageLabel;

/*!
 设置当前消息Cell的数据模型
 
 @param model 消息Cell的数据模型
 */
- (void)setDataModel:(RCMessageModel *)model;

@end
