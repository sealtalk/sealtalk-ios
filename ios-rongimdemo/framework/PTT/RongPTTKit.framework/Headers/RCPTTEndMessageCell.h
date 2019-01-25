//
//  RCPTTEndMessageCell.h
//  RongPTTKit
//
//  Created by Sin on 17/1/16.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface RCPTTEndMessageCell : RCMessageBaseCell
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
