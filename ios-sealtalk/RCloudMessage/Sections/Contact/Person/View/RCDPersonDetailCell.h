//
//  RCDPersonDetailCell.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TapDetailBlock)(NSString *detail);

@interface RCDPersonDetailCell : RCDTableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *leftImgView;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *rightImgView;

@property (nonatomic, copy) TapDetailBlock tapDetailBlock;

/*!
 cell的style
 */
typedef NS_ENUM(NSUInteger, RCDPersonDetailCellStyle) {
    Style_Default = 0,                   // leftLabel
    Style_Title_Detail,                  // leftLabel,rightLabel
    Style_Title_rightImg,                // leftLabel,rightImg
    Style_Title_Detail_rightImg,         // leftLabel,rightLabel,rightImg
    Style_Title_leftImg_Detail,          // leftLabel,leftImg,rightLabel
    Style_Title_leftImg_Detail_rightImg, // leftLabel,leftImg,rightLabel,rightImg
};

- (void)setCellStyle:(RCDPersonDetailCellStyle)style;

@end

NS_ASSUME_NONNULL_END
