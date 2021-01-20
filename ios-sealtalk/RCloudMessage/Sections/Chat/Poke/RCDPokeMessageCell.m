//
//  RCPokeMessageCell.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPokeMessageCell.h"
#import "RCDPokeMessage.h"

#define Poke_Message_Font_Size 17
#define PokeSize CGSizeMake(22, 22)
@interface RCDPokeMessageCell ()
@property (nonatomic, strong) UIImageView *pokeIcon;
@property (nonatomic, strong) UILabel *contentLabel;
@end
@implementation RCDPokeMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGSize size = [RCDPokeMessageCell getBubbleBackgroundViewSize:model];

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

- (void)initialize {
    [self showBubbleBackgroundView:YES];
    [self.messageContentView addSubview:self.pokeIcon];
    [self.messageContentView addSubview:self.contentLabel];
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self setAutoLayout];
}

- (void)setAutoLayout {
    if(self.model.messageDirection == MessageDirection_RECEIVE){
        [self.contentLabel setTextColor:[RCKitUtility generateDynamicColor:HEXCOLOR(0x333333) darkColor:RCMASKCOLOR(0xffffff, 0.8)]];
        self.pokeIcon.image = [UIImage imageNamed:@"poke_from_msg"];
    }else{
        [self.contentLabel setTextColor:RCDYCOLOR(0x333333, 0x040A0F)];
        self.pokeIcon.image = [UIImage imageNamed:@"poke_to_msg"];
    }
    self.contentLabel.attributedText = [[self class] getDisplayContent:self.model];
    CGSize textLabelSize = [[self class] getTextLabelSize:self.model];
    CGSize messageContentSize = [[self class] getBubbleSize:textLabelSize];
    
    
    self.messageContentView.contentSize = messageContentSize;

    self.pokeIcon.frame = CGRectMake(12, 8.5, PokeSize.width, PokeSize.height);
    self.contentLabel.frame =
        CGRectMake(CGRectGetMaxX(self.pokeIcon.frame) + 6, 7, textLabelSize.width, textLabelSize.height);
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
                       value:[RCKitUtility generateDynamicColor:HEXCOLOR(0x0099ff) darkColor:HEXCOLOR(0x005F9E)]
                       range:range];
        } else {
            [attributedString
                addAttribute:NSForegroundColorAttributeName
                       value:[RCKitUtility generateDynamicColor:HEXCOLOR(0x0099ff) darkColor:HEXCOLOR(0x1290e2)]
                       range:range];
        }
    }
    return attributedString.copy;
}

+ (CGSize)getTextLabelSize:(RCMessageModel *)model {
    NSAttributedString *attr = [self getDisplayContent:model];
    if ([attr.string length] > 0) {
        float maxWidth = RCDScreenWidth - (10 + RCKitConfigCenter.ui.globalMessagePortraitSize.width + 10) * 2 - 5 - 35;
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

    if (bubbleSize.width + 12 + 12 > 50) {
        bubbleSize.width = bubbleSize.width + 12 + 12 + PokeSize.width;
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
    }
    return _contentLabel;
}
@end
