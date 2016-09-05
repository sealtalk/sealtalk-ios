//
//  RCRichContentMessageCell.h
//  RongIMKit
//
//  Created by xugang on 15/2/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageCell.h"
#import "RCAttributedLabel.h"

#define RichContent_Title_Font_Size 15
#define RichContent_Message_Font_Size 12
#define RICH_CONTENT_THUMBNAIL_WIDTH 45
#define RICH_CONTENT_THUMBNAIL_HIGHT 45

/*!
 富文本（图文）消息Cell
 */
@interface RCRichContentMessageCell : RCMessageCell

/*!
 消息的背景View
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*!
 图片内容显示的View
 */
@property(nonatomic, strong) RCloudImageView *richContentImageView;

/*!
 文本内容显示的Label
 */
@property(nonatomic, strong) RCAttributedLabel *digestLabel;

/*!
 标题显示的Label
 */
@property(nonatomic, strong) RCAttributedLabel *titleLabel;

@end
