//
//  RedpacketMessageCell.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketMessageCell.h"
#import "RedpacketMessage.h"

#define Redpacket_Message_Font_Size 14
#define Redpacket_SubMessage_Font_Size 12
#define Redpacket_Background_Extra_Height 25
#define Redpacket_SubMessage_Text NSLocalizedString(@"查看红包", @"查看红包")
#define Redpacket_Label_Padding 2

@implementation RedpacketMessageCell


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
    // 设置背景
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.bubbleBackgroundView addGestureRecognizer:tap];
    
    // 设置红包图标
    UIImage *icon = [RCKitUtility imageNamed:@"redPacket_redPacktIcon" ofBundle:@"RedpacketCellResource.bundle"];
    self.iconView = [[UIImageView alloc] initWithImage:icon];
    self.iconView.frame = CGRectMake(13, 19, 26, 34);
    [self.bubbleBackgroundView addSubview:self.iconView];
    
    // 设置红包文字
    self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.greetingLabel.frame = CGRectMake(48, 19, 137, 15);
    self.greetingLabel.font = [UIFont systemFontOfSize:Redpacket_Message_Font_Size];
    self.greetingLabel.textColor = [UIColor whiteColor];
    self.greetingLabel.numberOfLines = 1;
    [self.greetingLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.greetingLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bubbleBackgroundView addSubview:self.greetingLabel];
    
    // 设置次级文字
    self.subLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    CGRect frame = self.greetingLabel.frame;
    frame.origin.y = 41;
    self.subLabel.frame = frame;
    self.subLabel.text = Redpacket_SubMessage_Text;
    self.subLabel.font = [UIFont systemFontOfSize:Redpacket_SubMessage_Font_Size];
    self.subLabel.numberOfLines = 1;
    self.subLabel.textColor = [UIColor whiteColor];
    self.subLabel.numberOfLines = 1;
    [self.subLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.subLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bubbleBackgroundView addSubview:self.subLabel];
    
    // 设置次级文字
    self.orgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    frame = CGRectMake(13, 76, 150, 12);
    self.orgLabel.frame = frame;
    self.orgLabel.text = Redpacket_SubMessage_Text;
    self.orgLabel.font = [UIFont systemFontOfSize:Redpacket_SubMessage_Font_Size];
    self.orgLabel.numberOfLines = 1;
    self.orgLabel.textColor = [UIColor lightGrayColor];
    self.orgLabel.numberOfLines = 1;
    [self.orgLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.orgLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bubbleBackgroundView addSubview:self.orgLabel];

    // 设置红包厂商图标
    icon = [RCKitUtility imageNamed:@"redPacket_yunAccount_icon" ofBundle:@"RedpacketCellResource.bundle"];
    self.orgIconView = [[UIImageView alloc] initWithImage:icon];
    [self.bubbleBackgroundView addSubview:self.orgIconView];
    

    CGRect rt = self.orgIconView.frame;
    rt.origin = CGPointMake(165, 75);
    rt.size = CGSizeMake(21, 14);
    self.orgIconView.frame = rt;

    [self.statusContentView removeFromSuperview];
    self.statusContentView = nil;
    
    [self.messageHasReadStatusView removeFromSuperview];
    self.messageHasReadStatusView = nil;

    [self.messageSendSuccessStatusView removeFromSuperview];
    self.messageSendSuccessStatusView = nil;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    
    [self setAutoLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.statusContentView.hidden = YES;
    self.messageHasReadStatusView.hidden = YES;
    self.messageSendSuccessStatusView.hidden = YES;
}

- (void)setAutoLayout {
    RedpacketMessage *redpacketMessage = (RedpacketMessage *)self.model.content;
    NSString *messageString = redpacketMessage.redpacket.redpacket.redpacketGreeting;
    self.greetingLabel.text = messageString;
    
    NSString *orgString = redpacketMessage.redpacket.redpacket.redpacketOrgName;
    self.orgLabel.text = orgString;
    
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize];
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    // 设置红包文字
    if (MessageDirection_RECEIVE == self.messageDirection) {
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(-8, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"redpacket_receiver_bg" ofBundle:@"RedpacketCellResource.bundle"];
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 25, 20)];
    } else {
        
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        messageContentViewRect.origin.x = self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + 12 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(8, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"redpacket_sender_bg" ofBundle:@"RedpacketCellResource.bundle"];
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 25, 20)];
    }
    
    self.statusContentView.hidden = YES;
    self.messageHasReadStatusView.hidden = YES;
    self.messageSendSuccessStatusView.hidden = YES;
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.delegate didTapMessageCell:self.model];
    }
}

+ (CGSize)getBubbleSize {
    CGSize bubbleSize = CGSizeMake(198, 94);
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(RedpacketMessage *)message {
    return [[self class] getBubbleSize];
}
@end
