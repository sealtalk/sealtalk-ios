//
//  RCDTipMessageCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTipMessageCell.h"
#import "RCDGroupNotificationMessage.h"
#import "RCDChatNotificationMessage.h"
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
@interface RCDTipMessageCell () <RCAttributedLabelDelegate>

@end

@implementation RCDTipMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    NSString *localizedMessage = nil;

    localizedMessage = [RCDTipMessageCell generateTipsStringForModel:model];
    if (localizedMessage.length <= 0) {
        model.isDisplayMessageTime = NO;
        return CGSizeMake(collectionViewWidth, 0);
    }

    CGFloat maxMessageLabelWidth = collectionViewWidth - 30 * 2;
    CGSize __textSize = [RCKitUtility getTextDrawingSize:localizedMessage
                                                    font:[UIFont systemFontOfSize:14.f]
                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 8, __textSize.height + 6);

    CGFloat __height = __labelSize.height;

    __height += extraHeight;

    return CGSizeMake(collectionViewWidth, __height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tipMessageLabel = [RCTipLabel greyTipLabel];
        self.tipMessageLabel.backgroundColor =
            [RCKitUtility generateDynamicColor:[UIColor colorWithWhite:0 alpha:0.1] darkColor:HEXCOLOR(0x232323)];
        self.tipMessageLabel.textColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xffffff) darkColor:HEXCOLOR(0x707070)];
        self.tipMessageLabel.userInteractionEnabled = NO;
        self.tipMessageLabel.attributeDictionary = @{};
        [self.baseContentView addSubview:self.tipMessageLabel];
        self.tipMessageLabel.marginInsets = UIEdgeInsetsMake(0.5f, 0.5f, 0.5f, 0.5f);
    }
    return self;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    self.tipMessageLabel.text = [RCDTipMessageCell generateTipsStringForModel:model];
    CGFloat maxMessageLabelWidth = self.baseContentView.bounds.size.width - 30 * 2;
    NSString *__text = self.tipMessageLabel.text;
    if (__text.length <= 0) {
        self.tipMessageLabel.frame = CGRectZero;
    } else {
        CGSize __textSize = [RCKitUtility getTextDrawingSize:__text
                                                        font:[UIFont systemFontOfSize:14.0f]
                                             constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
        __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
        CGSize __labelSize = CGSizeMake(__textSize.width + 8, __textSize.height + 6);
        CGFloat width = __labelSize.width;
        self.tipMessageLabel.frame =
            CGRectMake((self.baseContentView.bounds.size.width - width) / 2.0f, 0, width, __labelSize.height);
    }
}

+ (NSString *)generateTipsStringForModel:(RCMessageModel *)model {
    NSString *text;
    NSString *groupId;
    if (model.conversationType == ConversationType_GROUP) {
        groupId = model.targetId;
    }
    if ([model.content isMemberOfClass:[RCDGroupNotificationMessage class]]) {
        RCDGroupNotificationMessage *message = (RCDGroupNotificationMessage *)model.content;
        text = [message getDigest:groupId];
    } else if ([model.content isMemberOfClass:RCDChatNotificationMessage.class]) {
        RCDChatNotificationMessage *message = (RCDChatNotificationMessage *)model.content;
        text = [message getDigest:groupId];
    }
    return text;
}
@end
