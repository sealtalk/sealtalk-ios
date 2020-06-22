//
//  RCDPersonDetailCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPersonDetailCell.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import "RCDUtilities.h"
@implementation RCDPersonDetailCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.leftImgView];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.rightImgView];
}

- (void)setCellStyle:(RCDPersonDetailCellStyle)style {
    switch (style) {
    case Style_Default: {
        self.leftImgView.hidden = YES;
        self.rightImgView.hidden = YES;
        self.detailLabel.hidden = YES;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.contentView);
            make.height.offset(24);
        }];
    } break;
    case Style_Title_Detail: {
        self.leftImgView.hidden = YES;
        self.rightImgView.hidden = YES;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.contentView);
            make.height.offset(24);
        }];

        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.titleLabel.mas_right).offset(10);
            make.right.equalTo(self.contentView).offset(-10);
            make.centerY.equalTo(self.contentView);
        }];
    } break;
    case Style_Title_rightImg: {
        self.leftImgView.hidden = YES;
        self.detailLabel.hidden = YES;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.contentView);
            make.height.offset(24);
            make.right.equalTo(self.rightImgView.mas_left).offset(-10);
        }];

        [self.rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-10);
            make.height.offset(13);
            make.width.offset(8);
        }];
    } break;
    case Style_Title_Detail_rightImg: {
        self.leftImgView.hidden = YES;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.contentView);
            make.height.offset(24);
        }];

        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.titleLabel.mas_right).offset(10);
            make.right.equalTo(self.contentView).offset(-20);
            make.centerY.equalTo(self.contentView);
        }];

        [self.rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-10);
            make.height.offset(13);
            make.width.offset(8);
        }];
    } break;
    case Style_Title_leftImg_Detail: {
        self.rightImgView.hidden = YES;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.contentView);
            make.height.offset(24);
        }];

        [self.leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).offset(10);
            make.centerY.equalTo(self.titleLabel);
            make.height.width.offset(22);
        }];

        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.leftImgView.mas_right).offset(10);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
        }];
    } break;
    case Style_Title_leftImg_Detail_rightImg: {
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.contentView);
            make.height.offset(24);
        }];

        [self.leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).offset(10);
            make.centerY.equalTo(self.titleLabel);
            make.height.width.offset(22);
        }];

        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.rightImgView.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.left.greaterThanOrEqualTo(self.leftImgView.mas_right).offset(10);
        }];

        [self.rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-10);
            make.height.offset(13);
            make.width.offset(8);
        }];
    } break;
    default:
        self.leftImgView.hidden = YES;
        self.rightImgView.hidden = YES;
        self.detailLabel.hidden = YES;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView).inset(10);
            make.centerY.equalTo(self.contentView);
            make.height.offset(24);
        }];
        break;
    }
}

- (void)tapAction {
    if (self.tapDetailBlock) {
        self.tapDetailBlock(self.detailLabel.text);
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    }
    return _titleLabel;
}

- (UIImageView *)leftImgView {
    if (!_leftImgView) {
        _leftImgView = [[UIImageView alloc] init];
    }
    return _leftImgView;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:15];
        _detailLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_detailLabel addGestureRecognizer:tap];
    }
    return _detailLabel;
}

- (UIImageView *)rightImgView {
    if (!_rightImgView) {
        _rightImgView = [[UIImageView alloc] init];
        _rightImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightImgView;
}

@end
