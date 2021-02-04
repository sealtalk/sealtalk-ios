//
//  RCPokeMessageCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPokeMessageCell.h"
#import "RCDPokeMessage.h"

#define Poke_Message_Font_Size 15
#define PokeSize CGSizeMake(12, 14)
@interface RCDPokeMessageCell ()
/*!
 背景View
 */
@property (nonatomic, strong) UIImageView *bubbleBackgroundView;

@property (nonatomic, strong) UIImageView *pokeIcon;
@property (nonatomic, strong) UILabel *contentLabel;
@end
@implementation RCDPokeMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGSize size = [RCDPokeMessageCell getBubbleBackgroundViewSize:model];

    CGFloat __messagecontentview_height = size.height;
    if (__messagecontentview_height < [RCIM sharedRCIM].globalMessagePortraitSize.height) {
        __messagecontentview_height = [RCIM sharedRCIM].globalMessagePortraitSize.height;
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

- (void)initialize {
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    [self.bubbleBackgroundView addSubview:self.pokeIcon];
    [self.bubbleBackgroundView addSubview:self.contentLabel];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self setAutoLayout];
}

- (void)setAutoLayout {
    self.contentLabel.attributedText = [[self class] getDisplayContent:self.model];
    CGSize textLabelSize = [[self class] getTextLabelSize:self.model];
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
    CGRect messageContentViewRect = self.messageContentView.frame;
    CGFloat pokeX = 20;
    //拉伸图片
    if (MessageDirection_RECEIVE == self.messageDirection) {
        self.pokeIcon.image = [UIImage imageNamed:@"poke_msg_receive"];
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        self.messageContentView.frame = messageContentViewRect;

        self.bubbleBackgroundView.frame =
            CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.bubbleBackgroundView.image =
            [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                                image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        self.pokeIcon.image = [UIImage imageNamed:@"poke_msg_send"];
        pokeX = 12;
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        messageContentViewRect.size.height = bubbleBackgroundViewSize.height;
        messageContentViewRect.origin.x =
            self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + HeadAndContentSpacing +
                                                      [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;

        self.bubbleBackgroundView.frame =
            CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.bubbleBackgroundView.image =
            [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                                image.size.height * 0.2, image.size.width * 0.8)];
    }
    self.pokeIcon.frame = CGRectMake(pokeX, 12, PokeSize.width, PokeSize.height);
    self.contentLabel.frame =
        CGRectMake(CGRectGetMaxX(self.pokeIcon.frame) + 6, 7, textLabelSize.width, textLabelSize.height);
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}

+ (NSAttributedString *)getDisplayContent:(RCMessageModel *)model {
    RCDPokeMessage *pokeMessage = (RCDPokeMessage *)model.content;
    NSString *string;
    if (pokeMessage.content.length > 0) {
        string = [NSString stringWithFormat:@"%@  %@", RCDLocalizedString(@"Poke"), pokeMessage.content];
    } else {
        string = RCDLocalizedString(@"Poke");
    }
    NSRange range = [string rangeOfString:RCDLocalizedString(@"Poke")];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    if (range.location != NSNotFound) {
        if (model && model.messageDirection == MessageDirection_SEND) {
            [attributedString
                addAttribute:NSForegroundColorAttributeName
                       value:[RCKitUtility generateDynamicColor:HEXCOLOR(0x0099ff) darkColor:HEXCOLOR(0x219dbe)]
                       range:range];
        } else {
            [attributedString
                addAttribute:NSForegroundColorAttributeName
                       value:[RCKitUtility generateDynamicColor:HEXCOLOR(0x0099ff) darkColor:HEXCOLOR(0x0099ff)]
                       range:range];
        }
    }
    return attributedString.copy;
}

+ (CGSize)getTextLabelSize:(RCMessageModel *)model {
    NSAttributedString *attr = [self getDisplayContent:model];
    if ([attr.string length] > 0) {
        float maxWidth = RCDScreenWidth - (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 5 - 35;
        CGRect textRect =
            [attr.string boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                                      options:(NSStringDrawingTruncatesLastVisibleLine |
                                               NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:@{
                                       NSFontAttributeName : [UIFont systemFontOfSize:Poke_Message_Font_Size]
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

    if (bubbleSize.width + 12 + 20 > 50) {
        bubbleSize.width = bubbleSize.width + 12 + 20 + PokeSize.width;
    } else {
        bubbleSize.width = 50 + PokeSize.width;
    }
    if (bubbleSize.height + 7 + 7 > 40) {
        bubbleSize.height = bubbleSize.height + 7 + 7;
    } else {
        bubbleSize.height = 40;
    }

    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(RCMessageModel *)model {
    CGSize textLabelSize = [[self class] getTextLabelSize:model];
    return [[self class] getBubbleSize:textLabelSize];
}

#pragma mark - getter
- (UIImageView *)pokeIcon {
    if (!_pokeIcon) {
        _pokeIcon = [[UIImageView alloc] init];
    }
    return _pokeIcon;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:Poke_Message_Font_Size];
        _contentLabel.numberOfLines = 0;
        [_contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
        _contentLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x333333) darkColor:HEXCOLOR(0xe0e0e0)];
    }
    return _contentLabel;
}
@end
