//
//  RealTimeLocationStartCell.m
//  LocationSharer
//
//  Created by litao on 15/7/23.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RealTimeLocationStartCell.h"

@interface RealTimeLocationStartCell ()
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;
@property(nonatomic, strong) RCAttributedLabel *textLabel;
@property(nonatomic, strong) UIImageView *locationView;
@end

#define RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH 15
#define RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT 20

@implementation RealTimeLocationStartCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 40.0f;
    __messagecontentview_height += extraHeight;

    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    //
    //    for (UIView *subView in [self.messageContentView subviews]) {
    //        [subView removeFromSuperview];
    //    }

    NSString *content = RCDLocalizedString(@"i_start_location_share");
    [self.textLabel setText:content dataDetectorEnabled:NO];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
    // ios 7
    CGSize __textSize =
        [content boundingRectWithSize:CGSizeMake(self.baseContentView.bounds.size.width -
                                                     (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 -
                                                     5 - 35,
                                                 8000)
                              options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                      NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:Text_Message_Font_Size]}
                              context:nil]
            .size;
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width, __textSize.height + 5);

    CGFloat __bubbleWidth = __labelSize.width + 18 + RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH < 50
                                ? 50
                                : (__labelSize.width + 18 + RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH);
    CGFloat __bubbleHeight = __labelSize.height + 5 + 5 < 40 ? 40 : (__labelSize.height + 5 + 5);

    CGSize __bubbleSize = CGSizeMake(__bubbleWidth + 18, __bubbleHeight);

    CGRect messageContentViewRect = self.messageContentView.frame;

    //拉伸图片
    // CGFloat top, CGFloat left, CGFloat bottom, CGFloat right
    if (MessageDirection_RECEIVE == self.messageDirection) {
        messageContentViewRect.size.width = __bubbleSize.width;
        messageContentViewRect.size.height = __bubbleSize.height;
        self.messageContentView.frame = messageContentViewRect;

        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);
        self.bubbleBackgroundView.image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.locationView.frame = CGRectMake(
            18, self.bubbleBackgroundView.frame.size.height / 2 - RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT / 2,
            RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH, RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT);
        self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.locationView.frame) + 4, 20 - __labelSize.height / 2,
                                          __labelSize.width, __labelSize.height);
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
            resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                         image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        messageContentViewRect.size.width = __bubbleSize.width;
        messageContentViewRect.size.height = __bubbleSize.height;
        messageContentViewRect.origin.x =
            self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + HeadAndContentSpacing +
                                                      [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;

        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);

        self.textLabel.frame = CGRectMake(12, 20 - __labelSize.height / 2, __labelSize.width, __labelSize.height);

        self.locationView.frame = CGRectMake(
            12 + __labelSize.width + 4,
            self.bubbleBackgroundView.frame.size.height / 2 - RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT / 2,
            RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH, RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT);

        self.bubbleBackgroundView.image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
            resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                         image.size.height * 0.2, image.size.width * 0.8)];
    }
}
- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}
- (void)tapMessage:(id)sender {
    [self.delegate didTapMessageCell:self.model];
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
        [_textLabel setFont:[UIFont systemFontOfSize:Text_Message_Font_Size]];

        _textLabel.numberOfLines = 0;
        [_textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_textLabel setTextAlignment:NSTextAlignmentLeft];
        [_textLabel setTextColor:[UIColor blackColor]];

        [self.bubbleBackgroundView addSubview:_textLabel];
    }
    return _textLabel;
}

- (UIImageView *)bubbleBackgroundView {
    if (!_bubbleBackgroundView) {
        _bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.messageContentView addSubview:_bubbleBackgroundView];
        UITapGestureRecognizer *messageTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMessage:)];
        messageTap.numberOfTapsRequired = 1;
        messageTap.numberOfTouchesRequired = 1;
        [self.bubbleBackgroundView addGestureRecognizer:messageTap];
        self.bubbleBackgroundView.userInteractionEnabled = YES;
    }
    return _bubbleBackgroundView;
}
- (UIImageView *)locationView {
    if (!_locationView) {
        _locationView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.bubbleBackgroundView addSubview:_locationView];
        [_locationView setImage:[UIImage imageNamed:@"blue_location_icon"]];
    }
    return _locationView;
}
@end
