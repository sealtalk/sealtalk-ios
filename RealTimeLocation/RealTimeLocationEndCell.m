//
//  RealTimeLocationEndCell.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/8/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RealTimeLocationEndCell.h"
#define IOS_FSystenVersion ([[[UIDevice currentDevice] systemVersion] floatValue])
// 大于等于IOS7
#define RC_MULTILINE_TEXTSIZE_GEIOS7(text, font, maxSize) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;

// 小于IOS7
#define RC_MULTILINE_TEXTSIZE_LIOS7(text, font, maxSize, mode) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;

@implementation RealTimeLocationEndCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tipMessageLabel = [RCTipLabel greyTipLabel];
        [self.baseContentView addSubview:self.tipMessageLabel];
        //self.tipMessageLabel.marginInsets = UIEdgeInsetsMake(0.5f, 0.5f, 0.5f, 0.5f);
    }
    return self;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    
//    RCMessageContent *content = model.content;
    
    CGFloat maxMessageLabelWidth = self.baseContentView.bounds.size.width - 30 * 2;
    [self.tipMessageLabel setText:@"位置共享已结束" dataDetectorEnabled:NO];
    
    NSString *__text = self.tipMessageLabel.text;
    // ios 7
    //    CGSize __textSize =
    //        [__text boundingRectWithSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)
    //                             options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
    //                                     NSStringDrawingUsesFontLeading
    //                          attributes:@{
    //                              NSFontAttributeName : [UIFont systemFontOfSize:12.5f]
    //                          } context:nil]
    //            .size;
    
    //    CGSize __textSize = RC_MULTILINE_TEXTSIZE(__text, [UIFont systemFontOfSize:12.5f], CGSizeMake(maxMessageLabelWidth, MAXFLOAT), NSLineBreakByTruncatingTail);
    CGSize __textSize = CGSizeZero;
    if (IOS_FSystenVersion < 7.0) {
        __textSize = RC_MULTILINE_TEXTSIZE_LIOS7(__text, [UIFont systemFontOfSize:12.5f], CGSizeMake(maxMessageLabelWidth, MAXFLOAT), NSLineBreakByTruncatingTail);
    }else {
        __textSize = RC_MULTILINE_TEXTSIZE_GEIOS7(__text, [UIFont systemFontOfSize:12.5f], CGSizeMake(maxMessageLabelWidth, MAXFLOAT));
    }
    
    
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 10, __textSize.height + 6);
    
    self.tipMessageLabel.frame = CGRectMake((self.baseContentView.bounds.size.width - __labelSize.width) / 2.0f, 10,
                                            __labelSize.width, __labelSize.height);
}

@end
