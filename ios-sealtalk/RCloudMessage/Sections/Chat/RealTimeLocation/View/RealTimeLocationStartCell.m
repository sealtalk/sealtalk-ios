//
//  RealTimeLocationStartCell.m
//  LocationSharer
//
//  Created by litao on 15/7/23.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RealTimeLocationStartCell.h"
#import "RealTimeLocationDefine.h"

@interface RealTimeLocationStartCell ()
@property (nonatomic, strong) RCAttributedLabel *textLabel;
@property (nonatomic, strong) UIImageView *locationView;
@end

#define RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH 14
#define RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT 19.5

@implementation RealTimeLocationStartCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 40.0f;

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
    
}


- (void)setDataModel:(RCMessageModel *)model {
    [self showBubbleBackgroundView:YES];
    [super setDataModel:model];
    NSString *content = RTLLocalizedString(@"i_start_location_share");
    [self.textLabel setText:content dataDetectorEnabled:NO];
    if(self.model.messageDirection == MessageDirection_RECEIVE){
        [self.textLabel setTextColor:[RCKitUtility generateDynamicColor:HEXCOLOR(0x262626) darkColor:RCMASKCOLOR(0xffffff, 0.8)]];
    }else{
        [self.textLabel setTextColor:RCDYCOLOR(0x262626, 0x040A0F)];
    }
    CGSize __textSize =
        [content boundingRectWithSize:CGSizeMake(self.baseContentView.bounds.size.width -
                                                     (10 + RCKitConfigCenter.ui.globalMessagePortraitSize.width + 10) * 2 -
                                                     5 - 35,
                                                 8000)
                              options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                      NSStringDrawingUsesFontLeading
                           attributes:@{
                               NSFontAttributeName : [UIFont systemFontOfSize:Text_Message_Font_Size]
                           }
                              context:nil].size;
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width, __textSize.height + 5);

    CGFloat __bubbleHeight = __labelSize.height + 5 + 5 < 40 ? 40 : (__labelSize.height + 5 + 5);

    CGSize __bubbleSize = CGSizeMake( 12 + RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH + 4 + __labelSize.width + 12, __bubbleHeight);

    //拉伸图片
    // CGFloat top, CGFloat left, CGFloat bottom, CGFloat right
    self.messageContentView.contentSize = __bubbleSize;
    
    if (self.model.messageDirection == MessageDirection_SEND) {
        if ([RCKitUtility isRTL]) {
            self.locationView.frame = CGRectMake(12, self.messageContentView.frame.size.height / 2 -
                                                 RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT / 2, RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH, RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT);
            self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.locationView.frame) + 7, (__bubbleHeight - __labelSize.height) / 2, __labelSize.width, __labelSize.height);
        } else {
            self.textLabel.frame = CGRectMake(12, (__bubbleSize.height - __labelSize.height) / 2, __labelSize.width, __labelSize.height);
            self.locationView.frame =
            CGRectMake(12 + __labelSize.width + 4, self.messageContentView.frame.size.height / 2 -
                       RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT / 2,
                       RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH, RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT);
        }
        [self.locationView setImage:[UIImage imageNamed:@"realtime_location_send_icon"]];
    } else {
        if ([RCKitUtility isRTL]) {
            self.textLabel.frame = CGRectMake(12, (__bubbleSize.height - __labelSize.height) / 2, __labelSize.width, __labelSize.height);
            self.locationView.frame =
            CGRectMake(12 + __labelSize.width + 4, self.messageContentView.frame.size.height / 2 -
                       RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT / 2,
                       RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH, RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT);
        } else {
            self.locationView.frame = CGRectMake(12, self.messageContentView.frame.size.height / 2 -
                                                 RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT / 2, RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_WIDTH, RC_REAL_TIME_LOCATION_CELL_LOCATION_ICON_HEIGHT);
            self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.locationView.frame) + 7, (__bubbleHeight - __labelSize.height) / 2, __labelSize.width, __labelSize.height);
        }
        [self.locationView setImage:[UIImage imageNamed:@"realtime_location_receive_icon"]];
    }
}

#pragma mark - getter & setter
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
        [_textLabel setFont:[UIFont systemFontOfSize:Text_Message_Font_Size]];
        _textLabel.numberOfLines = 0;
        [_textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_textLabel setTextAlignment:NSTextAlignmentLeft];
        [self.messageContentView addSubview:_textLabel];
    }
    return _textLabel;
}

- (UIImageView *)locationView {
    if (!_locationView) {
        _locationView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.messageContentView addSubview:_locationView];
        [_locationView setImage:[UIImage imageNamed:@"realtime_location_send_icon"]];
    }
    return _locationView;
}
@end
