//
//  RCDTestMessageCell.m
//  RCloudMessage
//
//  Created by 岑裕 on 15/12/17.
//  Copyright © 2015年 RongCloud. All rights reserved.
//

#import "RCDTestMessageCell.h"

#define Test_Message_Font_Size 16

@implementation RCDTestMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    RCDTestMessage *message = (RCDTestMessage *)model.content;
    CGSize size = [RCDTestMessageCell getBubbleBackgroundViewSize:message];

    CGFloat __messagecontentview_height = size.height;

    if (__messagecontentview_height < RCKitConfigCenter.ui.globalMessagePortraitSize.height) {
        __messagecontentview_height = RCKitConfigCenter.ui.globalMessagePortraitSize.height;
    }

    __messagecontentview_height += extraHeight;

    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self showBubbleBackgroundView:YES];
    if(self.model.messageDirection == MessageDirection_RECEIVE){
        [self.textLabel setTextColor:[RCKitUtility generateDynamicColor:HEXCOLOR(0x262626) darkColor:RCMASKCOLOR(0xffffff, 0.8)]];
    }else{
        [self.textLabel setTextColor:RCDYCOLOR(0x262626, 0x040A0F)];
    }
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.textLabel setFont:[UIFont systemFontOfSize:Test_Message_Font_Size]];

    self.textLabel.numberOfLines = 0;
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setTextAlignment:NSTextAlignmentLeft];
    [self.messageContentView addSubview:self.textLabel];
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];

    [self setAutoLayout];
}

- (void)setAutoLayout {
    RCDTestMessage *testMessage = (RCDTestMessage *)self.model.content;
    if (testMessage) {
        self.textLabel.text = testMessage.content;
    }

    CGSize textLabelSize = [[self class] getTextLabelSize:testMessage];
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
    //拉伸图片
    self.textLabel.frame = CGRectMake(12, (bubbleBackgroundViewSize.height - textLabelSize.height)/2, textLabelSize.width, textLabelSize.height);
    self.messageContentView.contentSize = bubbleBackgroundViewSize;
}

+ (CGSize)getTextLabelSize:(RCDTestMessage *)message {
    if ([message.content length] > 0) {
        CGRect textRect = [message.content
            boundingRectWithSize:CGSizeMake([RCMessageCellTool getMessageContentViewMaxWidth], 8000)
                         options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                  NSStringDrawingUsesFontLeading)
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:Test_Message_Font_Size]
                      }
                         context:nil];
        textRect.size.height = ceilf(textRect.size.height);
        textRect.size.width = ceilf(textRect.size.width);
        return CGSizeMake(textRect.size.width + 5, textRect.size.height + 5);
    } else {
        return CGSizeZero;
    }
}

+ (CGSize)getBubbleSize:(CGSize)textLabelSize {
    CGSize bubbleSize = CGSizeMake(textLabelSize.width, textLabelSize.height);

    if (bubbleSize.width + 12 + 12 > 50) {
        bubbleSize.width = bubbleSize.width + 12 + 12;
    } else {
        bubbleSize.width = 50;
    }
    if (bubbleSize.height + 7 + 7 > 40) {
        bubbleSize.height = bubbleSize.height + 7 + 7;
    } else {
        bubbleSize.height = 40;
    }

    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(RCDTestMessage *)message {
    CGSize textLabelSize = [[self class] getTextLabelSize:message];
    return [[self class] getBubbleSize:textLabelSize];
}

@end
