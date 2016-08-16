//
//  RCCallTipMessageCell.h
//  RongCallKit
//
//  Created by 岑裕 on 16/3/20.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

/*!
 简略的通话摘要消息Cell
 */
@interface RCCallTipMessageCell : RCMessageBaseCell

/*!
 显示的内容Label
 */
@property(strong, nonatomic) RCTipLabel *messageLabel;

/*!
 设置当前消息Cell的数据模型

 @param model 消息Cell的数据模型
 */
- (void)setDataModel:(RCMessageModel *)model;

@end
